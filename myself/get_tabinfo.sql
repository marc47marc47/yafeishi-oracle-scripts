set feedback off
set linesize 1000 pagesize 1000 verify off
prompt display table info : &1..&2

column owner format a10;
column table_name heading "tab||name" format a30;
column partitioned format a4;
column global_stats format a10;
column last_analyzed format a30;
--column table_name format a20;

select owner,
       table_name,
       partitioned,
       num_rows,
       global_stats,
       last_analyzed,
       degree
  from dba_tables a
 where owner like upper('&1')
   and table_name like upper('&2');
 
prompt  
prompt display size of table : &1..&2
column segment_name format a30;
select owner, 
       segment_name, 
       sum(bytes) / 1024 / 1024 / 1024 "size(G)"
  from dba_segments a
 where owner like upper('&1')
   and segment_name like upper('&2')
 group by owner, segment_name;
 
prompt  
prompt display tablspace size  of table : &1..&2 
select tablespace_name, 
       sum(bytes) / 1024 / 1024 / 1024 "size(G)"
  from dba_segments a
 where owner like upper('&1')
   and segment_name like upper('&2')
 group by tablespace_name
 order by tablespace_name;
 
prompt  
prompt display index info  of table : &1..&2  
column table_owner format a10;
column index_type format a10;
column degree format a5;
select table_owner,
       table_name,
       index_name,
       index_type,
	   partitioned,
       uniqueness,
       clustering_factor,
	   DISTINCT_KEYS,
       degree,
       num_rows,
       last_analyzed
  from dba_indexes a
 where table_owner like upper('&1')
   and table_name like upper('&2');

prompt  
prompt display index column info  of table : &1..&2    
column column_name format a30; 
column column_position format a10; 
select table_owner,
       table_name,
       index_name,
	   column_position "POSITION",
       column_name
  from dba_ind_columns a
 where table_owner like upper('&1')
   and table_name like upper('&2')
 order by table_owner, table_name, index_name, column_position;

prompt  
prompt display index size of table : &1..&2  
with ind as
(
select table_owner,
	   table_name,
	   index_name
from dba_indexes  
where owner like upper('&1')
and table_name like upper('&2') 
)
select owner, 
       segment_name, 
	   sum(bytes) / 1024 / 1024 / 1024 "size(G)"
  from dba_segments  , ind
 where owner = ind.table_owner
   and segment_name = ind.index_name
 group by owner, segment_name
 order by owner, segment_name;
 
prompt  
prompt display index tablespace size of table : &1..&2 
with ind as
(
select table_owner,
     table_name,
     index_name
from dba_indexes  
where owner like upper('&1')
and table_name like upper('&2') 
)
select tablespace_name, 
     sum(bytes) / 1024 / 1024 / 1024 "size(G)"
  from dba_segments  , ind
 where owner = ind.table_owner
   and segment_name = ind.index_name
 group by tablespace_name
 order by tablespace_name;

  