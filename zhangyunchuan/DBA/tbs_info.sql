col segment_name format A30
col OWNER format A15
col PARTITION_NAME format A30
col size_M format 9999999
set linesize 1000

select owner,segment_name,partition_name,(bytes)/1024/1024 as size_M,tablespace_name
from dba_segments
where
tablespace_name like '&tablespace'
and extents<>1
and extents<>2
order by 4;
