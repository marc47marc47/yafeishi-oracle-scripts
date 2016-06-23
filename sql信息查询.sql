select username,
       sid,
       opname,
       target,
       round(sofar * 100 / totalwork, 0 ) || '%' as progress,
       time_remaining,
       elapsed_seconds,
       sql_text
  from v$session_longops, v$sql
 where time_remaining <> 0
  and  sql_address = address
  and  sql_hash_value = hash_value;


--未使用绑定变量的语句：
---0:
select FORCE_MATCHING_SIGNATURE, count(1)
  from v$sql
 where FORCE_MATCHING_SIGNATURE > 0
   and FORCE_MATCHING_SIGNATURE != EXACT_MATCHING_SIGNATURE
 group by FORCE_MATCHING_SIGNATURE
having count(1) > 10
 order by 2;

---1: 
select sql_id, FORCE_MATCHING_SIGNATURE, sql_text
  from v$SQL
 where FORCE_MATCHING_SIGNATURE in
       (select /*+ unnest */
         FORCE_MATCHING_SIGNATURE
          from v$sql
         where FORCE_MATCHING_SIGNATURE > 0
           and FORCE_MATCHING_SIGNATURE != EXACT_MATCHING_SIGNATURE
         group by FORCE_MATCHING_SIGNATURE
        having count(1) > 10)

---2:
with force_mathces as
 (select l.force_matching_signature mathces,
 max(l.sql_id || l.child_number) max_sql_child,
 COUNT(*) COUNT,
 dense_rank() over(order by count(*) desc) ranking
 from v$sql l
 where l.force_matching_signature <> 0
 and l.parsing_schema_name <> 'SYS'
 group by l.force_matching_signature
 having count(*) > 10)
 select v.sql_id, v.sql_text, v.parsing_schema_name, fm.mathces, fm.count,fm.ranking
 from force_mathces fm, v$sql v
 where fm.max_sql_child = (v.sql_id || v.child_number)
 and fm.ranking <= 5
 order by fm.ranking;
 
---from metalink:
--9i
SELECT substr(sql_text,1,40) "SQL", 
         count(*) , 
         sum(executions) "TotExecs"
    FROM v$sqlarea
   WHERE executions < 5
   GROUP BY substr(sql_text,1,40)
  HAVING count(*) > 30
   ORDER BY 2
  ;
 
--10g及其以后版本
SET pages 10000
SET linesize 250
column FORCE_MATCHING_SIGNATURE format 99999999999999999999999
WITH c AS
     (SELECT  FORCE_MATCHING_SIGNATURE,
              COUNT(*) cnt
     FROM     v$sqlarea
     WHERE    FORCE_MATCHING_SIGNATURE!=0
     GROUP BY FORCE_MATCHING_SIGNATURE
     HAVING   COUNT(*) > 20
     )
     ,
     sq AS
     (SELECT  sql_text                ,
              FORCE_MATCHING_SIGNATURE,
              row_number() over (partition BY FORCE_MATCHING_SIGNATURE ORDER BY sql_id DESC) p
     FROM     v$sqlarea s
     WHERE    FORCE_MATCHING_SIGNATURE IN
              (SELECT FORCE_MATCHING_SIGNATURE
              FROM    c
              )
     )
SELECT   sq.sql_text                ,
         sq.FORCE_MATCHING_SIGNATURE,
         c.cnt "unshared count"
FROM     c,
         sq
WHERE    sq.FORCE_MATCHING_SIGNATURE=c.FORCE_MATCHING_SIGNATURE
AND      sq.p=1
ORDER BY c.cnt DESC 


SELECT SUBSTR(sql_text,1,40) "SQL",
  plan_hash_value,
  COUNT(*) ,
  SUM(executions) "TotExecs"
FROM v$sqlarea
WHERE executions < 5
GROUP BY plan_hash_value,
  SUBSTR(sql_text,1,40)
HAVING COUNT(*) > 30
ORDER BY 2 ;

--检查 hash chain 的长度:
SELECT hash_value, count(*)
  FROM v$sqlarea
 GROUP BY hash_value
HAVING count(*) > 5;

--检查高版本:
SELECT address,
       hash_value,
       version_count,
       users_opening,
       users_executing,
       substr(sql_text, 1, 40) "SQL"
  FROM v$sqlarea
 WHERE version_count > 10;


