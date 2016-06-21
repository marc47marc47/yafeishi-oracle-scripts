-- 检查全表扫描，是否需要建索引。
with fsql as
 (select /*+ materialize */
   sql_id, to_clob(upper(sql_fulltext)) as ftext
    from v$sql
   where parsing_schema_name = 'SCOTT'),
sqlid as
 (select /*+ materialize */
   parsing_schema_name, sql_id, sql_text
    from v$sql
   where parsing_schema_name = 'SCOTT'
   group by parsing_schema_name, sql_id, sql_text),
sql as
 (select parsing_schema_name,
         sql_id,
         sql_text,
         (select ftext
            from fsql
           where sql_id = a.sql_id
             and rownum <= 1) ftext
    from sqlid a),
col as
 (select /*+ materialize */
   a.sql_id,
   a.object_owner,
   a.object_name,
   nvl(a.filter_predicates, '空') filter_predicates,
   a.column_cnt,
   b.column_cnttotal,
   b.size_mb
    from (select sql_id,
                 object_owner,
                 object_name,
                 object_type,
                 filter_predicates,
                 access_predicates,
                 projection,
                 length(projection) -
                 length(replace(projection, '], ', '] ')) + 1 column_cnt
            from v$sql_plan
           where object_owner = 'SCOTT'
             and operation = 'TABLE ACCESS'
             and options = 'FULL'
             and object_type = 'TABLE') a,
         (select /*+ USE_HASH(A,B) */
           a.owner, a.table_name, a.column_cnttotal, b.size_mb
            from (select owner, table_name, count(*) column_cnttotal
                    from DBA_TAB_COLUMNS
                   where owner = 'SCOTT'
                   group by owner, table_name) a,
                 (select owner, segment_name, sum(bytes / 1024 / 1024) size_mb
                    from dba_segments
                   where owner = 'SCOTT'
                   group by owner, segment_name) b
           where a.owner = b.owner
             and a.table_name = b.segment_name) b
   where a.object_owner = b.owner
     and a.object_name = b.table_name)
select a.parsing_schema_name "用户",
       a.sql_id,
       a.sql_text,
       b.object_name         "表名",
       b.size_mb             "表大小(MB)",
       b.column_cnt          "列访问数",
       b.column_cnttotal     "列总数",
       b.filter_predicates   "过滤条件",
       a.ftext
  from sql a, col b
 where a.sql_id = b.sql_id
 order by b.size_mb desc, b.column_cnt asc;

-- 检查回表再过滤的 考虑建议组合索引。
with fsql as
 (select /*+ materialize */
   sql_id, sql_text, to_clob(upper(sql_fulltext)) as ftext
    from v$sql
   where parsing_schema_name = 'SCOTT')
select sql_id,
       object_owner "用户",
       (select sql_text
          from fsql
         where sql_id = a.sql_id
           and rownum = 1) sql_text,
       object_name "表名",
       filter_predicates "谓词",
       length(projection) - length(replace(projection, '], ', '] ')) + 1 "列访问数",
       (select ftext
          from fsql
         where sql_id = a.sql_id
           and rownum = 1) ftext
  from (select distinct sql_id,
                        object_owner,
                        object_name,
                        filter_predicates,
                        projection
          from v$sql_plan
         where object_owner = 'UCR_CRM1'
           and operation = 'TABLE ACCESS'
           and options = 'BY INDEX ROWID'
           and filter_predicates is not null) a;
		   
		   