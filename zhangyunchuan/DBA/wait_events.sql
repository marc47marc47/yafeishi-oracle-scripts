    col  event format a30
    col  username format a15
    col  sids format a15
    set  pagesize 1000

   select sw.seq#,sw.sid||','||s.serial# sids,s.SQL_HASH_VALUE,s.username,sw.event,sw.P1,sw.P1RAW,sw.p2,sw.p3,sw.wait_time "WAIT", 
   sw.state,sw.seconds_in_wait sec,s.status,to_char(s.logon_time,'yyyy-mm-dd/hh24:mi:ss') logon_time 
   from v$session s,v$session_wait sw
   where 
   sw.sid =s.sid
   and s.username is not null
   and sw.event not like '%SQL*Net%'
   and sw.event not like 'PX Deq%'
   and sw.event not like 'rdbms ipc message'
   order by sw.event,s.SQL_HASH_VALUE,s.username,s.logon_time ;
