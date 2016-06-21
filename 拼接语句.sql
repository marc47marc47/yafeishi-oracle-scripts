--索引失效：
SELECT 'alter index ' ||a.owner||'.'||a.index_name|| ' unusable ;',a.status,a.partitioned
FROM dba_indexes a
WHERE a.table_name='TF_F_USER' ;

--重建分区索引：
SELECT 'alter index ' ||a.index_owner||'.'||a.index_name|| ' rebuild partition '||a.partition_name|| ' ;'
FROM dba_ind_partitions a,Dba_Indexes b
WHERE b.table_name='TF_F_USER'
AND B.index_name=A.INDEX_NAME(+)

--重建非分区索引：
SELECT 'alter index ' ||a.owner||'.'||a.index_name|| ' rebuild ;',a.status,a.partitioned
FROM dba_indexes a
WHERE a.table_name='TF_F_USER'
AND a.partitioned='NO' ;


--rename
select 'alter table '||a.table_name||' rename constraint '||a.constraint_name||' to '||a.constraint_name||'_j2ee ;'
from user_constraints a
where  a.constraint_name not like 'SYS%'
and a.table_name in
(
'TF_B_TRADE_BATDEAL',
'TF_BH_TRADE_BATDEAL'

);


select 'alter table '||a.table_name||' rename to '||a.table_name||'_j2ee ;'
from user_tables a
where a.table_name in
(
'TF_B_TRADE',
'TF_BH_TRADE_STAFF'
);


select 'alter index '||a.index_name||' rename to '||a.index_name||'_j2ee ;'
from user_indexes a
where a.table_name in
(
'TF_B_TRADE',
'TF_BH_TRADE_STAFF'

);

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
       

       

select 'execute DBMS_STATS.gather_table_stats(ownname=>'''||a.owner||''',tabname=>'''||b.table_name||''',partname => '''||a.partition_name||''',degree=>12,estimate_percent=>10,cascade=>true,no_invalidate => FALSE);',sum(a.bytes)/1024/1024  
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
       
select 'execute DBMS_STATS.gather_table_stats(ownname=>'''||a.owner||''',tabname=>'''||a.table_name||''',degree=>8,estimate_percent=>10,cascade=>true,no_invalidate => false);',
        sum(b.bytes)/1024/1024,
       'exec dbms_stats.delete_table_stats(ownname => '''||a.owner||''',tabname => '''||a.table_name||''',no_invalidate => false,cascade_indexes => true);'  
  from dba_tables a,dba_segments b 
 where a.table_name = b.segment_name
   and a.PARTITIONED='NO'
   and a.owner=b.owner
   and a.owner like 'UCR%'
   and b.owner like 'UCR%'
   and (a.NUM_ROWS =0 or a.NUM_ROWS is null)
group by a.owner,a.table_name,b.segment_name
having  sum(b.bytes)/1024/1024>14
order by sum(b.bytes)/1024/1024 desc;


select a.num_rows,'execute DBMS_STATS.gather_table_stats(ownname=>'''||a.table_owner||''',tabname=>'''||a.table_name||''',partname =>'''||a.partition_name||''',degree=>8,estimate_percent=>10,cascade=>true,no_invalidate => false);',
        sum(b.bytes)/1024/1024,
       'execute dbms_stats.delete_table_stats(ownname => '''||a.table_owner||''',tabname => '''||a.table_name||''',partname => '''||a.partition_name||''',cascade_indexes => true,no_invalidate => false)'
  from dba_tab_partitions a, dba_segments b
 where a.table_owner = b.owner
   and a.table_name = b.segment_name
   and a.partition_name = b.partition_name
   and a.table_owner like 'UCR%'
   and b.owner like 'UCR%'
   and (a.num_rows=0 or a.num_rows is null)
 group by a.num_rows, a.table_owner, a.table_name, a.partition_name
 having sum(b.BYTES/1024/1024) between 100 and 1000
 --having sum(b.BYTES/1024/1024) > 3000
 order by sum(b.BYTES/1024/1024) desc;

--6 session 相关: 
--event count
set pagesize 1000
set linesize 1000
select inst_id,event,event#,count(*) 
from gv$session 
where username like 'U%'
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


SELECT 'alter system kill session '||'''' ||a.sid|| ','||a.serial# ||''''|| ' immediate;'
FROM v$session a WHERE a.MACHINE ='ngemail1';

select 'kill -9 '||B.SPID||' ;'
from v$session a ,v$process b
where a.PADDR=b.ADDR
and a.USERNAME='SYS';

select distinct a.INST_ID,a.SID,a.SERIAL#,a.PROGRAM,a.MACHINE, a.osuser,a.USERNAME,a.EVENT,b.SQL_TEXT,b.SQL_IDfrom gv$session a,gv$sql b
where a.STATUS='ACTIVE'
and a.SQL_ID=b.SQL_ID
and a.USERNAME  like 'UOP%'
and a.EVENT not like '%SQL*Net message%'
order by a.inst_id,a.EVENT;


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
select 'exec dbms_job.interval('||a.JOB||','||'''sysdate+20/1440'');'
from user_jobs a
where a.WHAT like '%TD_B_PLATSVC%';

select 'exec dbms_job.instance('||a.JOB||',1);' 
from dba_jobs a where a.LOG_USER='UOP_WORKFLOW';

-- auto task
select * from dba_autotask_job_history a 
where a.WINDOW_NAME='MONDAY_WINDOW' order by WINDOW_START_TIME desc;
--shedule window
select t1.window_name, t1.repeat_interval, t1.duration
from dba_scheduler_windows t1, dba_scheduler_wingroup_members t2
 where t1.window_name = t2.window_name
   and t2.window_group_name in
       ('MAINTENANCE_WINDOW_GROUP', 'BSLN_MAINTAIN_STATS_SCHED');

	   
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
       ,estd_extra_bytes_rw/1024/1024 ||'M'"Extra Read/Write"
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

