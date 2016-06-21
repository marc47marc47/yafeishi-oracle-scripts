--根据等待事件查询语句
SELECT /*+ rule */ b.sid,b.username,b.program,a.hash_value,a.piece,a.sql_text
  FROM v$sqltext a,v$session b,v$session_wait c
 WHERE b.sid=c.sid
   and b.sql_hash_value=a.hash_value
   and c.event='log file sync'
  group by b.sid,b.username,b.program,a.hash_value,a.piece,a.sql_text

--等待事件
select event,
       sum(decode(wait_Time, 0, 0, 1)) "Prev",
       sum(decode(wait_Time, 0, 1, 0)) "Curr",
       count(*) "Tot"
  from v$session_Wait
 where event not in ('SQL*Net message from client', 'rdbms ipc message',
        'SQL*Net message to client')
 group by event
 order by 4 desc;

select a.sid,b.program,a.event,a.p1text,a.p1,a.p2text,a.p2,a.p3text,a.p3,a.wait_time,a.seconds_in_wait,a.state
 from v$session_wait a,v$session b
where a.sid=b.sid
  and a.event not in (select name from v$event_name where wait_class='Idle')
  --and a.event!='pipe get'
  --and a.event!='pmon timer'
  --and a.event!='PX Idle Wait'
  --and a.event!='PX Deq Credit: need buffer'
  --and a.event!='rdbms ipc message'
  --and a.event!='smon timer'
  --and a.event!='SQL*Net message from client'
  order by 2;

SELECT EVENT, N.WAIT_CLASS,
      TIME_WAITED_MICRO,ROUND(TIME_WAITED_MICRO*100/S.DBTIME,1) PCT_DB_TIME
  FROM V$SYSTEM_EVENT E, V$EVENT_NAME N,
    (SELECT VALUE DBTIME FROM V$SYS_TIME_MODEL WHERE STAT_NAME = 'DB time') S
   WHERE E.EVENT_ID = N.EVENT_ID
    AND N.WAIT_CLASS NOT IN ('Idle', 'System I/O')
  ORDER BY PCT_DB_TIME desc;
  
####################### latch :cache buffers chains
--determining the ADDR with  the highest sleep count.
select CHILD#  "cCHILD"
     ,      ADDR    "sADDR"
     ,      GETS    "sGETS"
     ,      MISSES  "sMISSES"
     ,      SLEEPS  "sSLEEPS" 
     from v$latch_children 
     where name = 'cache buffers chains'
     order by 5, 1, 2, 3;  

-- find segment_name	 
column segment_name format a35
     select /*+ RULE */
       e.owner ||'.'|| e.segment_name  segment_name,
       e.extent_id  extent#,
       x.dbablk - e.block_id + 1  block#,
       x.tch,
       l.child#
     from
       sys.v$latch_children  l,
       sys.x$bh  x,
       sys.dba_extents  e
     where
       x.hladdr  = '&ADDR' and
       e.file_id = x.file# and
       x.hladdr = l.addr and
       x.dbablk between e.block_id and e.block_id + e.blocks -1
     order by x.tch desc ;	 
	 
--The following query joins with DBA_OBJECTS to find the objects waiting, the misses, sleeps, etc:

SQL> with bh_lc as
(select /*+ ORDERED */
lc.addr, lc.child#, lc.gets, lc.misses, lc.immediate_gets,
lc.immediate_misses, lc.spin_gets, lc.sleeps,
bh.hladdr, bh.tch tch, bh.file#, bh.dbablk, bh.class,
bh.state, bh.obj
from
x$kslld ld,
v$session_wait sw,
v$latch_children lc,
x$bh bh
where lc.addr =sw.p1raw
and sw.p2= ld.indx
and ld.kslldnam='cache buffers chains'
and lower(sw.event) like '%latch%'
and sw.state='WAITING'
and bh.hladdr=lc.addr
)
select bh_lc.hladdr, bh_lc.tch, o.owner, o.object_name, o.object_type,
bh_lc.child#, bh_lc.gets,
bh_lc.misses, bh_lc.immediate_gets,
bh_lc.immediate_misses, spin_gets, sleeps
from
bh_lc,
dba_objects o
where bh_lc.obj = o.object_id(+)
union
select bh_lc.hladdr, bh_lc.tch, o.owner, o.object_name, o.object_type,
bh_lc.child#, bh_lc.gets, bh_lc.misses, bh_lc.immediate_gets,
bh_lc.immediate_misses, spin_gets, sleeps
from
bh_lc,
dba_objects o
where bh_lc.obj = o.data_object_id(+)
order by 1,2 desc;	 
