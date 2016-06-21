----------------------------- drop tablespace ------
主库查询：
SYS@ orcl >select file_name,tablespace_name from dba_data_files where tablespace_name='TBS_TEST_DG';

FILE_NAME
--------------------------------------------------------------------------------
TABLESPACE_NAME
------------------------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf
TBS_TEST_DG

SYS@ orcl >

备库查询：
SYS@ orcldg >select file_name,tablespace_name from dba_data_files where tablespace_name='TBS_TEST_DG';

FILE_NAME
--------------------------------------------------------------------------------
TABLESPACE_NAME
------------------------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf
TBS_TEST_DG

SYS@ orcldg >

主库删除表空间：
SYS@ orcl >drop tablespace tbs_test_dg including contents and datafiles;

Tablespace dropped.

查看备库alert：
Wed Jan 07 12:29:07 2015
Recovery deleting file #6:'/oracle/oradata/orcl/tbs_test_dg_1.dbf' from controlfile.
Deleted file /oracle/oradata/orcl/tbs_test_dg_1.dbf
Recovery dropped tablespace 'TBS_TEST_DG'

备库查询：
SYS@ orcldg >select file_name,tablespace_name from dba_data_files where tablespace_name='TBS_TEST_DG';

no rows selected

SYS@ orcldg >


---------------------- create tablespace -----------------------
主库创建表空间：
SYS@ orcl >create tablespace tbs_test_dg datafile '/oracle/oradata/orcl/tbs_test_dg_1.dbf' size 100M;

Tablespace created.

查看备库alert：
Wed Jan 07 12:32:11 2015
WARNING: File being created with same name as in Primary
Existing file may be overwritten
Recovery created file /oracle/oradata/orcl/tbs_test_dg_1.dbf
Successfully added datafile 6 to media recovery
Datafile #6: '/oracle/oradata/orcl/tbs_test_dg_1.dbf'

备库查询：SYS@ orcldg >select file_name,tablespace_name from dba_data_files where tablespace_name='TBS_TEST_DG';
FILE_NAME
--------------------------------------------------------------------------------
TABLESPACE_NAME
------------------------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf
TBS_TEST_DG

SYS@ orcldg >

----------------------------- datafile resize -----------------------------
1.主库查看当前大小：
SYS@ orcl >col file_name format a50;
SYS@ orcl >select file_name,bytes/1024/1024 from dba_data_files where tablespace_name='TBS_TEST_DG';

FILE_NAME                                          BYTES/1024/1024
-------------------------------------------------- ---------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf                         100

SYS@ orcl >

2.备库查看当前大小：
SYS@ orcldg >col file_name format a50;
SYS@ orcldg >select file_name,bytes/1024/1024 from dba_data_files where tablespace_name='TBS_TEST_DG';

FILE_NAME                                          BYTES/1024/1024
-------------------------------------------------- ---------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf                         100

SYS@ orcldg >

3.主库resize datafile，并查看结果：
SYS@ orcl >alter database datafile '/oracle/oradata/orcl/tbs_test_dg_1.dbf' resize 110M;

Database altered.

SYS@ orcl >select file_name,bytes/1024/1024 from dba_data_files where tablespace_name='TBS_TEST_DG';

FILE_NAME                                          BYTES/1024/1024
-------------------------------------------------- ---------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf                         110

SYS@ orcl >

4.备库查看当前大小：
SYS@ orcldg >select file_name,bytes/1024/1024 from dba_data_files where tablespace_name='TBS_TEST_DG';

FILE_NAME                                          BYTES/1024/1024
-------------------------------------------------- ---------------
/oracle/oradata/orcl/tbs_test_dg_1.dbf                         110

SYS@ orcldg >




---------------------- create user ------------------------
SYS@ orcl >create user adg identified by adg default tablespace tbs_test_dg;

User created.

SYS@ orcl >alter system switch logfile;

System altered.

SYS@ orcl >select username,created from dba_users where username='ADG';

USERNAME                       CREATED
------------------------------ ---------
ADG                            07-JAN-15

