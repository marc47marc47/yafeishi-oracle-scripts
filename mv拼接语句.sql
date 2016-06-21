select 'create materialized view MV_'||A.TABLE_NAME||' tablespace TBS_CRM_DPARAM pctfree 10
using index tablespace TBS_CRM_IPARAM
refresh fast start with SYSDATE next SYSDATE + 15/1440
as
select * from '||a.OWNER||'.'||a.TABLE_NAME||'@dblnk_crmceni1'
from dba_tables a
where a.owner='UCR_CEN1'
and a.table_name in

select 'create materialized view MV_'||A.TABLE_NAME||'tablespace TBS_CRM_DPARAM pctfree 10
using index tablespace TBS_CRM_IPARAM
REFRESH COMPLETE on demand start with SYSDATE next SYSDATE + 15/1440 with rowid
as
select * from '||a.OWNER||'.'||a.TABLE_NAME||'@dblnk_crmceni1'
from dba_tables a
where a.owner='UCR_CEN1'
and a.table_name in


select 'create or replace synonym '||a.TABLE_NAME||' for uif_crm&1._cen.MV_'||a.TABLE_NAME||' ;'
from dba_tables a
where a.OWNER like 'UCR_%'


select 'create materialized view log on '||a.OWNER||'.'||a.TABLE_NAME||' tablespace TBS_SNAPSHOT pctfree 10
with primary key ;'
from dba_tables a
where a.owner='UCR_PARAM'
and a.TABLE_NAME in 

select 'create materialized view log on '||a.OWNER||'.'||a.TABLE_NAME||' tablespace TBS_SNAPSHOT pctfree 10
with rowid ;'
from dba_tables a
where a.owner='UCR_CEN1';

--  全量刷新
exec dbms_mview.refresh('MV_TD_M_STAFF','C'); 

