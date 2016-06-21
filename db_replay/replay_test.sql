create user replay identified by a1234 default tablespace tbs_act_def;
grant dba to replay;

#!/bin/bash
. /oracle/.profile
rm -rf /oracle/danghb/db_replay_source
mkdir -p /oracle/danghb/db_replay_source
export ORACLE_SID=act
$ORACLE_HOME/bin/sqlplus /nolog <<EOF
conn danghb/Dang1#
create or replace directory REPLAY_SOURCE as '/oracle/danghb/db_replay_source';
set timing on;
exec dbms_workload_capture.delete_filter('filter_replay');
exec dbms_workload_capture.add_filter('filter_replay','USER','REPLAY');
exec dbms_workload_capture.START_CAPTURE(name => 'test_capture_2',-
                                    dir => 'REPLAY_SOURCE',-
                                    duration => 60*5,-
                                    default_action =>'INCLUDE');
exit;
EOF	

exec dbms_workload_capture.START_CAPTURE(name => 'test_capture_2',-
                                    dir => 'REPLAY_SOURCE',-
                                    duration => 60*5)

								

mkdir -p /oracle/danghb/db_replay_desti
cd /oracle/danghb/db_replay_desti
rm -rf *
cd /oracle/danghb/db_replay_source
cp -rf * /oracle/danghb/db_replay_desti
create or replace directory REPLAY_DESTI as '/oracle/danghb/db_replay_desti';

BEGIN
  DBMS_WORKLOAD_REPLAY.process_capture('REPLAY_DESTI');
  DBMS_WORKLOAD_REPLAY.initialize_replay (replay_name => 'test_capture_2',replay_dir  => 'REPLAY_DESTI');
  DBMS_WORKLOAD_REPLAY.prepare_replay (synchronization => TRUE);
END;
/

select table_name from user_tables;

os:
wrc mode=calibrate replaydir=/oracle/danghb/db_replay_desti

wrc danghb/Dang1# mode=replay replaydir=/oracle/danghb/db_replay_desti	

exec DBMS_WORKLOAD_REPLAY.START_REPLAY();

--- 查看表T的数据量
SQL> /

  COUNT(*)
----------
   1450768

SQL> /

  COUNT(*)
----------
    600848

SQL> /

  COUNT(*)
----------
         0

SQL> /

  COUNT(*)
----------
    181346

SQL> /

  COUNT(*)
----------
    725384

SQL> /

  COUNT(*)
----------
    725384



declare
replay_id number;
l_report  CLOB;
begin
select max(id) into replay_id
from dba_workload_replays
where status = 'COMPLETED';
l_report := DBMS_WORKLOAD_REPLAY.report(replay_id => replay_id,format =>DBMS_WORKLOAD_REPLAY.TYPE_HTML);
end;
/

select dbms_workload_replay.report(3,'HTML') from dual;