set linesize 1000
set pagesize 1000
select a.table_name,a.num_rows,a.partition_name,a.last_analyzed
from dba_tab_statistics a
where 1=1
and a.owner=upper('&&1')
and a.table_name=upper('&&2')
order by a.partition_position;