--找到占用shared pool 内存多的语句:
SELECT substr(sql_text, 1, 40) "Stmt",
       count(*),
       sum(sharable_mem) "Mem",
       sum(users_opening) "Open",
       sum(executions) "Exec"
  FROM v$sql
 GROUP BY substr(sql_text, 1, 40)
HAVING sum(sharable_mem) > &MEMSIZE;
        
        
--找到Invalidation较多的cursor:
SELECT SUBSTR(sql_text, 1, 40) "SQL",
invalidations
FROM v$sqlarea
ORDER BY invalidations DESC;

--长时间执行的语句
select a.SID,c.USERNAME,a.OPNAME,a.TARGET,a.START_TIME,a.LAST_UPDATE_TIME,a.ELAPSED_SECONDS ,b.SQL_TEXT,b.SQL_FULLTEXT
from v$session_longops a,v$sqlarea b ,v$session c
where a.sid=c.SID
and   a.SQL_HASH_VALUE=b.HASH_VALUE
order by a.ELAPSED_SECONDS desc;

--根据OS进程号查找SQL  
select a.sid,c.spid,a.username,a.status,a.event,a.program,b.sql_text,b.sql_id
  from v$session a,v$sqlarea b,v$process c
 where a.sql_hash_value=b.hash_value
   and a.paddr=c.addr
   and c.spid in(
'1482886'
)

--查找IO占用较多的语句
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

 

--查找前台发出的语句
select user_name,sql_text
　　 from v$open_cursor
　　 where sid in (select sid from (select sid,serial#,username,program
　　 from v$session
　　 where status='ACTIVE'));


--Top N SQL:
SELECT sql_text, sorts, executions, users_executing,
       TO_DATE(first_load_time, 'rrrr-mm-dd/hh24:mi:ss'),
       invalidations, parse_calls, physical_read_requests,s.buffer_gets,rows_processed,
       optimizer_mode, optimizer_cost, RAWTOHEX(address) address ,
       hash_value, u.username parsing_username,
       s.buffer_gets* 100/total.buffer_gets pct_total_gets,
       s.buffer_gets/DECODE(s.rows_processed,0 ,1 ,s.rows_processed) gets_per_row,
       sql_id || '_' || child_number ID,
       sql_id,
       child_number,elapsed_time/ 1000,cpu_time/ 1000,
       application_wait_time/ 1000, concurrency_wait_time/1000, cluster_wait_time/1000 ,
       user_io_wait_time/ 1000, plsql_exec_time/ 1000, java_exec_time/1000, direct_writes, optimized_phy_read_requests
  FROM v$sql s,
       all_users u,
       ( SELECT SUM (buffer_gets) buffer_gets FROM v$sql) total
 WHERE u.user_id=s.parsing_user_id AND executions > 0 
 ORDER BY ELAPSED_TIME DESC

--Busy Segments:
select * from
(SELECT owner || '.' || object_name, value
  FROM v$segment_statistics
 WHERE statistic_name = 'buffer busy waits'
   AND value > 0
 ORDER BY 2 DESC
) 
where rownum < 20;
 

--Busy Tablespace :
SELECT SUM (value ) total, tablespace_name
  FROM v$segment_statistics
 WHERE statistic_name = 'buffer busy waits'
 GROUP BY tablespace_name
 order by total desc

--Buffer Busy Waits:
SELECT /*+ NO_MERGE USE_INDEX(S) */
        s.sid,
         NVL (
            DECODE ( TYPE,
                    'BACKGROUND', 'SYS (' || b.ksbdpnam || ')',
                    s.username),
            SUBSTR (p.program, INSTR (p.program, '(')))
            username,
         s.osuser,
         s.machine,
         s.process,
         s.program,
         e.total_waits,
         e.time_waited * 10 ms_waited
    FROM v$session_event e,
         v$session s,
         v$process p,
         x$ksbdp b
   WHERE     e.event = 'buffer busy waits'
         AND s.sid = e.sid
         AND s.paddr = p.addr
         AND b.inst_id(+) = USERENV ( 'INSTANCE')
         AND p.addr = b.ksbdppro(+)
ORDER BY total_waits DESC

