1.检查锁情况:
SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid sess,type,id1,id2,lmode,request,ctime,block 
FROM v$lock 
WHERE (id1, id2, type) IN 
(SELECT id1, id2, type FROM v$lock WHERE request >0) ORDER BY ctime desc,id1, request;

select l.ctime,s.status, s.username,s.sid,s.serial#,l.lmode,l.type,o.owner,o.object_name,o.object_type,
s.terminal,s.machine,s.program, s.osuser,l.request,l.block,
decode(l.type, 'TM', 'table lock', 'TX', 'row lock', null) lock_level
from v$session s, v$lock l, dba_objects o
where l.sid = s.sid and l.id1 = o.object_id(+)  and  s.status in ('INACTIVE' ,'KILLED')
and l.TYPE in ('TX','TM');

SELECT A.INST_ID  OBJECT_NAME,
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
   AND (A.BLOCK = '1' OR A.CTIME > 10);

select 'kill -9 ' || a.spid, b.sid, b.type, b.lmode, b.block, b.ctime
  from v$process a, v$lock b, v$session c
 where a.addr = c.paddr
   and b.sid = c.sid
   and b.type in ('TX', 'TM')
 order by b.ctime desc;
 


--长时间执行的语句
select a.SID,c.USERNAME,a.OPNAME,a.TARGET,a.START_TIME,a.LAST_UPDATE_TIME,a.ELAPSED_SECONDS ,b.SQL_TEXT,b.SQL_FULLTEXT
from v$session_longops a,v$sqlarea b ,v$session c
where a.sid=c.SID
and a.SQL_HASH_VALUE=b.HASH_VALUE
order by a.ELAPSED_SECONDS desc;

SELECT A.ADDR,A.XIDUSN,B.NAME,TO_DATE(A.START_TIME,'MM/DD/YY HH24:MI:SS'),A.START_UEXT,A.USED_UBLK,A.USED_UREC
FROM  V$TRANSACTION A,V$ROLLNAME B
WHERE (SYSDATE - TO_DATE(A.START_TIME,'MM/DD/YY HH24:MI:SS') ) > ( 0.0001/(24*60))
AND A.XIDUSN = B.USN
order by 6;
 
select SQL_ADDRESS,SQL_HASH_VALUE,TADDR,SID ,SERIAL# ,PADDR ,USERNAME,STATUS ,STATUS,LOGON_TIME,
       SCHEMANAME,OSUSER,PROCESS,MACHINE,TERMINAL,PROGRAM,MODULE
from   v$session    
where taddr In (     
SELECT A.ADDR
FROM  V$TRANSACTION A 
WHERE (SYSDATE - TO_DATE(A.START_TIME,'MM/DD/YY HH24:MI:SS') ) > ( 10.0/(24*60)))
ORDER BY SQL_ADDRESS,SQL_HASH_VALUE;



--杀掉锁表的进程
select * from v$locked_object ;

alter system kill session '2124,65133';

select * from v$session where sid  ='2124';

--查询是不是分区表的索引是否为分区索引
select  * from dba_indexes where (owner,table_name) in (
select owner,segment_name from dba_segments                                            
where owner like 'U%' and segment_type in ('TABLE PARTITION')                          
group by owner,segment_name                                                            
having count(*) >1)                                                                    
and tablespace_name is not null;  

--根据SESSION号查主机进程 
select * from v$process where addr in (select paddr from v$session where sid =3882);            

--表锁
select B.SID, C.EVENT, C.USERNAME, C.OSUSER, C.TERMINAL,
       DECODE(B.ID2, 0, A.OBJECT_NAME, 'Trans-'||to_char(B.ID1)) OBJECT_NAME,
       B.TYPE,B.BLOCK,
       DECODE(B.LMODE,0,'--Waiting--',
                      1,'Null',
                      2,'Row Share',
                      3,'Row Excl',
                      4,'Share',
                      5,'Sha Row Exc',
                      6,'Exclusive',
                      'Other') "Lock Mode",
       DECODE(B.REQUEST,0,'',
                      1,'Null',
                      2,'Row Share',
                      3,'Row Excl',
                      4,'Share',
                      5,'Sha Row Exc',
                      6,'Exclusive',
                     'Other') "Req Mode"
  from DBA_OBJECTS A, V$LOCK B, V$SESSION C 
where A.OBJECT_ID(+) = B.ID1
  and B.SID = C.SID
  and C.USERNAME is not null
order by B.SID, B.ID2


--查锁
select b.owner,b.object_name,l.session_id,l.locked_mode 
from v$locked_object l, dba_objects b 
where b.object_id=l.object_id 


SELECT s.username, s.sid,
       DECODE (
          l.TYPE,
          'MR', 'Media Recovery',
          'RT', 'Redo Thread',
          'UN', 'User Name',
          'TX', 'Transaction',
          'TM', 'DML',
          'UL', 'PL/SQL User Lock',
          'DX', 'Distributed Xaction',
          'CF', 'Control File',
          'IS', 'Instance State',
          'DS', 'File Set',
          'IR', 'Instance Recovery',
          'ST', 'Disk Space Transaction',
          'TS', 'Temp Segment',
          'IV', 'Library Cache Invalidation',
          'LS', 'Log Start or Switch',
          'RW', 'Row Wait',
          'SQ', 'Sequence Number',
          'TE', 'Extend Table',
          'TT', 'Temp Table'
       ) ltype,
       o.object_name,
       DECODE (
          l.lmode,
          2, 'Row-S(SS)',
          3, 'Row-X(SX)',
          4, 'Share',
          5, 'S/Row-X(SSX)',
          6, 'Exclusive',
          'Other'
       ) mode_held
  FROM dba_objects o, v$session s, v$lock l
