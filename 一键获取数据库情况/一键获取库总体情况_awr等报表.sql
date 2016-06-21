
SET markup html ON spool ON pre off entmap off

set term off
set heading on
set verify off
set feedback off

set linesize 2000
set pagesize 30000
set long 999999999
set longchunksize 999999

column index_name format a30
column table_name format a30
column num_rows format 999999999
column index_type format a24
column num_rows format 999999999
column status format a8
column clustering_factor format 999999999
column degree format a10
column blevel format 9
column distinct_keys format 9999999999
column leaf_blocks format   9999999
column last_analyzed    format a10
column column_name format a25
column column_position format 9
column temporary format a2
column partitioned format a5
column partitioning_type format a7
column partition_count format 999
column program  format a30
column spid  format a6
column pid  format 99999
column sid  format 99999
column serial# format 99999
column username  format a12
column osuser    format a12
column logon_time format  date
column event    format a32
column JOB_NAME        format a30
column PROGRAM_NAME    format a32
column STATE           format a10
column window_name           format a30
column repeat_interval       format a60
column machine format a30
column program format a30
column osuser format a15
column username format a15
column event format a50
column seconds format a10
column sqltext format a100




--以下使用html标签
SET markup html off spool ON pre off entmap off

set trim on
set trimspool on
set heading off

--查询dbid、instance_number
column dbid new_value awr_dbid
column instance_number new_value awr_inst_num
select dbid from v$database;
select instance_number from v$instance;

--半小时内的ash报告
column ashbegintime new_value ashbegin_str
column ashendtime new_value ashend_str
select to_char(sysdate-3/144,'yyyymmddhh24miss') as ashbegintime, to_char(sysdate,'yyyymmddhh24miss') as ashendtime from dual;

column ashfile_name new_value ashfile
select 'ashrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&ashbegin_str) || '_' || to_char(&&ashend_str) ashfile_name from dual;
spool &&ashfile..html
select * from table(dbms_workload_repository.ash_report_html(to_char(&&awr_dbid),to_char(&&awr_inst_num),to_date(to_char(&&ashbegin_str),'yyyymmddhh24miss'),to_date(to_char(&&ashend_str),'yyyymmddhh24miss')));
spool off;

--按需创建awr断点
column begin_snap new_value awr_begin_snap
column end_snap new_value awr_end_snap
select max(snap_id) begin_snap
  from dba_hist_snapshot
 where snap_id < (select max(snap_id) from dba_hist_snapshot);
select max(snap_id) end_snap from dba_hist_snapshot;
declare
  snap_maxtime date;
  snap_mintime date;
begin
  select max(end_interval_time) + 0
    into snap_maxtime
    from dba_hist_snapshot
   where snap_id = to_number(&&awr_end_snap);
  select max(end_interval_time) + 0
    into snap_mintime
    from dba_hist_snapshot
   where snap_id = to_number(&&awr_begin_snap);
  if sysdate - snap_maxtime > 10/1445 then
    dbms_workload_repository.create_snapshot();
  end if;
end;
/

--最新两次snap_id间的awr报告
column begin_snap new_value awr_begin_snap
column end_snap new_value awr_end_snap
select max(snap_id) begin_snap
  from dba_hist_snapshot
 where snap_id < (select max(snap_id) from dba_hist_snapshot);
select max(snap_id) end_snap from dba_hist_snapshot;
column awrfile_name new_value awrfile
select 'awrrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&awr_begin_snap) || '_' || to_char(&&awr_end_snap) awrfile_name from dual;

spool &&awrfile..html
select output from table(dbms_workload_repository.awr_report_html(&&awr_dbid,&&awr_inst_num,&&awr_begin_snap,&&awr_end_snap));
spool off;




--最新addm报告
column addmfile_name new_value addmfile
select 'addmrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&awr_begin_snap) || '_' || to_char(&&awr_end_snap) addmfile_name from dual;
set serveroutput on
spool &&addmfile..txt
declare
  id          number;
  name		  varchar2(200) := '';
  descr       varchar2(500) := '';
  addmrpt     clob;
  v_ErrorCode number;
BEGIN
  name := '&&addmfile';
  begin
    dbms_advisor.create_task('ADDM', id, name, descr, null);
    dbms_advisor.set_task_parameter(name, 'START_SNAPSHOT', &&awr_begin_snap);
    dbms_advisor.set_task_parameter(name, 'END_SNAPSHOT', &&awr_end_snap);
    dbms_advisor.set_task_parameter(name, 'INSTANCE', &&awr_inst_num);
    dbms_advisor.set_task_parameter(name, 'DB_ID', &&awr_dbid);
    dbms_advisor.execute_task(name);
  exception
    when others then
      null;
  end;
  select dbms_advisor.get_task_report(name, 'TEXT', 'TYPICAL')
    into addmrpt
    from sys.dual;
  dbms_output.enable(20000000000);
  for i in 1 .. (DBMS_LOB.GETLENGTH(addmrpt) / 2000 + 1) loop
    dbms_output.put_line(substr(addmrpt, 1900 * (i - 1) + 1, 1900));
  end loop;
  dbms_output.put_line('');
  begin
    dbms_advisor.delete_task(name);
  exception
    when others then
      null;
  end;
end;
/
spool off;

--可获取的最长awr报告(一周以来的所有分析)
column begin_snap new_value awr_begin_snap
column end_snap new_value awr_end_snap
select min(snap_id) begin_snap
  from dba_hist_snapshot;
select max(snap_id) end_snap from dba_hist_snapshot;
column awrfile_name new_value awrfile
select 'awrrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&awr_begin_snap) || '_' || to_char(&&awr_end_snap) ||'_all' awrfile_name from dual;

spool &&awrfile..html
select output from table(dbms_workload_repository.awr_report_html(&&awr_dbid,&&awr_inst_num,&&awr_begin_snap,&&awr_end_snap));
spool off;

exit;
