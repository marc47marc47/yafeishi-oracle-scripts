BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'UCR_ACTP',
                                tabname          => 'TF_B_PAYLOG_CENTER', 
                                method_opt       => 'for all columns size auto',
                                no_invalidate    => FALSE,
                                degree           => 50,
                granularity      => 'ALL',
                                cascade          => TRUE);
END;
/

select a.OWNER,a.TABLE_NAME,sum(b.BYTES/1024/1024/1024) G,'execute dbms_stats.gather_table_stats(ownname=> '|| ''''||a.owner ||''''|| ','
       || 'tabname=>'||'''' ||b.segment_name|| ''''||',degree => 30,cascade => true,granularity =>'|| ''''||'ALL'||''''||',no_invalidate =>false);'
from dba_tab_statistics a ,dba_segments b
where 1=1 
and (a.NUM_ROWS is null or a.LAST_ANALYZED is null or a.stale_stats='YES')
and a.OWNER like 'U%'
and a.OWNER=b.owner
and a.TABLE_NAME not like '%MLOG%'
and a.TABLE_NAME not like 'BIN$%'
and a.TABLE_NAME=b.segment_name
and a.PARTITION_NAME=b.partition_name
--and b.segment_name in ('TS_B_BILL_BEFORE')
group by a.OWNER,a.TABLE_NAME,b.segment_name
order by 3 desc;

 
select a.num_rows,a.last_analyzed,a.stale_stats,a.*
from dba_tab_statistics a
where a.owner='UCR_CRM1'
and a.table_name='TF_B_TRADE_ATTR_BAK';

-- 表的采样率
SELECT owner,
       table_name,
       num_rows,
       sample_size,
       ceil(sample_size / num_rows * 100) estimate_percent 
  FROM DBA_TAB_STATISTICS
 WHERE owner='SCOTT' AND table_name='TEST';


exec dbms_stats.delete_column_stats('UCR_CRMG', 'TF_B_ORDER', 'ACCEPT_MONTH', col_stat_type=>'HISTOGRAM');


--查看GATHER_STATS_JOB的执行日志：
select to_char(log_date, 'yyyymmdd hh24miss' ),
       status,
       run_duration,
       cpu_used,
       ADDITIONAL_INFO
  from dba_scheduler_job_run_details
 where job_name = 'GATHER_STATS_JOB'
 order by log_date desc ;

--查看哪些对象的统计信息被锁：
SELECT OWNER, TABLE_NAME, STATTYPE_LOCKED
  FROM DBA_TAB_STATISTICS
 WHERE STATTYPE_LOCKED IS NOT NULL
   AND OWNER = 'UCR_CRM1'


-- 查看直方图信息   
select a.owner || '.' || a.table_name name,
       a.column_name,
       b.num_rows,
       a.num_distinct Cardinality,
       a.num_distinct / b.num_rows selectivity,
       num_nulls,
       density,
       a.histogram,
       a.num_buckets
  from dba_tab_col_statistics a, dba_tables b
 where a.owner = b.owner
   and a.table_name = b.table_name
   and a.owner = upper('adwu_optima_we11')
   and a.table_name = upper('OPT_REF_UOM_TEMP_SDIM')
   and a.column_name = upper('RELTV_CURR_QTY');
   

--统计信息收集间隔: 
select owner,
      table_name,
      partition_name,
      subpartition_name,
      stats_update_time,
      stats_update_time - lag(stats_update_time, 1, null) over(partition by owner, table_name order by stats_update_time) interval
 from DBA_TAB_STATS_HISTORY
where 1=1
and owner like 'U%'
 and table_name not like 'BIN$%'
order by owner, table_name, stats_update_time desc;    
   
--刷新dml缓存：
exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO();

select * from dba_tab_modifications;

exec dbms_stats.gather_fixed_objects_stats();
exec dbms_stats.gather_dictionary_stats();



BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SUBS',
                                tabname          => 'INT_SYNCINFO_UPLOADFILE_EX',
                                method_opt       => 'for all columns size auto',
                                no_invalidate    => FALSE,
                                degree           => 8,
																granularity      => 'ALL',
                                cascade          => TRUE);
