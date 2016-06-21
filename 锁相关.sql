--1.检查锁情况:
SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid sess,type,id1,id2,lmode,request,ctime,block
FROM v$lock
WHERE (id1, id2, type) IN
(SELECT id1, id2, type FROM v$lock WHERE request >0) ORDER BY ctime desc,id1, request;


SELECT DECODE(a.request,0,'Holder: ','Waiter: ')||a.sid sess,a.type,a.id1,a.id2,a.lmode,a.request,a.ctime
FROM v$lock a,v$lock b
where a.id1=b.ID1
and  a.ID2=b.ID2
and b.REQUEST > 0;

select l.ctime,s.status, s.username,s.sid,s.serial#,p.SPID,s.EVENT,l.lmode,l.type,o.owner,o.object_name,o.object_type,
s.terminal,s.machine,s.program, s.osuser,l.request,l.block,
decode(l.type, 'TM', 'table lock', 'TX' , 'row lock', null) lock_level
from v$session s, v$lock l, dba_objects o,v$process p
where l.sid = s.sid and l.id1 = o.object_id(+) -- and  s.status in ('INACTIVE' ,'KILLED')
and l.TYPE in ('TX', 'TM')AND s.PADDR=p.ADDR
order by 1;

SELECT A.INST_ID  INSTANCE_ID,
       A.TYPE     LOCKED_MODE,
       A.SID      SESSION_ID,
       B.USERNAME ORACLE_USERNAME,
       B.MACHINE  OS_USER_NAME,
       B.PROGRAM  PROCESS,
       A.CTIME    CTIME
  FROM gv$LOCK A, gv$SESSION B
 WHERE A.SID = B.SID
   AND A.TYPE IN ('TX', 'DX')
  AND A.INST_ID = B.INST_ID
   AND (A.BLOCK = '1' OR A.CTIME > 10)
ORDER BY a.CTIME DESC;

select distinct 'kill -9 ' || a.spid,c.MACHINE, b.sid, b.type, b.lmode, b.block, b.ctime
  from v$process a, v$lock b, v$session c
 where a.addr = c.paddr
   and b.sid = c.sid
   and c.SID=5945
   and b.type in ('TX', 'TM')
 order by b.ctime desc;
 
select a.STATUS,a.sid,a.blocking_session,a.last_call_et,a.event,
object_name,
dbms_rowid.rowid_create( 1,data_object_id,rfile#,ROW_WAIT_BLOCK#,ROW_WAIT_ROW#) "rowid" ,
c.sql_text,c.sql_fulltext
from v$session a,v$sqlarea c ,dba_objects,v$datafile
where a.blocking_session is not null
and a.sql_hash_value = c.hash_value
and ROW_WAIT_OBJ#=object_id and file#=ROW_WAIT_FILE#;

--看看谁锁了谁：
select s1.username || '@' || s1.machine
  || ' ( SID=' || s1.sid || ' ) ('||s1.STATUS||')  is blocking '
  || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
  from v$lock l1, v$session s1, v$lock l2, v$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid
  and l1.BLOCK= 1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2 ;

--查看被锁对象：
SELECT a.owner,a.object_name,a.object_type
FROM dba_objects a ,v$locked_object b
WHERE a.object_id=b.OBJECT_ID
and a.OWNER like 'U%';

SELECT a.owner,a.object_name,a.object_type,b.SESSION_ID,c.STATUS,
 'alter system kill session   '''||c.SID||','||c.SERIAL#||'''  immediate;'
FROM dba_objects a ,v$locked_object b,v$session c
WHERE a.object_id=b.OBJECT_ID
and b.SESSION_ID=c.SID
and a.OWNER like 'U%'
and a.object_name in

SELECT b.INST_ID,a.owner,a.object_name,a.object_type,b.SESSION_ID,c.STATUS,
 'alter system kill session   '''||c.SID||','||c.SERIAL#||'''  immediate;'
FROM dba_objects a ,gv$locked_object b,gv$session c
WHERE 1=1
and b.INST_ID=c.INST_ID
and a.object_id=b.OBJECT_ID
and b.SESSION_ID=c.SID
and a.OWNER like 'U%'


--锁的语句：
select sql_text from v$sql where hash_value in
    ( select sql_hash_value from v$session where sid in (select session_id from v$locked_object));

--锁的进程：
SELECT s.username,l.OBJECT_ID,l.SESSION_ID,s.SERIAL#, l.ORACLE_USERNAME,
     l.OS_USER_NAME,l.PROCESS FROM V$LOCKED_OBJECT l,V$SESSION S
     WHERE l.SESSION_ID=S.SID;

--查找锁住其他表的语句
SELECT /*+ rule */ b.sid,b.username,b.program,a.piece,a.sql_text
  FROM v$sqltext a,v$session b,v$lock c 
 WHERE c.block=1
   and c.sid=b.sid
   and b.sql_hash_value=a.hash_value
  group by b.sid,b.username,b.program,a.piece,a.sql_text
  
--根据SID找SQL
SELECT /*+ rule */ b.sid,b.username,b.program,a.hash_value,a.piece,a.sql_text
  FROM v$sqltext a,v$session b
 WHERE b.sid=&X
   and b.sql_hash_value=a.hash_value
  order by  a.piece;
  
  
select 'Holder:'||a.BLOCKING_SESSION||' and Waiter:'||a.SID
from v$session a
where a.STATE='WAITING'
 AND A.WAIT_CLASS <> 'Idle';  
 
select distinct a.INST_ID,a.SID,a.SERIAL#,a.MACHINE, a.osuser,a.USERNAME,a.EVENT,b.SQL_TEXT,b.SQL_ID,a.blocking_session,a.PROGRAM
from gv$session a,gv$sql b
where a.STATUS='ACTIVE'
and a.SQL_ID=b.SQL_ID
and a.USERNAME  like 'U%'
and a.USERNAME not  like 'UBAK'
and a.EVENT not like '%SQL*Net message%'
order by a.inst_id,a.EVENT;
 
--cursor: pin S wait on X
select p2raw,to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX') sid 
     from v$session 
     where event = 'cursor: pin S wait on X';  

select p1, p2raw, count(*) from v$session 
     where event ='cursor: pin S wait on X'
     and wait_time = 0 
     group by p1, p2raw;	 


锁类型：

'MR', 'Media Recovery', 
'RT', 'Redo Thread', 
'UN', 'User Name', 
'TX', 'Transaction', 
'TM', 'DML', 
'UL', 'PL/SQL User Lock', 
'DX', 'Distributed Xaction', 
'CF', 'Control File', 
'IS', 'Instance State', 
'FS', 'File Set', 
'IR', 'Instance Recovery', 
'ST', 'Disk Space Transaction', 
'TS', 'Temp Segment', 
'IV', 'Library Cache Invalidation', 
'LS', 'Log Start or Switch', 
'RW', 'Row Wait', 
'SQ', 'Sequence Number', 
'TE', 'Extend Table', 
'TT', 'Temp Table', 
'TC', 'Thread Checkpoint', 
'SS', 'Sort Segment', 
'JQ', 'Job Queue', 
'PI', 'Parallel operation', 
'PS', 'Parallel operation', 
'DL', 'Direct Index Creation', 

lmode:
0, 'None',            
1, 'Null',            
2, 'Row-S (SS)',      
3, 'Row-X (SX)',      
4, 'Share',           
5, 'S/Row-X (SSX)',   
6, 'Exclusive',       
