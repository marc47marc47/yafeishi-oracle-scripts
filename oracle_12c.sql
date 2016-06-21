--查看数据库是否为CDB
select name, decode(cdb, 'YES', 'Multitenant Option enabled', 'Regular 12c Database: ') "Multitenant Option" , open_mode, con_id 
from v$database;

--切换容器:
alter session set  container=pdbtest;  

--查看当前容器：
show con_name

SQL> show con_name

CON_NAME
------------------------------
PDBTEST

select sys_context('userenv', 'con_name') "Container DB" from dual;

-- 查看 pluggable database:
select con_id, dbid, guid, name , open_mode from v$pdbs;
show pdbs

SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         3 PDBTEST                        READ WRITE NO

-- 打开关闭 pluggable database：
alter pluggable database pdbtest open;

SQL> alter session set container=pdbtest;

Session altered.

SQL> startup
Pluggable Database opened.

alter pluggable database pdbtest close;

SQL> shutdown
Pluggable Database closed.
SQL>
SQL>
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         3 PDBTEST                        MOUNTED
         

--切换容器：
alter session set container=cdb$root;


SELECT name,pdb
FROM   v$services
ORDER BY name;


--连接pdb
sqlplus system/dang@192.168.56.101:1522/pdbtest

sqlplus sys/dang@192.168.56.101:1522/pdbtest as sysdba

sqlplus z3/z3@pdbtest

-- 创建local user：
create user pdb6_dba1 identified by manager1 container=current;


set linesize 200s
col username format a30;
col EXTERNAL_NAME format a30;
select username,EXTERNAL_NAME,COMMON,LAST_LOGIN from dba_users where username like '%Z%';
 
         
alter system set service_names='orcl12c,pdbtest';

alter system set service_names='orcl12c';

-- easyconnect:
conn system/dang@dang-db:1522/pdbtest
conn system/dang@dang-db:1522/orcl12c

export ORACLE_UNQNAME=orcl12c

-- create pluggable database：
CREATE PLUGGABLE DATABASE pdb2 
ADMIN USER pdb2_admin IDENTIFIED BY pdb2_admin
CREATE_FILE_DEST='/ora12c/oradata/orcl12c/pdb2';

CREATE PLUGGABLE DATABASE pdb2 
ADMIN USER pdb2_admin IDENTIFIED BY pdb2_admin
FILE_NAME_CONVERT=('/ora12c/oradata/orcl12c/pdbseed','/ora12c/oradata/orcl12c/pdb2');

alter system set db_create_file_dest='/ora12c/oradata';

-- drop pluggable database:
drop pluggable database pdb2 including datafiles;


EXEC DBMS_PDB.DESCRIBE('/ora12c/oradata/orcl12cnopdb.xml');

EXEC DBMS_PDB.DESCRIBE('/ora12c/oradata/orcl12cnopdb2.xml');

create pluggable database pdb2 using '/ora12c/oradata/orcl12cnopdb2.xml';

@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql