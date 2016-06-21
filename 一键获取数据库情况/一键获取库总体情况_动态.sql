
SET markup html ON spool ON pre off entmap off

set term off
set heading on
set verify off
set feedback off

set linesize 2000
set pagesize 30000
set long 999999999
set longchunksize 999999

column index_name format a30
column table_name format a30
column num_rows format 999999999
column index_type format a24
column num_rows format 999999999
column status format a8
column clustering_factor format 999999999
column degree format a10
column blevel format 9
column distinct_keys format 9999999999
column leaf_blocks format   9999999
column last_analyzed    format a10
column column_name format a25
column column_position format 9
column temporary format a2
column partitioned format a5
column partitioning_type format a7
column partition_count format 999
column program  format a30
column spid  format a6
column pid  format 99999
column sid  format 99999
column serial# format 99999
column username  format a12
column osuser    format a12
column logon_time format  date
column event    format a32
column JOB_NAME        format a30
column PROGRAM_NAME    format a32
column STATE           format a10
column window_name           format a30
column repeat_interval       format a60
column machine format a30
column program format a30
column osuser format a15
column username format a15
column event format a50
column seconds format a10
column sqltext format a100



column dbid new_value spool_dbid
column inst_num new_value spool_inst_num
select dbid from v$database where rownum = 1;
select instance_number as inst_num from v$instance where rownum = 1;
column spoolfile_name new_value spoolfile
select 'spool_'||(select name from v$database where rownum=1) ||'_'|| (select instance_name from v$instance where rownum=1)||'_'||to_char(sysdate,'yy-mm-dd_hh24.mi')||'_dynamic' as spoolfile_name from dual;
spool &&spoolfile..html

prompt <p>30������CPU��ȴ����
select t.*, s.sid, s.serial#, s.machine, s.program, s.osuser
  from (select c.USERNAME,
               a.event,
               to_char(a.cnt) as seconds,
               a.sql_id,
               dbms_lob.substr(b.sql_fulltext,100,1) sqltext
          from (select rownum rn, t.*
                  from (select decode(s.session_state,
                                      'WAITING',
                                      s.event,
                                      'Cpu + Wait For Cpu') Event,
                               s.sql_id,
                               s.user_id,
                               count(*) CNT
                          from v$active_session_history s
                         where sample_time > sysdate - 30 / 1440
                         group by s.user_id,
                                  decode(s.session_state,
                                         'WAITING',
                                         s.event,
                                         'Cpu + Wait For Cpu'),
                                  s.sql_id
                         order by CNT desc) t
                 where rownum < 20) a,
               v$sqlarea b,
               dba_users c
         where a.sql_id = b.sql_id
           and a.user_id = c.user_id
         order by CNT desc) t,
       v$session s
where t.sql_id = s.sql_id(+);


prompt <p>�ȴ��¼�����ǰ��
select t.event, count(*)
  from v$session t
group by event
order by count(*) desc;

prompt <p>�ȴ��¼�����ʷ�㼯�� 
select t.event, t. total_waits
  from v$system_event t
order by total_waits desc;

prompt <p>�α�ʹ�����
select sid, count(*) cnt
  from v$open_cursor
group by  sid
having count(*) >= 1000
order by cnt desc;

prompt <p>�鿴LOCK�����
SELECT /*+ RULE */
 LS.OSUSER OS_USER_NAME,
 LS.USERNAME USER_NAME,
 DECODE(LS.TYPE,
        'RW',
        'Row wait enqueue lock',
        'TM',
        'DML enqueue lock',
        'TX',
        'Transaction enqueue lock',
        'UL',
        'User supplied lock') LOCK_TYPE,
 O.OBJECT_NAME OBJECT,
 DECODE(LS.LMODE,
        1,
        NULL,
        2,
        'Row Share',
        3,
        'Row Exclusive',
        4,
        'Share',
        5,
        'Share Row Exclusive',
        6,
        'Exclusive',
        NULL) LOCK_MODE,
 O.OWNER,
 LS.SID,
 LS.SERIAL# SERIAL_NUM,
 LS.ID1,
 LS.ID2
  FROM SYS.DBA_OBJECTS O,
       (SELECT S.OSUSER,
               S.USERNAME,
               L.TYPE,
               L.LMODE,
               S.SID,
               S.SERIAL#,
               L.ID1,
               L.ID2
          FROM V$SESSION S, V$LOCK L
         WHERE S.SID = L.SID) LS
 WHERE O.OBJECT_ID = LS.ID1
   AND O.OWNER <> 'SYS'
 ORDER BY O.OWNER, O.OBJECT_NAME;

