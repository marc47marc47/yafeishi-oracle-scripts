set pagesize 1000
set linesize 1000
select * from table(dbms_xplan.display_cursor('&&1'));