WHERE s.sid = l.sid AND o.object_id = l.id1
  and l.type !='MR'


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

--根据OS进程号查找SQL  
select a.sid,c.spid,a.status,a.program,b.sql_text
  from v$session a,v$sqlarea b,v$process c
 where a.sql_hash_value=b.hash_value
   and a.paddr=c.addr
   and c.spid in(
'1482886'
)

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

2.查找活动事务
SELECT  r.name 回滚段名,
  r.usn,
	s.sid,
	s.serial#,
	s.username 用户名,
	s.logon_time,
	s.status session_status,
	t.status,
	t.cr_get,
	t.phy_io,
	t.used_ublk,
	t.noundo,
	substr(s.program, 1, 78) 操作程序
FROM   sys.v_$session s,sys.v_$transaction t,sys.v_$rollname r
WHERE  t.addr = s.taddr and t.xidusn = r.usn  
ORDER  BY t.cr_get,t.phy_io

SELECT r.status "Status",
r.segment_name "Name",
r.tablespace_name "Tablespace",
s.extents "Extents",
TO_CHAR((s.bytes/1024/1024),'99999990.000') "Size"
FROM sys.dba_rollback_segs r, sys.dba_segments s
WHERE r.segment_name = s.segment_name
AND s.segment_type IN ('ROLLBACK', 'TYPE2 UNDO')
ORDER BY 5 DESC;

SELECT r.NAME 回滚段名,s.sid SID,s.serial# Serial,
       s.username,s.machine,
       t.start_time,t.status,
       t.used_ublk,t.USED_UREC,
       t.cr_get,t.cr_change,
       t.log_io,t.phy_io,
       t.noundo NoUndo,g.extents Extents,substr(s.program, 1, 50) 操作程序
   FROM v$session s, v$transaction t, v$rollname r,v$rollstat g
  WHERE t.addr = s.taddr
    AND t.xidusn = r.usn
    AND r.usn = g.usn
 ORDER BY t.used_ublk desc;

 
3.表空间使用情况
select b.tablespace_name              "表空间名",
       round(b.all_byte)              "总空间(M)",
       round(b.all_byte-a.free_byte)  "已使用(M)",
       round(a.free_byte)             "剩余空间",
       round((a.free_byte/b.all_byte)*100)  "剩余百分比" 
  from (select tablespace_name,sum(nvl(bytes,0))/1024/1024 free_byte from dba_free_space group by tablespace_name) a,
       (select tablespace_name,sum(nvl(bytes,0))/1024/1024 all_byte from dba_data_files group by tablespace_name) b
 where b.tablespace_name = a.tablespace_name(+)
 and b.tablespace_name='TBS_CUS_IUSR1'
 order by 5;
 
 
61.增加表空间（裸设备）
CREATE TABLESPACE TBS_ACT_DEF
DATAFILE
  '/dev/actvg1/ractvg1_8_01'      SIZE 8191M AUTOEXTEND OFF,
  '/dev/actvg2/ractvg2_8_01'      SIZE 8191M AUTOEXTEND OFF
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO
/
alter tablespace TBS_CUS_IUSR1 add datafile '/dev/cusvg1/rcusvg1_8_011' size 8191M AUTOEXTEND OFF;
alter tablespace TBS_STA_COMMUNITY add datafile '/dev/rvgsta5_4_45' size 4095M AUTOEXTEND OFF;
alter tablespace TBS_STA_COMMUNITY add datafile '/dev/rvgsta5_4_47' size 4095M AUTOEXTEND OFF;
alter tablespace TBS_STA_COMMUNITY add datafile '/dev/rvgsta5_4_48' size 4095M AUTOEXTEND OFF;
alter tablespace TBS_STA_COMMUNITY add datafile '/dev/rvgsta5_4_52' size 4095M AUTOEXTEND OFF;
 
 select a.file_name,
    a.file_id,
    a.tablespace_name,
    a.bytes allocated,
    nvl(b.free,0) free,
    a.bytes-nvl(b.free,0) used
from dba_data_files a,
   ( select file_id, sum(bytes) free
       from dba_free_space
       group by file_id ) b
where a.file_id = b.file_id (+) 

--temp tablespace
select sum(bytes_cached)/1024/1024 "总空间",sum(bytes_used)/1024/1024 "已使用空间"
  from v$temp_extent_pool
 
4.监控事例的等待 

select event,sum(decode(wait_Time,0,0,1)) "Prev", 
sum(decode(wait_Time,0,1,0)) "Curr",count(*) "Tot" 
from v$session_Wait 
group by event order by 4;

3.回滚段的争用情况
select name, waits, gets, waits/gets "Ratio" 
from v$rollstat a, v$rollname b 
where a.usn = b.usn; 

4.查看temporary tablespace的使用情况
select * from v$sort_segment

