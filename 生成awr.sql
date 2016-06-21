--awr 信息
select * from dba_hist_wr_control;
exec dbms_workload_repository.modify_snapshot_settings(interval => 30,retention => 24*60*10);
@?/rdbms/admin/awrinfo.sql  --  awr 元数据

--11G
select *
from dba_hist_ash_snapshot a
where a.INSTANCE_NUMBER in (select instance_number from v$instance)
order by a.SNAP_ID desc;

--10g
select *
from dba_hist_snapshot a
where a.INSTANCE_NUMBER in (select instance_number from v$instance)
order by a.SNAP_ID desc;

select *
from table(dbms_workload_repository.awr_global_report_html(283961491, '', 952, 957 ));

--awr报告
select *
from 
table(dbms_workload_repository.awr_report_html(283961491,2, 952, 957 ));

--sql 报告
select *
from 
table(dbms_workload_repository.awr_sql_report_text(3586341486,2,4040,4041,'btsupvuc5zgch'));
 
--ash报告
SELECT * FROM 
TABLE(dbms_workload_repository.ash_report_html(970909962,1,to_date('20150701 15:01:00','YYYYMMDD HH24:MI:SS'),to_date('20150701 15:05:59','YYYYMMDD HH24:MI:SS')));