--Physical IO:
SELECT * FROM
(SELECT owner,
       object_name,
       SUM(DECODE(statistic_name, 'physical reads',                     VALUE,
           DECODE(statistic_name, 'physical reads direct',              VALUE,
           DECODE(statistic_name, 'physical writes',                    VALUE,
           DECODE(statistic_name, 'physical writes direct',             VALUE, 0 ))))) "total physical io",
       SUM(DECODE(statistic_name, 'logical reads',                      VALUE, 0 ))    "logical reads",
       SUM(DECODE(statistic_name, 'physical reads',                     VALUE, 0 ))    "physical reads",
       SUM(DECODE(statistic_name, 'physical reads direct',              VALUE, 0 ))    "physical reads direct",
       SUM(DECODE(statistic_name, 'physical writes',                    VALUE, 0 ))    "physical writes",
       SUM(DECODE(statistic_name, 'physical writes direct',             VALUE, 0 ))    "physical writes direct",
       SUM(DECODE(statistic_name, 'ITL waits',                          VALUE, 0 ))    "ITL waits",
       SUM(DECODE(statistic_name, 'buffer busy waits',                  VALUE, 0 ))    "buffer busy waits",
       SUM(DECODE(statistic_name, 'db block changes',                   VALUE, 0 ))    "db block changes",
       SUM(DECODE(statistic_name, 'gc cr blocks received',              VALUE, 0 ))    "gc cr blocks served",
       SUM(DECODE(statistic_name, 'gc current blocks received',         VALUE, 0 ))    "gc current blocks served",
       SUM(DECODE(statistic_name, 'row lock waits',                     VALUE, 0 ))    "row lock waits"
  FROM v$segment_statistics
 GROUP BY owner, object_name
 ORDER BY "total physical io" DESC, "logical reads")
WHERE ROWNUM <=100;

--ORDER BY CPU:
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
	 
--prompt 15 Most expensive SQL in the cursor cache
SELECT *
  FROM (SELECT SQL_ID,
               ELAPSED_TIME / 1000000 AS ELAPSED,
               SQL_TEXT
          FROM V$SQLSTATS
         ORDER BY ELAPSED_TIME DESC)
 WHERE ROWNUM <= 15;
 
-- order by  每次执行时间 
select a.SQL_ID,a.SQL_TEXT,round(a.ELAPSED_TIME/a.EXECUTIONS/1000000,3) as "time_per_run(seconds)",A.EXECUTIONS,a.PARSING_SCHEMA_NAME,a.MODULE
from v$sqlarea a
where 1=1
and a.PARSING_SCHEMA_NAME like 'U%' 
and a.EXECUTIONS <> 0
and (a.MODULE   like 'JDBC Thin Client%' or a.MODULE   like '%node%')
and round(a.ELAPSED_TIME/a.EXECUTIONS/1000000,3)>1 
and a.EXECUTIONS > 5
order by 3 desc;

--table access full sql
select a.SQL_ID,a.SQL_TEXT,b.OPERATION,b.OPTIONS,b.OBJECT_NAME,round(a.ELAPSED_TIME/a.EXECUTIONS/1000000,3),b.CPU_COST
from v$sql a,v$sql_plan b
where a.SQL_ID=b.SQL_ID
and b.OPERATION='TABLE ACCESS'
and b.OPTIONS='FULL'
and a.PARSING_SCHEMA_NAME like '%UOP_REWORKFLOW%'
and round(a.ELAPSED_TIME/a.EXECUTIONS/1000000,3)>10
and a.MODULE='JDBC Thin Client';

-- 逻辑读多的SQL 
select * from (select buffer_gets, sql_text 
from v$sqlarea 
where buffer_gets > 500000 
order by buffer_gets desc) where rownum<=30; 

-- 执行次数多的SQL    
select sql_text,executions from 
(select sql_text,executions from v$sqlarea order by executions desc) 
 where rownum<81; 

-- 读硬盘多的SQL  
select sql_text,disk_reads from 
(select sql_text,disk_reads from v$sqlarea order by disk_reads desc) 
 where rownum<21;     

-- 排序多的SQL    
select sql_text,sorts from 
 (select sql_text,sorts from v$sqlarea order by sorts desc) 
  where rownum<21;            
  
--分析的次数太多，执行的次数太少，要用绑变量的方法来写sql 
set pagesize 600; 
set linesize 120; 
select substr(sql_text,1,80) "sql", count(*), sum(executions) "totexecs" 
   from v$sqlarea 
   where executions < 5 
   group by substr(sql_text,1,80) 
   having count(*) > 30 
   order by 2;
 
 
--查看buffer cache中的内容
SELECT /*+ ORDERED USE_HASH(o u) MERGE */
 DECODE(obj#,
        NULL,
        to_char(bh.obj),
        u.name || '.' || o.name) name,
 COUNT(*) total,
 SUM(DECODE((DECODE(lru_flag, 8, 1, 0) + DECODE(SIGN(tch - 2), 1, 1, 0)),
            2,
            1,
            1,
            1,
            0)) hot,
 SUM(DECODE(DECODE(SIGN(lru_flag - 8), 1, 0, 0, 0, 1) +
            DECODE(tch, 2, 1, 1, 1, 0, 1, 0),
            2,
            1,
            1,
            0,
            0)) cold,
 SUM(DECODE(BITAND(flag, POWER(2, 19)), 0, 0, 1)) fts,
 SUM(tch) total_tch,
 ROUND(AVG(tch), 2) avg_tch,
 MAX(tch) max_tch,
 MIN(tch) min_tch
  FROM x$bh bh, sys.obj$ o, sys.user$ u
 WHERE 
    bh.obj <> 4294967295
   AND bh.state in (1, 2, 3)
   AND bh.obj = o.dataobj#(+)
   AND bh.inst_id = USERENV('INSTANCE')
 AND o.owner# = u.user#(+)
--   AND o.owner# > 5
   AND u.name NOT like 'AURORA$%'
 GROUP BY DECODE(obj#,
                 NULL,
                 to_char(bh.obj),
                 u.name || '.' || o.name)
 ORDER BY  total desc
 
	 
select name, value
  from v$sysstat
 where name in ('physical read total IO requests',
        'physical read total multi block requests',
        'physical write total IO requests',
        'physical write total multi block requests');
		
		
-- sql_id
select sql_id,hash_value,dbms_utility.SQLID_TO_SQLHASH(sql_id) convert 
from v$sql where rownum <9;		

-- 抓 某个 列 出现在 where条件里面
select
    r.name owner,
    o.name table_name ,
    c.name column_name,
    equality_preds, ---等值过滤
    equijoin_preds, ---等值JOIN过滤 比如where a.id=b.id
    nonequijoin_preds, ----不等JOIN过滤
    range_preds, ----范围过滤 > >= < <= between and
    like_preds,  ----LIKE过滤
    null_preds,  ----NULL 过滤
    timestamp
 from
    sys.col_usage$ u,
    sys.obj$ o,
    sys.col$ c,
    sys.user$ r
 where
    o.obj# = u.obj#
 and c.obj# = u.obj#
 and c.col# = u.intcol#
 and r.name='SCOTT' and o.name='TEST';

--   
SELECT SUBSTR(sql_text, 1, 40), module, COUNT(*) total_number
  FROM v$sql
 GROUP BY module, SUBSTR(sql_text, 1, 40)
HAVING COUNT(*) > 50
 ORDER BY 3 DESC;
 
--将该语句刷出 share pool
select a.ADDRESS,a.HASH_VALUE,a.* 
from v$sqlarea  a where a.SQL_ID='7jprshpcr5f21';


exec sys.dbms_shared_pool.purge('07000110EF43A7A0,4271850940','c');


-- unshared sql count
WITH c AS
(SELECT FORCE_MATCHING_SIGNATURE,
COUNT(*) cnt
FROM v$sqlarea
WHERE FORCE_MATCHING_SIGNATURE!=0
GROUP BY FORCE_MATCHING_SIGNATURE
HAVING COUNT(*) > 20
)
,
sq AS
(SELECT sql_text ,
FORCE_MATCHING_SIGNATURE,
row_number() over (partition BY FORCE_MATCHING_SIGNATURE ORDER BY sql_id DESC) p
FROM v$sqlarea s
WHERE FORCE_MATCHING_SIGNATURE IN
(SELECT FORCE_MATCHING_SIGNATURE
FROM c
)
)
SELECT sq.sql_text ,
sq.FORCE_MATCHING_SIGNATURE,
c.cnt "unshared count"
FROM c,
sq
WHERE sq.FORCE_MATCHING_SIGNATURE=c.FORCE_MATCHING_SIGNATURE
AND sq.p =1
ORDER BY c.cnt DESC;

-- invalidation sql
SELECT SUBSTR(sql_text, 1, 40) "SQL",
invalidations
FROM v$sqlarea
ORDER BY invalidations DESC;

