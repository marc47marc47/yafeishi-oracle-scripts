select distinct a.INST_ID,a.SID,a.SERIAL#,a.PROGRAM,a.MACHINE, a.osuser,a.USERNAME,a.EVENT,b.SQL_TEXT,b.SQL_ID
from gv$session@to_bjlcrmdb a,gv$sql@to_bjlcrmdb b
where a.STATUS='ACTIVE'
and a.SQL_ID=b.SQL_ID
and a.USERNAME  like 'U%'
and a.EVENT not like '%SQL*Net message%'
order by a.inst_id,a.EVENT;



select distinct a.INST_ID,a.SID,a.SERIAL#,a.PROGRAM,a.MACHINE, a.osuser,a.USERNAME,a.EVENT,b.SQL_TEXT,b.SQL_ID
from gv$session@to_ngech a,gv$sql@to_ngech b
where a.STATUS='ACTIVE'
and a.SQL_ID=b.SQL_ID
and a.USERNAME  like 'U%'
and a.EVENT not like '%SQL*Net message%'
order by a.inst_id,a.EVENT;

select *
from gV$ADVISOR_PROGRESS@to_bjlcrmdb;

select inst_id,sid,serial#,username,task_id,target_desc, sofar,totalwork,round(sofar/totalwork,2),round(elapsed_seconds/60),round(elapsed_seconds/3600,2)
from gV$ADVISOR_PROGRESS@to_bjlcrmdb order by target_desc;


select inst_id,sid,serial#,username,task_id,target_desc, sofar,totalwork,round(sofar/totalwork,2),round(elapsed_seconds/3600,2)
from gV$ADVISOR_PROGRESS@to_ngech  order by target_desc;

select * from dba_sqlset@to_bjlcrmdb order by created desc;

select * from dba_sqlset@to_crm order by created desc;

select * from dba_sqlset@to_ngech order by created desc;

