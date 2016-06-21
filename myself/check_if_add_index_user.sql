/*
  找出数据库里一些建议创建索引的列：
  1.在where条件中出现
  2.选择性很高
  用法：
  @check_if_add_index_user.sql username selectivity tab_rows
*/
begin 
 dbms_stats.flush_database_monitoring_info;
end;
/
---查看sql中where过滤情况
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
 and r.name=upper('&1') 
 ),
--查看表的统计信息
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
   and (b.num_rows is not null and b.num_rows<>0)
 ),
ind as
  (
    select A.TABLE_OWNER,A.TABLE_NAME,A.INDEX_NAME,A.COLUMN_NAME
	from dba_ind_columns a
	where a.index_owner=upper('&1')
  )
  select distinct wa.table_name,wa.column_name,sta.selectivity,sta.Cardinality
  from wa,sta
 where wa.owner = sta.owner
   and wa.table_name = sta.table_name
   and wa.column_name = sta.column_name
   and sta.selectivity > &2
   and sta.num_rows > &3
   and sta.column_name not in 
       (select COLUMN_NAME from ind )
   order by  wa.table_name,wa.column_name,sta.selectivity;  
   	   
   