--- 检索Library Cache hit ratio
SELECT SUM(PINS) "EXECUTIONS",
SUM(RELOADS) "CACHE MISSES WHILE EXECUTING"
FROM V$LIBRARYCACHE;


-- 找到占用shared pool 内存多的语句:

SELECT substr(sql_text,1,40) "Stmt", count(*),
        sum(sharable_mem)    "Mem",
        sum(users_opening)   "Open",
        sum(executions)      "Exec"
  FROM v$sql
 GROUP BY substr(sql_text,1,40)
HAVING sum(sharable_mem) > &MEMSIZE;

----------------------------------------------------------------------------------

--who has how many cursors open? 
select a.osuser,  a.sid,a.username, a.machine, count(*) from
v$session a, V$OPEN_CURSOR b
where a.sid  =  b.sid  
group by
a.osuser, a.sid, a.username,a.machine
order by count(*) desc;

  
--------------------------------------------------------------------------------------------------
/* Shared pool usage */
select 100-round(a.bytes/b.sm*100,2) pctused from 
(select bytes from v$sgastat where name='free memory' AND pool='shared pool') a,
(select sum(bytes) sm from v$sgastat where pool = 'shared pool') b  ;

--------------------------------------------------------------------------------------------------
What rollback segments are in use, and by whom?

select /*+ rule */  r.name, p.pid, p.spid, nvl(p.username,'no transaction') 
osuser,p.terminal,
nvl(l.username,'no transaction') username
from    
 (select si.username, lo.* from v$lock lo, v$session si where lo.sid=si.sid) l,
 v$process p, v$rollname r
where   l.sid = p.pid(+) and     trunc(l.id1(+)/65536) = r.usn 
and     l.type(+) = 'TX' and     l.lmode(+) = 6
order by r.name

select s.sid, s.username, r.name "ROLLBACK SEG"
  from v$session s, v$transaction t, v$rollname r
 where s.taddr=t.addr
  and  t.xidusn = r.usn;
  
  
  
------------------------------------library cache pin/lock -----------------------------------------------------
Library cache pins. Use the value of v$session_wait.p1raw in the queries below.

Identify which object is being waited for:


 SELECT kglnaown "Owner", kglnaobj "Object" 
     FROM x$kglob WHERE kglhdadr='9074709432';
     
Who is pinning the object?

SELECT s.sid, s.serial#, s.username, s.osuser, s.machine, s.status, 
kglpnmod "Mode", kglpnreq "Req"
FROM x$kglpn p, v$session s 
WHERE p.kglpnuse=s.saddr AND 
kglpnhdl='value of p1raw';

"Mode"=mode pin is held in, "Request"=mode of request. 
The "Mode" and "Request" can be either exclusive (3) or shared (2).
On systems where a webserver repeatedly reissues SQL after a timeout, 
you can see a large buildup of webserver sessions all trying to pin the same blocked library cache pin. 
Use the following script to generate SQL to kill off multiple sessions all waiting for the same library cache pin.

  SELECT 'alter system kill session ''' || s.sid || ','  || s.serial# || ''';'
  FROM x$kglpn p, v$session s
  WHERE p.kglpnuse=s.saddr
  AND kglpnhdl='value of p1raw';
    
  
---------------------library cache pin/lock  
SELECT addr, kglhdadr, kglhdpar, kglnaown, kglnaobj, kglnahsh, kglhdobj
  FROM x$kglob
 WHERE kglhdadr IN (SELECT p1raw
                      FROM v$session_wait
                     WHERE event LIKE 'library%');


--blocking session
SELECT a.SID,
       a.username,
       a.program,
       a.event,
       a.P1RAW,
       a.P1TEXT,
       b.addr,
       b.kglpnadr,
       b.kglpnuse,
       b.kglpnses,
       b.kglpnhdl,
       b.kglpnlck,
       b.kglpnmod,
       b.kglpnreq
  FROM v$session a, x$kglpn b
 WHERE a.saddr = b.kglpnuse
   AND b.kglpnmod <> 0
   AND b.kglpnhdl IN
       (SELECT p1raw FROM v$session_wait WHERE event LIKE 'library%');

--library的sql   blocking session sql
select sql_text
  FROM v$sqlarea
 WHERE (v$sqlarea.address, v$sqlarea.hash_value) IN
       (SELECT sql_address, sql_hash_value
          FROM v$session
         WHERE SID IN (SELECT SID
                         FROM v$session a, x$kglpn b
                        WHERE a.saddr = b.kglpnuse
                          AND b.kglpnmod <> 0
                          AND b.kglpnhdl IN
                              (SELECT p1raw
                                 FROM v$session_wait
                                WHERE event LIKE 'library%')))  
  