END;
/

--31.表分析语句
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SCOTT',
                                tabname          => 'INT_SYNCINFO_UPLOADFILE_EX',
                                estimate_percent => 30,
                                method_opt       => 'for all columns size repeat',
                                no_invalidate    => FALSE,
                                degree           => 8,
																granularity      => 'ALL',
                                cascade          => TRUE);
END;
/

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SCOTT',
                                tabname          => 'DEPT',
                                estimate_percent => 30,
                                method_opt       => 'for all columns size repeat',
                                no_invalidate    => FALSE,
                                degree           => 8,
                                granularity      => 'ALL',
                                cascade          => TRUE);
END;
/
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SCOTT',
                                tabname          => 'TEST',
                                estimate_percent => 30,
                                method_opt       => 'for all columns size auto',
                                no_invalidate    => FALSE,
                                degree           => 10,
                                cascade          => TRUE);
END;
/
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SCOTT',
                                tabname          => 'TEST',
                                estimate_percent => 100,
                                method_opt       => 'for all columns size skewonly',
                                no_invalidate    => FALSE,
                                degree           => 8,
                                cascade          => TRUE);
END;
/
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SCOTT',
                                tabname          => 'TEST',
                                estimate_percent => 100,
                                method_opt       => 'for all columns size 1',
                                no_invalidate    => FALSE,
                                degree           => 8,
                                cascade          => TRUE);
END;
/
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SCOTT',
                                tabname          => 'TEST',
                                estimate_percent => 100,
                                method_opt       => 'for columns xxx size skewonly',
                                no_invalidate    => FALSE,
                                degree           => 8,
                                cascade          => TRUE);
