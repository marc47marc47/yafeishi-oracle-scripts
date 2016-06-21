set linesize 1000
set pagesize 1000
col INDEX_NAME format a30
col COLUMN_NAME format a30 
select a.index_name,a.column_name,a.column_position
from dba_ind_columns a,dba_indexes b
where a.index_owner=b.owner
and a.index_name=b.index_name 
and b.table_owner=upper('&&1')
and b.table_name=upper('&&2')
order by a.index_name,a.column_position;
