--索引失效：
SELECT 'alter index ' ||a.owner||'.'||a.index_name|| ' unusable ;',a.status,a.partitioned
FROM dba_indexes a
WHERE a.table_name='TF_F_USER' ;

--重建分区索引：
SELECT 'alter index ' ||a.index_owner||'.'||a.index_name|| ' rebuild partition '||a.partition_name|| ' ;'
FROM dba_ind_partitions a,Dba_Indexes b
WHERE b.table_name='TF_F_USER'
AND B.index_name=A.INDEX_NAME(+);
--重建非分区索引：
SELECT 'alter index ' ||a.owner||'.'||a.index_name|| ' rebuild ;',a.status,a.partitioned
FROM dba_indexes a
WHERE a.table_name='TF_F_USER'
AND a.partitioned='NO' ;

alter index ucr_act1.IDX_TF_B_PAYLOG_RECV invisible;

--rename
select 'alter table '||a.table_name||' rename constraint '||a.constraint_name||' to '||a.constraint_name||'_yh ;'
from dba_constraints a
where  1=1
and a.constraint_name not like 'SYS%'
and a.owner='UCR_STA1'
and a.table_name in ('TF_B_RES_SALE_LOG_IN','TF_BH_TRADE_STAFF_IN','TF_B_ADJUSTALOG_C','TF_R_VALUECARD_IDLE','TF_R_VALUECARD_USE');


select 'alter table '||a.table_name||' rename to '||a.table_name||'_yh ;'
from dba_tables a
where  1=1
and a.owner='UCR_STA1'
and a.table_name in ('TF_B_RES_SALE_LOG_IN','TF_BH_TRADE_STAFF_IN','TF_B_ADJUSTALOG_C','TF_R_VALUECARD_IDLE','TF_R_VALUECARD_USE');


select 'alter index '||a.index_name||' rename to '||a.index_name||'_yh ;'
from dba_indexes a
where  1=1
and a.owner='UCR_STA1'
and a.table_name in ('TF_B_RES_SALE_LOG_IN','TF_BH_TRADE_STAFF_IN','TF_B_ADJUSTALOG_C','TF_R_VALUECARD_IDLE','TF_R_VALUECARD_USE');


select 'create user '||a.username||' identified by '||a.username||' default tablespace '||a.default_tablespace|| ' temporary tablespace '||a.temporary_tablespace|| '   profile DEFAULT ;'
from dba_users a
where username like 'U%'
and (username not like '%CC' or  username not like '%WORK%')
order by username;

select 'grant select,insert,update,delete on '||a.OWNER||'.'||a.TABLE_NAME||' to UOP'||substr(a.OWNER,4)||' ;',
  a.*
from dba_tables a
where a.OWNER in 
order by a.OWNER,a.TABLE_NAME;

select 'grant '||a.privilege||' on '||a.owner||'.'||a.table_name||' to '||a.grantee||' ;'
from dba_tab_privs a 
where a.table_name='TD_IVR_TELINFO';