END;
/
execute DBMS_STATS.gather_table_stats(ownname=>'UCR_CRM1',tabname=>'TF_F_USER',degree=>8,estimate_percent=>10,cascade=>true,no_invalidate =>false);
execute DBMS_STATS.gather_table_stats(ownname=>'UCR_CRM1',tabname=>'TF_A_PAYLOG',partname=>'PAR_TF_A_PAYLOG_4',degree=>8,estimate_percent=>10,cascade=>true);
execute DBMS_STATS.delete_table_stats(ownname=>'UCR_CRM1',tabname=>'DUZR_MOREFEESET_SERVID');
execute DBMS_STATS.delete_table_stats(ownname=>'UCR_CRM1',tabname=>'TF_A_PAYLOG',partname=>'PAR_TF_A_PAYLOG_4');
execute DBMS_STATS.gather_index_stats(ownname=>'UCR_CRM1',indname=>'PK_TF_F_RELATION_UU',degree=>8,estimate_percent=>10);
execute DBMS_STATS.create_stat_table('UMON','T_STATS_BAK','TBS_CRM_DEF');
execute DBMS_STATS.export_schema_stats(ownname=>'UCR_CRM1',stattab=>'T_STATS_BAK',statown=>'UMON');
execute DBMS_STATS.export_table_stats(ownname=>'UCR_CRM2',stattab=>'T_STATS_BAK_061129',tabname=>'TI_CR_OLCOMWORK_SERV',statown=>'UMON',cascade=>TRUE);
execute DBMS_STATS.import_table_stats(ownname=>'UCR_CRM1',stattab=>'T_STATS_BAK_061129',tabname=>'TF_B_TRADE',statown=>'UMON',cascade=>TRUE);
execute DBMS_STATS.gather_table_stats(ownname=>'UCR_CRM1',tabname=>'TF_B_TRADE_BATDEAL',cascade=>true,degree=>8,method_opt=>'FOR ALL COLUMNS SIZE 10',estimate_percent=>10);
execute DBMS_STATS.GATHER_TABLE_STATS(ownname=>'UCR_CRM1',tabname=>'TI_C_OLCOMDIVIDE',estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size repeat',degree=>DBMS_STATS.DEFAULT_DEGREE, cascade=>TRUE );
--method_opt=>'for all indexed columns size 254'--
execute DBMS_STATS.LOCK_SCHEMA_STATS('UCR_CRM1');
execute DBMS_STATS.LOCK_TABLE_STATS('UCR_CRM1','SUBS_QQ_MID');
execute DBMS_STATS.UNLOCK_TABLE_STATS('UCR_CRM1','SUBS_QQ_MID');


DBMS_STATS.CREATE_STAT_TABLE ('hr', 'savestats');
DBMS_STATS.GATHER_TABLE_STATS ('hr', 'employees', stattab => 'savestats');
DBMS_STATS.DELETE_TABLE_STATS ('hr', 'employees');
DBMS_STATS.IMPORT_TABLE_STATS ('hr', 'employees', stattab => 'savestats');
select * from DBA_OPTSTAT_OPERATIONS
select * from dba_tab_stats_history where table_name='TS_B_BILL'


----导入导出分析数据的步骤
1、创建一个用于保存分析数据的表
execute dbms_stats.create_stat_table(ownname => 'UMON',stattab => 'STAT_TABLE'); 
2、导出某个表的分析数据，存入你刚才建的表
execute DBMS_STATS.export_table_stats(ownname=>'UCR_ACT1',stattab=>'stat_table',tabname=>'TS_BH_BILL_BEFORE',statown=>'UMON',cascade=>TRUE);
3、将保存的分析数据导入
execute dbms_stats.import_table_stats(ownname =>'UCR_CRM1',tabname =>'tf_bh_trade',stattab =>'stat_table',statown =>'umon',no_invalidate => false,cascade => true);


execute dbms_stats.create_stat_table(ownname => 'UCR_RES',stattab => 'STAT_TABLE',tblspace => 'TBS_EXPORT');
execute dbms_stats.export_table_stats(ownname => 'UCR_RES',tabname => 'TF_R_VALUECARD_USE',stattab => 'STAT_TABLE',statown => 'UCR_RES');
execute dbms_stats.delete_table_stats(ownname=> 'UCR_RES',tabname=>'TF_R_VALUECARD_USE',no_invalidate =>false,cascade_indexes => true);
execute dbms_stats.import_table_stats(ownname => 'UCR_RES',
                                         tabname => TF_R_VALUECARD_USE,
                                         stattab => 'STAT_TABLE',
                                         cascade => true,
                                         statown => 'UCR_RES',
                                         no_invalidate => false);


--10g
exec dbms_scheduler.enable('SYS.GATHER_STATS_JOB'); 

select a.job_name,a.last_start_date,a.last_run_duration
from Dba_Scheduler_Jobs  a
where JOB_NAME = 'GATHER_STATS_JOB';

select log_date, job_name, status
  from dba_scheduler_job_run_details
 where job_name = 'GATHER_STATS_JOB'
 order by log_id;
										 
										 
--auto task
select * 
from dba_autotask_job_history a 
where a.WINDOW_NAME='MONDAY_WINDOW' 
order by WINDOW_START_TIME desc;

select * 
from dba_autotask_client_job;

select a.job_status,a.job_start_time,a.WINDOW_DURATION,a.job_info,a.*
from dba_autotask_job_history a
where a.client_name='auto optimizer stats collection'
order by a.job_start_time desc;

--11g+
select *
from (
select a.job_status,a.job_start_time,a.WINDOW_DURATION,a.job_info
from dba_autotask_job_history a
where a.client_name='auto optimizer stats collection'
order by a.job_start_time desc
)
where rownum < 5;

--shedule window
select t1.window_name, t1.repeat_interval, t1.duration,t1.resource_plan,t1.active
from dba_scheduler_windows t1, dba_scheduler_wingroup_members t2
 where t1.window_name = t2.window_name
   and t2.window_group_name in
       ('MAINTENANCE_WINDOW_GROUP', 'BSLN_MAINTAIN_STATS_SCHED');
select client_name,status from dba_autotask_task a ;

select a.WINDOW_NAME,
       a.WINDOW_NEXT_TIME,
       a.WINDOW_ACTIVE,
       a.AUTOTASK_STATUS,
       a.OPTIMIZER_STATS
  from DBA_AUTOTASK_WINDOW_CLIENTS a;
  
exec dbms_scheduler.enable('MONDAY_WINDOW');


exec DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);  
  