prompt <p>�鿴˭��ס��˭
select  /*+no_merge(a) no_merge(b) */
(select username from v$session where sid=a.sid) blocker,
a.sid, 'is blocking',
(select username from v$session where sid=b.sid) blockee,
b.sid
from v$lock a,v$lock b
where a.block=1 and b.request>0
and a.id1=b.id1
and a.id2=b.id2
order by a.sid;

prompt <p>PGAռ�����Ľ���
SELECT * FROM (
SELECT p.spid,
       p.pid,
       s.sid,
       s.serial#,
       s.status,
       p.pga_alloc_mem,
       s.username,
       s.osuser,
       s.program
  FROM v$process p, v$session s
WHERE s.paddr(+) = p.addr
Order by p.pga_alloc_mem desc)
where rownum < 21;

prompt <p>��¼ʱ�����SESSION
select *
  from (select t.sid,
               t2.spid,
               t.PROGRAM,
               t.status,
               t.sql_id,
               t.PREV_SQL_ID,
               t.event,
               t.LOGON_TIME,
               trunc(sysdate - logon_time)
          from v$session t, v$process t2
         where t.paddr = t2.ADDR
           and t.type <> 'BACKGROUND'
         order by logon_time)
where rownum <= 10;


prompt <p>awr��ͼ�е�load profile
select s.snap_date,
       decode(s.redosize, null, '--shutdown or end--', s.currtime) "TIME",
       to_char(round(s.seconds/60,2)) "elapse(min)",
       round(t.db_time / 1000000 / 60, 2) "DB time(min)",
       s.redosize redo,
       round(s.redosize / s.seconds, 2) "redo/s",
       s.logicalreads logical,
       round(s.logicalreads / s.seconds, 2) "logical/s",
       physicalreads physical,
       round(s.physicalreads / s.seconds, 2) "phy/s",
       s.executes execs,
       round(s.executes / s.seconds, 2) "execs/s",
       s.parse,
       round(s.parse / s.seconds, 2) "parse/s",
       s.hardparse,
       round(s.hardparse / s.seconds, 2) "hardparse/s",
       s.transactions trans,
       round(s.transactions / s.seconds, 2) "trans/s"
  from (select curr_redo - last_redo redosize,
               curr_logicalreads - last_logicalreads logicalreads,
               curr_physicalreads - last_physicalreads physicalreads,
               curr_executes - last_executes executes,
               curr_parse - last_parse parse,
               curr_hardparse - last_hardparse hardparse,
               curr_transactions - last_transactions transactions,
               round(((currtime + 0) - (lasttime + 0)) * 3600 * 24, 0) seconds,
               to_char(currtime, 'yy/mm/dd') snap_date,
               to_char(currtime, 'hh24:mi') currtime,
               currsnap_id endsnap_id,
               to_char(startup_time, 'yyyy-mm-dd hh24:mi:ss') startup_time
          from (select a.redo last_redo,
                       a.logicalreads last_logicalreads,
                       a.physicalreads last_physicalreads,
                       a.executes last_executes,
                       a.parse last_parse,
                       a.hardparse last_hardparse,
                       a.transactions last_transactions,
                       lead(a.redo, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_redo,
                       lead(a.logicalreads, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_logicalreads,
                       lead(a.physicalreads, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_physicalreads,
                       lead(a.executes, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_executes,
                       lead(a.parse, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_parse,
                       lead(a.hardparse, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_hardparse,
                       lead(a.transactions, 1, null) over(partition by b.startup_time order by b.end_interval_time) curr_transactions,
                       b.end_interval_time lasttime,
                       lead(b.end_interval_time, 1, null) over(partition by b.startup_time order by b.end_interval_time) currtime,
                       lead(b.snap_id, 1, null) over(partition by b.startup_time order by b.end_interval_time) currsnap_id,
                       b.startup_time
                  from (select snap_id,
                               dbid,
                               instance_number,
                               sum(decode(stat_name, 'redo size', value, 0)) redo,
                               sum(decode(stat_name,
                                          'session logical reads',
                                          value,
                                          0)) logicalreads,
                               sum(decode(stat_name,
                                          'physical reads',
                                          value,
                                          0)) physicalreads,
                               sum(decode(stat_name, 'execute count', value, 0)) executes,
                               sum(decode(stat_name,
                                          'parse count (total)',
                                          value,
                                          0)) parse,
                               sum(decode(stat_name,
                                          'parse count (hard)',
                                          value,
                                          0)) hardparse,
                               sum(decode(stat_name,
                                          'user rollbacks',
                                          value,
                                          'user commits',
                                          value,
                                          0)) transactions
                          from dba_hist_sysstat
                         where stat_name in
                               ('redo size',
                                'session logical reads',
                                'physical reads',
                                'execute count',
                                'user rollbacks',
                                'user commits',
                                'parse count (hard)',
                                'parse count (total)')
                         group by snap_id, dbid, instance_number) a,
                       dba_hist_snapshot b
                 where a.snap_id = b.snap_id
                   and a.dbid = b.dbid
                   and a.instance_number = b.instance_number
                   and a.dbid = &&spool_dbid
                   and a.instance_number = &&spool_inst_num
                 order by end_interval_time)) s,
       (select lead(a.value, 1, null) over(partition by b.startup_time order by b.end_interval_time) - a.value db_time,
               lead(b.snap_id, 1, null) over(partition by b.startup_time order by b.end_interval_time) endsnap_id
          from dba_hist_sys_time_model a, dba_hist_snapshot b
         where a.snap_id = b.snap_id
           and a.dbid = b.dbid
           and a.instance_number = b.instance_number
           and a.stat_name = 'DB time'
           and a.dbid = &&spool_dbid
           and a.instance_number = &&spool_inst_num) t
 where s.endsnap_id = t.endsnap_id
 order by  s.snap_date desc ,time asc;


prompt <p>�߼������
select *
  from (select sql_id,
               sql_text,
               s.EXECUTIONS,
               s.LAST_LOAD_TIME,
               s.FIRST_LOAD_TIME,
               s.DISK_READS,
               s.BUFFER_GETS
          from v$sql s
         where s.buffer_gets > 300
         order by buffer_gets desc)
where rownum <= 10;

prompt <p>�������� 
select * 
  from (select sql_id,
       sql_text,
       s.EXECUTIONS,
       s.LAST_LOAD_TIME,
       s.FIRST_LOAD_TIME,
       s.DISK_READS,
       s.BUFFER_GETS,
       s.PARSE_CALLS
  from v$sql s
where s.disk_reads > 300
order by disk_reads desc)
where rownum<=10;

prompt <p>ִ�д������
select *
  from (select sql_id,
               sql_text,
               s.EXECUTIONS,
               s.LAST_LOAD_TIME,
               s.FIRST_LOAD_TIME,
               s.DISK_READS,
               s.BUFFER_GETS,
               s.PARSE_CALLS
          from v$sql s
         order by s.EXECUTIONS desc)
where rownum <= 10;

prompt <p>�����������
select *
  from (select sql_id,
               sql_text,
               s.EXECUTIONS,
               s.LAST_LOAD_TIME,
               s.FIRST_LOAD_TIME,
               s.DISK_READS,
               s.BUFFER_GETS,
               s.PARSE_CALLS
          from v$sql s
         order by s.PARSE_CALLS desc)
where rownum <= 10;

prompt <p>��DISK SORT���ص�SQL
select sess.username, sql.sql_text, sql.address, sort1.blocks
  from v$session sess, v$sqlarea sql, v$sort_usage sort1
where sess.serial# = sort1.session_num
   and sort1.sqladdr = sql.address
   and sort1.sqlhash = sql.hash_value
   and sort1.blocks > 200
order by sort1.blocks desc;

prompt <p>��ѯ�����ڴ�ռ����
select count(*),round(sum(sharable_mem)/1024/1024,2) from  v$db_object_cache  a;


prompt <p>��־�л�Ƶ�ʷ���(ע��۲������first_time֮���ʱ�����᲻��̣ܶ��ܶ̾����л���Ƶ����
select *
  from (select thread#, sequence#, to_char(first_time, 'MM/DD/RR HH24:MI:SS')
          from v$log_history
         order by first_time desc)
 where rownum <= 50;

prompt <p>���10����ÿ����־�л�����(���ɷ���10��Ĳ��ȣ��ֿɷ���24Сʱ�ڣ��ɺ����׿����쳣���)
SELECT SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) Day,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22 , 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23, 
       COUNT(*) TOTAL 
FROM v$log_history  a  
   where first_time>=to_char(sysdate-11)
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) 
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) DESC;



prompt <p>��־���С
select group#,bytes,status from v$log;

prompt <p>�鿴ARCHIVELOG��־ʹ���ʣ������۲�DB_RECOVERY_FILE_DEST_SIZ�������������Կ���crosscheck archivelog all; delete expired archivelog all;��
 select substr(name, 1, 30) name,
        space_limit as quota,
        space_used as used,
        space_reclaimable as reclaimable,
        number_of_files as files
   from v$recovery_file_dest;
select * from V$FLASH_RECOVERY_AREA_USAGE;

prompt <p>�ύ��������SESSION
select t1.sid, t1.value, t2.name
   from v$sesstat t1, v$statname t2
  where t2.name like '%user commits%'
    and t1.STATISTIC# = t2.STATISTIC#
    and value >= 10000
  order by value desc;
  

   

prompt <p>��˭ռ����undo��ռ�
SELECT r.name �ع�����, rssize/1024/1024/1024 "RSSize(G)",
  s.sid,
  s.serial#,
  s.username �û���,
  s.status,
  s.sql_hash_value,
  s.SQL_ADDRESS,
  s.MACHINE,
  s.MODULE,
  substr(s.program, 1, 78) ��������,
  r.usn,
  hwmsize/1024/1024/1024,shrinks ,xacts
FROM sys.v_$session s,sys.v_$transaction t,sys.v_$rollname r, v$rollstat rs
WHERE t.addr = s.taddr and t.xidusn = r.usn and r.usn=rs.USN
Order by rssize desc;

prompt <p>��˭ռ����temp��ռ�
select sql.sql_id,
       t.Blocks * 16 / 1024 / 1024,
       s.USERNAME,
       s.SCHEMANAME,
       t.tablespace,
       t.segtype,
       t.extents,
       s.PROGRAM,
       s.OSUSER,
       s.TERMINAL,
       s.sid,
       s.SERIAL#,
       sql.sql_text
  from v$sort_usage t, v$session s , v$sql sql
where t.SESSION_ADDR = s.SADDR and t.SQLADDR=sql.ADDRESS and t.SQLHASH=sql.HASH_VALUE;

prompt <p>�۲�ع��Σ���ʱ�μ���ͨ�η����Զ���չ
select t.file_name, 
       t.tablespace_name, 
       t.bytes, 
       t.autoextensible, 
       t.online_status
  from dba_data_files t
where tablespace_name like '%UNDO%';
select t.file_name, 
       t.bytes, 
       t.status, 
       t.autoextensible
  from dba_temp_files t;
select t.file_name, 
       t.tablespace_name, 
       t.status,
       t.bytes, 
       t.autoextensible
  from dba_data_files t ; 


 
 
prompt <p>�ȵ��(���ܣ�

SELECT /*+ rule */
         e.owner, e.segment_name, e.segment_type, sum(b.tch) tch
          FROM dba_extents e,
               (SELECT *
                  FROM (SELECT addr, ts#, file#, dbarfil, dbablk, tch
                          FROM x$bh
                         ORDER BY tch DESC)
                 WHERE ROWNUM <= 10) b
         WHERE e.relative_fno = b.dbarfil
           AND e.block_id <= b.dbablk
           AND e.block_id + e.blocks > b.dbablk
		   group by e.owner, e.segment_name, e.segment_type
order by tch desc;

prompt <p>�ȵ��(չ����δ���ܣ�
SELECT /*+ rule */
        distinct e.owner, e.segment_name, e.segment_type, dbablk,b.tch
          FROM dba_extents e,
               (SELECT *
                  FROM (SELECT addr, ts#, file#, dbarfil, dbablk, tch
                          FROM x$bh
                         ORDER BY tch DESC)
                 WHERE ROWNUM <= 10) b
         WHERE e.relative_fno = b.dbarfil
           AND e.block_id <= b.dbablk
           AND e.block_id + e.blocks > b.dbablk
order by tch desc;