select 'execute p_output_file('''||a.owner||''',''1'',''TABLE'',''2'','''||a.table_name||''',''DATA_PUMP_DIR'','','',''1'',outflag => :outflag);' 
from dba_tables a
where a.owner='UCR_CC'
and a.partitioned='YES';


select 'alter index '||a.index_name||' rebuild partition '||a.partition_name||' tablespace TBS_MS_IUSR4 ;'
from user_ind_partitions a
where mod(a.partition_position,4)=0;

--查找分区表的全局索引
select a.OWNER,a.TABLE_NAME,a.PARTITIONED,b.index_name,b.table_name,b.partitioned
from dba_tables a,dba_indexes b
where a.OWNER=b.owner
and a.OWNER like 'U%'
and a.TABLE_NAME=b.table_name
and a.PARTITIONED='YES'
and b.partitioned='NO'
order by a.OWNER,a.TABLE_NAME;

--4.收集分区表的统计信息：

SELECT 'execute dbms_stats.gather_table_stats(ownname=> '|| ''''||table_owner ||''''|| ','
       ||'tabname=>'|| ''''||table_name ||''''|| ',partname=>'||'''' ||partition_name|| ''''
       || ',granularity=>''PARTITION'',estimate_percent => 20,degree => 10,cascade => true,no_invalidate =>false);'
       FROM  dba_tab_partitions
       WHERE table_owner like 'UCR_ACT1'
       AND   table_name =  'TF_F_INTEGRAL_ACCOUNT'; 
       
--5.收集非分区表的统计信息：
SELECT 'execute dbms_stats.gather_table_stats(ownname=> '|| ''''||owner ||''''|| ','
       || 'tabname=>'||'''' ||segment_name|| ''''||',estimate_percent => 10,degree => 8,cascade => true,no_invalidate =>false);'
       FROM  dba_segments
       WHERE owner = 'UCR_STA1'
       AND   segment_name =  'TF_F_INTEGRAL_PLAN_INSTANCE';


SELECT 'execute dbms_stats.gather_table_stats(ownname=> '|| ''''||a.owner ||''''|| ','
       || 'tabname=>'||'''' ||a.table_name|| ''''||',estimate_percent => 10,degree => 18,cascade => true,no_invalidate =>false);'
       ,'execute dbms_stats.delete_table_stats(ownname=> '|| ''''||a.owner ||''''|| ','
       || 'tabname=>'||'''' ||a.table_name|| ''''||',no_invalidate =>false,cascade_indexes => true);'
       FROM  dba_tables a
       WHERE owner like  'UCR_ACT__'
       and a.table_name='';
       
SELECT 'execute dbms_stats.delete_table_stats(ownname=> '|| ''''||a.owner ||''''|| ','
       || 'tabname=>'||'''' ||a.table_name|| ''''||',no_invalidate =>false,cascade_indexes => true);'
       FROM  dba_tables a
       WHERE owner like  'UCR_CRM__'
       and a.TABLE_NAME='TI_B_CUST_GROUPMEMBER';

SELECT 'execute dbms_stats.delete_table_stats(ownname=> '|| ''''||a.table_owner ||''''|| ','
       || 'tabname=>'||'''' ||a.table_name|| ''''||','||'partname=>'||'''' ||a.partition_name|| ''''||',no_invalidate =>false,cascade_indexes => true);'
       FROM dba_tab_partitions a
       WHERE a.table_owner like  'UCR_CRM__'
       and a.TABLE_NAME='TF_BH_ORDER'
       and a.partition_position=12;	   
       
SELECT 'execute dbms_stats.lock_table_stats(ownname=> '|| ''''||a.owner ||''''|| ','
       || 'tabname=>'||'''' ||a.table_name|| ''''||');'
       FROM  dba_tables a
       WHERE owner like  'UCR_CRM__'
       and a.TABLE_NAME='TI_B_CUST_GROUPMEMBER';       
       

       

select  /*+ rule */ 'execute DBMS_STATS.gather_table_stats(ownname=>'''||a.owner||''',tabname=>'''||b.table_name||''',partname => '''||a.partition_name||''',degree=>12,estimate_percent=>10,cascade=>true,no_invalidate => FALSE);',sum(a.bytes)/1024/1024  
  from dba_segments a,dba_tab_partitions b 
 where (b.num_rows<100 or b.num_rows is null)
   and a.segment_name =b.table_name
   and a.partition_name = b.partition_name
   and a.owner=b.table_owner
   and b.table_owner like 'UCR%'
   and a.owner like 'UCR%'
group by a.owner,b.table_name,b.partition_name,a.partition_name
having  sum(a.bytes)/1024/1024>8    
order by sum(a.bytes)/1024/1024 desc;   
       
select  /*+ rule */ a.num_rows,'execute DBMS_STATS.gather_table_stats(ownname=>'''||a.owner||''',tabname=>'''||a.table_name||''',degree=>8,estimate_percent=>10,cascade=>true,no_invalidate => false);',
        sum(b.bytes)/1024/1024,
       'exec dbms_stats.delete_table_stats(ownname => '''||a.owner||''',tabname => '''||a.table_name||''',no_invalidate => false,cascade_indexes => true);'  
  from dba_tables a,dba_segments b 
 where a.table_name = b.segment_name
   and a.PARTITIONED='NO'
   and a.owner=b.owner
   and a.owner like 'U%'
   and b.owner like 'U%'
   and (a.NUM_ROWS =0 or a.NUM_ROWS is null)
group by a.num_rows,a.owner,a.table_name,b.segment_name
having  sum(b.bytes)/1024/1024>14
order by sum(b.bytes)/1024/1024 desc;


select  /*+ rule */ a.num_rows,'execute DBMS_STATS.gather_table_stats(ownname=>'''||a.table_owner||
''',tabname=>'''||a.table_name||
''',partname =>'''||a.partition_name||
''',degree=>20,cascade=>true,no_invalidate => false);',
        sum(b.bytes)/1024/1024,
       'execute dbms_stats.delete_table_stats(ownname => '''||a.table_owner||''',tabname => '''||a.table_name||''',partname => '''||a.partition_name||''',cascade_indexes => true,no_invalidate => false)'
  from dba_tab_partitions a, dba_segments b
 where a.table_owner = b.owner
   and a.table_name = b.segment_name
   and a.table_name<>'TF_B_TRADE_PLATSVC_BAK'
   and a.partition_name = b.partition_name
   and a.table_owner like 'U%'
   and b.owner like 'U%'
   and (a.num_rows=0 or a.num_rows is null)
 group by a.num_rows, a.table_owner, a.table_name, a.partition_name
 --having sum(b.BYTES/1024/1024) between 100 and 1000
 having sum(b.BYTES/1024/1024) > 100
 order by sum(b.BYTES/1024/1024) desc;

--6 session 相关: 
--event count
set pagesize 1000
set linesize 1000
select inst_id,event,event#,count(*) 
from gv$session 
where 1=1
--and username like 'U%'
and status='ACTIVE'
and event not like 'SQL*Net%'
group by inst_id,event,event#
order by inst_id,count(*) desc;

--event name
set linesize 1000
set pagesize 1000
col SQL_ID  format a15;
col SQL_TEXT format A40;
col MACHINE format A10;
col USERNAME  format a10;
select a.INST_ID,a.SQL_ID,substr(a.SQL_TEXT,1,40),b.MACHINE,b.USERNAME
from gv$sqlarea a, gv$session b
where a.INST_ID=b.INST_ID
and a.SQL_ID=b.SQL_ID
and b.event='gc buffer busy'
order by a.INST_ID,a.SQL_ID;

--event#
set linesize 1000
set pagesize 1000
col SQL_ID  format a15;
col SQL_TEXT format A40;
col MACHINE format A10;
col USERNAME  format a10;
select a.INST_ID,a.SQL_ID,substr(a.SQL_TEXT,1,40),b.MACHINE,b.USERNAME
from gv$sqlarea a, gv$session b
where a.INST_ID=b.INST_ID
and a.SQL_ID=b.SQL_ID
and b.event# ='&&1'
order by a.INST_ID,a.SQL_ID;

--get sql_text
set pagesize 10000
col sql_text format a70
select sql_text 
from gv$sqltext_with_newlines 
where 1=1
and sql_id='avsfztx80jcsp' 
order by piece;


--get table index
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

--get table statistics
set linesize 1000
set pagesize 1000
select a.table_name,a.num_rows,a.partition_name,a.last_analyzed
from dba_tab_statistics a
where 1=1
and a.owner=upper('&&1')
and a.table_name=upper('&&2')
order by a.partition_position;

--get segment size
set linesize 1000
set pagesize 1000
col segment_name format a30; 
select a.segment_name,a.partition_name,a.bytes/1024/1024/1024 "size",a.tablespace_name
from dba_segments a
where a.owner=upper('&&1')
and a.segment_name=upper('&&2')
order by a.partition_name;

-- kill session
SELECT 'alter system kill session '||'''' ||a.sid|| ','||a.serial# ||''''|| ' immediate;'
FROM v$session a 
WHERE a.MACHINE ='ngemail1';

SELECT a.USERNAME,a.MODULE,a.STATUS,a.EVENT,'alter system kill session '||'''' ||a.sid|| ','||a.serial# ||',@'||A.INST_ID||''' immediate;'
FROM gv$session a 
WHERE 1=1
--and a.inst_id=1
--and username='CLOUD_DH';
and a.SID in ('6538');


