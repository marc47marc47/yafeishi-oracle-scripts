set linesize 1000
set pagesize 1000
col segment_name format a30; 
select a.segment_name,a.partition_name,a.bytes/1024/1024/1024 "size",a.tablespace_name
from dba_segments a
where a.owner=upper('&&1')
and a.segment_name=upper('&&2')
order by a.partition_name;