exec dbms_auto_task_admin.ENABLE;
exec dbms_auto_task_admin.DISABLE;
exec DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);
exec DBMS_AUTO_TASK_ADMIN.ENABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);
exec DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'sql tuning advisor',operation => NULL,window_name => NULL);

exec dbms_stats.set_global_prefs('estimate_percent','30');
exec dbms_stats.set_global_prefs('cascade', 'TRUE');
exec dbms_stats.set_global_prefs('no_invalidate', 'FALSE');
exec dbms_stats.set_global_prefs(pname=>'degree',pvalue=>'20');
exec dbms_stats.set_global_prefs('granularity','AUTO');
select dbms_stats.get_param(pname=>'method_opt') from dual;
select dbms_stats.get_param(pname=>'estimate_percent') from dual;
select dbms_stats.get_param(pname=>'no_invalidate') from dual;
select dbms_stats.get_param(pname=>'granularity') from dual;
select dbms_stats.get_param(pname=>'degree') from dual;
--------------------------------------------------------------------------------
exec dbms_scheduler.set_attribute('SYS.MONDAY_WINDOW','DURATION','+000 06:00:00');
exec dbms_scheduler.set_attribute('SYS.TUESDAY_WINDOW','DURATION','+000 06:00:00');
exec dbms_scheduler.set_attribute('SYS.WEDNESDAY_WINDOW','DURATION','+000 06:00:00');
exec dbms_scheduler.set_attribute('SYS.THURSDAY_WINDOW','DURATION','+000 06:00:00');
exec dbms_scheduler.set_attribute('SYS.FRIDAY_WINDOW','DURATION','+000 06:00:00');
exec dbms_scheduler.set_attribute('SYS.SATURDAY_WINDOW','DURATION','+000 06:00:00');
exec dbms_scheduler.set_attribute('SYS.SUNDAY_WINDOW','DURATION','+000 06:00:00');

exec dbms_scheduler.set_attribute('SYS.MONDAY_WINDOW','repeat_interval','freq=daily;byday=MON;byhour=2;byminute=0; bysecond=0');
exec dbms_scheduler.set_attribute('SYS.TUESDAY_WINDOW','repeat_interval','freq=daily;byday=TUE;byhour=2;byminute=0; bysecond=0');
exec dbms_scheduler.set_attribute('SYS.WEDNESDAY_WINDOW','repeat_interval','freq=daily;byday=WED;byhour=2;byminute=0; bysecond=0');
exec dbms_scheduler.set_attribute('SYS.THURSDAY_WINDOW','repeat_interval','freq=daily;byday=THU;byhour=2;byminute=0; bysecond=0');
exec dbms_scheduler.set_attribute('SYS.FRIDAY_WINDOW','repeat_interval','freq=daily;byday=FRI;byhour=2;byminute=0; bysecond=0');
exec dbms_scheduler.set_attribute('SYS.SATURDAY_WINDOW','repeat_interval','freq=daily;byday=SAT;byhour=2;byminute=0; bysecond=0');
exec dbms_scheduler.set_attribute('SYS.SUNDAY_WINDOW','repeat_interval','freq=daily;byday=SUN;byhour=2;byminute=0; bysecond=0');

exec dbms_scheduler.set_attribute(name=>'SUNDAY_WINDOW',attribute=>'resource_plan',value=>'DEFAULT_MAINTENANCE_PLAN');

alter system set  resource_manager_plan='' scope=both sid='*';
exec dbms_scheduler.set_attribute('SYS.SUNDAY_WINDOW','repeat_interval','freq=daily;byday=SUN;byhour=3;byminute=27; bysecond=0');
exec dbms_Scheduler.close_window('SUNDAY_WINDOW');	

exec dbms_scheduler.set_attribute(name=>'SUNDAY_WINDOW',attribute=>'resource_plan',value=>'');
exec dbms_scheduler.set_attribute('SYS.SUNDAY_WINDOW','repeat_interval','freq=daily;byday=SUN;byhour=6;byminute=32; bysecond=0');
exec dbms_Scheduler.close_window('SUNDAY_WINDOW');	

