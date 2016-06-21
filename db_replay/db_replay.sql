
--查询过滤器信息
select type, name, attribute, status, value from dba_workload_filters;

#!/bin/bash
. /home/oracle/.profile
/oracle/app/oracle/product/11.2.0/db/bin/sqlplus /nolog <<EOF
conn system/linkage@10.238.11.116/ngact
create or replace directory replay_data as '/oracle/app/oracle/danghb/db_replay_21';
set timing on;
exec dbms_workload_capture.start_capture('test_capture_1','REPLAY_DATA', 60*60);
exit;
EOF

--手工结束捕捉
exec dbms_workload_capture.finish_capture;

--查询
select name, directory, status, start_time, end_time, duration_secs, errors
from dba_workload_captures;