select 'kill -9 '||B.SPID||' ;'
from v$session a ,v$process b
where a.PADDR=b.ADDR
and a.USERNAME='SYS';

select 'kill -9 '||B.SPID||' ;'
from gv$session a ,gv$process b
where 1=1
and a.INST_ID=b.INST_ID
and a.INST_ID=4
and a.PADDR=b.ADDR
and a.PROGRAM like 'jftrade@4F780KLpar1%'; 

------ running session
select distinct a.INST_ID,a.SID,a.SERIAL#,A.STATUS,a.MACHINE, a.LOGON_TIME, a.osuser,a.USERNAME,a.EVENT,b.SQL_TEXT,b.SQL_ID,b.HASH_VALUE,a.PROGRAM,a.BLOCKING_INSTANCE,a.BLOCKING_SESSION
from gv$session a,gv$sql b
where 1=1
and a.STATUS='ACTIVE'
and a.SQL_ID=b.SQL_ID
and a.USERNAME  like 'U%'
and a.USERNAME not  like 'SYSTEM'
and a.USERNAME not  like 'UTOPTEA'
and a.EVENT not like '%SQL*Net%'
order by a.inst_id,a.EVENT;

select (sysdate - a.logon_time) * 24 * 60 minutes,
       a.username,
       a.BLOCKING_INSTANCE,
       a.BLOCKING_SESSION,
       a.program,
       a.machine,
       a.osuser,
       a.status,
       a.sid,
       a.serial#,
       a.event,
       a.p1,
       a.p2,
       a.p3,
       a.sql_id,
       a.sql_child_number,
       b.sql_text
  from v$session a, v$sql b
 where a.sql_address = b.address
   and a.sql_hash_value = b.hash_value
   and a.sql_child_number = b.child_number
   and a.username like '%USERNAME%'
 order by 1 desc;