查看备库alert：Wed Jan 07 12:35:34 2015
RFS[2]: Selected log 4 for thread 1 sequence 64 dbid 1396010433 branch 868229697
Wed Jan 07 12:35:34 2015
Archived Log entry 31 added for thread 1 sequence 63 ID 0x533637c1 dest 1:
Wed Jan 07 12:35:34 2015
Media Recovery Waiting for thread 1 sequence 64 (in transit)
Recovery of Online Redo Log: Thread 1 Group 4 Seq 64 Reading mem 0
  Mem# 0: /oracle/oradata/orcl/stdb_redo01.log

备库查询：
SYS@ orcldg >select username,created from dba_users where username='ADG';

USERNAME                       CREATED
------------------------------ ---------
ADG                            07-JAN-15

SYS@ orcldg >

---------------------   grant test ---------------
主库给 adg 用户赋 connect role：
SYS@ orcl >select grantee,granted_role from dba_role_privs where grantee='ADG';

GRANTEE                        GRANTED_ROLE
------------------------------ ------------------------------
ADG                            CONNECT

SYS@ orcl >

备库查询：
SYS@ orcldg >select grantee,granted_role from dba_role_privs where grantee='ADG';

GRANTEE                        GRANTED_ROLE
------------------------------ ------------------------------
ADG                            CONNECT

SYS@ orcldg >

再次赋权：
SYS@ orcl >grant resource to adg;   

Grant succeeded.

SYS@ orcl >select grantee,granted_role from dba_role_privs where grantee='ADG';

GRANTEE                        GRANTED_ROLE
------------------------------ ------------------------------
ADG                            RESOURCE
ADG                            CONNECT

SYS@ orcl >

SYS@ orcldg >select grantee,granted_role from dba_role_privs where grantee='ADG';

GRANTEE                        GRANTED_ROLE
------------------------------ ------------------------------
ADG                            RESOURCE
ADG                            CONNECT

SYS@ orcldg >

----  grant table privilege ------
主库赋权：
SYS@ orcl >conn adg/adg@orcl
Connected.
ADG@ orcl >select * from danghb.test;
select * from danghb.test
                     *
ERROR at line 1:
ORA-00942: table or view does not exist


ADG@ orcl >conn sys/dang@orcl as sysdba
Connected.
SYS@ orcl >grant select on danghb.test to adg;

Grant succeeded.

SYS@ orcl >
SYS@ orcl >select  grantee,owner,table_name,privilege from dba_tab_privs where table_name='TEST';

GRANTEE                        OWNER
------------------------------ ------------------------------
TABLE_NAME                     PRIVILEGE
------------------------------ ----------------------------------------
ADG                            DANGHB
TEST                           SELECT


SYS@ orcl >conn adg/adg@orcl
Connected.
ADG@ orcl >select * from danghb.test;

        ID
----------
         2
         1

ADG@ orcl >

备库直接查询test表：
ADG@ orcldg >conn adg/adg@orcldg;
Connected.
ADG@ orcldg >select * from danghb.test;

        ID
----------
         2
         1
备库查询权限：
现在主库给ADG用户赋查系统视图权限：
SYS@ orcl >grant select_catalog_role to adg;

Grant succeeded.

备库ADG重新登陆后可以查询:
ADG@ orcldg >select  grantee,owner,table_name,privilege from dba_tab_privs where table_name='TEST';
select  grantee,owner,table_name,privilege from dba_tab_privs where table_name='TEST'
                                                *
ERROR at line 1:
ORA-00942: table or view does not exist

ADG@ orcldg >conn adg/adg@orcldg;
Connected.
ADG@ orcldg >select  grantee,owner,table_name,privilege from dba_tab_privs where table_name='TEST';
GRANTEE                        OWNER
------------------------------ ------------------------------
TABLE_NAME                     PRIVILEGE
------------------------------ ----------------------------------------
ADG                            DANGHB
TEST                           SELECT
ADG@ orcldg >

