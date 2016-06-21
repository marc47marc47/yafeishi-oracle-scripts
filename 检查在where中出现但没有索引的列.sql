begin 
 dbms_stats.flush_database_monitoring_info;
end;
/
with wa as (
select /*+ materialize*/
    r.name owner,
    o.name table_name ,
    c.name column_name,
    equality_preds, ---等值过滤
    equijoin_preds, ---等值JOIN过滤 比如where a.id=b.id
    nonequijoin_preds, ----不等JOIN过滤
    range_preds, ----范围过滤 > >= < <= between and
    like_preds,  ----LIKE过滤
    null_preds,  ----NULL 过滤
    timestamp
 from
    sys.col_usage$ u,
    sys.obj$ o,
    sys.col$ c,
    sys.user$ r
 where
    o.obj# = u.obj#
 and c.obj# = u.obj#
 and c.col# = u.intcol#
 and r.name=upper('&1') and o.name=upper('&2')
 ),
 sta as 
 (select a.owner,
       a.table_name,
       a.column_name,
       b.num_rows,
       a.num_distinct Cardinality,
        round(a.num_distinct / b.num_rows * 100, 2) selectivity,
       a.histogram,
       a.num_buckets
  from dba_tab_col_statistics a, dba_tables b
 where a.owner = b.owner
   and a.table_name = b.table_name
   and a.owner = upper('&1')
   and a.table_name = upper('&2')),
  ind as
  (
    select A.TABLE_OWNER,A.TABLE_NAME,A.INDEX_NAME,A.COLUMN_NAME
	from dba_ind_columns a
	where a.index_owner=upper('&1')
      and a.table_name=upper('&2')
  )
  select  wa.table_name,wa.column_name
  from wa,sta
 where wa.owner = sta.owner
   and wa.table_name = sta.table_name
   and wa.column_name = sta.column_name
   and sta.selectivity > &3
   and sta.column_name not in 
       (select COLUMN_NAME from ind );
   	   
   