select a.INST_ID,count(*)
from gv$session a
group by a.INST_ID
order by a.INST_ID;

SELECT distinct a.owner,a.object_name,a.object_type,b.SESSION_ID,c.STATUS,'alter system kill session '||'''' ||c.sid|| ','||c.serial# ||''''|| ' immediate;'
FROM dba_objects a ,v$locked_object b,v$session c
wHERE a.object_id=b.OBJECT_ID
and b.SESSION_ID=c.SID
and a.OBJECT_NAME in ('TF_B_ORDER','TF_B_TRADE')

select a.INST_ID,a.STAT_NAME,a.VALUE,b.STAT_NAME,b.VALUE,round(a.VALUE/b.VALUE*100,2)
from gv$osstat a,gv$osstat b
where a.STAT_NAME = 'LOAD'
and b.STAT_NAME='NUM_LCPUS'
and a.INST_ID=b.INST_ID
order by a.INST_ID

--job
select 'exec dbms_job.interval('||a.JOB||','||'''sysdate+5/1440'');',a.WHAT,a.*
from user_jobs a
where a.WHAT like '%TF_M_ROLEFUNCRIGHT%';

select 'exec dbms_job.instance('||a.JOB||',1);' 
from dba_jobs a where a.LOG_USER='UOP_WORKFLOW';

select 'exec dbms_job.instance('||a.JOB||',1);' 
from dba_jobs a where a.LOG_USER='UOP_WORKFLOW';

select 'exec dbms_job.run('||a.JOB||');',a.WHAT,a.*
from dba_jobs a
where 1=1
--and a.WHAT like '%TD_B_ITEMPRIORRULE%'
and a.FAILURES<>0;

select 'exec dbms_mview.refresh(''' || trim(a.name) || '''' || ',' ||
     '''C'');', c.owner,c.segment_name,sum(c.bytes)/1024/1024/1024
from user_mview_refresh_times a ,dba_tables@dblnk_ngcendb11 b, dba_segments@dblnk_ngcendb11 c
where 1=1
and a.MASTER_OWNER=b.owner
and a.MASTER=b.table_name
and a.MASTER_OWNER=c.owner
and a.MASTER=c.segment_name
group by a.name,c.owner,c.segment_name
order by sum(c.bytes)/1024/1024/1024 desc;

--根据表名全量刷新MV 
select 'exec dbms_mview.refresh(''' || trim(a.MVIEW_NAME) || '''' || ',' ||
       '''C'');'
  from user_mview_detail_relations a
 where a.detailobj_name in

select 'exec dbms_mview.refresh(''' || trim(a.name) || '''' || ',' ||
       '''C'');'
  from user_mview_refresh_times a
 where a.master in
 

select 'exec dbms_job.run('||a.JOB||');',a.WHAT,a.*
from user_jobs a
where a.FAILURES<>0;

-- auto task
select * from dba_autotask_job_history a 
where a.WINDOW_NAME='MONDAY_WINDOW' order by WINDOW_START_TIME desc;
--shedule window
select t1.window_name, t1.repeat_interval, t1.duration
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
  from DBA_AUTOTASK_WINDOW_CLIENTS@to_bjlcrmdb a;


