--tran_2pc.sql
set echo off
set heading on pages 400 lines 300 verify off
col local_tran_id for a20
col global_tran_id for a40
col in_out for a6
col database for a15
col  dbuser_owner for a15
col interface for a5
col  state for a15
col fail_retry_time for a28
SELECT a.local_tran_id,
       b.global_tran_id,
       a.in_out,
       a.database,
       a.dbuser_owner,
       a.interface,
       b.state,
          TO_CHAR (b.fail_time, 'yy-mm-dd hh24:ss')
       || '*'
       || TO_CHAR (b.retry_time, 'dd hh24:mi')
          fail_retry_time
  FROM DBA_2PC_NEIGHBORS a, DBA_2PC_PENDING b
 WHERE a.local_tran_id = b.local_tran_id;
 
SQL> @tran_2pc.sql

LOCAL_TRAN_ID        GLOBAL_TRAN_ID                           IN_OUT DATABASE        DBUSER_OWNER    INTER STATE           FAIL_RETRY_TIME
-------------------- ---------------------------------------- ------ --------------- --------------- ----- --------------- ----------------------------
1548.55.259146       1096044365.3133352E3132392E392E3138362E7 in     jdbc_549        JK_TASK         N     prepared        15-08-15 04:26*15 14:39
                     46D30323039363333333733
                     
                     
SQL> rollback force '1548.55.259146';
这里一直HANG住，
另外开一个回话
SQL> commit force '1548.55.259146';

Commit complete.

SQL> select state,local_tran_id from dba_2pc_pending where state='prepared'; 

STATE            LOCAL_TRAN_ID
---------------- ----------------------
forced commit    1548.55.259146

SQL> select state,local_tran_id from dba_2pc_pending;

STATE            LOCAL_TRAN_ID
---------------- ----------------------
forced commit    1548.55.259146


SQL> execute DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('1548.55.259146');

PL/SQL procedure successfully completed.

SQL> commit;

Commit complete.

SQL> select state,local_tran_id from dba_2pc_pending;

no rows selected