5.监控表空间的 I/O 比例

select df.tablespace_name name,df.file_name "file",f.phyrds pyr,
f.phyblkrd pbr,f.phywrts pyw, f.phyblkwrt pbw
from v$filestat f, dba_data_files df
where f.file# = df.file_id
order by df.tablespace_name;

5. 监控文件系统的 I/O 比例(I/O请求)

select substr(a.file#,1,2) "#", substr(a.name,1,30) "Name", 
a.status, a.bytes, b.phyrds, b.phywrts 
from v$datafile a, v$filestat b 
where a.file# = b.file#; 

(I/O读的数据库块数量)

select substr(a.file#,1,2) "#", substr(a.name,1,30) "Name", 
a.status, a.bytes, b.PHYBLKRD, b.PHYBLKWRT 
from v$datafile a, v$filestat b 
where a.file# = b.file#; 

6.监控 SGA 的命中率

select a.value + b.value "logical_reads", c.value "phys_reads",
round(100 * ((a.value+b.value)-c.value) / (a.value+b.value)) "BUFFER HIT RATIO" 
--from v$sysstat a, v$sysstat b, v$sysstat c
--where a.statistic# = 40 and b.statistic# = 41 
--and c.statistic# = 42; 
from
(select s.value from v$statname n,v$sysstat s where n.statistic#=s.statistic# and n.name='db block gets cache') a,
(select s.value from v$statname n,v$sysstat s where n.statistic#=s.statistic# and n.name='consistent gets cache') b,
(select s.value from v$statname n,v$sysstat s where n.statistic#=s.statistic# and n.name='physical reads cache') c;
SELECT NAME, PHYSICAL_READS, DB_BLOCK_GETS, CONSISTENT_GETS,              
      1 - (PHYSICAL_READS / (DB_BLOCK_GETS + CONSISTENT_GETS)) "Hit Ratio"
  FROM V$BUFFER_POOL_STATISTICS;                                          
select a.name, b.value
 from v$statname a, v$sysstat b
 where a.statistic# = b.statistic#
 and a.name like '%ga memory%' and sid=&1; 

7.监控 SGA 中字典缓冲区的命中率

select parameter, gets,Getmisses , getmisses/(gets+getmisses)*100 "miss ratio",
(1-(sum(getmisses)/ (sum(gets)+sum(getmisses))))*100 "Hit ratio"
from v$rowcache 
where gets+getmisses <>0
group by parameter, gets, getmisses; 

8.根据文件号和block号查找数据库对象
select owner, segment_name, partition_name, segment_type,tablespace_name 
  from dba_extents 
 where file_id=237 
   and block_id <=73445 
   and block_id+blocks>=73445+1;
   
select owner,segment_name,segment_type,tablespace_name from dba_extents where file_id=152
and 239210 between block_id and block_id + blocks -1;

9.非共享性语句

create or replace function remove_constants ( p_query in varchar2 ) 
return varchar2 
as 
l_query long; 
l_char varchar2(8); 
l_in_quotes boolean default FALSE; 
begin 
for i in 1 .. length(p_query) 
loop 
l_char:=substr(p_query,i,1); 
if (l_char='''' and l_in_quotes) 
then 
l_in_quotes:=FALSE; 
elsif (l_char='''' and not l_in_quotes) 
then 
l_in_quotes:=true; 
l_query:=l_query||'''#'; 
end if; 
if (not l_in_quotes) then 
l_query:=l_query || l_char; 
end if; 
end loop; 
l_query:=translate (l_query,'0123456789','@@@@@@@@@@'); 
for i in 0 .. 8 
loop 
l_query:=replace (l_query,lpad('@',10-i,'@'),'@'); 
l_query:=replace (l_query,lpad('',10-i,''),''); 
end loop; 
return upper(l_query); 
end; 
create table sql_area_tmp  as select hash_value,sql_text,sql_text sql_text_two_constants from v$sqlarea where 1=0; 

insert into sql_area_tmp (hash_value,sql_text) select hash_value,sql_text from v$sqlarea; 

update sql_area_tmp set sql_text_two_constants = substr(remove_constants(sql_text),1,1000); 

select sql_text_two_constants "非共享语句",min_hash_value "最小hash_value",a "总条数",
      sharable_mem "每条语句占用内存",trunc(a*sharable_mem/1024/1024) "合计消耗内存M"
 from (select hash_value,sharable_mem from v$sqlarea) a,
     (select sql_text_two_constants,min(hash_value) min_hash_value,count(*) a from sql_area_tmp 
          group by sql_text_two_constants having count(*) >10 ) b
 where hash_value=min_hash_value
   order by 3 desc


10.查找IO占用较多的语句
SELECT b.module,a.sql_text,round(b.disk_reads*8/1024/1024) "disk_read(G)", b.executions,round((b.disk_reads/b.executions)*8/1024) "Reads/Exec(M)",first_load_time,b.hash_value     
   FROM v$sqltext a,v$sqlarea b
 where a.hash_value = b.hash_value
   and b.executions>10
   and b.disk_reads/b.executions > 500    
   ORDER BY b.disk_reads desc ,a.piece;
   
SELECT b.module,a.sql_text,round(b.buffer_gets*8/1024/1024) "buffer_gets(G)", b.executions,round((b.buffer_gets/b.executions)*8/1024) "Reads/Exec(M)",first_load_time,b.hash_value     
   FROM v$sqltext a,v$sqlarea b
 where a.hash_value = b.hash_value
   and buffer_gets > 5000 
   AND EXECUTIONS>10
   ORDER BY b.disk_reads desc ,a.piece;


11.查找前台发出的语句
select user_name,sql_text
　　 from v$open_cursor
　　 where sid in (select sid from (select sid,serial#,username,program
　　 from v$session
　　 where status='ACTIVE'));

12.每次执行产生的物理I/O操作超过1000块或逻辑I/O操作超过10000块这种很大的数字。

select HASH_VALUE,sql_text,  EXECUTIONS, BUFFER_GETS, DISK_READS, BUFFER_GETS/EXECUTIONS buffer_per_exec,DISK_READS/EXECUTIONS disk_per_exec, VERSION_COUNT, LOADED_VERSIONS, OPEN_VERSIONS, USERS_OPENING
from v$sqlarea
where EXECUTIONS > 200
and (BUFFER_GETS/EXECUTIONS > 10000 or disk_reads/EXECUTIONS > 1000) 
order by buffer_per_exec,disk_per_exec  desc;

13.查找被锁对象
select a.object_name,a.object_id,b.sid,b.serial#,b.terminal,b.command,
           b.program,b.module,b.process,d.*,c.*
      from all_objects a,v$session b,v$LOCKED_OBJECT c,v$session_wait d
     where a.object_id=c.object_id and b.sid=c.SESSION_ID and b.sid=d.sid;
     
14.查询temp表空间当前使用情况
select b.sid,b.username,b.program,a.extents 
  from v$sort_usage a,v$session b 
 where a.session_addr=b.saddr;

15.收缩temp表空间
alter tablespace temp storage(maxextents unlimited);

16.用dbv检测数据文件是否有坏块,例如
dbv file='/dev/rjslvol8_133' blocksize=8192

17.根据PID查找session信息
select a.spid,b.*
  from v$process a,v$session b
 where a.addr=b.paddr
   and b.spid in
   (
   
   )
    
18.查出挂起事务的程序名和执行的SQL，即dba_2pc_penging中有挂起事务： 
    
select e.sql_text,d.program,d.sid,d.username
  from v$transaction c, v$session d, v$sqlarea e 
 where d.taddr = c.addr 
   and e.address = d.prev_sql_addr 
   and c.xidusn = 54
   and c.xidslot =56 
   and c.xidsqn = 2415476
其中c.xidusn、xidslot和xidsqn为local_trancs_id组成
 
19.dump内存
 ALTER SESSION SET EVENTS 'immediate trace name LIBRARY_CACHE level 4';

20.由cache buffers chains查找哪些segments:
  方法一(效率高)：
select object_name 
  from dba_objects 
 where data_object_id in
      (select obj 
         from x$bh 
        where hladdr in
           (select addr 
              from (select addr 
                      from v$latch_children 
                     where latch#=98
                    order by sleeps desc) 
            where rownum < 11)) ;
  方法二：
select distinct a.owner,a.segment_name 
  from dba_extents a,
      (select dbarfil,dbablk 
         from x$bh 
        where hladdr in
              (select addr 
                 from (select addr 
                         from v$latch_children
                        where latch#=98
                       order by sleeps desc) 
               where rownum < 11)) b
where a.RELATIVE_FNO = b.dbarfil
  and a.BLOCK_ID <= b.dbablk 
  and a.block_id + a.blocks > b.dbablk;
  
21.查找导致热点块的sql语句
select sql_text 
from v$sqltext a,
(select distinct a.owner,a.segment_name,a.segment_type from 
dba_extents )a,
(select dbarfil,dbablk 
from (select dbarfil,dbablk 
    from x$bh order by tch desc) where rownum < 11) b
where a.RELATIVE_FNO = b.dbarfil
and a.BLOCK_ID <= b.dbablk and a.block_id + a.blocks > b.dbablk) b
where a.sql_text like '%'||b.segment_name||'%' and b.segment_type = 'TABLE'
order by  a.hash_value,a.piece;

select sql_text 
  from v$sqltext a,
   (select object_name,object_type 
      from dba_objects 
     where data_object_id in
           (select obj 
              from x$bh 
             where hladdr in
                  (select addr 
                     from (select addr 
                             from v$latch_children 
                            where latch#=66
                            order by sleeps desc) 
                    where rownum < 11)
            )
    ) b
where a.sql_text like '%'||b.object_name||'%' 
  and b.object_type = 'TABLE'
order by  a.hash_value,a.piece;

22.查询长时间运行事件
select sid,OPNAME,target,start_time,last_update_time,sofar,totalwork,
       time_remaining,elapsed_seconds
 from v$session_longops
where  time_remaining>0  

22.查询长时间未提交的事件(10分钟)
select SQL_ADDRESS,SQL_HASH_VALUE,TADDR,SID ,SERIAL# ,PADDR ,USERNAME,STATUS ,STATUS,LOGON_TIME,
       SCHEMANAME,OSUSER,PROCESS,MACHINE,TERMINAL,PROGRAM,MODULE
from   v$session    
where taddr In (     
SELECT A.ADDR
FROM  V$TRANSACTION A 
WHERE (SYSDATE - TO_DATE(A.START_TIME,'MM/DD/YY HH24:MI:SS') ) > ( 10.0/(24*60)))
ORDER BY SQL_ADDRESS,SQL_HASH_VALUE;
   
23.检查索引无效
select * from dba_indexes where status='UNUSABLE'  
   
   
24.查询share_pool的ora-4031问题：
SELECT free_space, avg_free_size,used_space, avg_used_size, request_failures,
       last_failure_size
  FROM v$shared_pool_reserved;
  
25.如何确定语句多version_count原因
select * 
  from v$sqlarea a,v$sql_shared_cursor b
 where a.address=b.kglhdpar 

26.rebuild index语句
select 'alter index '||owner||'.'||segment_name||' rebuild partition '||partition_name||' online;',bytes/1024/1024 a
 from dba_segments
 where tablespace_name='TBS_OSS_HI301'
  and segment_type='INDEX PARTITION'
  order by a 

27.kill session后，session的status标记为killed，但session没有release，根据SID关联v$session
   和v$process无法找到SPID的处理方法：
SVRMGRL>  SELECT spid                  
            FROM v$process                  
           WHERE NOT EXISTS ( SELECT 1                                     
                                FROM v$session                                     
                               WHERE paddr = addr);  
然后kill OS进程：                                      
% kill <spid>       

--28.根据SID查找IP地址
--select SYS_CONTEXT('USERENV','IP_ADDRESS') from v$session where sid=841 
--select sys_context('USERENV','IP_ADDRESS') from dual;

29.使某个用户具有授其他用户对象权限的方法
grant grant any object privilege to tt;

30.查看workarea使用情况
SELECT sql_text,operation_type,policy,last_memory_used/1024/1024 memory_used,l.hash_value,
       last_execution, last_tempseg_size
  FROM v$sqltext l, v$sql_workarea a
 WHERE l.hash_value = a.hash_value
 order by memory_used desc,l.hash_value,piece;

--单个SQL操作能够使用的PGA内存按照以下原则分配：
--对于串行：global memory bound=MIN(5% * PGA_AGGREGATE_TARGET,100MB) 
--对于并行：global memory bound=30% PGA_AGGREGATE_TARGET /DOP （DOP=Degree Of Parallelism 并行度）
--从v$pgastat可以查询出global memory bound，实际上这个100M的上限是受到了另外一个隐含参数的控制,
--该参数为_pga_max_size,该参数的缺省值为200M,单进程串行操作PGA的上限不能超过该参数的1/2（SYS.x$ksppi，SYS.x$ksppcv） 

31.表分析语句
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
   
   dbms_stats.set_param('estimate percent','30');
   dbms_stats.set_param('cascade', 'TRUE');
	 dbms_stats.set_param('no_invalidate', 'FALSE');
	 DBMS_STATS.CREATE_STAT_TABLE ('hr', 'savestats');
   DBMS_STATS.GATHER_TABLE_STATS ('hr', 'employees', stattab => 'savestats');
	 DBMS_STATS.DELETE_TABLE_STATS ('hr', 'employees');
   DBMS_STATS.IMPORT_TABLE_STATS ('hr', 'employees', stattab => 'savestats');
   select * from DBA_OPTSTAT_OPERATIONS
	 select * from dba_tab_stats_history where table_name='TS_B_BILL'


32.如何获得SCN号
1.在Oracle9i中，可以使用dbms_flashback.get_system_change_number来获得 例如: 
SQL> select dbms_flashback.get_system_change_number from dual;
2.在Oracle9i之前 可以通过查询x$ktuxe获得 
--KTUXE:[K]ernel [T]ransaction [U]ndo Transa[x]tion [E]ntry (table)   
SQL> select max(ktuxescnw*power(2,32)+ktuxescnb) from x$ktuxe;

33.监视索引的使用情况
alter index cust_name_idx monitoring usage; 
查询V$OBJECT_USAGE 视图和 USAGE 字段来判断索引是否被访问过。

34.统计redo size大小
select value
  from v$mystat, v$statname
 where v$mystat.statistic# = v$statname.statistic#
   and v$statname.name = 'redo size';

35.crm数据库gtm相关的3张参数表：
td_s_work
td_s_task
td_s_route

36.计算表记录的长度
Column size including byte length = column size + (1, if column size < 250, else 3) 
Rowsize = row header (3 * UB1) + sum of column sizes including length bytes 
Space used per row (rowspace) = MAX(UB1 * 3 + UB4 + SB2, rowsize) + SB2
 其中：
  UB1、UB4、SB2都是常量，定义的大小可以从V$TYPE_SIZE视图中获得。
  注意该计算方式算出来的长度不包括ROWID（10或6个字节）。
  
37.中间件进程有异常

 当发现中间件进程有异常时，首先用topas或nmon查看嫌疑进程，找到中间件进程的进程号，然后用
    下面的SQL检查该进程刚刚执行了什么语句：
select sid,process,status,program,b.sql_text
  from v$session a,v$sqlarea b
 where a.prev_hash_value=b.hash_value
   and process in(
'552978',
'610520',
'827600',
'901232'
)

38.分布式事务挂起处理
首先查询dba_2pc_pending,找到local_tran_id，然后尝试强制回滚，回滚后dba_2pc_pending还有该记录，可以使用系统包purge掉该事务:
SQL>ROLLBACK FORCE 'local_tran_id';
SQL>alter session set "_smu_debug_mode" = 4;
SQL>execute DBMS_TRANSACTION.PURGE_LOST_DB_ENTRY('local_tran_id');
SQL>commit;


39.业务量统计
tf_bh_trade + tf_b_trade
accept_date>trunc(sysdtae)
这个是业务受理的
tf_a_paylog　里是缴费的量
recv_time>>trunc(sysdtae) 

40.工单积压查询
select subscribe_state,count(*) 
  from tf_b_trade 
 where exec_time<sysdate 
   and next_deal_tag='0' group by subscribe_state ;

--各类工单积压情况，优先级数字越大优先级越高
select b.trade_type,a.PRIORITY, count(*)
  from uop_crm2.tf_b_trade a, uop_crm2.td_s_tradetype b
 where a.trade_type_code = b.trade_type_code
   and b.eparchy_code = '0029'
   and exec_time < sysdate
   and next_deal_tag = '0'
   and subscribe_state not in ('6', 'B')
 group by b.trade_type,a.PRIORITY
 order by a.PRIORITY desc
 
41.统计数据库文件的读写性能（平均每次）
SELECT ROUND(MAX(atpr), 1) "最大读",
      ROUND(MAX(atpw), 1) "最大写",
       ROUND(MAX(atpwt), 1) "最大Buffer",
       DECODE(SUM(DECODE(atpr, 0, 0, 1)),0,0,ROUND(SUM(atpr) / SUM(DECODE(atpr, 0, 0, 1)), 1)) "平均读",
       DECODE(SUM(DECODE(atpw, 0, 0, 1)),0,0,ROUND(SUM(atpw) / SUM(DECODE(atpw, 0, 0, 1)), 1)) "平均写",
       DECODE(SUM(DECODE(atpwt, 0, 0, 1)),0,0,ROUND(SUM(atpwt) / SUM(DECODE(atpwt, 0, 0, 1)), 1)) "Buffer平均"
  FROM (SELECT e.tsname,
               e.filename,
               DECODE((e.phyrds - NVL(b.phyrds, 0)),0,0,
                      ((e.readtim - NVL(b.readtim, 0)) / (e.phyrds - NVL(b.phyrds, 0))) * 10) atpr,
               DECODE((e.phywrts - NVL(b.phywrts, 0)),0,0,
                      ((e.writetim - NVL(b.writetim, 0)) / (e.phywrts - NVL(b.phywrts, 0))) * 10) atpw,
               DECODE((e.wait_count - NVL(b.wait_count, 0)),0,0,
                      ((e.TIME - NVL(b.TIME, 0)) / (e.wait_count - NVL(b.wait_count, 0))) * 10) atpwt
          FROM perfstat.stats$filestatxs e, perfstat.stats$filestatxs b
         WHERE b.snap_id(+) = &begin_snap_id
           AND e.snap_id = &end_snap_id
           AND b.dbid(+) = e.dbid
           AND b.instance_number(+) = e.instance_number
           AND b.tsname(+) = e.tsname
           AND b.filename(+) = e.filename
           AND ((e.phyrds - NVL(b.phyrds, 0)) + (e.phywrts - NVL(b.phywrts, 0))) > 0
        UNION
        SELECT e.tsname,
               e.filename,
               DECODE((e.phyrds - NVL(b.phyrds, 0)),0,0,
                      ((e.readtim - NVL(b.readtim, 0)) / (e.phyrds - NVL(b.phyrds, 0))) * 10) atpr,
               DECODE((e.phywrts - NVL(b.phywrts, 0)),0,0,
                      ((e.writetim - NVL(b.writetim, 0)) / (e.phywrts - NVL(b.phywrts, 0))) * 10) atpw,
               DECODE((e.wait_count - NVL(b.wait_count, 0)),0,0,
                      ((e.TIME - NVL(b.TIME, 0)) / (e.wait_count - NVL(b.wait_count, 0))) * 10) atpwt
          FROM perfstat.stats$tempstatxs e, perfstat.stats$tempstatxs b
         WHERE b.snap_id(+) = &begin_snap_id
           AND e.snap_id = &end_snap_id
           AND b.dbid(+) = e.dbid
           AND b.instance_number(+) = e.instance_number
           AND b.tsname(+) = e.tsname
           AND b.filename(+) = e.filename
           AND ((e.phyrds - NVL(b.phyrds, 0)) + (e.phywrts - NVL(b.phywrts, 0))) > 0);

42.命中率：
--Library Hit
select round(sum(pinhits)/sum(pins)*100,2) "Library Hit(%)"
from v$librarycache;

--Latch Hit
select round((1-sum(misses)/sum(gets))*100,2) "Latch Hit(%)"
from v$latch;

--Buffer Hit
select round(100*(1-(a.value-b.value-nvl(c.value,0))/d.value),2) "Buffer Hit(%)"
from v$sysstat a,v$sysstat b,v$sysstat c,v$sysstat d
where a.name='physical reads'
and b.name='physical reads direct'
and c.name='physical reads direct (lob)'
and d.name='session logical reads';

43.切换undo tablespace
若某个undo tablespace被撑满，可以切换到备用的undo tablespace上：
alter system set 
Undo Tablespace 3 moved to Pending Switch-Out state.
Undo Tablespace 3 successfully switched out.

44.查看share pool的使用情况
--如果 FLUSHED CHUNKS> PINS AND RELEASES * 10%，说明shared pool空间争用较大，应该适当加大shared pool size。
select
  inst_id,
  kghlurcr "RECURRENT|CHUNKS",
  kghlutrn "TRANSIENT|CHUNKS",
  kghlufsh "FLUSHED|CHUNKS",
  kghluops "PINS AND|RELEASES",
  kghlunfu "ORA-4031|ERRORS",
  kghlunfs "LAST ERROR|SIZE"
from
  sys.x$kghlu
where
  inst_id = userenv('Instance')
 
45.删除SLOG中无效的注册信息
select 'execute DBMS_MVIEW.PURGE_MVIEW_FROM_LOG('||mview_id||');'
 from DBA_BASE_TABLE_MVIEWS 
where mview_last_refresh_time<sysdate-1

46.如何获得隐含参数
select
  x.ksppinm  name,
  y.ksppstvl  value,
  y.ksppstdf  isdefault,
  decode(bitand(y.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE')  ismod,
  decode(bitand(y.ksppstvf,2),2,'TRUE','FALSE')  isadj
from
  sys.x$ksppi x,
  sys.x$ksppcv y
where
  x.inst_id = userenv('Instance') and
  y.inst_id = userenv('Instance') and
  x.indx = y.indx and
  x.ksppinm like '%_&par%'
order by
  translate(x.ksppinm, ' _', ' ')
/

47.生成批量杀进程脚本
ps -ef|grep exp|awk '{if($3=="1") print "kill -9 "$2}'|sh

48.从系统表中生成index:
SELECT table_owner "用户",
		 table_name "表",
		 index_name||'('||LTRIM(MAX(SYS_CONNECT_BY_PATH(column_name,',')),',')||')' "索引"
  FROM dba_ind_columns
 WHERE table_owner LIKE 'UCR%'
 START WITH column_position = 1
CONNECT BY PRIOR column_position = column_position - 1
           AND PRIOR table_owner = table_owner AND
			  PRIOR table_name = table_name
           AND PRIOR index_name = index_name
 GROUP BY table_owner, table_name, index_name;
 
49.move含有LOB字段的表
alter table TI_B_IBTRADE_SVCCONT move tablespace TBS_CEN_DUIF nologging lob(REQSVCCONT) store as (tablespace TBS_CEN_DUIF);

50.过程中使用alter语句事项
需要定义动态SQL，执行动态SQL的模式来完成，如：
v_sql:='alter session set global_names=true';
execute immediate v_sql;

51.DML误操作flashback数据
select * from td_m_naming as of timestamp to_timestamp('2008-12-19 18:30:00', 'yyyy-mm-dd hh24:mi:ss') 
--where context_id=9906

52.session显示登陆IP
CREATE OR REPLACE TRIGGER ON_LOGON_TRIGGER
  AFTER LOGON ON DATABASE
declare 
BEGIN
  dbms_application_info.set_client_info('logon '||sys_context('userenv','ip_address'));
END;
/

53.rebuild unusable local indexes
ALTER TABLE TF_BHB_ZSL MODIFY PARTITION PAR_TF_B_PAYLOG_1 REBUILD UNUSABLE LOCAL INDEXES

54.取序列
select 'create sequence '||sequence_name||' minvalue '||min_value||' maxvalue '||max_value||' start with '||last_number||' increment by '||increment_by||' cache '||cache_size||';'
 from dba_sequences where sequence_owner='UOP_ACT1'
 
55.生成执行计划
explain plan set statement_id = 'ID_111' for select * from tf_f_user where user_id=2325346;
SELECT plan_table_output
  FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE','ID_111','ALL'));
--
delete from plan_table;
explan plan for...
select * from table(dbms_xplan.display);

56.替代for update修改记录的方法
select a.*,a.rowid from tab_name a;

57.从库中提取建表语句和索引语句
select dbms_metadata.get_ddl('TABLE','TF_F_USER') from dual;

select dbms_metadata.get_ddl('INDEX','IDX_TS_BH_BILL_ID') from dual;

58.从快照中恢复被删除的数据
create table  ucr_param.TD_TIME_BINDMETHOD2  tablespace TBS_ACT_DPARAM as
select * from ucr_param.TD_TIME_BINDMETHOD 
as of timestamp (systimestamp -interval'19000'second)


59.加表空间
select 'alter tablespace '||tablespace_name||' add datafile ''/oracledata2/actdata/'||tablespace_name||'100'' size 128m autoextend on;' from (
select b.tablespace_name,              
       round(b.all_byte)              "总空间(M)",
       round(b.all_byte-a.free_byte)  "已使用(M)",
       round(a.free_byte)             "剩余空间",
       round((a.free_byte/b.all_byte)*100)  "剩余百分比"
  from (select tablespace_name,sum(nvl(bytes,0))/1024/1024 free_byte from dba_free_space group by tablespace_name) a,
       (select tablespace_name,sum(nvl(bytes,0))/1024/1024 all_byte from dba_data_files group by tablespace_name) b
 where a.tablespace_name = b.tablespace_name and b.tablespace_name<>'SYSTEM' and b.tablespace_name<>'USERS'
       and b.tablespace_name<>'TBS_SNAPSHOT' and b.tablespace_name<>'SYSAUX'  and b.tablespace_name<>'UNDOTBS1' 
order by 5);


--快照
select * from mytest as of timestamp sysdate-5/1440;


60.回收站恢复
FLASHBACK TABLE TD_LAC_FEMTO TO BEFORE DROP;


61.查询 FSFI
select tablespace_name,sqrt(max(blocks)/sum(blocks))* 
　　(100/sqrt(sqrt(count(blocks)))) FSFI 
　　from dba_free_space 
　　group by tablespace_name order by 1;

--Oracle10g的自动undo retention，
都没有一个活动事务了，改了undo_retention为1秒了，也不释放空间
alter system set "_undo_autotune" = false;

62. 查看表中记录在块上的分布
select 'T' tbl_name, rows_per_block, count(*) number_of_such_blocks 
from (
 select dbms_rowid.ROWID_BLOCK_NUMBER( rowid ), count(*) rows_per_block
 from emp
 group by dbms_rowid.ROWID_BLOCK_NUMBER( rowid )
 )
 group by 'T', rows_per_block;

63.查并行语句
SELECT QCSID, SID, INST_ID "Inst", SERVER_GROUP "Group", SERVER_SET "Set",
  DEGREE "Degree", REQ_DEGREE "Req Degree"
FROM GV$PX_SESSION ORDER BY QCSID, QCINST_ID, SERVER_GROUP, SERVER_SET



64.从内存中捞出执行计划

select child_number, bind_mismatch B, optimizer_mode_mismatch O from v$sql_shared_cursor
  where sql_id = '1qqtru155tyz8';

select * from table( dbms_xplan.display_cursor('1qqtru155tyz8,1 ));


select s.sid,s.serial#,s.BLOCKING_SESSION,s.BLOCKING_SESSION_STATUS,s.SADDR,s.STATUS
from v$session s where blocking_session  is  not null;
  

65.对比高水位
select   round((1-a.used/b.num_total)*100,0)   percent from
(SELECT COUNT (DISTINCT SUBSTR(rowid,1,15)) Used FROM 表名) a,
(select blocks num_total from dba_tables where table_name='表名' and owner='用户名') b;

66 .awrsqrpt --使用

crmdb1:/oracle/support>  
crmdb1:/oracle/support> ss

SQL*Plus: Release 10.2.0.4.0 - Production on Wed Nov 25 12:26:17 2009

Copyright (c) 1982, 2007, Oracle.  All Rights Reserved.


Connected to:
Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - 64bit Production
With the Partitioning, Real Application Clusters, OLAP, Data Mining
and Real Application Testing options

SQL> @?/rdbms/admin/awrsqrpt

Current Instance
~~~~~~~~~~~~~~~~

   DB Id    DB Name      Inst Num Instance
----------- ------------ -------- ------------
 4172634383 NGCRM               1 ngcrm1


Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
Would you like an HTML report, or a plain text report?
Enter 'html' for an HTML report, or 'text' for plain text
Defaults to 'html'
Enter value for report_type: text

Type Specified:  text


Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   DB Id     Inst Num DB Name      Instance     Host
------------ -------- ------------ ------------ ------------
  4172634383        2 NGCRM        ngcrm2       crmdb2
* 4172634383        1 NGCRM        ngcrm1       crmdb1

Using 4172634383 for database Id
Using          1 for instance number


Specify the number of days of snapshots to choose from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Entering the number of days (n) will result in the most recent
(n) days of snapshots being listed.  Pressing <return> without
specifying a number lists all completed snapshots.


Enter value for num_days: 1

Listing the last day s Completed Snapshots

                                                        Snap
Instance     DB Name        Snap Id    Snap Started    Level
------------ ------------ --------- ------------------ -----
ngcrm1       NGCRM             5655 25 Nov 2009 00:56      1
                               5656 25 Nov 2009 01:55      1
                               5657 25 Nov 2009 02:56      1
                               5658 25 Nov 2009 03:56      1
                               5659 25 Nov 2009 04:55      1
                               5660 25 Nov 2009 05:56      1
                               5661 25 Nov 2009 06:56      1
                               5662 25 Nov 2009 07:55      1
                               5663 25 Nov 2009 08:56      1
                               5664 25 Nov 2009 09:56      1
                               5665 25 Nov 2009 10:41      1
                               5666 25 Nov 2009 11:56      1



Specify the Begin and End Snapshot Ids
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter value for begin_snap: 5664
Begin Snapshot Id specified: 5664

Enter value for end_snap: 5665
End   Snapshot Id specified: 5665




Specify the SQL Id
~~~~~~~~~~~~~~~~~~
Enter value for sql_id: 4gc2mtudndwur
SQL ID specified:  4gc2mtudndwur
declare
*
ERROR at line 1:
ORA-20025: SQL ID 4gc2mtudndwur does not exist for this database/instance
ORA-06512: at line 22


Disconnected from Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - 64bit Production
With the Partitioning, Real Application Clusters, OLAP, Data Mining
and Real Application Testing options