exec dbms_auto_task_admin.ENABLE;
exec DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);
exec DBMS_AUTO_TASK_ADMIN.ENABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);


	   
-- SCN
select id,
       dfname,
       ctl_df_hd,
       df_scn,
       crt_scn,
       ceil((cast(scn_to_timestamp(crt_scn)as date) -
            cast(scn_to_timestamp(df_scn) as date)) * 24 * 60 * 60) delay_seconds
  from (select b.FILE# id,
               trim(a.name) dfname,
               a.CHECKPOINT_CHANGE# ctl_df_hd,
               b.CHECKPOINT_CHANGE# df_scn,
               (select to_char(current_scn) from v$database) crt_scn
          from v$datafile_header a, v$datafile b
         where a.file# = b.file#) scn_view
order by scn_view.id;	   
	   
--size
select a.TABLE_NAME "表名",sum(a.DATA_LENGTH) "每条记录大小(B)"
from dba_tab_columns a
where a.OWNER='UCR_ACT1'
and a.TABLE_NAME in ('TS_B_BILL','TF_B_PRINTLOGTASK','TF_B_VATPRINTDETAILLOG','TF_B_VATPRINTLOG')
group by a.TABLE_NAME;	  

select a.owner,a.segment_name,a.partition_name,b.num_rows,trunc(trunc(a.bytes/1024/1024/1024,2)/b.num_rows,10) "record_size(G)",
       trunc(a.bytes/1024/1024/1024,2) "size(G)",a.tablespace_name,trunc(a.bytes/1024/1024/1024,2)*1.5 "账单拆分后_size(G)"
from dba_segments@DBLNK_ZW a,dba_tab_statistics@DBLNK_ZW b
where 1=1
and a.owner=b.owner
and a.segment_name=b.table_name
and a.partition_name=b.partition_name
and a.owner='UCR_ACT1'
and a.segment_name='TF_B_NOTEPRINTLOG' 
order by a.tablespace_name; 

--GET DDL
select dbms_metadata.get_ddl('PROCEDURE','P_CMS_SCORECREATE_BILL_HX','UOP_ACT1') from dual;	   
	   
select 'alter system kill session '''||c.sid||','||c.SERIAL#||''';',c.LOGON_TIME,b.CTIME,
 c.USERNAME blocker,c.STATUS,
 a.sid,c.OSUSER,c.MACHINE,
 ' is blocking ',
 d.USERNAME blockee,d.STATUS,
 b.sid,d.OSUSER,d.MACHINE,b.CTIME,d.SQL_ID,'alter system kill session '''||c.sid||','||c.SERIAL#||''';'
 from v$lock a, v$lock b,v$session c,v$session d
 where a.block = 1
 and b.request > 0
 and a.id1 = b.id1
 and a.id2 = b.id2
 and c.SID=a.SID
 and d.SID=b.SID
 and c.STATUS='INACTIVE'
 and c.MACHINE like 'p750%'
 and d.MACHINE like 'p750%'
 and c.OSUSER ='app'
 and d.OSUSER ='app'
 order by c.LOGON_TIME desc ;
  
select 'alter system kill session '''||a.sid||','||a.SERIAL#||''';',
 a.STATUS,a.LOGON_TIME,a.MACHINE,a.USERNAME,a.*
from v$session a
where a.STATUS='INACTIVE'
and a.OSUSER='app'
and a.MACHINE like 'p750%'
and a.USERNAME like 'UOP_CRM__'
and a.LOGON_TIME < to_date('2013-11-16 18:09:00','YYYY-MM-DD HH24:MI:SS');

select a.*,b.STATUS,B.LOGON_TIME
from v$locked_object a,v$session b
where a.object_id in (
select object_id from dba_objects where object_name ='TF_B_ORDER' and owner ='UCR_CRM11'
)
and a.SESSION_ID=b.SID
and b.STATUS ='INACTIVE';  

--查表碎片
select owner,
       table_name,
       ROUND(blocks * 8 / 1024 ,2)TAB_SIZE_MB,
       ROUND(((AVG_ROW_LEN * NUM_ROWS) / (BLOCKS * 8 * 1024)) * 100,2) used_pct,
       round(100-((AVG_ROW_LEN * NUM_ROWS) / (BLOCKS * 8 * 1024)) * 100,2) 碎片率,
       ROUND((AVG_ROW_LEN * NUM_ROWS) / 1024 / 1024,2) real_space_MB
  from dba_tables
 where owner = 'UCR_PF1'
   and table_name = 'TL_B_IBPLAT_SYN';

select owner,
       table_name,
       ROUND(blocks * 8 / 1024 ,2)TAB_SIZE_MB,
       ROUND(((AVG_ROW_LEN * NUM_ROWS) / (BLOCKS * 8 * 1024)) * 100,2) used_pct,
       round(100-((AVG_ROW_LEN * NUM_ROWS) / (BLOCKS * 8 * 1024)) * 100,2) 碎片率,
       ROUND((AVG_ROW_LEN * NUM_ROWS) / 1024 / 1024,2) real_space_MB
  from dba_tables a
 where owner = 'UCR_OLCOM1'
 and a.NUM_ROWS<>0 and a.BLOCKS<>0
 and ROUND(blocks * 8 / 1024 ,2) > 100
 order by 5 desc   

--CPU used by this session
select /*+ materialize */
   sess.inst_id,
   sess.sid,
   sess.serial#,
   sess.username,
   sess.module,
   sess.program,
   stat.value cpu_used_by_this_session,
   i.physical_reads,
   i.block_gets,
   sess.command,
   sess.status,
   sess.lockwait,
   decode(sess.sql_hash_value, 0, sess.prev_hash_value, sess.sql_hash_value) sql_hash_value,
   decode(sess.sql_address, '00', sess.prev_sql_addr, sess.sql_address) sql_address
    from gv$sesstat stat, gv$session sess, gv$sess_io i
   where stat.statistic# =
         (select statistic#
            from v$statname
           where name = 'CPU used by this session')
     and stat.sid = sess.sid
     and sess.STATUS='ACTIVE'
     and sess.USERNAME like 'UOP%'
     and stat.inst_id = sess.inst_id
     and (stat.value > 100 or i.physical_reads > 100 or i.block_gets > 100)
     and sess.username is not null
     and i.sid = sess.sid
     and i.inst_id = sess.inst_id
     order by 7 desc;

--排重
delete /*+ parallel(a,10) */ 
from  TF_F_USERLIST_SN partition (PAR_TF_F_USERLIST_SN_0)  a
where a.rowid > (select /*+  parallel(b,10) */ min(rowid)
                     from  TF_F_USERLIST_SN partition (PAR_TF_F_USERLIST_SN_0) b
                    where b.USER_ID = a.USER_ID);  

--查看数据库的uptime
SELECT TO_CHAR(startup_time, 'DD-MON-YYYY HH24:MI:SS') started_at,
       TRUNC(SYSDATE - (startup_time)) || ' day(s), ' ||
       TRUNC(24 *
             ((SYSDATE - startup_time) - TRUNC(SYSDATE - startup_time))) ||
       ' hour(s), ' || MOD(TRUNC(1440 * ((SYSDATE - startup_time) -
                                 TRUNC(SYSDATE - startup_time))),
                           60) || ' minute(s), ' ||
       MOD(TRUNC(86400 *
                 ((SYSDATE - startup_time) - TRUNC(SYSDATE - startup_time))),
           60) || ' seconds' uptime
  FROM v$instance;	


--查看PGA advice
Select pga_target_for_estimate/1024/1024 ||'M' "Estimate PGA Target"
       ,estd_pga_cache_hit_percentage "CacheHit(%)"
       ,estd_extra_bytes_rw/1024/1024 ||'M' "Extra Read/Write"
       ,estd_overalloc_count "Over alloccount"
From v$pga_target_advice 

--查询Top 5 的争用的latch address
select *
  from (select CHILD#, ADDR, GETS, MISSES, SLEEPS
          from v$latch_children
         where name = 'cache buffers chains'
           and misses > 0
           and sleeps > 0
         order by 5 desc, 1, 2, 3)
 where rownum < 6; 
 
 --根据上面的hladdr找出Hot block
 select /*+ RULE */

 e.owner || '.' || e.segment_name segment_name,
 
 e.extent_id extent#,
 
 x.dbablk - e.block_id + 1 block#,
 
 x.tch, /* sometimes tch=0,we need to see tim */
 x.tim,
 l.child#

  from v$latch_children l,
       
       x$bh x,
       
       dba_extents e

 where

 x.hladdr = '00000004495C2608'
 and

 e.file_id = x.file#
 and

 x.hladdr = l.addr
 and

 x.dbablk between e.block_id and e.block_id + e.blocks - 1

 order by x.tch desc;


--创建用户命令：
select 'create user '||username||' identified by '||username||' default tablespace '|| default _tablespace||' temporary tablespace TEMP profile DEFAULT; 'from (select * from dba_users order by user_id) where user_id>26 and user_id<>47
注：11g密码开始区分大小写，该处的密码是大写的

--赋予用户系统权限：
select 'grant '||a.privilege||' to '||a.GRANTEE||';'
  from dba_sys_privs a, dba_users b
 where a.GRANTEE = b.username
   and b.user_id > 26
   and b.user_id <> 47
   order by  a.GRANTEE;

--赋予用户角色权限：
select 'grant '||a.GRANTED_ROLE||' to '||a.GRANTEE||';'
  from dba_role_privs a, dba_users b
 where a.GRANTEE = b.username
   and b.user_id > 26
   and b.user_id <> 47
   order by  a.GRANTEE;

--修改用户默认表空间：
select 'alter user '||a.username||' default tablespace '||a.default_tablespace||';' from dba_users@DBLIK_NEW a ,dba_users b
where a.username=b.username
and  b.user_id > 26
   and b.user_id <> 47;
   
GTM 相关：
select  q.*,q.rowid  from ucr_act1.td_s_work q order by q.work_id asc ;
select  q.*,q.rowid  from ucr_act1.td_s_work q where q.work_id in ('401100') ;
select  q.*,q.rowid  from ucr_act1.td_s_task q where q.task_id like '4011%' order by q.task_id desc ;
select  q.*,q.rowid  from ucr_act1.td_s_route q where q.work_id in ('401100') order by q.end_task_id desc ;
select  q.*,q.rowid  from ucr_act1.tl_o_gtm_log q where q.task_id = 401100  ;  

PURGE recyclebin; 
purge dba_recyclebin;

--查看隐含参数
set lines 600
col name format a30;
col value format a30;
col isdefault format a10;
col ismod format a10;
col isadj format a10;
select x.ksppinm name,
       y.ksppstvl value,
       y.ksppstdf isdefault,
       decode(bitand(y.ksppstvf, 7),
              1,
              'MODIFIED',
              4,
              'SYSTEM_MOD',
              'FALSE') ismod,
       decode(bitand(y.ksppstvf, 2), 2, 'TRUE', 'FALSE') isadj
  from sys.x$ksppi x, sys.x$ksppcv y
 where x.inst_id = userenv('Instance')
   and y.inst_id = userenv('Instance')
   and x.indx = y.indx
   and (x.ksppinm like '_use_single_log_writer%'
   or x.ksppinm like '_max_outstanding_log_writes%')
 order by translate(x.ksppinm, ' _', ' ');
 
 
alter system set  "_use_single_log_writer"=false scope=spfile;

alter system set  "_max_outstanding_log_writes"=3 scope=spfile;

alter system set cpu_count=5 scope=both;

set lines 600
col param_name format a30;
col param_value format a30;
col descp format a50;
select  ksppinm param_name,ksppstvl param_value,ksppdesc descp
   from sys.x$ksppi, sys.x$ksppcv
   where x$ksppi.indx = x$ksppcv.indx
    and ksppinm like '%_max_outstanding_log_writes%'
    order by ksppinm;


select userenv('language') from dual;

---查看块中 记录数
select distinct dbms_rowid.rowid_relative_fno(rowid) file#,
dbms_rowid.rowid_block_number(rowid) blk#
from LUNAR
where rownum=1;


select count(*) 
from LUNAR 
where dbms_rowid.rowid_relative_fno(rowid)=1 
  and dbms_rowid.rowid_block_number(rowid)=50345;
  
  
select rowid,scn_to_timestamp(ora_rowscn) row_scn 
from LUNAR
where dbms_rowid.rowid_relative_fno(rowid)=1 
  and dbms_rowid.rowid_block_number(rowid)=50345;  
  
select distinct ora_rowscn from ucr_cen1.TF_CHL_CHANNEL order by 1 desc;

select scn_to_timestamp(13136540398788) from dual;
select CURRENT_SCN from v$database;  
  
-- 查看回滚进度  
SELECT r.NAME 回滚段名,s.sid SID,s.serial# Serial,
       s.username 用户名,s.machine 机器名,
       t.start_time 开始时间,t.status 状态,
       t.used_ublk 撤消块,USED_UREC 撤消记录,
       t.cr_get 一致性取,t.cr_change 一致性变化,
       t.log_io "逻辑I/O",t.phy_io "物理I/O",
       t.noundo NoUndo,g.extents Extents,substr(s.program, 1, 50) 操作程序
  FROM v$session s, v$transaction t, v$rollname r,v$rollstat g
WHERE t.addr = s.taddr
   AND t.xidusn = r.usn
   AND r.usn = g.usn
ORDER BY t.used_ublk desc;
  
--  metadata to  word  
SELECT t1.Table_Name   AS "表名称",
       t3.comments     AS "表说明",
       t1.Column_Name  AS "字段名称",
       t1.Data_Type    AS "数据类型",
       t1.Data_Length  AS "长度",
       t1.NullAble     AS "是否为空",
       t2.Comments     AS "字段说明",
       t1.Data_Default "默认值"
  FROM cols t1
  left join user_col_comments t2 on t1.Table_name = t2.Table_name
                                and t1.Column_Name = t2.Column_Name
  left join user_tab_comments t3 on t1.Table_name = t3.Table_name
 WHERE NOT EXISTS (SELECT t4.Object_Name
          FROM User_objects t4
         WHERE t4.Object_Type = 'TABLE'
           AND t4.Temporary = 'Y'
           AND t4.Object_Name = t1.Table_Name)
 ORDER BY t1.Table_Name, t1.Column_ID;
 
 
---- undo
select s.username, u.name
  from v$transaction t,
       v$rollstat    r,
       v$rollname    u,
       v$session     s 　　
where s.taddr = t.addr and t.xidusn = r.usn and r.usn = u.usn
 order by s.username;

select usn,
       xacts,
       rssize / 1024 / 1024 / 1024,
       hwmsize / 1024 / 1024 / 1024,
       shrinks
  from v$rollstat
 order by rssize; 

--查看补丁：
$ORACLE_HOME/OPatch/opatch lsinventory -bugs_fixed | grep -i -E 'DATABASE PSU|DATABASE PATCH SET UPDATE'

-- 查看table及索引占用表空间大小：
select * from 
(select s.tablespace_name,sum(bytes)/1024/1024/1024 
from dba_segments s
where s.owner='UCR_ACT1'
and s.segment_name in ('TF_F_USER','TF_F_ACCOUNT') 
group by s.tablespace_name 
union all
select s.tablespace_name,sum(bytes)/1024/1024/1024 
from dba_segments s,dba_indexes i,dba_tables t 
where t.owner=i.owner 
and i.owner=s.owner 
and t.table_name=i.table_name 
and (s.segment_name=i.index_name) 
and t.table_name in ('TF_F_USER','TF_F_ACCOUNT') 
and t.owner='UCR_ACT1' 
group by s.tablespace_name 
)
order by 1

	
 
select * from td_m_issp_config as of timestamp sysdate-10/1440;

--刷新物化视图
exec  dbms_mview.refresh('MV_NAME','Corf');
commit;

--根据OS进程号查找SQL 
select a.sid,c.spid,a.status,a.program,b.sql_text
  from v$session a,v$sqlarea b,v$process c
 where a.sql_hash_value=b.hash_value
   and a.paddr=c.addr
   and c.spid in(
'1482886'
)

-- kill local
ps -ef | grep ora | grep LOCAL=NO|awk '{if($3=="1") print "kill -9 "$2}'|sh

-- 限制用户登录
alter system enable restricted session;
alter system disable restricted session;

-- group by object_type
select a.object_type,count(*)
from dba_objects a
where a.owner='UCR_OLCOM'
group by a.object_type
order by a.object_type;

-- redo
SELECT GROUP#, ARCHIVED,thread#, STATUS,bytes/1024/1024/1024 FROM gV$LOG order by thread#,group#;
select group#,type,member from v$logfile order by group#,member;

alter system switch logfile;
alter system checkpoint;

step1:
alter database add logfile thread 2  group 6   ('+DG_DATA/ngechdb/onlinelog/group6_1.redo','+DG_DATA/ngechdb/onlinelog/group6_2.redo') size 4096M;  

-- find long clob
select *
from dba_tab_columns a
where (a.DATA_TYPE='LONG' or a.DATA_TYPE='CLOB')
and a.OWNER like 'U%'
order by a.OWNER,a.TABLE_NAME,a.COLUMN_NAME;

-- 
select RESOURCE_NAME as "RESOURCE",
'     '||CURRENT_UTILIZATION as current_used,
'     '||round(CURRENT_UTILIZATION/LIMIT_VALUE * 100) || '%' as current_pct,
'  '||MAX_UTILIZATION as max_used,
LIMIT_VALUE as limit
from v$resource_limit t 
where t.RESOURCE_NAME in ('processes','sessions');

-- count(*)
create table cloud_dh.TL_S_COUNT_LOG
(
dbname varchar2(30),
owner varchar2(30),
tab_name varchar2(30),
start_time date,
cnt number
)
tablespace tbs_def;

select 'insert into cloud_dh.TL_S_COUNT_LOG  select /*+ parallel(a,30)*/ ''NGCRMDB1'',' || '''' ||
       a.owner || ''',' || '''' || a.table_name ||
       ''',sysdate,count(*) from ' || a.owner || '.' || a.table_name ||
       ' a;'
  from dba_tables a
 where a.owner like 'U%';
 
 
-- 根据DBA查询file_id, block_id
select dbms_utility.data_block_address_file('25165844') FILE_ID,  
     dbms_utility.data_block_address_block('25165844') BLOCK_ID 
	 from dual;   
	 
-- ash:
select event,count(*) 
from dba_hist_active_sess_history a
where 1=1
and a.INSTANCE_NUMBER=2
and a.SAMPLE_TIME > to_date('2016-07-04 16:50:00', 'yyyy-mm-dd hh24:mi:ss')
and a.SAMPLE_TIME < to_date('2016-07-04 17:00:00', 'yyyy-mm-dd hh24:mi:ss')
group by a.event
order by 2 desc;

select to_char(a.SAMPLE_TIME,'yyyy-mm-dd hh24:mi'),count(*)
from dba_hist_active_sess_history a
where 1=1
and a.INSTANCE_NUMBER=2
and a.SAMPLE_TIME > to_date('2016-07-04 16:50:00', 'yyyy-mm-dd hh24:mi:ss')
and a.SAMPLE_TIME < to_date('2016-07-04 17:00:00', 'yyyy-mm-dd hh24:mi:ss')
and a.event='enq: TX - allocate ITL entry'
group by to_char(a.SAMPLE_TIME,'yyyy-mm-dd hh24:mi') 
order by 2 desc;

select *
from dba_hist_active_sess_history a
where 1=1
and a.INSTANCE_NUMBER=2
and to_char(a.SAMPLE_TIME,'yyyy-mm-dd hh24:mi:ss') ='2016-07-04 16:57:10'
--and a.SAMPLE_TIME < to_date('2016-07-04 16:59:00', 'yyyy-mm-dd hh24:mi:ss')
and a.event='enq: TX - allocate ITL entry'


select
    optimizer_feature_enable,
   description
from
   v$system_fix_control
where
   substr(optimizer_feature_enable,1,2) = '10'
order by
   to_number(optimizer_feature_enable),
   description;	 