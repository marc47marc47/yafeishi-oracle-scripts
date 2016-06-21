set pagesize 1000
set linesize 100
select inst_id,event,event#,count(*) 
from gv$session 
where username like 'U%'
and status='ACTIVE'
and event not like 'SQL*Net%'
group by inst_id,event,event#
order by inst_id,count(*) desc;