-------library cache pin                               
The following SQL can be used to show the sessions which are holding and/or requesting pins on the object that given in P1 in the wait:
  SELECT s.sid, kglpnmod "Mode", kglpnreq "Req",s.status 
    FROM x$kglpn p, v$session s
   WHERE p.kglpnuse=s.saddr
     AND kglpnhdl='&P1RAW';  
     
SELECT s.sid||','||s.serial# SID_SERIAL, kglpnmod "Mode Held", kglpnreq "Request",s.status 
FROM sys.x$kglpn p, sys.v_$session s  
WHERE p.kglpnuse = s.saddr 
 AND kglpnhdl = '&P1RAW';     
 
 
SELECT s.sid,
       p.kglpnmod "Mode",
       p.kglpnreq "Req",
       l.kglnaobj "Object",
       o.SPID "OS Process"
  FROM v$session_wait w, x$kglpn p, x$kgllk l, v$session s, v$process o
 WHERE p.kglpnses = s.saddr
   AND p.kglpnhdl = w.p1raw
   and p.kglpnhdl = l.kgllkhdl
   and l.kgllkses = s.saddr
   and w.event like '%library cache pin%'
   and s.paddr = o.addr;
 

select distinct ses.ksusenum sid,
                ses.ksuseser serial#,
                ses.ksuudlna username,
                ses.ksuseunm machine,
                ob.kglnaown obj_owner,
                ob.kglnaobj obj_name,
                pn.kglpncnt pin_cnt,
                pn.kglpnmod pin_mode,
                pn.kglpnreq pin_req,
                w.state,
                w.event,
                w.wait_Time,
                w.seconds_in_Wait 
                -- lk.kglnaobj, lk.user_name, lk.kgllksnm, 
                --,lk.kgllkhdl,lk.kglhdpar 
                --,trim(lk.kgllkcnt) lock_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req, 
                --,lk.kgllkpns, lk.kgllkpnc,pn.kglpnhdl 
                from x$kglpn pn, x$kglob ob,x$ksuse ses , v$session_wait w 
                where pn.kglpnhdl in 
                (select kglpnhdl from x$kglpn where kglpnreq >0 ) 
                and ob.kglhdadr = pn.kglpnhdl 
                and pn.kglpnuse = ses.addr 
                and w.sid = ses.indx 
                order by seconds_in_wait desc;
                
     
 
-------library cache lock
-- blocking session
select kgllkses saddr,kgllkhdl handle,kgllkmod mod,kglnaobj object
from x$kgllk lock_a
where kgllkmod > 0
and exists (select lock_b.kgllkhdl from x$kgllk lock_b
where kgllkses in (select saddr from v$session where event= 'library cache lock')   /* blocked session */
and lock_a.kgllkhdl = lock_b.kgllkhdl
and kgllkreq > 0);

