
--找到全表扫描的对象：
Select distinct object_name,object_owner 
from v$sql_plan p 
Where p.operation='TABLE ACCESS'
and p.options='FULL' 
and object_owner='XX';

--cmd window  查看执行计划：
explain plan for select * from scott.emp;
select * from table(dbms_xplan.display());
select * from table(dbms_xplan.display(null,null,'OUTLINE'));
select * from table(dbms_xplan.display(null,null,'ADVANCED -PROJECTION'));
select * from table(dbms_xplan.display(null,null,'ADVANCED'));

SET AUTOTRACE OFF ---------------- 不显示执行计划和统计信息，这是缺省模式
SET AUTOTRACE ON EXPLAIN ------ 只显示优化器执行计划
SET AUTOTRACE ON STATISTICS -- 只显示统计信息
SET AUTOTRACE ON ----------------- 执行计划和统计信息同时显示
SET AUTOTRACE TRACEONLY ------ 不真正执行，只显示预期的执行计划，同explain plan

alter session set statistics_level=all;		

select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

select * from table(dbms_xplan.display_awr('b662wdxr4pxhk'));
select * from table(dbms_xplan.display_cursor('73yh6bukptxt0','0'));
select * from table(dbms_xplan.display_cursor('cywqnbyj2s3hu','0','advanced'));


select *
  from v$sql_plan
where (hash_value, child_number) =
       (select sql_hash_value, sql_child_number
          from v$session
         where sid = &sid);

SELECT /*+gather_plan_statistics*/ CUST_EMAIL
FROM   CUSTOMERS
WHERE  CUST_STATE_PROVINCE='MA'
AND    COUNTRY_ID='US'
;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALLSTATS LAST'));
select * from table(dbms_xplan.display_cursor('cywqnbyj2s3hu','0','ALLSTATS LAST'));


------------------------ SPM ---------------------------------		 
--load plan
DECLARE
   l_plans_loaded  PLS_INTEGER;
 BEGIN
   l_plans_loaded :=DBMS_SPM.load_plans_from_cursor_cache(sql_id => 'btsupvuc5zgch');
 END;
/	

--查询spb
SELECT sql_handle, plan_name,enabled, accepted,fixed
FROM   dba_sql_plan_baselines ;

--显示SQL Plan Baselines
SELECT * FROM  
TABLE(DBMS_XPLAN.display_sql_plan_baseline(plan_name=>'SQL_PLAN_8bdh6xqw6sw21e57cfb31'));

--修改 Plan Baselines
DECLARE
 l_plans_altered  PLS_INTEGER;
BEGIN
 l_plans_altered := DBMS_SPM.alter_sql_plan_baseline(
    sql_handle      => 'SQL_85b606edb86c7041',
    plan_name       => 'SQL_PLAN_8bdh6xqw6sw21ad7d9519',
   attribute_name  => 'fixed',
   attribute_value => 'yes');
 DBMS_OUTPUT.put_line('Plans Altered: ' || l_plans_altered);
END;
/ 	 

--删除Plan Baselines
DECLARE
 l_plans_dropped  PLS_INTEGER;
BEGIN
 l_plans_dropped := DBMS_SPM.drop_sql_plan_baseline (
   sql_handle => 'SQL_7b76323ad90440b9',
   plan_name  => NULL);
 DBMS_OUTPUT.put_line(l_plans_dropped);
end;
/ 

-------------------------------- sql profile -----------------------------
coe_xfr_sql_profile.sql 
--get outline
select * from table(dbms_xplan.display_cursor('0bbt69m5yhf3p',null,'outline'));
--create sql profile
declare
 v_hints sys.sqlprof_attr;
 begin
 v_hints:=sys.sqlprof_attr(
      'BEGIN_OUTLINE_DATA',
      'IGNORE_OPTIM_EMBEDDED_HINTS',
      'OPTIMIZER_FEATURES_ENABLE(''11.2.0.3'')',
      'DB_VERSION(''11.2.0.3'')',
      'ALL_ROWS',
      'OUTLINE_LEAF(@"SEL$1")',
      'FULL(@"SEL$1" "T_XIFENFEI"@"SEL$1")',   --这个是由于hint产生,其实我们需要的就是这个
      'END_OUTLINE_DATA');
dbms_sqltune.import_sql_profile(
'SELECT OBJECT_NAME FROM T_XIFENFEI WHERE OBJECT_ID=100',
v_hints,'SQLPROFILE_XIFENFEI',                 --sql profile 名称
force_match=>true,replace=>true);
end;
/

--删除sql profile
exec dbms_sqltune.drop_sql_profile(name =>’SQLPROFILE_XIFENFEI’ );


------------------------------ sql tune -----------------------------------
DECLARE
  my_task_name VARCHAR2(30);
  my_sqltext CLOB;
BEGIN
  select sql_fulltext into  my_sqltext from v$sqlarea where sql_id='a0bptxu46w000';
  my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(
                           sql_text => my_sqltext,
                           user_name => 'UBAK',
                           scope => 'COMPREHENSIVE',
                           time_limit => 60,
                           task_name => 'TEST_sql_tuning_task',
                           description => 'Task to tune a query on a specified PRODUCT');
END;


Execute dbms_sqltune.Execute_tuning_task (task_name => 'TEST_sql_tuning_task');

set long 65536
set longchunksize 65536
set linesize 100
select dbms_sqltune.report_tuning_task('TEST_sql_tuning_task') from dual;

DECLARE
my_sqlprofile_name VARCHAR2(30);
begin
my_sqlprofile_name := DBMS_SQLTUNE.ACCEPT_SQL_PROFILE (
task_name => 'TEST_sql_tuning_task',
name => 'my_sql_profile');
end;
/

PL/SQL procedure successfully completed.

----------------------------- SQL_MONITOR -------------------------------------
select
DBMS_SQLTUNE.REPORT_SQL_MONITOR(
sql_id=>'10754',
report_level=>'ALL',
type=>'html') as report
from dual;

select dbms_sqltune.report_sql_monitor from dual; 
 
--------------查看执行计划历史
select a.INSTANCE_NUMBER,a.snap_id,a.sql_id,a.plan_hash_value,b.begin_interval_time
from dba_hist_sqlstat a, dba_hist_snapshot b 
where sql_id ='7rxyd162qz1bt'
and a.snap_id = b.snap_id 
order by instance_number,begin_interval_time  desc;
 

SELECT distinct
s.snap_id ,
PLAN_HASH_VALUE,
to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
SQL.executions_delta,
SQL.buffer_gets_delta/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_lio,
--SQL.ccwait_delta,
(SQL.cpu_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_cputime ,
(SQL.elapsed_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_etime,
SQL.DISK_READS_DELTA/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_pio,
SQL.rows_processed_total/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_row
--,SQL.sql_profile
FROM
dba_hist_sqlstat SQL,
dba_hist_snapshot s
WHERE
SQL.instance_number =(select instance_number from v$instance)
and SQL.dbid =(select dbid from v$database)
and s.snap_id = SQL.snap_id
AND sql_id in
('bsznt7ts70nwv') order by s.snap_id desc 
/

--根据 sql profile name 查找outline信息
SELECT so.signature,extractValue(value(h),'.') AS hint
 FROM sys.sqlobj$data od, sys.sqlobj$ so,
 table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
 WHERE so.name = 'coe_8nuxf3w2dp5sb_2848050578'
 AND so.signature = od.signature
 AND so.category = od.category
 AND so.obj_type = od.obj_type
 AND so.plan_id = od.plan_id