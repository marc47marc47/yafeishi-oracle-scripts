create table cloud_dh.TL_S_COUNT_LOG_dang
(
dbname varchar2(30),
owner varchar2(30),
tab_name varchar2(30),
start_time date,
cnt number
)
tablespace tbs_def;


select 'insert into cloud_dh.TL_S_COUNT_LOG_dang  select /*+ parallel(a,30)*/ ''NGCRMDB1'',' || '''' ||
       a.owner || ''',' || '''' || a.table_name ||
       ''',sysdate,count(*) from ' || a.owner || '.' || a.table_name ||
       ' a;'
  from dba_tables a
 where a.owner like 'U%';
 
 
 