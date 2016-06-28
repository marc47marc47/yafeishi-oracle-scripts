
--10053  trace sql 
alter session set tracefile_identifier='10053_normal';
ALTER SESSION SET EVENTS '10053 TRACE NAME CONTEXT FOREVER, LEVEL 1';
select /* hard parse comment */ * from emp where ename = 'SCOTT';
ALTER SESSION SET EVENTS '10053 TRACE NAME CONTEXT OFF';

-- sysdba 权限
oradebug setmypid
oradebug event 10053 trace name context forever,level 1
select /* hard parse comment */ * from emp where ename = 'SCOTT';
oradebug event 10053 trace name context off
oradebug tracefile_name

Level      Action
 
1     Print statistics and computations
 
2     Print computations only


select value
from v$diag_info
where name='Default Trace File';

--10035  trace parse failed sql
alter system set events '10035 trace name context forever, level 1';
ALTER SYSTEM SET EVENTS '10035 trace name context off';


-- 10046 
ALTER SESSION SET EVENTS '10046 trace name context forever, level 8';   

ALTER SESSION SET EVENTS '10046 trace name context off';   


-- dump index content   level &object_id
ALTER SESSION SET EVENTS 'immediate trace name treedump level 92882';

SELECT DBMS_UTILITY.DATA_BLOCK_ADDRESS_FILE(25170052) file#,
       DBMS_UTILITY.DATA_BLOCK_ADDRESS_BLOCK(25170052) block#
FROM dual;  

ALTER SYSTEM DUMP DATAFILE 6 BLOCK 4228;

SELECT utl_raw.cast_to_number(replace('c1',' ')) value FROM dual;

