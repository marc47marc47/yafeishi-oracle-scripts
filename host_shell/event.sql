set linesize 1000
set pagesize 1000
col SQL_ID  format a15;
col SQL_TEXT format A40;
col MACHINE format A10;
col USERNAME  format a10;
select a.INST_ID,a.SQL_ID,substr(a.SQL_TEXT,1,40),b.MACHINE,b.USERNAME
from gv$sqlarea a, gv$session b
where a.INST_ID=b.INST_ID
and a.SQL_ID=b.SQL_ID
and b.event# ='&&1'
order by a.INST_ID,a.SQL_ID;
