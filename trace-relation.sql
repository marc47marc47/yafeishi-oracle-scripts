select value from v$diag_info where name='Default Trace File'; 
 
-- 10046 
alter session set events='10046 trace name context forever, level 12';  
alter session set events='10046 trace name context off'; 