-----------------  create table ----------------
主库建表：
ADG@ orcl >create table test_adg (id number);

Table created.

ADG@ orcl >select table_name from user_tables;

TABLE_NAME
------------------------------
TEST_ADG

备库查询：
ADG@ orcldg >select table_name from user_tables;

TABLE_NAME
------------------------------
TEST_ADG		 

-------   insert，delete，update----------------
主库insert：
ADG@ orcl >insert into test_adg values(1);

1 row created.

ADG@ orcl >insert into test_adg values(2);    

1 row created.

ADG@ orcl >insert into test_adg values(3);

1 row created.

ADG@ orcl >insert into test_adg values(4);

1 row created.

ADG@ orcl >insert into test_adg values(5);

1 row created.

ADG@ orcl >commit;

Commit complete.

ADG@ orcl >select * from test_adg;

        ID
----------
         1
         2
         3
         4
         5

ADG@ orcl >


ADG@ orcldg >select * from test_adg;

        ID
----------
         1
         2
         3
         4
         5

ADG@ orcldg >

主库delete：
ADG@ orcl >delete test_adg where id=5;

1 row deleted.

ADG@ orcl >commit;

Commit complete.

ADG@ orcl >select * from test_adg;

        ID
----------
         1
         2
         3
         4

ADG@ orcl >

备库查询：
ADG@ orcldg >select * from test_adg;

        ID
----------
         1
         2
         3
         4

ADG@ orcldg >
		 
主库update：
ADG@ orcl >update test_adg set id=5 where id=4;

1 row updated.

ADG@ orcl >commit;

Commit complete.

ADG@ orcl >select * from test_adg;

        ID
----------
         1
         2
         3
         5

ADG@ orcl >

备库查询：
ADG@ orcldg >select * from test_adg;

        ID
----------
         1
         2
         3
         5

ADG@ orcldg >

----------------  create index  ------
主库建索引：
ADG@ orcl >create index idx_adg_1 on test_adg (id);

Index created.

ADG@ orcl >select index_name from user_indexes;

INDEX_NAME
------------------------------
IDX_ADG_1

ADG@ orcl >

备库查询：
ADG@ orcldg >select index_name from user_indexes;

INDEX_NAME
------------------------------
IDX_ADG_1

-------------------- create synonym  ---------
ADG@ orcl >create synonym syn_dang_test for danghb.test;
create synonym syn_dang_test for danghb.test
*
ERROR at line 1:
ORA-01031: insufficient privileges

---此处有个赋权
ADG@ orcl >create synonym syn_dang_test for danghb.test;

Synonym created.

ADG@ orcl >select synonym_name from user_synonyms;

SYNONYM_NAME
------------------------------
SYN_DANG_TEST

ADG@ orcl >select * from SYN_DANG_TEST;

        ID
----------
         2
         1

ADG@ orcl >
	 
备库查询：
ADG@ orcldg >select synonym_name from user_synonyms;

SYNONYM_NAME
------------------------------
SYN_DANG_TEST

ADG@ orcldg >select * from SYN_DANG_TEST;

        ID
----------
         2
         1

ADG@ orcldg >

---------------------------- create view ---------------------
主库创建视图：
ADG@ orcl >create view v_adg_test as select * from test_adg where id=1;

View created.

ADG@ orcl >select * from v_adg_test;

        ID
----------
         1

ADG@ orcl >

备库查询;
ADG@ orcldg >select * from v_adg_test;

        ID
----------
         1

ADG@ orcldg >

主库视图的基表插入数据：
ADG@ orcl >insert into test_adg values(1);

1 row created.

ADG@ orcl >insert into test_adg values(1);

1 row created.

ADG@ orcl >insert into test_adg values(1);

1 row created.

ADG@ orcl >commit;

Commit complete.

ADG@ orcl >select * from v_adg_test;

        ID
----------
         1
         1
         1
         1

ADG@ orcl >

备库查询：
ADG@ orcldg >select * from v_adg_test;

        ID
----------
         1
         1
         1
         1

ADG@ orcldg >



 