--blocked session
select sid,username,terminal,program 
from v$session
where saddr in 
(select kgllkses from x$kgllk lock_a 
 where kgllkreq > 0
 and exists (select lock_b.kgllkhdl from x$kgllk lock_b
             where kgllkses = '572eac94' /* blocking session */
             and lock_a.kgllkhdl = lock_b.kgllkhdl
             and kgllkreq = 0);
             
             
select s.sid,
       lk.kgllkhdl "Handle",
       lk.kgllkmod "Mode",
       lk.kgllkreq "Request",
       lk.kglnaobj "Object",
       p.pid       "PID",
       p.spid      "OS Process"
  from x$kgllk lk, v$session s, v$process p
 where lk.kgllkses = s.saddr
   and lk.kgllkhdl = s.p1raw
   and s.paddr = p.addr
   and (kgllkreq > 0 or KGLLKMOD > 0);
                            
             
select distinct ses.ksusenum sid,
                ses.ksuseser serial#,
                ses.ksuudlna username,
                KSUSEMNM module,
                ob.kglnaown obj_owner,
                ob.kglnaobj obj_name,
                lk.kgllkcnt lck_cnt,
                lk.kgllkmod lock_mode,
                lk.kgllkreq lock_req,
                w.state,
                w.event,
                w.wait_Time,
                w.seconds_in_Wait
  from x$kgllk lk, x$kglob ob, x$ksuse ses, v$session_wait w
 where lk.kgllkhdl in (select kgllkhdl from x$kgllk where kgllkreq > 0)
   and ob.kglhdadr = lk.kgllkhdl
   and lk.kgllkuse = ses.addr
   and w.sid = ses.indx
 order by seconds_in_wait desc;             



-- rac:
select inst_id,
       handle,
       grant_level,
       request_level,
       resource_name1,
       resource_name2,
       pid,
       transaction_id0,
       transaction_id1,
       owner_node,
       blocked,
       blocker,
       state
  from gv$ges_blocking_enqueue;
 
 
select Distinct /*+ ordered */ w1.sid waiting_session,
                h1.sid holding_session,
                w.kgllktype lock_or_pin,
                od.to_owner object_owner,
                od.to_name object_name,
                oc.Type,
                decode(h.kgllkmod,
                       0,
                       'None',
                       1,
                       'Null',
                       2,
                       'Share',
                       3,
                       'Exclusive',
                       'Unknown') mode_held,
                decode(w.kgllkreq,
                       0,
                       'None',
                       1,
                       'Null',
                       2,
                       'Share',
                       3,
                       'Exclusive',
                       'Unknown') mode_requested,
                xw.KGLNAOBJ wait_sql,
                xh.KGLNAOBJ hold_sql
  from dba_kgllock         w,
       dba_kgllock         h,
       v$session           w1,
       v$session           h1,
       v$object_dependency od,
       V$DB_OBJECT_CACHE   oc,
       x$kgllk             xw,
       x$kgllk             xh
 where (((h.kgllkmod != 0) and (h.kgllkmod != 1) and
       ((h.kgllkreq = 0) or (h.kgllkreq = 1))) and
       (((w.kgllkmod = 0) or (w.kgllkmod = 1)) and
       ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
   and w.kgllktype = h.kgllktype
   and w.kgllkhdl = h.kgllkhdl
   and w.kgllkuse = w1.saddr
   and h.kgllkuse = h1.saddr
   And od.to_address = w.kgllkhdl
   And od.to_name = oc.Name
   And od.to_owner = oc.owner
   And w1.sid = xw.KGLLKSNM
   And h1.sid = xh.KGLLKSNM
   And (w1.SQL_ADDRESS = xw.KGLHDPAR And w1.SQL_HASH_VALUE = xw.KGLNAHSH)
   And (h1.SQL_ADDRESS = xh.KGLHDPAR And h1.SQL_HASH_VALUE = xh.KGLNAHSH); 
 
 
--------- cursor: pin S wait on X   parse time is too long
select p2raw,to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX') 'holding session'
     from v$session 
     where event = 'cursor: pin S wait on X';   
     
-- Script:	objects_on_hot_latches.sql
-- Purpose:	to list the library cache objects on the hot KGL latches     
     
select /*+ ordered */
  l.child#  latch#,
  o.kglnaobj  object_name
from
  ( select
      count(*)  latches,
      avg(sleeps)  sleeps
    from
      sys.v_$latch_children
    where
      name = 'library cache'
  )  a,
  sys.v_$latch_children  l,
  ( select
      s.buckets *
      power(
        2,
        least(
          8,
          ceil(log(2, ceil(count(*) / s.buckets)))
        )
      )  buckets
    from
      ( select
	  decode(y.ksppstvl,
	    0, 509,
	    1, 1021,
	    2, 2039,
	    3, 4093,
	    4, 8191,
	    5, 16381,
	    6, 32749,
	    7, 65521,
	    8, 131071,
            509
	  )  buckets
	from
	  sys.x_$ksppi  x,
	  sys.x_$ksppcv  y
	where
	  x.inst_id = userenv('Instance') and
	  y.inst_id = userenv('Instance') and
	  x.ksppinm = '_kgl_bucket_count' and
	  y.indx = x.indx
      )  s,
      sys.x_$kglob  c
    where
      c.inst_id = userenv('Instance') and
      c.kglhdadr = c.kglhdpar
    group by
      s.buckets
  )  b,
  sys.x_$kglob  o
where
  l.name = 'library cache' and
  l.sleeps > 2 * a.sleeps and
  mod(mod(o.kglnahsh, b.buckets), a.latches) + 1 = l.child# and
  o.inst_id = userenv('Instance') and
  o.kglhdadr = o.kglhdpar
/

     