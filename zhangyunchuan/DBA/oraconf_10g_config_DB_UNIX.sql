-- Version: 2.0.2
-- HTML Header OraConf 2.0.0
-- Build Version: 1
-- Copyright: Oracle Corp.
-- For info please email John.OConnor@oracle.com

set echo off
set feedback off
set ver off
set pagesize 50000
set linesize 400
set trimspool on
set trim on
set define on

WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET SERVEROUTPUT ON SIZE 10000 FORMAT WRAPPED;

DECLARE
  v_sysdba varchar2(255);
BEGIN
  BEGIN
    SELECT DISTINCT username
    INTO   v_sysdba
    FROM   user_sys_privs
    WHERE  username = (SELECT USER FROM dual);
  
    IF v_sysdba != 'SYS'
    THEN
      raise_application_error(-20101,
                              'Expecting an user with SYSDBA privilegies! Please use an user with SYSDBA privilegies');
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      dbms_output.put_line('Expecting an user with SYSDBA privilegies! Please use an user with SYSDBA privilegies');
  END;
END;
/

WHENEVER SQLERROR continue;

REM ioprea/joconnor 12.jan.07  BUG5642124 for 10g is using /*+ rule*/ hint

COL VERSION NEW_VALUE VERSION;
set termout off
SELECT case WHEN version like '10%' then '+ rule' end VERSION FROM v$instance; 
set termout on

REM joconnor 17.nov.08  BUG7574891 for 10.1 asm selects
COL CA_ASM1 NEW_VALUE CA_ASM1
COL CA_ASM2 NEW_VALUE CA_ASM2
set termout off

SELECT case WHEN   version like '10.1%' then ' '
            else ',SOFTWARE_VERSION, COMPATIBLE_VERSION'
            end  CA_ASM1 FROM v$instance;

SELECT case WHEN   version like '10.1%' then ' '
            else ',OFFLINE_DISKS, COMPATIBILITY, DATABASE_COMPATIBILITY'
            end  CA_ASM2 FROM v$instance;

set termout on

set markup html on

col inst4dir noprint new_value inst_name
col thread# noprint new_value thread_nr
col instance_number noprint new_value inst_nr
set markup html off
select instance_number,instance_name "inst4dir" from v$instance
/
set markup html on
host mkdir ../../../out/ORADB_&inst_name
set markup html off; 
set termout on; 
prompt ORACONF:  database.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/database.html

-- Title: Basic database information

select /*ORACONF*/
  name,
  log_mode,
  to_char(created,'DD-MON-YY HH24:MI') "CREATED"
from v$database
/


spool off

set termout off;
set heading off;
set markup html off;


spool ../../../out/ORADB_&inst_name/sp_control.text
set termout off; 
prompt 2.2.0

spool off
spool ../../../out/ORADB_&inst_name/db_facts.text

 select  /*ORACONF*/ 'version = '|| version from v$instance;
 select  /*ORACONF*/ 'charset = '||value from nls_database_parameters where parameter = 'NLS_CHARACTERSET';
 select  /*ORACONF*/ 'ncharset = '||value from nls_database_parameters where parameter = 'NLS_NCHAR_CHARACTERSET';
 select  /*ORACONF*/ 'hostname = '|| host_name from v$instance;
 select  /*ORACONF*/ 'db_status = '|| database_status from v$instance;
 select  /*ORACONF*/ 'log_mode = '||log_mode from v$database;
 select  /*ORACONF*/ 'cpu_count = '|| value from v$parameter where name like 'cpu_count'; 
 select  /*ORACONF*/ 'optimizer = '|| value from v$parameter where name like 'optimizer_mode'; 
 select 'datafiles = '||to_char(sum(bytes/1024/1024),99999990) from v$dataFile;
 select 'tempfiles = '||to_char(sum(bytes/1024/1024),99999990) from v$tempFile;
 
set heading on;
set termout on;

set markup html on;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  instance.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/instance.html

-- Title: Database instance

select /*ORACONF*/
  instance_number "INSTANCE" ,
  instance_name,
  host_name "HOST_NAME",
  to_char(startup_time,'DD-MON-YY HH24:MI') "STARTUP"
from v$instance
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dbversion.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dbversion.html

-- Title: Database version

select /*ORACONF*/
 banner "Banner"
from
 sys.v$version
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dboptions.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dboptions.html

-- Title: Database options

select /*ORACONF*/
 parameter "Option",
 value "Installed?"
from
 sys.v$option
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  init_nondef.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/init_nondef.html

-- Title: Non-default init.ora parameters

select /*ORACONF*/
 a.ksppinm "Parameter",
 b.ksppstvl "Value",
 a.ksppdesc "Description"
from
 sys.x$ksppi a, sys.x$ksppsv b
where
 a.indx=b.indx and upper(b.ksppstdf)='FALSE'
 order by a.ksppinm
/



spool off
set markup html off;
spool ../../../out/ORADB_&inst_name/dbparameter_config.text
set termout off;

-- DB-Config parameter
column "col1" format a29 heading "Parameter name"
column "col2" format a55 wrap heading "non default value"

select  /*ORACONF*/ name "col1",value "col2" from v$parameter a
where a.isdefault = 'FALSE' AND
a.name not like '\_\_%' ESCAPE '\'
order by 1
/

spool off
spool ../../../out/ORADB_&inst_name/redolog_files_doc.text
set termout off;
col "Redolog-file" format a50 wrap heading "Redolog-file" on
col "Group" format 999 heading "Group" on
col "Instance" format 999999 heading "Instance" on
col "Type" format a10 heading "Type" on 

select /*ORACONF*/ a.member "Redolog-file"
      , a.Group# "Group"
      ,b.thread# "Instance"
      , a.Type "Type"
 from v$logfile a, v$log b
 where a.group#=b.group#
 order by 3,4,2; 



set termout on;

spool off
spool ../../../out/ORADB_&inst_name/parameter_undo.text
set termout off;

col "Parameter" format a48 heading "Initialization Parameter" on
col "Value" format a20 heading "Value" on
col "Default" format a10 heading "IsDefault" on

select /*ORACONF*/
a.ksppinm "Parameter",
b.ksppstvl "Value",
b.ksppstdf "Default"
from
sys.x$ksppi a, sys.x$ksppsv b
where a.ksppinm like '%undo%'
and substr(a.ksppinm,1,1) != '_'
and a.indx=b.indx 
order by a.ksppinm;

set termout on;
spool off
spool ../../../out/ORADB_&inst_name/parameter_parallelism.text
set termout off;

col "Parameter" format a48 heading "Initialization Parameter" on
col "Value" format a20 heading "Value" on
col "Default" format a10 heading "IsDefault" on

select /*ORACONF*/
a.ksppinm "Parameter",
b.ksppstvl "Value",
b.ksppstdf "Default"
from
sys.x$ksppi a, sys.x$ksppsv b
where a.ksppinm like 'parallel%'
and a.indx=b.indx
order by a.ksppinm;

set termout on;
spool off

spool ../../../out/ORADB_&inst_name/parameter_jobqueue.text
set termout off;

col "Parameter" format a48 heading "Initialization Parameter" on
col "Value" format a20 heading "Value" on
col "Default" format a10 heading "IsDefault" on

select /*ORACONF*/
a.ksppinm "Parameter",
b.ksppstvl "Value",
b.ksppstdf "Default"
from
sys.x$ksppi a, sys.x$ksppsv b
where a.ksppinm like 'job_queue_%'
and a.indx=b.indx
order by a.ksppinm;

REM JOC Don't seem to need following three lines, so REM them
REM set termout on;
REM spool off
REM set markup html on;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  init_all.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/init_all.html

-- Title: Init.ora parameters (including hidden)

select /*ORACONF*/
 a.ksppinm "Parameter",
 b.ksppstvl "Value",
 b.ksppstdf "Default",
 a.ksppdesc "Description"
from
 sys.x$ksppi a, sys.x$ksppsv b
where
 a.indx=b.indx order by a.ksppinm
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  init_hidden.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/init_hidden.html
-- Title: Hidden init.ora Parameter

col "Parameter" format a20 wrap heading "Parametername"
col "Value" format a15 wrap heading "Value"
col "Description" format a40 wrap heading "Description"

select /*ORACONF*/
 a.ksppinm "Parameter",
 b.ksppstvl "Value",
 a.ksppdesc "Description"
from
 sys.x$ksppi a, sys.x$ksppsv b
where
 a.indx=b.indx 
 and b.ksppstdf = 'FALSE'
 and substr(a.ksppinm,1,1) = '_'
 order by a.ksppinm
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  db_facts.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/db_facts.html
set termout off;
set heading off;

 select  /*ORACONF*/ 'version = '|| version from v$instance;
 select  /*ORACONF*/ 'charset = '||value from nls_database_parameters where parameter = 'NLS_CHARACTERSET';
 select  /*ORACONF*/ 'ncharset = '||value from nls_database_parameters where parameter = 'NLS_NCHAR_CHARACTERSET';
 select  /*ORACONF*/ 'hostname = '|| host_name from v$instance;
 select  /*ORACONF*/ 'db_status = '|| database_status from v$instance;
 select  /*ORACONF*/ 'log_mode = '||log_mode from v$database;
 select  /*ORACONF*/ 'cpu_count = '|| value from v$parameter where name like 'cpu_count'; 
 select  /*ORACONF*/ 'optimizer = '|| value from v$parameter where name like 'optimizer_mode'; 
 select 'datafiles = '||to_char(sum(bytes/1024/1024),99999990) from v$dataFile;
 select 'tempfiles = '||to_char(sum(bytes/1024/1024),99999990) from v$tempFile;
set heading on;
set termout on;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  os_facts.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/os_facts.html

spool off 

 host echo uname_osrelease = `uname -r`>> ../../../out/ORADB_&inst_name/os_facts.text 2>/dev/null
 host echo uname_plattform = `uname`   >> ../../../out/ORADB_&inst_name/os_facts.text 2>/dev/null
 host echo uname = `uname -a`          >> ../../../out/ORADB_&inst_name/os_facts.text 2>/dev/null
REM host echo uname_hardware = `uname -i` >> ../../../out/ORADB_&inst_name/os_facts.text 2>/dev/null
host echo uname_hardware = `uname -sm` >> ../../../out/ORADB_&inst_name/os_facts.text 2>/dev/null
 host echo instance_count = `ps -ef | grep -i pmon | grep -v grep | wc -l` >> ../../../out/ORADB_&inst_name/os_facts.text 2>/dev/null

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  sparse_indexes.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/sparse_indexes.html

-- Title: Normal indexes that should be rebuilt

column index_name format a40
column part_name format a20
column subpart_name format a20
column last_ddl_time  format a13
column x noprint new_value x
column last_analyzed format a13
column compression format a11

define density='75'

define obj = 'nvl(isp.obj#, nvl(ip.obj#,i.obj#))'
define objp = 'nvl(ip.obj#,i.obj#)'
define rowcnt = 'decode(&obj, isp.obj#, isp.rowcnt, ip.obj#, ip.rowcnt, i.rowcnt)'
define leafcnt = 'decode(&obj, isp.obj#, isp.leafcnt, ip.obj#, ip.leafcnt, i.leafcnt)'
define pctf = 'decode(&obj, isp.obj#, isp.pctfree$, ip.obj#, ip.pctfree$, i.pctfree$)'
define initr = 'decode(&obj, isp.obj#, isp.initrans, ip.obj#, ip.initrans, i.initrans)'
define last_analyzed = 'nvl(decode(&obj, isp.obj#, isp.analyzetime, ip.obj#, ip.analyzetime, i.analyzetime),to_date(''01.01.1900'',''dd.mm.yyyy''))'
define compress = 'decode(&obj, isp.obj#, ''N/A'', ip.obj#, decode(bitand(ip.flags, 1024), 0, ''DISABLED'', 1024, ''ENABLED'',''N/A''), decode(bitand(i.flags, 32), 0, ''DISABLED'', 32, ''ENABLED'',''N/A''))'

select  /*ORACONF*/ /*+ ordered */
  u.name ||'.'|| o.name  index_name,
  op.subname part_name,
  decode(&obj, isp.obj#, o.subname, '') subpart_name,
  to_char(100*(1 - floor( &leafcnt -
    &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
  )/&leafcnt),'999.00') ||'%' density,
  floor( &leafcnt -
  &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
  ) extra_blocks,
  max(o.mtime) last_ddl_time,
  decode(max(&last_analyzed),to_date('01.01.1900','dd.mm.yyyy'),'not analyzed',max(&last_analyzed)) last_analyzed,
  max(&compress) compression
from
  sys.ind$  i,
  sys.icol$  ic,
  ( select obj#, part#, bo#, ts#, rowcnt, leafcnt, initrans, pctfree$, analyzetime, flags from sys.indpart$
    union all
    select  /*ORACONF*/ obj#, part#, bo#, defts#, rowcnt, leafcnt, definitrans, defpctfree, analyzetime, flags from sys.indcompart$ ) ip,
  sys.indsubpart$ isp,
  ( select ts#, blocksize value
    from sys.ts$
      )  p,
  sys.hist_head$  h,
  sys.obj$  o,
  sys.user$  u,
  sys.obj$  op
where
  i.obj# = ip.bo#(+) and
  ip.obj# = isp.pobj#(+) and
  &leafcnt > 1 and
  i.type# in (1) and -- exclude special types
  i.pctthres$ is null and -- exclude IOT secondary indexes
  decode(&obj, isp.obj#, isp.ts#, ip.obj#, ip.ts#, i.ts#) = p.ts# and
  ic.obj# = i.obj# and
  h.obj# = i.bo# and
  h.intcol# = ic.intcol# and
  o.obj# = &obj and
  o.owner# NOT IN (select USER# from sys.user$ where NAME in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )) and
  u.user# = o.owner# and
  op.obj# = &objp
group by
  u.name,
  o.name,
  op.subname,
  decode(&obj, isp.obj#, o.subname, ''),
  &rowcnt,
  &leafcnt,
  &initr,
  &pctf,
  p.value
  having
    100*(1 - floor( &leafcnt -
    &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
    )/&leafcnt) <= nvl('&density','75') and
    floor( &leafcnt -
      &rowcnt * (sum(h.avgcln) + 10) / ((p.value - 66 - &initr * 24)*(1 - &pctf/100))
    ) > 0
order by
  5 desc, 4
/

undefine rowcnt
undefine leafcnt
undefine pctf
undefine initr
undefine last_analyzed
undefine compress
undefine obj
undefine density

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  sparse_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/sparse_tables.html
-- List all SPARSE Tables

col "Owner" format a11 wrap heading "Owner"
col "Table" format a18 wrap heading "Tablename"
col "Partition" format a10 wrap heading "Partition"
col "Blocks" format 99999999 heading "Used Blocks"
col "Avg. Bytes/Block" format 99999D99 heading "avg. KBytes|/Block"
col "Pct used" format 999 heading "Pct|Used"
col "Pct free" format 999 heading "Pct|Free"
col "Freelists" format 999 heading "Free|lists"
col "last_analyzed" format a11 heading "last|Analyzed"

col "RowCount" format 9999999999 heading "Row Count"
col "Empty_Blk" format 9999999999 heading "Empty Blocks"
col "Free_Spc" format 9999999999 heading "Free Block Space"
col "Avg_Row_Len" format 999999999 heading "Avg Row Length"
col "HWM" format 999999999 heading "HWM"
col "Useds" format 999999999 heading "Useds"
     

SELECT /*ORACONF*/
 table_owner "Owner",
 table_name "Table",
 a.partition_name "Partition",
 trunc(a.num_rows * a.avg_row_len / a.blocks) / 1024 "Avg. Bytes/Block",
 a.blocks "Blocks",
 a.num_rows "RowCount",
 a.empty_blocks "Empty_Blk",
 a.avg_space "Free_Spc",
 a.avg_row_len "Avg_Row_Len",
 (b.blocks - a.empty_blocks - 1) hwm,
 (a.num_rows * a.avg_row_len) / 1024 useds,
 nvl(to_char(a.pct_used,
             999),
     '   -') "Pct used",
 nvl(to_char(a.pct_free,
             999),
     '   -') "Pct free",
 nvl(to_char(a.freelists,
             9999),
     '    -') "Freelists",
 nvl(to_char(a.last_analyzed,
             'DD-MON-YY'),
     'not analyzed') "last_analyzed"
FROM   dba_tab_partitions a,
       dba_segments       b
WHERE  a.num_rows * a.avg_row_len / a.blocks <
       (SELECT VALUE / 2
        FROM   v$parameter
        WHERE  lower(NAME) = 'db_block_size') AND
       extents > 1 AND
       a.table_owner = b.owner AND
       b.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
       a.table_name = b.segment_name AND
       a.partition_name = b.partition_name AND
       a.blocks > 100 AND
       a.num_rows > 0 AND
       a.last_analyzed IS NOT NULL
UNION ALL
SELECT /*ORACONF*/
 a.owner "Owner",
 table_name "Table",
 'n/a' "Partition",
 trunc(a.num_rows * a.avg_row_len / a.blocks) / 1024 "Avg. Bytes/Block",
 a.blocks "Blocks",
 a.num_rows "RowCount",
 a.empty_blocks "Empty_Blk",
 a.avg_space "Free_Spc",
 a.avg_row_len "Avg_Row_Len",
 (b.blocks - a.empty_blocks - 1) hwm,
 (a.num_rows * a.avg_row_len) / 1024 useds,
 nvl(to_char(a.pct_used,
             999),
     '   -') "Pct used",
 nvl(to_char(a.pct_free,
             999),
     '   -') "Pct free",
 nvl(to_char(a.freelists,
             9999),
     '    -') "Freelists",
 nvl(to_char(a.last_analyzed,
             'DD-MON-YY'),
     'not analyzed') "last_analyzed"
FROM   dba_tables   a,
       dba_segments b
WHERE  a.num_rows * a.avg_row_len / a.blocks <
       (SELECT VALUE / 2
        FROM   v$parameter
        WHERE  lower(NAME) = 'db_block_size') AND
       extents > 1 AND
       a.owner = b.owner AND
       b.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
       a.table_name = b.segment_name AND
       a.blocks > 100 AND
       a.num_rows > 0 AND
       a.tablespace_name <> ' ' AND
       a.last_analyzed IS NOT NULL
ORDER  BY "Avg. Bytes/Block" DESC;

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  low_maxtrans.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/low_maxtrans.html

-- Title: Objects with MAXTRANS set low

-- Hint: can lead to enqueue waits (TX shared mode)

select /*ORACONF*/
  table_name, owner, max_trans
from dba_tables
where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
max_trans between 1 and 20
/

select /*ORACONF*/
  index_name, owner, max_trans
from dba_indexes
where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
max_trans between 1 and 20
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  row_migration.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/row_migration.html

-- Title: Chained and migrated rows

-- Hint: Output only valid if tables have been analyzed

select /*ORACONF*/
 owner "Owner",
 table_name "Table Name",
 pct_free "Pct free",
 pct_used "Pct used",
 num_rows "Nr of Rows",
 CHAIN_CNT "Chain Cnt",
 AVG_ROW_LEN "Avg. Row Len",
 round(100*chain_cnt/num_rows,2) "% migrated"
from
 dba_tables
where
 owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) 
and num_rows > 0
and chain_cnt>0
order by chain_cnt/num_rows
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  many_extents.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/many_extents.html

-- Title: Objects with many extents in dict. managed tablespaces

-- Hint: Can have a major impact when dropping the object

column segment_name format a25

select /*ORACONF*/
a.owner,a.segment_name,a.SEGMENT_TYPE,a.extents from
dba_segments a,dba_tablespaces b
where a.tablespace_name=b.tablespace_name
and a.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
and b.EXTENT_MANAGEMENT='DICTIONARY'
and a.extents>200
order by 4 desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  extents_used_75.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/extents_used_75.html

-- Title: Segments with more than 75% of max extents

select /*ORACONF*/
 OWNER "Owner",
 TABLESPACE_NAME "Tablespace",
 SEGMENT_NAME "Segment",
 SEGMENT_TYPE "Segment Type",
 BYTES "Size",
 EXTENTS "Extents",
 MAX_EXTENTS "Max. Extents",
 (EXTENTS/MAX_EXTENTS)*100 "% of Max Extents used"
from
 dba_segments
where
 SEGMENT_TYPE in ('TABLE','INDEX') and EXTENTS > MAX_EXTENTS/4*3
 and OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 order by (EXTENTS/MAX_EXTENTS) desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  unextendible_objects.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/unextendible_objects.html

-- Title: Objects that cannot extend

select /*ORACONF*/
  s.owner "Owner",
  s.segment_name "Segment",
  s.partition_name "Partition",
  s.extents "Extents",
  to_char(decode(t.extent_management,'LOCAL',t.min_extlen,s.next_extent)/1024,'9999999999.99') || 'K' "Next Extent",
  s.tablespace_name "Tablespace",
  decode(t.extent_management,'LOCAL','',s.max_extents) "Max Extents"
from
 sys.dba_tablespaces t, sys.dba_segments s
where
  s.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
  and
  s.tablespace_name = t.tablespace_name
  and
  t.status = 'ONLINE'
  and
  ( ( decode(t.extent_management,'LOCAL',t.min_extlen,s.next_extent)
      >
      (select max(bytes)
        from sys.dba_free_space
        where tablespace_name = s.tablespace_name
      )
      and not exists
        (select *
         from dba_data_files
         where
           tablespace_name = s.tablespace_name
           and
           autoextensible='YES'
           and
           (maxbytes - bytes) >= decode(t.extent_management,'LOCAL',t.min_extlen,s.next_extent)))
    or
    s.extents = decode(t.extent_management,'LOCAL',0,s.max_extents)
  )
order by s.tablespace_name,s.segment_name,s.partition_name
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  invalid_objects.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/invalid_objects.html

-- Title: Invalid objects

select /*ORACONF*/
 OWNER "Owner",
 OBJECT_TYPE "Object Type",
 OBJECT_NAME "Object Name",
 STATUS "Status"
from
 dba_objects
where
 STATUS = 'INVALID' AND
 OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
order by OWNER, OBJECT_TYPE, OBJECT_NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  all_errors.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/all_errors.html

-- Title: ALL_ERRORS to add information for invalid objects

select /*ORACONF*/
 owner,
 name,
 type,
 text
from
 all_errors
where
 OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
order by 1,2
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  analyzed_dict.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/analyzed_dict.html

-- Title: Analyzed data dictionary tables

select /*ORACONF*/
 'Analyzed Objects' "Dictionary",
 count(*) "Number of Objects"
from
 all_tables
where
 OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 and num_rows > 0
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  system_users.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/system_users.html
-- Title: Users with objects in the SYSTEM tablespace

col "Col1" format a20 wrap heading "User"
col "Col2" format a25 wrap heading "Segment Name"
col "Col3" format a8 wrap heading "Type"
col "Col4" format a15 wrap heading "Tablespace"
col "Col5" format 999999D99 heading "Size (MB)"

select /*ORACONF*/
 OWNER "Col1",
 SEGMENT_NAME "Col2",
 SEGMENT_TYPE "Col3",
 TABLESPACE_NAME "Col4",
 BYTES/1024/1024 "Col5"
from
 dba_segments
where
 TABLESPACE_NAME = 'SYSTEM' and OWNER not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 order by OWNER, SEGMENT_NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  hot_backup_mode.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/hot_backup_mode.html

-- Title: Tablespaces in hot backup mode

select /*ORACONF*/
 f.name "File",
 b.status "Status",
 b.change# "Change#",
 b.time "Time"
from
 v$backup b, v$datafile f
where
 b.status='ACTIVE' and b.file#=f.file#
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  rman_corruptions.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/rman_corruptions.html

-- Title: Corruptions found during RMAN Backup / Copy

-- v$backup_corruption, v$copy_corruption describe
-- corrupt blocks which existed in some particular backup.  The backup in which
-- the corrupt blocks were found is identified by the set_stamp and set_count
-- columns.  Even if the block is fixed later, that does not change the fact
-- that the block is corrupt in *that particular* backup.
-- In 9.2, we are introducing a new view, v$database_block_corruption,
-- which recognizes that a block is no longer corrupt if another backup, or
-- copy, done with RMAN has scanned the file and found that the block is OK.


-- Hint: Backup corruption

select /*ORACONF*/
file#,block#,recid,stamp
from v$backup_corruption;

-- Hint: Copy corruption

select /*ORACONF*/
file#,block#,recid,stamp
from v$copy_corruption;


-- Hint: Corruptions that have not been recovered so far

select /*ORACONF*/
file#,block#,blocks,CORRUPTION_TYPE
from V$DATABASE_BLOCK_CORRUPTION;

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_default_tbs_system.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_default_tbs_system.html
-- Title: User default tablespaces SYSTEM or temporary tablespace not correct

col "Col1" format a20 wrap heading "User"
col "Col2" format a16 wrap heading "Status"
col "Col3" format a20 wrap heading "Default|Tablespace"
col "Col4" format a20 wrap heading "Temp|Tablespace"

select /*ORACONF*/
 USERNAME "Col1",
 ACCOUNT_STATUS "Col2",
 DEFAULT_TABLESPACE "Col3",
 TEMPORARY_TABLESPACE "Col4"
from
 dba_users 
 where
 USERNAME NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
(  
   temporary_tablespace not in (select tablespace_name 
                                 from dba_tablespaces 
                                 where contents = 'TEMPORARY')
    or
    default_tablespace = 'SYSTEM'                               
)   
order by 2,3,4,1
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  chk_dblinks.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/chk_dblinks.html
set serveroutput on size 1000000
set markup html off
spool off
spool ../../../out/ORADB_&inst_name/test_dblink.lst
declare      
  crstr       varchar2(200);
  drstr       varchar2(200);
  selstr      varchar2(200);
  linkowner   varchar2(200);
  tabnum      number;
  dbl_created number;
begin
   for c in (select * from link$ where userid is not null and passwordx is not null) loop
      begin
         crstr := 'create database link '||c.name||
                  ' connect to '||c.userid||
                  ' identified by '||c.passwordx;
         if c.host is not null then
            crstr := crstr||
                     ' using '''||c.host||'''';
         end if;
         execute immediate crstr;
         dbl_created := 1;
         exception
            when others then
               dbl_created := 0;
      end;
      begin
      select  /*ORACONF*/ name into linkowner from user$ where user#=c.owner#;
         selstr := 'select count(*) from tab@'||c.name;
         execute immediate selstr into tabnum;
         dbms_output.put_line('Testing Database Link '||linkowner||'.'||c.name||' --> ok'); 
         exception
            when others then
                 dbms_output.put_line('Testing Database Link '||linkowner||'.'||c.name||'  --> error '||substr(sqlerrm,1,100));
      end;
      begin
         if dbl_created = 1 then
            drstr := 'drop database link '||c.name;
            execute immediate drstr;
         end if;
      end;
   end loop;
end;
/

set markup html on

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tablespaces.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tablespaces.html

-- Title: Tablespace summary

select /*ORACONF*/
 TABLESPACE_NAME "Tablespace",
 INITIAL_EXTENT "Initial extent",
 NEXT_EXTENT "Next extent",
 MIN_EXTENTS "Min extents",
 MAX_EXTENTS "Max extents",
 PCT_INCREASE "Pct Increase",
 MIN_EXTLEN "Min extlen",
 STATUS "Status",
 decode(CONTENTS,'PERMANENT','PERM','TEMPORARY','TEMP',CONTENTS) "Content",
 decode(LOGGING,'LOGGING','YES','NOLOGGING','NO',LOGGING) "Logging",
 decode(EXTENT_MANAGEMENT,'DICTIONARY','DICT',EXTENT_MANAGEMENT) "Extent management",
 SEGMENT_SPACE_MANAGEMENT "Segment space management",
 BLOCK_SIZE "Block size",
 ALLOCATION_TYPE "Allocation type",
 PLUGGED_IN "Plugged in"
from
 dba_tablespaces order by tablespace_name
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tablespace_usage.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tablespace_usage.html

-- Title: Tablespace usage

select /*ORACONF*/
 a.TABLESPACE_NAME "Tablespace",
 round(a.BYTES/(1024*1024),2) "Size (MB)",
 round((a.BYTES-b.BYTES)/(1024*1024),2) "Used Space (MB)",
 round(b.BYTES/(1024*1024),2) "Free Space (MB)",
 round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) "% filled"
from
(select TABLESPACE_NAME, sum(BYTES) BYTES
 from dba_data_files
 group by TABLESPACE_NAME) a,
(select TABLESPACE_NAME, sum(BYTES) BYTES
 from dba_free_space
 group by TABLESPACE_NAME) b
where
 a.TABLESPACE_NAME=b.TABLESPACE_NAME
 order by ((a.BYTES-b.BYTES)/a.BYTES) desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tablespace_free_space.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tablespace_free_space.html

-- Title: Tablespace free space and largest extent

select /*ORACONF*/
 TABLESPACE_NAME "Tablespace",
 sum(BYTES) "Free Space (Bytes)",
 max(BYTES) "Largest Extent (Bytes)"
from
 dba_free_space group by tablespace_name
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  datafiles.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/datafiles.html

-- Title: Datafiles

select /*ORACONF*/
 file_name "Filename",
 tablespace_name "Tablespace",
 file_id "File ID",
 relative_fno "Rel. Fileno",
 status "Status",
 bytes "Size",
 to_char(bytes/1024/1024,'999999999.99') "Size (MB)",
 autoextensible "Auto Ext."
from
 dba_data_files
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tempfiles.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tempfiles.html
-- > ioprea   12/12/2006 added the tablespace TEMPORARY section

-- Title: Temporary datafiles

SELECT /*ORACONF*/
 file_name "Filename",
 tablespace_name "Tablespace",
 file_id "File ID",
 relative_fno "Rel. Fileno",
 status "Status",
 bytes "Size",
 to_char(bytes / 1024 / 1024,
         '999999999.99') "Size (MB)",
 autoextensible "Auto Ext."
FROM   dba_temp_files
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  temp_datafiles.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/temp_datafiles.html
-- Title: tablespace TEMPORARY

SELECT /*ORACONF*/
 file_name "Filename",
 tablespace_name "Tablespace",
 file_id "File ID",
 relative_fno "Rel. Fileno",
 status "Status",
 bytes "Size",
 to_char(bytes / 1024 / 1024,
         '999999999.99') "Size (MB)",
 autoextensible "Auto Ext."
FROM   dba_data_files df
WHERE  EXISTS (SELECT 'X'
        FROM   dba_tablespaces dt
        WHERE  dt.tablespace_name = df.tablespace_name AND
               dt.contents = 'TEMPORARY')
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  autoextension.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/autoextension.html

-- Title: Autoextesible datafiles

select /*ORACONF*/
 FILE_NAME "File name",
 TABLESPACE_NAME "Tablespace",
 BYTES "Size",
 STATUS "Status",
 MAXBYTES "Max (Bytes)",
 INCREMENT_BY "Increment by"
from
 dba_data_files
where
 AUTOEXTENSIBLE = 'YES' order by TABLESPACE_NAME, FILE_NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  logfiles.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/logfiles.html

-- Title: Logfiles

select /*ORACONF*/
 a.MEMBER "Member",
 b.GROUP# "Group",
 b.THREAD# "Thread",
 b.SEQUENCE# "Sequence",
 b.BYTES "Size",
 to_char(b.bytes/1024/1024,'999999999.99') "Size (MB)",
 b.MEMBERS "Members",
 b.ARCHIVED "Archived",
 b.STATUS "Status",
 b.FIRST_CHANGE# "First Change",
 b.FIRST_TIME "First Time"
from
 sys.v_$logfile a, sys.v_$log b
where
 a.GROUP# = b.GROUP# order by a.MEMBER
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  controlfiles.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/controlfiles.html

-- Title: Controlfiles

select /*ORACONF*/
 name "Filename",
 status "Status"
from
 sys.v$controlfile
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  rollback_segments.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/rollback_segments.html

-- Title: Rollback segments

select /*ORACONF*/
 SEGMENT_NAME "Segment",
 OWNER "Owner",
 TABLESPACE_NAME "Tablespace",
 SEGMENT_ID "Segment ID",
 FILE_ID "File ID",
 BLOCK_ID "Block ID",
 decode(sign(INITIAL_EXTENT-(512*1024)),1,INITIAL_EXTENT/(1024*1024)||' mb',INITIAL_EXTENT||' b') "Initial extent",
 decode(sign(NEXT_EXTENT-(512*1024)),1,NEXT_EXTENT/(1024*1024)||' mb',NEXT_EXTENT||' b') "Next extent",
 MIN_EXTENTS "Min extents",
 MAX_EXTENTS "Max extents",
 PCT_INCREASE "% increase",
 STATUS "Status",
 INSTANCE_NUM "Instance"
from
 dba_rollback_segs
where
OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
order by SEGMENT_NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  rollback_segments_usage.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/rollback_segments_usage.html

-- Title: Rollback segment usage

select /*ORACONF*/
 b.NAME "Segment",
 a.USN "Seg. Nr",
 GETS "Gets",
 WAITS "Waits",
 round(((GETS-WAITS)*100)/GETS,2) "% Successful Gets",
 XACTS "Transactions",
 WRITES "Writes"
from
 sys.v_$rollstat a, sys.v_$rollname b
where
 a.USN = b.USN
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  rollback_growth.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/rollback_growth.html

-- Title: Rollback growth

select /*ORACONF*/
 NAME "Segment",
 a.USN "Seg Nr.",
 RSSIZE "Size",
 OPTSIZE "Optimal Size",
 HWMSIZE "Highwater Mark",
 EXTENDS "Extents",
 WRAPS "Wraps",
 SHRINKS "Shrinks",
 AVESHRINK "Avg. Shrink",
 AVEACTIVE "Avg. Active",
 STATUS "Status"
from
 sys.v_$rollstat a, sys.v_$rollname b
where
 a.USN=b.USN order by NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  bgprocess.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/bgprocess.html

-- Title: Background processes

select /*ORACONF*/
 s.sid "SID",
 b.name "Process",
 p.spid "OS PID",
 b.description "Description"
from
 sys.v$session s,sys.v$bgprocess b, v$process p
where
 s.paddr=b.paddr and s.paddr=p.addr
 order by sid
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_sessions.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_sessions.html

-- Title: User sessions

select /*ORACONF*/
 nvl( username, 'background') "Username",
 program "Program",
 server "Server",
 count(*) "Sessions"
from
 sys.v_$session
where
 type='USER'
 and program not like '%QMN%'
 and program not like '%CJQ%'
group by username, program, server
order by count(*) desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_default_tablespaces.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_default_tablespaces.html

-- Title: User default tablespaces

SELECT /*ORACONF*/
 username             "User",
 created              "Created",
 profile              "Profile",
 account_status       "Account Status",
 default_tablespace   "Default Tablespace",
 temporary_tablespace "Temporary Tablespace"
FROM   dba_users
WHERE  username NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
ORDER  BY account_status,
          default_tablespace,
          temporary_tablespace,
          username;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_object_overview.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_object_overview.html

-- Title: User object overview

select /*ORACONF*/
 USERNAME "User",
 count(decode(o.TYPE#, 2,o.OBJ#,'')) "Tables",
 count(decode(o.TYPE#, 1,o.OBJ#,'')) "Indexes",
 count(decode(o.TYPE#, 5,o.OBJ#,'')) "Synonyms",
 count(decode(o.TYPE#, 4,o.OBJ#,'')) "Views",
 count(decode(o.TYPE#, 6,o.OBJ#,'')) "Sequences",
 count(decode(o.TYPE#, 7,o.OBJ#,'')) "Procedures",
 count(decode(o.TYPE#, 8,o.OBJ#,'')) "Functions",
 count(decode(o.TYPE#, 9,o.OBJ#,'')) "Packages",
 count(decode(o.TYPE#,12,o.OBJ#,'')) "Triggers",
 count(decode(o.TYPE#,10,o.OBJ#,'')) "Non-Existant"
from
 sys.obj$ o, dba_users u
where 
 u.USERNAME NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
 u.USER_ID = o.OWNER# (+) and o.TYPE# is NOT NULL
 group by USERNAME order by USERNAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_space_allocated.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_space_allocated.html

-- Title: User space allocated

select /*ORACONF*/
 OWNER "Owner",
 SEGMENT_TYPE "Segment Type",
 round(sum(BYTES)/(1024*1024),2) "Total (MB)"
from
 dba_segments
where
 OWNER not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) group by OWNER, SEGMENT_TYPE
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_tablespace_quotas.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_tablespace_quotas.html

-- Title: User tablespace quotas

select /*ORACONF*/
 TABLESPACE_NAME "Tablespace",
 USERNAME "User",
 BYTES "Size",
 MAX_BYTES "Max size",
 BLOCKS "Blocks",
 MAX_BLOCKS "Max blocks"
from
 dba_ts_quotas 
where
 USERNAME NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
order by 
 TABLESPACE_NAME, USERNAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  user_privs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/user_privs.html
-- Title: Users with to many privileges

col "Col1" format a30 wrap heading "User"
col "Col2" format a30 wrap heading "Privilege"
col "Col3" format a12 wrap heading "Admin Option"


select  /*ORACONF*/ * from 
(	select /*ORACONF*/
	 Grantee "Col1",
	 granted_role "Col2", 
	 admin_option "Col3"
	from
	 dba_role_privs
	where
	 granted_role='DBA'
union
	select /*ORACONF*/
	 Grantee  "Col1", 
	 privilege "Col2", 
	 admin_option "Col3"
	from
	 dba_sys_privs
	where
	 privilege in ('GRANT ANY PRIVILEGE','GRANT ANY ROLE')
	 and Grantee <> 'DBA'
union
        select  /*ORACONF*/ username "Col1", 
       decode(sysdba||sysoper,'TRUETRUE','SYSDBA,SYSOPER','TRUEFALSE','SYSDBA','FALSETRUE','SYSOPER','FALSEFALSE','n/a') "Col2",
       'NO' "Col3"
        from
        v$pwfile_users
)
order by 1	 
;

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  redolog_history.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/redolog_history.html

-- Title: Redo log switch history

select /*ORACONF*/
 substr(to_char(FIRST_TIME,'YYYY/MM/DD'),1,10) "Day",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) "00",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) "01",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) "02",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) "03",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) "04",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) "05",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) "06",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) "07",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) "08",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) "09",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) "10",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) "11",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) "12",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) "13",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) "14",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) "15",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) "16",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) "17",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) "18",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) "19",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) "20",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) "21",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) "22",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) "23",
 decode(sum(1),0,'-',sum(1)) "Per Day"
from
 sys.v$log_history
where thread# = sys_context('USERENV','INSTANCE')
 group by substr(to_char(FIRST_TIME,'YYYY/MM/DD'),1,10)
 order by substr(to_char(FIRST_TIME,'YYYY/MM/DD'),1,10) desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  redolog_history_doc.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/redolog_history_doc.html

-- Title: Redo log switch history

select /*ORACONF*/
 substr(to_char(FIRST_TIME,'YYYY/MM/DD'),1,10) "Day",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) "00",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) "01",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) "02",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) "03",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) "04",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) "05",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) "06",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) "07",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) "08",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) "09",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) "10",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) "11",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) "12",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) "13",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) "14",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) "15",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) "16",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) "17",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) "18",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) "19",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) "20",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) "21",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) "22",
 decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) "23",
 decode(sum(1),0,'-',sum(1)) "Per Day"
from
 sys.v$log_history
 where FIRST_TIME > sysdate - 45
   and thread# = sys_context('USERENV','INSTANCE')
 group by substr(to_char(FIRST_TIME,'YYYY/MM/DD'),1,10)
 order by substr(to_char(FIRST_TIME,'YYYY/MM/DD'),1,10) desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  logsw_last_week.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/logsw_last_week.html

-- Title: Logswitches last week

select /*ORACONF*/
 SUM(CASE WHEN round((lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60) < 2 THEN 1 ELSE 0 END) "Logswitch < 2 min",
 SUM(CASE WHEN round((lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60) BETWEEN 2 AND 5 THEN 1 ELSE 0 END) "between 2 and 5 min",
 SUM(CASE WHEN round((lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60) BETWEEN 6 AND 15 THEN 1 ELSE 0 END) "between 6 and 15 min",
 SUM(CASE WHEN round((lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60) BETWEEN 16 AND 30 THEN 1 ELSE 0 END) "between 16 and 30 min",
 SUM(CASE WHEN round((lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60) BETWEEN 31 AND 60 THEN 1 ELSE 0 END) "between 31 and 60 min",
 SUM(CASE WHEN round((lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60) > 60 THEN 1 ELSE 0 END) "> 60 min"
from
 v$log_history lh1, v$log_history lh2
where
 lh1.SEQUENCE# + 1 = lh2.SEQUENCE#
 and lh1.SEQUENCE# < (select max(SEQUENCE#) from v$log_history )
 and lh1.first_time > sysdate -7
 and lh1.thread# = sys_context('USERENV','INSTANCE')
 and lh1.thread# = lh2.thread#
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  checkpoint_interval.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/checkpoint_interval.html

-- Title: CheckPoint interval (minutes)

select /*ORACONF*/
 round(min(lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60,2) "Minimum",
 round(max(lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60,2) "Maximum",
 round(avg(lh2.FIRST_TIME - lh1.FIRST_TIME) * 24 * 60,2) "Average"
from
 sys.v$log_history lh1, sys.v$log_history lh2
where
 lh1.SEQUENCE# + 1 = lh2.SEQUENCE#
 and lh1.SEQUENCE# < (select max(SEQUENCE#) from sys.v$log_history )
 and lh1.thread# = sys_context('USERENV','INSTANCE')
 and lh1.thread# = lh2.thread#
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  undo_stats.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/undo_stats.html

-- Title: Undo statistics

select /*ORACONF*/
 to_char(BEGIN_TIME,'DD-MON-YY HH24:MI') "Begin Time",
 to_char(END_TIME,'DD-MON-YY HH24:MI') "End Time",
 UNDOBLKS "Undo  blocks  consumed",
 TXNCOUNT "Transactions",
 MAXQUERYLEN "Longest query (sec.)",
 MAXCONCURRENCY "Max concurrent transactions",
 UNXPSTEALCNT "Unexpired stealing count",
 UNXPBLKRELCNT "Unexpired blocks removed",
 UNXPBLKREUCNT "Unexpired blocks reused",
 SSOLDERRCNT "Errors",
 NOSPACEERRCNT "Errors in instance"
from
 v$undostat
where
 UNXPSTEALCNT > 0
 or UNXPBLKRELCNT > 0
 or UNXPBLKREUCNT > 0
 or SSOLDERRCNT > 0
 or NOSPACEERRCNT > 0
order by 1
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  memparams.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/memparams.html

-- Title: Memory initialization parameters

-- FIXME: gibt Fehler bei Angaben mit Character, wie '10M'
--        to_char(value/1024/1024,'999999999.99') "Size (MB)"

select /*ORACONF*/
 name "Parameter",
 value "Size"
from
 sys.v$parameter
where
 lower(name) in ('sga_max_size','shared_pool_size','shared_pool_reserved_size',
 'large_pool_size','java_pool_size','sort_area_size','sort_area_retained_size',
 'bitmap_merge_area_size','hash_area_size','db_block_size','db_block_buffers',
 'db_cache_size','db_2k_cache_size','db_4k_cache_size','db_8k_cache_size',
 'db_16k_cache_size','db_32k_cache_size','db_keep_cache_size',
 'db_recycle_cache_size')
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  shared_pool.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/shared_pool.html

-- Title: Shared pool chunks on LRU list

select /*ORACONF*/
 kghluidx "Subheap",
 kghlurcr "Recurrent",
 kghlutrn "Transient Chunks",
 kghlufsh "Flushed Chunks",
 kghluops "Changes to LRU List",
 kghlunfu "ORA-4031 Errors",
 kghlunfs "Last Error Size"
from
 x$kghlu
where
 inst_id = userenv('Instance')
 order by kghluidx
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  reserved_pool.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/reserved_pool.html

-- Title: Reserved pool

select /*ORACONF*/
 (FREE_SPACE+USED_SPACE) "Total",
 FREE_SPACE "Free",
 USED_SPACE "Used",
 requests "Requests",
 request_failures "Request Failures"
from
 sys.v$shared_pool_reserved
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  sga.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/sga.html

-- Title: SGA allocation

select /*ORACONF*/
 'SGA Total' "Region",
 sum(value) "Size",
 to_char(sum(value)/1024/1024,'999999999.99') "Size (MB)"
from
 sys.v$sga
union
select /*ORACONF*/
 name,
 value,
 to_char(value/1024/1024,'999999999.99')
from
 sys.v$sga
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  latches.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/latches.html

-- Title: Top 10 latches

select  /*ORACONF*/ *
from (
 select /*ORACONF*/
 name "Latch",
 gets "Gets",
 misses "Misses",
 sleeps "Sleeps"
 from
 sys.v$latch
 where
 misses>0 or sleeps>0
 order by sleeps desc
)
where rownum < 11
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  no_idle_waits.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/no_idle_waits.html

-- Title: Non-idle wait events

select /*ORACONF*/
  substr(dummy.n_major, 3) "Major",
  substr(dummy.n_minor, 3) "Minor",
  dummy.wait_event "Wait Event",
  round(dummy.time/100,2) "Seconds"
from
  (
    select /*ORACONF*/
      stat_num,
      decode(n_minor,
'1 normal I/O','2 disk I/O',
'2 full scans','2 disk I/O',
'3 direct I/O','2 disk I/O',
'4 BFILE reads','2 disk I/O',
'5 other I/O','2 disk I/O',
'1 DBWn writes','3 waits',
'2 LGWR writes','3 waits',
'3 ARCn writes','3 waits',
'4 enqueue locks','3 waits',
'5 PCM locks','3 waits',
'6 other locks','3 waits',
'1 commits','4 latency',
'2 network','4 latency',
'3 file ops','4 latency',
'4 process ctl','4 latency',
'5 global locks','4 latency',
'6 misc','4 latency'
      )  n_major,
      n_minor,
      wait_event,
      time
    from
      (
select  /*ORACONF*/ /*+ ordered use_nl */    n.event# stat_num,
  decode(
    e.event,
-- disk I/O
    'db file sequential read','1 normal I/O',
    'db file scattered read','2 full scans',
    'BFILE read','4 BFILE reads',
    'KOLF: Register LFI read','4 BFILE reads',
    'log file sequential read','5 other I/O',
    'log file single write','5 other I/O',
-- resource waits
    'checkpoint completed','1 DBWn writes',
    'free buffer waits','1 DBWn writes',
    'write complete waits','1 DBWn writes',
    'local write wait','1 DBWn writes',
    'log file switch (checkpoint incomplete)','1 DBWn writes',
    'rdbms ipc reply','1 DBWn writes',
    'log file switch (archiving needed)','3 ARCn writes',
    'enqueue','4 enqueue locks',
    'buffer busy due to global cache','5 PCM locks',
    'global cache cr request','5 PCM locks',
    'global cache lock cleanup','5 PCM locks',
    'global cache lock null to s','5 PCM locks',
    'global cache lock null to x','5 PCM locks',
    'global cache lock s to x','5 PCM locks',
    'lock element cleanup','5 PCM locks',
    'checkpoint range buffer not saved','6 other locks',
    'dupl. cluster key','6 other locks',
    'PX Deq Credit: free buffer','6 other locks',
    'PX Deq Credit: need buffer','6 other locks',
    'PX Deq Credit: send blkd','6 other locks',
    'PX qref latch','6 other locks',
    'Wait for credit - free buffer','6 other locks',
    'Wait for credit - need buffer to send','6 other locks',
    'Wait for credit - send blocked','6 other locks',
    'global cache freelist wait','6 other locks',
    'global cache lock busy','6 other locks',
    'index block split','6 other locks',
    'lock element waits','6 other locks',
    'parallel query qref latch','6 other locks',
    'pipe put','6 other locks',
    'rdbms ipc message block','6 other locks',
    'row cache lock','6 other locks',
    'sort segment request','6 other locks',
    'transaction','6 other locks',
    'unbound tx','6 other locks',
-- routine waits
    'log file sync','1 commits',
    'name-service call wait','2 network',
    'Test if message present','4 process ctl',
    'process startup','4 process ctl',
    'read SCN lock','5 global locks',
    decode(substr(e.event, 1, instr(e.event, ' ')),
-- disk I/O
      'direct ','3 direct I/O',
      'control ','5 other I/O',
      'db ','5 other I/O',
-- resource waits
      'log ','2 LGWR writes',
      'buffer ','6 other locks',
      'free ','6 other locks',
      'latch ','6 other locks',
      'library ','6 other locks',
      'undo ','6 other locks',
-- routine waits
      'SQL*Net ','2 network',
      'BFILE ','3 file ops',
      'KOLF: ','3 file ops',
      'file ','3 file ops',
      'KXFQ: ','4 process ctl',
      'KXFX: ','4 process ctl',
      'PX ','4 process ctl',
      'Wait ','4 process ctl',
      'inactive ','4 process ctl',
      'multiple ','4 process ctl',
      'parallel ','4 process ctl',
      'DFS ','5 global locks',
      'batched ','5 global locks',
      'on-going ','5 global locks',
      'global ','5 global locks',
      'wait ','5 global locks',
      'writes ','5 global locks',
      '6 misc'
    )
  )  n_minor,
  e.event  wait_event,-- event name
  e.time_waited   time -- wait time
from
  sys.v_$system_event e,
  sys.v_$event_name n
where
  n.name = e.event and
  e.time_waited > 0 and
  e.event not in (
    'Null event',
    'pmon timer',
    'smon timer',
    'rdbms ipc reply',
    'KXFQ: Dequeue Range Keys - Slave',
    'KXFQ: Dequeuing samples',
    'KXFQ: kxfqdeq - dequeue from specific qref',
    'KXFQ: kxfqdeq - normal deqeue',
    'KXFX: Execution Message Dequeue - Slave',
    'KXFX: Parse Reply Dequeue - Query Coord',
    'KXFX: Reply Message Dequeue - Query Coord',
    'PAR RECOV : Dequeue msg - Slave',
    'PAR RECOV : Wait for reply - Query Coord',
    'Parallel Query Idle Wait - Slaves',
    'PL/SQL lock timer',
    'PX Deq: Execute Reply',
    'PX Deq: Execution Msg',
    'PX Deq: Index Merge Execute',
    'PX Deq: Index Merge Reply',
    'PX Deq: Par Recov Change Vector',
    'PX Deq: Par Recov Execute',
    'PX Deq: Par Recov Reply',
    'PX Deq: Parse Reply',
    'PX Deq: Table Q Get Keys',
    'PX Deq: Table Q Normal',
    'PX Deq: Table Q Sample',
    'PX Deq: Table Q qref',
    'PX Deq: Txn Recovery Reply',
    'PX Deq: Txn Recovery Start',
    'PX Deque wait',
    'PX Idle Wait',
    'Replication Dequeue',
    'Replication Dequeue ',
    'SQL*Net message from client',
    'SQL*Net message from dblink',
    'debugger command',
    'dispatcher timer',
    'parallel query dequeue wait',
    'pipe get',
    'queue messages',
    'rdbms ipc message',
    'secondary event',
    'single-task message',
    'slave wait',
    'lock manager wait for remote message',
    'wakeup time manager',
    'virtual circuit status',
    'control file heartbeat'
  ) and
  e.event not like 'resmgr:%'
      )
  ) dummy -- s. Note 118978.1
order by dummy.time desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  non_shared_sql.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/non_shared_sql.html

-- Title: Non shared SQL

select /*ORACONF*/
 substr(sql_text,1,40) "SQL",
 count(*) "Count in Cache",
 round((sum(SHARABLE_MEM)/1024/1024),2) "Memory Usage (MB)",
 sum(executions) "Total Executions"
from
 v$sqlarea
where
 executions < 5
 and sql_text not like '%/*ORACONF*/%'
 GROUP BY substr(sql_text,1,40)
 HAVING count(*) > 10
 ORDER BY sum(SHARABLE_MEM) desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  high_version_count.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/high_version_count.html

-- Title: SQL with version_count > 10

select /*ORACONF*/
 SHARABLE_MEM "Sharable Mem",
 PERSISTENT_MEM "Persisitent Mem",
 RUNTIME_MEM "Runtime Mem",
 VERSION_COUNT "Version Count",
 EXECUTIONS "Executions",
 SQL_TEXT "Sql"
from
 sys.v$sqlarea
where
 VERSION_COUNT>10 order by version_count
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  library_cache.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/library_cache.html

-- Title: Library cache details

select /*ORACONF*/
 namespace "Namespace",
 gets "Gets",
 to_char(gethitratio,'999.99') "Get Hitratio"
from
 sys.v$librarycache
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  library_cache_miss_rate.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/library_cache_miss_rate.html

-- Title: Library cache miss rate

select /*ORACONF*/
 sum(pins) "Executions",
 sum(reloads) "Cache misses while execution",
 to_char(sum(reloads)/sum(pins)*100,'999.99') "% Misses"
from
 sys.v$librarycache
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  queue_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/queue_tables.html

-- Title: Queue tables

select /*ORACONF*/
 owner "Schema",
 queue_table "Queue table",
 compatible "Compatible",
 type "Type",
 object_type "Object Type",
 sort_order "Sort order",
 user_comment "Comment"
from
 dba_queue_tables
 where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 order by owner,queue_table
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  multiqueue_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/multiqueue_tables.html

-- Title: Queue tables with more than 1 queues

select /*ORACONF*/
 name "Schema",
 queue_table "Queue table",
 count(name) "Nr. of Queues"
from
 dba_queues
 group by name,Queue_table  having count(name) > 1
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  old_queue_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/old_queue_tables.html

-- Title: Queue Tables with compatible < 8.1

select /*ORACONF*/
 owner "Schema",
 queue_table "Queue table",
 compatible "Compatible",
 type "Type",
 object_type "Object Type",
 sort_order "Sort order",
 user_comment "Comment"
from
 dba_queue_tables
where
 to_number(translate(compatible,'.','0')) < 80100
 and OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 order by owner,queue_table
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  queues.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/queues.html

-- Title: List of queues

select /*ORACONF*/
 Owner "Owner",
 name "Queue",
 QUEUE_TYPE "Type",
 MAX_RETRIES "Max. retries",
 RETRY_DELAY "Retry delay",
 ENQUEUE_ENABLED "EnQ",
 DEQUEUE_ENABLED "DeQ",
 RETENTION "Retention"
from
 dba_queues
where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 order by owner,name
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  propagation_without_errors.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/propagation_without_errors.html

-- Title: Propagation schedules without errors

select /*ORACONF*/
 Schema "Schema",
 PROCESS_NAME "Process",
 START_DATE "Start Date",
 START_TIME "Start Time",
 NEXT_RUN_TIME "Next Run Time",
 Qname "Queue Name",
 Destination "Destination",
 Latency "Latency",
 Next_time "Next Time",
 propagation_window "Prop. Window",
 message_delivery_mode "Message Delivery Mode"
from
 dba_queue_schedules
where
 last_error_msg is NULL
 order by schema,qname
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  propagation_with_errors.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/propagation_with_errors.html

-- Title: Propagation schedules with errors

select /*ORACONF*/
 schema "Schema",
 qname "Queue",
 Destination "Destination",
 Last_error_date "Last error date",
 Last_error_time "Last error time",
 Last_error_msg "Error",
 message_delivery_mode "Message Delivery Mode"
from
 dba_queue_schedules
where
 last_error_msg is not null
 order by schema,qname
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  udt_in_different_schema.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/udt_in_different_schema.html

-- Title: UDT with the same name in different Schemas

select /*ORACONF*/
 type_name "Type",
 count(*) "Nr. of schemas"
from
 dba_Types group by type_name having count(*) > 1
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  db_links.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/db_links.html

-- Title: Database links

select /*ORACONF*/
 OWNER "Owner",
 DB_LINK "Database Link",
 USERNAME "Username",
 HOST "Host",
 to_char(CREATED,'MM/DD/YYYY HH24:MI:SS') "Created"
from
 dba_db_links order by OWNER,DB_LINK
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tpc_pending.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tpc_pending.html

-- Title: Two phase commit pending information

select /*ORACONF*/
 LOCAL_TRAN_ID "Local Tran ID",
 GLOBAL_TRAN_ID "Global Tran ID",
 STATE "State",
 MIXED "Mixed",
 ADVICE "Advice",
 TRAN_COMMENT "Comment",
 FAIL_TIME "Fail Time",
 FORCE_TIME "Force Time",
 RETRY_TIME "Retry Time",
 OS_USER "OS User",
 OS_TERMINAL "OS Terminal",
 HOST "Host",
 DB_USER "DB User",
 COMMIT# "Commit#"
from
 dba_2pc_pending order by LOCAL_TRAN_ID, GLOBAL_TRAN_ID
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tpc_neighbor.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tpc_neighbor.html

-- Title: Two phase commit neighbor information

select /*ORACONF*/
 LOCAL_TRAN_ID "Local Tran ID",
 IN_OUT "In/Out",
 DATABASE "Database",
 DBUSER_OWNER "Database user",
 INTERFACE "Interface",
 DBID "DB Id",
 SESS# "Session#",
 BRANCH "Branch"
from
 dba_2pc_neighbors order by LOCAL_TRAN_ID, IN_OUT
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  traffic_controller.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/traffic_controller.html

-- Title: DLM Traffic Controller

select /*ORACONF*/
 inst_id "Instance",
 local_nid "Local Node",
 remote_nid "Rem. Node",
 tckt_avail "Tickets",
 tckt_limit "Limit",
 substr(tckt_wait,1,4) "Wait",
 snd_seq_no "Send seq",
 rcv_seq_no "Recv seq"
from
 gv$dlm_traffic_controller
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  lock_conversions.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/lock_conversions.html

-- Title: Lock conversions

select /*ORACONF*/
 from_val "From",
 to_val "To",
 action_val "Action",
 counter "Count"
from
 v$lock_activity
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  block_pings.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/block_pings.html

-- Title: Ping on block level

select /*ORACONF*/
 file# "File",
 block# "Block",
 class# "Class",
 status "Status",
 xnc "XNC",
 forced_reads "Forces reads",
 forced_writes "Forced writes",
 name "Object",
 partition_name "Partition",
 Kind "Type",
 owner# "Owner"
from
 v$ping
where
 xnc > 0.5 * (select max(xnc) from v$ping)
order by xnc desc
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  object_pings.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/object_pings.html

-- Title: Ping on object level

select  /*ORACONF*/ *
from
( select /*ORACONF*/
 name "Name",
 file# "File Nr.",
 class# "Class Nr.",
 max(xnc) "Max xnc"
 from
 v$ping
 group by name,file#,class#
 order by 4
)
where rownum < 11
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  pings_per_file.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/pings_per_file.html

-- Title: Pings per file

select /*ORACONF*/
 file_number "File number",
 x_2_null "X -> null",
 x_2_s "X -> S",
 x_2_ssx "X -> SSX"
from
 v$file_ping
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  lock_distribution.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/lock_distribution.html

-- Title: Lock distribution

select /*ORACONF*/
 file_name "File",
 start_lk "Start lock",
 nlocks "Nr. Locks"
from
 file_lock
 order by start_lk
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  jobs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/jobs.html
-- Title: Database jobs

col jid  format 9999999999  heading 'Id' 
col subu format a10  heading 'Submitter'     wrap
-- col secd format a10  heading 'Security'      trunc 
col proc format a20  heading 'Job'           wrap
col lsd  format a5   heading 'Last|Ok|Date'  
col lst  format a5   heading 'Last|Ok|Time' 
col nrd  format a5   heading 'Next|Run|Date' 
col nrt  format a5   heading 'Next|Run|Time' 
col fail format 999  heading 'Errs' 
col ok   format a3   heading 'Job|Ok' 
 
select  /*ORACONF*/
  job                        jid, 
  log_user                   subu, 
--  priv_user                  secd, 
  what                       proc, 
  to_char(last_date,'MM/DD') lsd, 
  substr(last_sec,1,5)       lst, 
  to_char(next_date,'MM/DD') nrd, 
  substr(next_sec,1,5)       nrt, 
  failures                   fail, 
  decode(broken,'Y','N','Y') ok 
from 
  sys.dba_jobs 
/ 
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  jobs_inst.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/jobs_inst.html
-- Title: Database jobs

col jid  format 9999999999  heading 'Id' 
col subu format a10  heading 'Submitter'     wrap
-- col secd format a10  heading 'Security'      trunc 
col proc format a20  heading 'Job'           wrap
col lsd  format a5   heading 'Last|Ok|Date'  
col lst  format a5   heading 'Last|Ok|Time' 
col nrd  format a5   heading 'Next|Run|Date' 
col nrt  format a5   heading 'Next|Run|Time' 
col fail format 999  heading 'Errs' 
col ok   format a3   heading 'Job|Ok' 
 
select  /*ORACONF*/
  job                        jid, 
  log_user                   subu, 
--  priv_user                  secd, 
  what                       proc, 
  to_char(last_date,'MM/DD') lsd, 
  substr(last_sec,1,5)       lst, 
  to_char(next_date,'MM/DD') nrd, 
  substr(next_sec,1,5)       nrt, 
  failures                   fail, 
  decode(broken,'Y','N','Y') ok 
from 
  sys.dba_jobs where INSTANCE = (SELECT INSTANCE_NUMBER from v$instance)
/ 
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  cron_jobs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/cron_jobs.html

-- Title: Crontab jobs

host crontab -l > ../../../out/ORADB_&inst_name/cron_jobs.html 2>/dev/null

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dba_scheduler_jobs_details.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dba_scheduler_jobs_details.html
-- Title: dba_scheduler_jobs  details

select  /*ORACONF*/ * from (select * from DBA_SCHEDULER_JOB_RUN_DETAILS order
by log_date desc) where rownum < 21
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dba_scheduler_jobs_ext_prog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dba_scheduler_jobs_ext_prog.html
-- Title: dba_scheduler_jobs external program

select   /*ORACONF*/ JOB_NAME,JOB_TYPE,job_action, failure_count from  
dba_scheduler_jobs
where job_type='EXECUTABLE'
/ 

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dba_scheduler_jobs_prog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dba_scheduler_jobs_prog.html
-- Title: dba_scheduler_jobs program

select  /*ORACONF*/ JOB_NAME,JOB_TYPE,PROGRAM_OWNER,PROGRAM_NAME,failure_count 
from  
dba_scheduler_jobs
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dba_scheduler_jobs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dba_scheduler_jobs.html
-- Title: General information dba_scheduler_jobs

select  /*ORACONF*/ job_name,run_count,failure_count, enabled,
to_char(start_Date,'dd.mm.rr hh24:mi') "START_DATE",
 repeat_interval, to_char(last_run_duration,'hh:mm:ss') "RUNTIME" ,
failure_count  
 from dba_scheduler_jobs  
 order by owner
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  dba_scheduler_jobs_unsuc.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/dba_scheduler_jobs_unsuc.html
-- Title: dba_scheduler_jobs unsuccessful jobs

select  /*ORACONF*/ * from (select * from DBA_SCHEDULER_JOB_RUN_DETAILS where
status <> 'SUCCEEDED' order by log_date desc) where rownum < 21
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  resource_mgr.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/resource_mgr.html

-- Title: Resource Manager

-- Hint: Defined resource plans

select /*ORACONF*/
  plan,status,comments
from DBA_RSRC_PLANS;

-- Hint: Defined resource consumer groups

select /*ORACONF*/
  b.granted_group, a.status,count(b.grantee) USER_COUNT,a.comments
from DBA_RSRC_CONSUMER_GROUPS a , DBA_RSRC_CONSUMER_GROUP_PRIVS b
where a.consumer_group=b.granted_group
group by b.granted_group,a.status,a.comments;

-- Hint: Plans for consumer groups

select  /*ORACONF*/ *
from DBA_RSRC_PLAN_DIRECTIVES;

-- Hint: Currently active plans

select  /*ORACONF*/ *
from V$RSRC_PLAN;

-- Hint: Currently active consumer groups

select /*ORACONF*/
  RESOURCE_CONSUMER_GROUP,count(*) CURRENT_SESSIONS
from v$session
where RESOURCE_CONSUMER_GROUP is not null
group by RESOURCE_CONSUMER_GROUP;

-- Hint: Current status of consumer groups

select  /*ORACONF*/ *
from V$RSRC_CONSUMER_GROUP;


spool off
set markup html off; 
set termout on; 
prompt ORACONF:  analyzed_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/analyzed_tables.html

-- Title: Summary of analyzed tables
col "Owner" format a25 wrap heading "Table|Owner"
col "Col4" format a13 heading "Oldest|Analyze"
col "Not Analyzed" format 99999990 heading "Not|Analyze"
col "Total Tables" format 99999990 heading "Total|Tables"



select /*ORACONF*/
 OWNER "Owner",
 sum(decode(nvl(NUM_ROWS,999999999), 999999999,0,1)) "Analyzed",
 sum(decode(nvl(NUM_ROWS,999999999), 999999999,1,0)) "Not Analyzed",
 nvl(to_char(min(last_analyzed),'DD-Mon-RR'),'not available') "Col4",
 count(TABLE_NAME) "Total Tables"
from
 dba_tables
where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
group by OWNER
/

col "Owner" CLEAR
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  analyzed_indexes.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/analyzed_indexes.html
-- Title: Summary of analyzed indexes
col "Owner" format a25 wrap heading "Index|Owner"
col "Col4" format a13 heading "Oldest|Analyze"
col "Not Analyzed"  format 99999990 heading "Not|Analyze"
col "Total Indexes" format 99999990 heading "Total|Indexes"


select /*ORACONF*/
 OWNER "Owner",
 sum(decode(nvl(NUM_ROWS,999999999), 999999999,0,1)) "Analyzed",
 sum(decode(nvl(NUM_ROWS,999999999), 999999999,1,0)) "Not Analyzed",
 nvl(to_char(min(last_analyzed),'DD-Mon-RR'),'not available') "Col4",
 count(INDEX_NAME) "Total Indexes"
from
 dba_indexes
where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
 index_type <> 'LOB'
group by OWNER
;

col "Owner" CLEAR
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  table_indexes.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/table_indexes.html

-- Title: Tables with more than 5 indexes

-- Hint: SYS and SYSTEM and Oracle product users are excluded

select /*ORACONF*/
 OWNER "Owner",
 TABLE_NAME "Table",
 COUNT(*) "Nr. of Indexes"
from
 dba_indexes
where
 OWNER not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 and index_type <> 'LOB'
 group by OWNER, TABLE_NAME having COUNT(*) > 5
 order by COUNT(*) desc, OWNER, TABLE_NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tables_without_indexes.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tables_without_indexes.html

-- Title: Large tables without indexes

col "Owner" format a25 wrap heading "Table|Owner"

SELECT /*ORACONF*/
/*&version*/
 t.owner "Owner",
 t.table_name "Table",
 round(SUM(e.bytes) / 1024 / 1024,
       2) "Size (MB)"
FROM   (SELECT owner,
               table_name
        FROM   dba_tables
        MINUS
        SELECT /*ORACONF*/
        /*&version*/
         table_owner,
         table_name
        FROM   dba_indexes) t,
       dba_extents e
WHERE  t.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
       t.owner = e.owner AND
       t.table_name = e.segment_name AND
       t.table_name NOT LIKE 'SYS_IOT_OVER%'
GROUP  BY t.owner,
          t.table_name
HAVING SUM(e.blocks) >= (SELECT
                         /*ORACONF*/
                         /*&version*/
                          b.ksppstvl
                         FROM   x$ksppi  a,
                                x$ksppsv b
                         WHERE  a.indx = b.indx AND
                                a.ksppinm = '_small_table_threshold')
ORDER  BY SUM(e.bytes),
          t.owner,
          t.table_name DESC
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  table_index_locations.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/table_index_locations.html

-- Title: Table and index locations

SELECT /*ORACONF*/
 owner "Owner",
 tablespace_name "Tablespace",
 SUM(decode(segment_type,
            'TABLE',
            1,
            0)) "Tables",
 SUM(decode(segment_type,
            'INDEX',
            1,
            0)) "Indexes"
FROM   dba_segments
WHERE  segment_type IN ('TABLE', 'INDEX') AND
       owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
GROUP  BY owner,
          tablespace_name;


spool off
set markup html off; 
set termout on; 
prompt ORACONF:  table_index_locations_doc.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/table_index_locations_doc.html

-- Title: Table and index locations

SELECT /*ORACONF*/
 *
FROM   (SELECT /*ORACONF*/
         owner "Owner",
         tablespace_name "Tablespace",
         SUM(decode(segment_type,
                    'TABLE',
                    1,
                    0)) tables,
         SUM(decode(segment_type,
                    'INDEX',
                    1,
                    0)) indexes
        FROM   dba_segments
        WHERE  segment_type IN ('TABLE', 'INDEX') AND
               owner NOT IN
               ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
        GROUP  BY owner,
                  tablespace_name) a
WHERE  a.tables != 0 AND
       a.indexes != 0;

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  partitioned_indexes.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/partitioned_indexes.html

-- Title: Partitioned indexes

SELECT /*ORACONF*/
 owner                  "Owner",
 index_name             "Index",
 table_name             "Table",
 partitioning_type      "Part. Type",
 partition_count        "Part. Count",
 subpartitioning_type   "Subpart. Type",
 def_subpartition_count "Subpart. Count",
 locality               "Locality",
 def_tablespace_name    "Default Tablespace"
FROM   dba_part_indexes
WHERE  owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
ORDER  BY owner,
          index_name;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  partitioned_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/partitioned_tables.html

-- Title: Partitioned tables

-- Hint: SYS and SYSTEM and Oracle product users are excluded

select /*ORACONF*/
 owner "Owner",
 table_name "Table",
 PARTITIONING_TYPE "Part. Type",
 PARTITION_COUNT "Part. Count",
 SUBPARTITIONING_TYPE "Subpart. Type",
 DEF_SUBPARTITION_COUNT "Subpart. Count"
from
 dba_part_tables
where
 owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
order by OWNER, TABLE_NAME
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  non_partitioned_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/non_partitioned_tables.html
-- Title: NON Partitioned tables larger than 2GB

-- Hint: SYS, SYSTEM and Oracle product users are excluded.


set pagesize 5000
set lin 1000
set trimspool on
col owner format a50
col table_name format a50
col column_name format a50
col data_type format a50

SELECT  /*ORACONF*/ tc.owner,
       tc.table_name,
       tc.column_name,
       tc.data_type,
       ds.tablespace_name,
       round(ds.bytes / power(2,
                              20)) SIZE_MB
FROM   dba_segments ds,
       dba_tab_cols tc
WHERE  ds.owner = tc.owner AND
       ds.segment_name = tc.table_name AND
       ds.segment_type = 'TABLE' AND
       ds.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
       ds.bytes > 2 * power(2,
                            30)
ORDER  BY 1,
          2
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  lobs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/lobs.html
-- Title: Large objects information

-- Hint: Oracle users are excluded.


set pagesize 5000
set lin 1000
set trimspool on
col owner format a20
col table_name format a50
col column_name format a80
col tablespace_name format a50
col segment_name format a50
col index_name format a50

SELECT /*ORACONF*/ dl.owner,
       dl.table_name,
       dl.column_name,
       dl.tablespace_name,
       dl.segment_name,
       dl.index_name,
       dl.chunk/1024 "CHUNK [kB]",
       ds.bytes/1024 "Segment size[kB]",
       dl.cache,
       dl.in_row,
       dl.retention,
       dl.pctversion,
       dl.logging,
       dl.partitioned
FROM   dba_lobs dl,
       Dba_Segments ds
WHERE  dl.segment_name=ds.segment_name
       AND dl.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
ORDER BY 1,2,3
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  fk_without_index.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/fk_without_index.html

-- Title: FK constraints without index on child table

select /*ORACONF*/
 acc.OWNER "Owner",
 acc.CONSTRAINT_NAME "Constraint",
 acc.table_name "Table",
 acc.COLUMN_NAME "Column",
 acc.POSITION "Position"
from
 dba_cons_columns acc, dba_constraints ac
where
 ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME and ac.CONSTRAINT_TYPE = 'R'
 and acc.OWNER not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 and acc.OWNER = ac.OWNER
 and not exists ( select 'TRUE' from dba_ind_columns b
                  where b.TABLE_OWNER = acc.OWNER
                  and b.TABLE_NAME = acc.TABLE_NAME
                  and b.COLUMN_NAME = acc.COLUMN_NAME
                  and b.COLUMN_POSITION = acc.POSITION)
 order by acc.OWNER, acc.CONSTRAINT_NAME, acc.COLUMN_NAME, acc.POSITION
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  degree.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/degree.html

-- Title: Degree and instances of tables and indexes
-- Hint: Degree 0 and 1 excluded

col "Col1" format a20 wrap heading "Owner" 
col "Col2" format a12 heading "Degree" 
col "Col3" format a12 heading "Inst." 
col "Col4" format a20 wrap heading "Number |of tabs" 

select  /*ORACONF*/ out.owner "Col1",
       out.degree "Col2",
       out.instances "col3",
       out.objs "col4"
from    
(	select /*ORACONF*/
	 owner ,
	 degree ,
	 instances ,
	 count(*)||' Table(s)' Objs
	from
	 dba_tables
	where instances not in ('         0','         1')
	 or   degree not in ('         0','         1')
         and OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
	group by owner ,degree ,instances 
	union
	select /*ORACONF*/
	 owner ,degree ,instances ,count(*)||' Index(es)' Objs
	from
	 dba_indexes
	where instances not in ('0','1')
	 or   degree not in ('0','1')
         and OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
	group by owner ,degree ,instances 
) out
order by 2,3
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tables_without_pk.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tables_without_pk.html

-- Title: Tables without primary key constraint

-- Hint: SYS, SYSTEM and Oracle product users are excluded

SELECT /*ORACONF*/
 owner      "Owner",
 table_name "Table"
FROM   (SELECT owner,
               table_name
        FROM   dba_tables
        WHERE  table_name NOT LIKE 'SYS_IOT_OVER%' AND
               table_name NOT LIKE 'MLOG$%' AND
               table_name NOT LIKE 'RUPD$%' AND
               table_name NOT LIKE 'PLAN_TABLE'
        MINUS
        SELECT /*ORACONF*/
         owner,
         table_name
        FROM   dba_constraints
        WHERE  constraint_type = 'P')
WHERE  owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
ORDER  BY owner,
          table_name;

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tables_without_pk_doc.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tables_without_pk_doc.html

-- Title: Tables without primary key constraint

-- Hint: SYS and SYSTEM users are excluded

SELECT /*ORACONF*/
 owner "Owner",
 COUNT(*) "No. Tables without PK"
FROM   (SELECT owner,
               table_name
        FROM   dba_tables
        WHERE  table_name NOT LIKE 'SYS_IOT_OVER%' AND
               table_name NOT LIKE 'MLOG$%' AND
               table_name NOT LIKE 'RUPD$%' AND
               table_name NOT LIKE 'PLAN_TABLE'
        MINUS
        SELECT /*ORACONF*/
         owner,
         table_name
        FROM   dba_constraints
        WHERE  constraint_type = 'P')
WHERE  owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
GROUP  BY owner
ORDER  BY owner;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  disabled_constraints.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/disabled_constraints.html
-- Title: Disabled constraints

col "Owner" format a15 wrap heading "Owner"
col "Table" format a20 wrap heading "Table"
col "Constraints" format a20 wrap heading "Constraints"
col "Type" format a12 wrap heading "Const. Type"
col "Status" format a10 wrap heading "Status"


select /*ORACONF*/
 OWNER "Owner",
 TABLE_NAME "Table",
 CONSTRAINT_NAME "Constraint",
 decode(CONSTRAINT_TYPE,'C','Check','P','Primary Key','U','Unique','R','Foreign Key','V','With Check Option') "Type",
 STATUS "Status"
from
 dba_constraints
where
 OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) AND
 STATUS = 'DISABLED' and
 TABLE_NAME not like 'LOGMNR_%'
 order by OWNER, TABLE_NAME, CONSTRAINT_NAME
/

col "Owner" off
col "Table" off
col "Constraints" off
col "Type" off
col "Status" off

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  large_unpinned.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/large_unpinned.html

-- Title: Large objects not pinned

-- Hint: Sharable memory larger than 10000 bytes

select /*ORACONF*/
 owner "Owner",
 name "Object Name",
 round(sharable_mem/1024) "Sharable Memory (kb)",
 type "Object Type",
 loads "Loads",
 executions "Executions"
from
 v$db_object_cache
where
 SHARABLE_MEM > 10000
 and OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
 and type in ('PACKAGE','PROCEDURE','FUNCTION','TRIGGER')
 and kept='NO'
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  pinned_objects.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/pinned_objects.html

-- Title: Pinned objects

select /*ORACONF*/
 owner "Owner",
 name "Object Name",
 round(sharable_mem/1024) "Sharable Memory (kb)",
 type "Object Type",
 loads "Loads",
 executions "Executions"
from
 v$db_object_cache
where
 OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) and
 type not in ('TABLE','INDEX','CLUSTER','JAVA CLASS')
 and
 kept='YES'
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  cached_tables.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/cached_tables.html

-- Title: Cached tables

select /*ORACONF*/
 OWNER "Owner",
 TABLE_NAME "Table",
 CACHE "Cache"
from
 dba_tables
where
 OWNER not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' ) and CACHE like '%Y'
order by OWNER, TABLE_NAME
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  special_objects.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/special_objects.html

-- Title: Index organized tables

select /*ORACONF*/
  table_name "IOT", owner, iot_type
from dba_tables where iot_type is not null
and owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

-- Title: Nested tables

select /*ORACONF*/
  owner, table_name "NESTED TABLES"
from dba_nested_tables
where owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

-- Title: Tables with VARRAYS

select /*ORACONF*/
  owner,PARENT_TABLE_NAME "TABLES WITH VARRAYS"
from dba_varrays
where owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

-- Title: Compressed tables

select /*ORACONF*/
  table_name "COMPRESSED TABLES", owner
from dba_tables where compression='ENABLED'
AND owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

-- Title: Compressed indexes

select /*ORACONF*/
index_name "COMPRESSED INDEXES", table_name "ON TABLE",owner
from dba_indexes where compression='ENABLED'
AND owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

-- Title: Tables with LOB columns

select /*ORACONF*/
  OWNER,TABLE_NAME,count(distinct (COLUMN_NAME)) "Number of Lob Columns"
from dba_lobs where owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
group by OWNER,TABLE_NAME
/

-- Title: Table monitoring

select /*ORACONF*/
  table_name "MONITORED TABLES", owner
from dba_tables where monitoring='YES'
and owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  snapshots.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/snapshots.html

-- Title: Snapshots

col error format 99999999

select /*ORACONF*/
  name,
  type,
  error,
  master,
  next,
  to_char(last_refresh,'DD-MON-YY HH24:MI:SS') last_refresh
from sys.dba_snapshots
/

col error off

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  registered_snapshots.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/registered_snapshots.html

-- Title: Registered Snapshots

set termout off
select  /*ORACONF*/ owner,
       name,
       mview_site,
       can_use_log,
       updatable,
       refresh_method,
       version
from   dba_registered_mviews
where OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/

set termout on
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  snapshot_logs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/snapshot_logs.html

-- Title: Snapshot_Logs

select /*ORACONF*/
  log_owner,
  Master,
  log_table,
  rowids,
  primary_key,
  filter_columns,
  snapshot_id,
  to_char(current_snapshots,'DD-MON-YY HH24:MI:SS') current_snapshots,
  bytes/1024/1024 Size_in_mb,
  freelists
from  sys.dba_snapshot_logs a,
      sys.dba_segments      b
where a.log_owner = b.owner
and b.owner NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
and   a.log_table = b.segment_name
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  snapshot_refreshes.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/snapshot_refreshes.html

-- Title: Snapshot_Refreshes

select  /*ORACONF*/ a.OWNER,
 MASTER,
 MASTER_LINK,
 UPDATABLE,
 REFRESH_METHOD,
 b.name , 
 TYPE
from dba_snapshots a, dba_rgroup b 
where a.REFRESH_GROUP=b.REFGROUP 
AND a.OWNER NOT IN ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
order by owner, b.name, a.master
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  refresh_groups.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/refresh_groups.html

-- Title: Snapshot_Refreshes

column what format a40 wor
select  /*ORACONF*/ a.NAME,
 refgroup,
 a.job,
 b.what,
 b.interval,
 last_date,
 last_sec,
 next_date,
 next_sec 
from dba_rgroup a, dba_jobs b 
where a.job=b.job
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  index_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/index_nolog.html

-- Title: NOLOGGING Indexes


select /*ORACONF*/ 
 owner, index_name, table_name,logging 
from  
 DBA_INDEXES 
where 
 logging='NO' 
and 
 owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  table_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/table_nolog.html

-- Title: NOLOGGING tables


select /*ORACONF*/
 owner, table_name,logging 
from 
 DBA_TABLES
where 
 logging='NO' 
and 
 owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  object_tables_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/object_tables_nolog.html

-- Title: NOLOGGING Object Tables


select /*ORACONF*/
 owner, table_name,logging 
from 
 DBA_OBJECT_TABLES
where 
 logging='NO' 
and 
 owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  lobs_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/lobs_nolog.html

-- Title: NOLOGGING LOBS


select /*ORACONF*/
 owner, table_name, logging 
from 
 DBA_LOBS
where 
 logging='NO' 
and 
 owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tab_part_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tab_part_nolog.html

-- Title: NOLOGGING Partitioned Tables


select /*ORACONF*/
 table_owner, table_name, partition_name,subpartition_count, logging 
from 
 DBA_TAB_PARTITIONS
where 
 logging='NO' 
and 
 table_owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  ind_part_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/ind_part_nolog.html

-- Title: NOLOGGING Partitioned Indexes


select /*ORACONF*/
 index_owner, index_name, partition_name,subpartition_count,logging 
from 
 DBA_IND_PARTITIONS
where 
 logging='NO' 
and 
 index_owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  tab_subpart_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/tab_subpart_nolog.html

-- Title: NOLOGGING SubPartitioned Tables


select /*ORACONF*/
 table_owner, table_name, partition_name, subpartition_name, logging 
from  
 DBA_TAB_SUBPARTITIONS
where 
 logging='NO' 
and 
 table_owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  ind_subpart_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/ind_subpart_nolog.html

-- Title: NOLOGGING SubPartitioned Indexes


select /*ORACONF*/
 index_owner, index_name, partition_name, subpartition_name,logging 
from  
 DBA_IND_SUBPARTITIONS
where 
 logging='NO' 
and 
 index_owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  lobs_part_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/lobs_part_nolog.html

-- Title: NOLOGGING Partitioned LOBS


select /*ORACONF*/
 table_owner, table_name, partition_name, lob_partition_name, logging 
from 
 DBA_LOB_PARTITIONS
where 
 logging='NO' 
and 
 table_owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  lobs_subpart_nolog.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/lobs_subpart_nolog.html

-- Title: NOLOGGING Partitioned LOBS


select /*ORACONF*/
 table_owner, table_name, lob_name, lob_partition_name, subpartition_name, logging 
from 
 DBA_LOB_SUBPARTITIONS
where 
 logging='NO' 
and 
 table_owner not in ( 'ANONYMOUS', 'AURORA$', 'AURORA', 'CTXSYS', 'DBSNMP', 'DIP', 'DMSYS', 'DVF', 'DVSYS', 'EXFSYS', 'HR', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW', 'ODM', 'ODM_MTR', 'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORAWSM', 'ORDPLUGINS', 'ORDSYS', 'OSE', 'OUTLN', 'PERFSTAT', 'PM', 'QS', 'QS_ADM', 'QS_CB', 'QS_CBADM', 'QS_CS', 'QS_ES', 'QS_OS', 'QS_WS', 'REPADMIN', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SYS', 'SYSMAN', 'SYSTEM', 'TRACESVR', 'TSMSYS', 'WKPROXY', 'WKSYS', 'WK_TEST', 'WKUSER', 'WMSYS', 'XDB' )
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_alias.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_alias.html
-- Title:ASM Alias 

select /*ORACONF*/
 NAME, GROUP_NUMBER , FILE_NUMBER , FILE_INCARNATION  
from 
 V$ASM_ALIAS
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_clients.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_clients.html
-- Title: ASM CLIENTS

select /*ORACONF*/
 GROUP_NUMBER,INSTANCE_NAME,DB_NAME,STATUS &CA_ASM1
from
 v$asm_client;
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_disk1.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_disk1.html
-- Title: ASM DISK (part 1)

select  /*ORACONF*/
 DISK_NUMBER, GROUP_NUMBER, NAME, PATH, HEADER_STATUS 
FROM 
 V$ASM_DISK
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_disk2.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_disk2.html
-- Title: ASM DISK (part 2)

select /*ORACONF*/
 GROUP_NUMBER, DISK_NUMBER, MOUNT_STATUS,STATE, REDUNDANCY,TOTAL_MB, FREE_MB,NAME, FAILGROUP,PATH,READ_ERRS, WRITE_ERRS 
from 
 v$asm_disk
/

spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_disk_tree.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_disk_tree.html
-- Title: ASM Disk Tree

SELECT /*ORACONF*/ 
 concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path 
FROM
 (SELECT /*ORACONF*/
   g.name gname, a.parent_index pindex, a.name aname, a.reference_index rindex 
  FROM 
   v$asm_alias a, v$asm_diskgroup g
  WHERE 
   a.group_number = g.group_number)
START WITH 
 (mod(pindex, power(2, 24))) = 0
CONNECT BY PRIOR 
 rindex = pindex
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_file.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_file.html
-- Title: ASM FILE

select /*ORACONF*/
 GROUP_NUMBER , FILE_NUMBER , INCARNATION, BLOCK_SIZE , BLOCKS, TYPE , REDUNDANCY, STRIPED 
from  
v$asm_file
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  asm_operations.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/asm_operations.html
-- Title: ASM OPERATIONS

select /*ORACONF*/ 
 * 
from 
 v$asm_operation
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  disk_groups1.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/disk_groups1.html

-- Title: ASM Disk Groups (part 1)
select /*ORACONF*/
 name, state, type, total_mb, free_mb 
from 
 v$asm_diskgroup
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  disk_groups2.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/disk_groups2.html

-- Title: ASM Disk Groups (part 2)
select /*ORACONF*/
 name, path, mode_status, state, disk_number 
from 
 v$asm_disk
/

select  /*ORACONF*/
 NAME , SECTOR_SIZE , BLOCK_SIZE , ALLOCATION_UNIT_SIZE &CA_ASM2
from 
v$asm_diskgroup
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  disk_partner.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/disk_partner.html
-- Title: Disk Partner

select /*ORACONF*/ 
 grp DG#, disk, NUMBER_KFDPARTNER partner, PARITY_KFDPARTNER parity, ACTIVE_KFDPARTNER active
from 
 x$kfdpartner
/
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  copy_unix_rgs.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/copy_unix_rgs.html
-- Copyright (c) 1996, 2004, Oracle Corporation.  All rights reserved.
--
-- NAME
-- copy_unix_rgs.sql 
--
-- NOTES
-- The script is part of the OraConf V2 package. It needs to run
-- in the PERFSTAT schema.
-- It copy the $ORACLE_HOME/unix.rgs file to unix_rgs2doc.log
--
--
-- MODIFIED    (MM/DD/YY)
--  tbreidt     10/22/04  - create script 

prompt CONFIG: Copy unix.rgs                        Filename: $ORACLE_HOME/install/unix.rgs
set termout off;

host cat $ORACLE_HOME/install/unix.rgs  > ../../../out/ORADB_&inst_name/unix_rgs2doc.log 2>/dev/null

set termout on;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  copy_environment.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/copy_environment.html
-- Copyright (c) 1996, 2004, Oracle Corporation.  All rights reserved.
--
-- NAME
-- copy_environment.sql 
--
-- NOTES
-- The script is part of the OraConf V2 package. It needs to run
-- in the PERFSTAT schema.
-- It copy the $ORACLE_HOME/unix.rgs file to unix_rgs2doc.log
--
--
-- MODIFIED    (MM/DD/YY)
--  tbreidt     10/22/04  - create script 

prompt CONFIG: Copy User Environment Information
set termout off;

host echo "ulimit -a " > ../../../out/ORADB_&inst_name/ENV_ulimit 2>/dev/null
host ulimit -a        >> ../../../out/ORADB_&inst_name/ENV_ulimit 2>/dev/null

set termout on;
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  chk_user_security.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/chk_user_security.html
set markup html off;
set define '#'  
set heading off

spool off;
set define '&'

spool ../../../out/ORADB_&inst_name/check_user_std.lst
select  /*ORACONF*/ 'User with Default Password --> '||username 
 from dba_users
 where password in
('E066D214D5421CCC',  -- dbsnmp
 '24ABAB8B06281B4C',  -- ctxsys
 '72979A94BAD2AF80',  -- mdsys
 'C252E8FA117AF049',  -- odm
 'A7A32CD03D3CE8D5',  -- odm_mtr
 '88A2B2C183431F00',  -- ordplugins
 '7EFA02EC7EA6B86F',  -- ordsys
 '4A3BA55E08595C81',  -- outln
 'F894844C34402B67',  -- scott
 '3F9FBD883D787341',  -- wk_proxy
 '79DF7A1BD138CF11',  -- wk_sys
 '7C9BA362F8314299',  -- wmsys
 '88D8364765FCE6AF',  -- xdb
 'F9DA8977092B7B81',  -- tracesvr
 '9300C0977D7DC75E',  -- oas_public
 'A97282CE3D94E29E',  -- websys
 'AC9700FD3F1410EB',  -- lbacsys
 'E7B5D92911C831E1',  -- rman
 'AC98877DE1297365',  -- perfstat
 '66F4EF5650C20355',  -- exfsys
 '84B8CBCA4D477FA3',  -- si_informtn_schema
 'D4C5016086B2DC6A',  -- sys
 'D4DF7931AB130E37')  -- system
 and account_status = 'OPEN' and (EXPIRY_DATE < sysdate  OR EXPIRY_DATE IS NULL);

spool off

set define '&'
SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED

spool ../../../out/ORADB_&inst_name/temp_check_user_oracle.txt

DECLARE
  CURSOR c1 IS
    SELECT /*ORACONF*/
     u.username
    FROM   dba_users u
    WHERE  u.account_status = 'OPEN' AND
           (expiry_date < SYSDATE OR expiry_date IS NULL);
  CURSOR c2 IS
    SELECT /*ORACONF*/
     u.username,
     expiry_date,
     account_status
    FROM   dba_users u
    WHERE  u.account_status = 'OPEN' AND
           expiry_date > SYSDATE;
  v2               dba_users.expiry_date%TYPE;
  v1               dba_users.username%TYPE;
  v_profile        dba_profiles.profile%TYPE;
  v_limit          dba_profiles.LIMIT%TYPE;
  v_account_status dba_users.account_status%TYPE;
  v_lcount         NUMBER;
BEGIN
  dbms_output.put_line('define t1 = ''User with Username = Password --> ''');
  dbms_output.put_line('define t2 = ''User with Password = ORACLE   --> ''');
  dbms_output.put_line('set define ''^''');
  FOR c1rec IN c1
  LOOP
    v1 := c1rec.username;
  
    SELECT /*ORACONF*/
     p.profile,
     p.LIMIT,
     us.lcount,
     u.account_status
    INTO   v_profile,
           v_limit,
           v_lcount,
           v_account_status
    FROM   dba_profiles p,
           dba_users    u,
           user$        us
    WHERE  u.profile = p.profile AND
           us.user# = u.user_id AND
           p.resource_name = 'FAILED_LOGIN_ATTEMPTS' AND
           u.username = v1;

    IF v_limit = 'DEFAULT'
    THEN
      SELECT /*ORACONF*/
         LIMIT
      INTO
         v_limit
      FROM
        dba_profiles
      WHERE
        resource_name = 'FAILED_LOGIN_ATTEMPTS' AND
        profile = 'DEFAULT';
    END IF;
  
    IF v_lcount = 0
       OR v_limit = 'UNLIMITED'
       OR v_limit IS NULL
    THEN
      dbms_output.put_line('conn ' || v1 || '/' || v1);
      dbms_output.put_line('select ' || chr(39) ||
                           '^t1' || chr(39) ||
                           ' || user from dual;');
      dbms_output.put_line('conn ' || v1 || '/oracle');
      dbms_output.put_line('select ' || chr(39) ||
                           '^t2' || chr(39) ||
                           ' || user from dual;');
    ELSIF v_lcount < v_limit - 2
    THEN
      dbms_output.put_line('conn ' || v1 || '/' || v1);
      dbms_output.put_line('select ' || chr(39) ||
                           '^t1' || chr(39) ||
                           ' || user from dual;');
      dbms_output.put_line('conn ' || v1 || '/oracle');
      dbms_output.put_line('select ' || chr(39) ||
                           '^t2' || chr(39) ||
                           ' || user from dual;');
    ELSE
      dbms_output.put_line('prompt WARNING  ##');
      dbms_output.put_line('prompt WARNING ! ' || 'User name: ' || v1);
      dbms_output.put_line('prompt WARNING  We cannot test this user: ' || v1 ||
                           ' because at next attempt it will be LOCKED');
      dbms_output.put_line('prompt WARNING ' || 'Login attempts: ' ||
                           v_lcount);
      dbms_output.put_line('prompt WARNING ' || 'Limit attempts: ' ||
                           v_limit);
      dbms_output.put_line('prompt WARNING ' || 'Account status: ' ||
                           v_account_status);
      dbms_output.put_line('prompt WARNING  ##');
    END IF;
  END LOOP;
    dbms_output.put_line('prompt WARNING  We cannot test the following users');
    dbms_output.put_line('prompt WARNING  because the password has EXPIRED or will EXPIRE at the next login attempt');
  FOR c1rec IN c2
  LOOP
    v1 := c1rec.username;
    v2 := c1rec.expiry_date;
    dbms_output.put_line('prompt WARNING  ##');
    dbms_output.put_line('prompt WARNING ! ' || 'User name: ' || v1);
    dbms_output.put_line('prompt WARNING  ' || 'Account status: ' ||
                         v_account_status);
    dbms_output.put_line('prompt WARNING  ' || 'Expired date: ' || v2);
    dbms_output.put_line('prompt WARNING  ##');
  END LOOP;
  dbms_output.put_line('set define ''&''');
END;
/

spool off
spool ../../../out/ORADB_&inst_name/temp_check_user_oracle.lst
@../../../out/ORADB_&inst_name/temp_check_user_oracle.txt
spool off


host cat ../../../out/ORADB_&inst_name/temp*lst>../../../out/ORADB_&inst_name/check_user.tmp 2>/dev/null
host "For these ORACLE users we cannot test the security policy:" >../../../out/ORADB_&inst_name/check_user_NOT_tested.lst 2>/dev/null
host grep "WARNING ! " ../../../out/ORADB_&inst_name/check_user.tmp>../../../out/ORADB_&inst_name/check_user_NOT_tested.lst 2>/dev/null

host grep -i "user with" ../../../out/ORADB_&inst_name/check_user.tmp>../../../out/ORADB_&inst_name/check_user.lst 2>/dev/null
--host cat ../../../out/ORADB_&inst_name/check_user.lst >> ../../../out/ORADB_&inst_name/chk_user_security.html 2>/dev/null

host rm -f ../../../out/ORADB_&inst_name/temp_check*sql 2>/dev/null
host rm -f ../../../out/ORADB_&inst_name/temp_check*txt 2>/dev/null
host rm -f ../../../out/ORADB_&inst_name/temp_check*lst 2>/dev/null
host rm -f ../../../out/ORADB_&inst_name/check_user.tmp 2>/dev/null

set heading on
set markup html on
spool off
set markup html off; 
set termout on; 
prompt ORACONF:  awrinfo.html 
set termout off;
set markup html on; 
spool ../../../out/ORADB_&inst_name/awrinfo.html
-- Copyright (c) 1996, 2004, Oracle Corporation.  All rights reserved.
--
-- NAME
-- awrinfo.sql 
--
-- NOTES
-- The script is part of the OraConf V2 package. It needs to run
-- in the PERFSTAT schema.
--
--
-- MODIFIED    (MM/DD/YY)
--  tbreidt     04/27/05  - create script 

prompt CONFIG: AWRinfo 
set termout off;
set markup html off;

define report_name=../../../out/ORADB_&inst_name/awrinfo.txt

host sed -e "s/set termout on/set termout off/g" $ORACLE_HOME/rdbms/admin/awrinfo.sql > ../../../out/ORADB_&inst_name/oraconf_awrinfo.sql 2>/dev/null

connect / as sysdba

@../../../out/ORADB_&inst_name/oraconf_awrinfo.sql

set termout off;
spool off
set termout off markup html off
set define '&' 
set define '&' 
spool ../../../out/ORADB_&inst_name/CONF_left_frame.html
prompt <!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
prompt <HTML lang='en-US'><HEAD><TITLE>ORACONF V2</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD>
prompt <body onLoad="onLoad="parent.rda_sub_index.location.href='blank.html'">
prompt <DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'><SPAN class='rda_red'>List of CONF files </SPAN></H1>
prompt <P><ul>
prompt <li class=h><a href="ORACONF_sub_Configuration.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Configuration</a></li>
prompt <li class=h><a href="ORACONF_sub_Problems.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Problems</a></li>
prompt <li class=h><a href="ORACONF_sub_Tablespaces_Files.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Tablespaces/Files</a></li>
prompt <li class=h><a href="ORACONF_sub_Processes.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Processes</a></li>
prompt <li class=h><a href="ORACONF_sub_User_related.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">User related</a></li>
prompt <li class=h><a href="ORACONF_sub_Redolog.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Redolog</a></li>
prompt <li class=h><a href="ORACONF_sub_Memory.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Memory</a></li>
prompt <li class=h><a href="ORACONF_sub_Performance.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Performance</a></li>
prompt <li class=h><a href="ORACONF_sub_Advanced_Queuing.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Advanced Queuing</a></li>
prompt <li class=h><a href="ORACONF_sub_Network.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Network</a></li>
prompt <li class=h><a href="ORACONF_sub_RAC.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">RAC</a></li>
prompt <li class=h><a href="ORACONF_sub_Job_Control.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Job Control</a></li>
prompt <li class=h><a href="ORACONF_sub_Resource_manager.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Resource manager</a></li>
prompt <li class=h><a href="ORACONF_sub_Database_Objects.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Database Objects</a></li>
prompt <li class=h><a href="ORACONF_sub_ASM.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">ASM</a></li>
prompt <li class=h><a href="ORACONF_sub_Config_guide_unix_only.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Config guide (unix only)</a></li>
prompt <li class=h><a href="ORACONF_sub_Oneoff-Patches.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">Oneoff-Patches</a></li>
prompt <li class=h><a href="ORACONF_sub_AWR.html" target='rda_sub_index' onClick="parent.rda_report.location.href='blank.html'">AWR</a></li>
prompt </ul>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Configuration.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Configuration</H1>
prompt <P><UL>
prompt <li><a href="database.html" target=rda_report>database</a></li>
prompt <li><a href="instance.html" target=rda_report>instance</a></li>
prompt <li><a href="dbversion.html" target=rda_report>dbversion</a></li>
prompt <li><a href="dboptions.html" target=rda_report>dboptions</a></li>
prompt <li><a href="init_nondef.html" target=rda_report>init_nondef</a></li>
prompt <li><a href="init_all.html" target=rda_report>init_all</a></li>
prompt <li><a href="init_hidden.html" target=rda_report>init_hidden</a></li>
prompt <li><a href="db_facts.html" target=rda_report>db_facts</a></li>
prompt <li><a href="os_facts.html" target=rda_report>os_facts</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Problems.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Problems</H1>
prompt <P><UL>
prompt <li><a href="sparse_indexes.html" target=rda_report>sparse_indexes</a></li>
prompt <li><a href="sparse_tables.html" target=rda_report>sparse_tables</a></li>
prompt <li><a href="low_maxtrans.html" target=rda_report>low_maxtrans</a></li>
prompt <li><a href="row_migration.html" target=rda_report>row_migration</a></li>
prompt <li><a href="many_extents.html" target=rda_report>many_extents</a></li>
prompt <li><a href="extents_used_75.html" target=rda_report>extents_used_75</a></li>
prompt <li><a href="unextendible_objects.html" target=rda_report>unextendible_objects</a></li>
prompt <li><a href="invalid_objects.html" target=rda_report>invalid_objects</a></li>
prompt <li><a href="all_errors.html" target=rda_report>all_errors</a></li>
prompt <li><a href="analyzed_dict.html" target=rda_report>analyzed_dict</a></li>
prompt <li><a href="system_users.html" target=rda_report>system_users</a></li>
prompt <li><a href="hot_backup_mode.html" target=rda_report>hot_backup_mode</a></li>
prompt <li><a href="rman_corruptions.html" target=rda_report>rman_corruptions</a></li>
prompt <li><a href="user_default_tbs_system.html" target=rda_report>user_default_tbs_system</a></li>
prompt <li><a href="chk_dblinks.html" target=rda_report>chk_dblinks</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Tablespaces_Files.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Tablespaces_Files</H1>
prompt <P><UL>
prompt <li><a href="tablespaces.html" target=rda_report>tablespaces</a></li>
prompt <li><a href="tablespace_usage.html" target=rda_report>tablespace_usage</a></li>
prompt <li><a href="tablespace_free_space.html" target=rda_report>tablespace_free_space</a></li>
prompt <li><a href="datafiles.html" target=rda_report>datafiles</a></li>
prompt <li><a href="tempfiles.html" target=rda_report>tempfiles</a></li>
prompt <li><a href="temp_datafiles.html" target=rda_report>temp_datafiles</a></li>
prompt <li><a href="autoextension.html" target=rda_report>autoextension</a></li>
prompt <li><a href="logfiles.html" target=rda_report>logfiles</a></li>
prompt <li><a href="controlfiles.html" target=rda_report>controlfiles</a></li>
prompt <li><a href="rollback_segments.html" target=rda_report>rollback_segments</a></li>
prompt <li><a href="rollback_segments_usage.html" target=rda_report>rollback_segments_usage</a></li>
prompt <li><a href="rollback_growth.html" target=rda_report>rollback_growth</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Processes.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Processes</H1>
prompt <P><UL>
prompt <li><a href="bgprocess.html" target=rda_report>bgprocess</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_User_related.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>User_related</H1>
prompt <P><UL>
prompt <li><a href="user_sessions.html" target=rda_report>user_sessions</a></li>
prompt <li><a href="user_default_tablespaces.html" target=rda_report>user_default_tablespaces</a></li>
prompt <li><a href="user_object_overview.html" target=rda_report>user_object_overview</a></li>
prompt <li><a href="user_space_allocated.html" target=rda_report>user_space_allocated</a></li>
prompt <li><a href="user_tablespace_quotas.html" target=rda_report>user_tablespace_quotas</a></li>
prompt <li><a href="user_privs.html" target=rda_report>user_privs</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Redolog.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Redolog</H1>
prompt <P><UL>
prompt <li><a href="redolog_history.html" target=rda_report>redolog_history</a></li>
prompt <li><a href="redolog_history_doc.html" target=rda_report>redolog_history_doc</a></li>
prompt <li><a href="logsw_last_week.html" target=rda_report>logsw_last_week</a></li>
prompt <li><a href="checkpoint_interval.html" target=rda_report>checkpoint_interval</a></li>
prompt <li><a href="undo_stats.html" target=rda_report>undo_stats</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Memory.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Memory</H1>
prompt <P><UL>
prompt <li><a href="memparams.html" target=rda_report>memparams</a></li>
prompt <li><a href="shared_pool.html" target=rda_report>shared_pool</a></li>
prompt <li><a href="reserved_pool.html" target=rda_report>reserved_pool</a></li>
prompt <li><a href="sga.html" target=rda_report>sga</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Performance.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Performance</H1>
prompt <P><UL>
prompt <li><a href="latches.html" target=rda_report>latches</a></li>
prompt <li><a href="no_idle_waits.html" target=rda_report>no_idle_waits</a></li>
prompt <li><a href="non_shared_sql.html" target=rda_report>non_shared_sql</a></li>
prompt <li><a href="high_version_count.html" target=rda_report>high_version_count</a></li>
prompt <li><a href="library_cache.html" target=rda_report>library_cache</a></li>
prompt <li><a href="library_cache_miss_rate.html" target=rda_report>library_cache_miss_rate</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Advanced_Queuing.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Advanced_Queuing</H1>
prompt <P><UL>
prompt <li><a href="queue_tables.html" target=rda_report>queue_tables</a></li>
prompt <li><a href="multiqueue_tables.html" target=rda_report>multiqueue_tables</a></li>
prompt <li><a href="old_queue_tables.html" target=rda_report>old_queue_tables</a></li>
prompt <li><a href="queues.html" target=rda_report>queues</a></li>
prompt <li><a href="propagation_without_errors.html" target=rda_report>propagation_without_errors</a></li>
prompt <li><a href="propagation_with_errors.html" target=rda_report>propagation_with_errors</a></li>
prompt <li><a href="udt_in_different_schema.html" target=rda_report>udt_in_different_schema</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Network.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Network</H1>
prompt <P><UL>
prompt <li><a href="db_links.html" target=rda_report>db_links</a></li>
prompt <li><a href="tpc_pending.html" target=rda_report>tpc_pending</a></li>
prompt <li><a href="tpc_neighbor.html" target=rda_report>tpc_neighbor</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_RAC.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>RAC</H1>
prompt <P><UL>
prompt <li><a href="traffic_controller.html" target=rda_report>traffic_controller</a></li>
prompt <li><a href="lock_conversions.html" target=rda_report>lock_conversions</a></li>
prompt <li><a href="block_pings.html" target=rda_report>block_pings</a></li>
prompt <li><a href="object_pings.html" target=rda_report>object_pings</a></li>
prompt <li><a href="pings_per_file.html" target=rda_report>pings_per_file</a></li>
prompt <li><a href="lock_distribution.html" target=rda_report>lock_distribution</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Job_Control.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Job_Control</H1>
prompt <P><UL>
prompt <li><a href="jobs.html" target=rda_report>jobs</a></li>
prompt <li><a href="jobs_inst.html" target=rda_report>jobs_inst</a></li>
prompt <li><a href="cron_jobs.html" target=rda_report>cron_jobs</a></li>
prompt <li><a href="dba_scheduler_jobs_details.html" target=rda_report>dba_scheduler_jobs_details</a></li>
prompt <li><a href="dba_scheduler_jobs_ext_prog.html" target=rda_report>dba_scheduler_jobs_ext_prog</a></li>
prompt <li><a href="dba_scheduler_jobs_prog.html" target=rda_report>dba_scheduler_jobs_prog</a></li>
prompt <li><a href="dba_scheduler_jobs.html" target=rda_report>dba_scheduler_jobs</a></li>
prompt <li><a href="dba_scheduler_jobs_unsuc.html" target=rda_report>dba_scheduler_jobs_unsuc</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Resource_manager.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Resource_manager</H1>
prompt <P><UL>
prompt <li><a href="resource_mgr.html" target=rda_report>resource_mgr</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Database_Objects.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Database_Objects</H1>
prompt <P><UL>
prompt <li><a href="analyzed_tables.html" target=rda_report>analyzed_tables</a></li>
prompt <li><a href="analyzed_indexes.html" target=rda_report>analyzed_indexes</a></li>
prompt <li><a href="table_indexes.html" target=rda_report>table_indexes</a></li>
prompt <li><a href="tables_without_indexes.html" target=rda_report>tables_without_indexes</a></li>
prompt <li><a href="table_index_locations.html" target=rda_report>table_index_locations</a></li>
prompt <li><a href="table_index_locations_doc.html" target=rda_report>table_index_locations_doc</a></li>
prompt <li><a href="partitioned_indexes.html" target=rda_report>partitioned_indexes</a></li>
prompt <li><a href="partitioned_tables.html" target=rda_report>partitioned_tables</a></li>
prompt <li><a href="non_partitioned_tables.html" target=rda_report>non_partitioned_tables</a></li>
prompt <li><a href="lobs.html" target=rda_report>lobs</a></li>
prompt <li><a href="fk_without_index.html" target=rda_report>fk_without_index</a></li>
prompt <li><a href="degree.html" target=rda_report>degree</a></li>
prompt <li><a href="tables_without_pk.html" target=rda_report>tables_without_pk</a></li>
prompt <li><a href="tables_without_pk_doc.html" target=rda_report>tables_without_pk_doc</a></li>
prompt <li><a href="disabled_constraints.html" target=rda_report>disabled_constraints</a></li>
prompt <li><a href="large_unpinned.html" target=rda_report>large_unpinned</a></li>
prompt <li><a href="pinned_objects.html" target=rda_report>pinned_objects</a></li>
prompt <li><a href="cached_tables.html" target=rda_report>cached_tables</a></li>
prompt <li><a href="special_objects.html" target=rda_report>special_objects</a></li>
prompt <li><a href="snapshots.html" target=rda_report>snapshots</a></li>
prompt <li><a href="registered_snapshots.html" target=rda_report>registered_snapshots</a></li>
prompt <li><a href="snapshot_logs.html" target=rda_report>snapshot_logs</a></li>
prompt <li><a href="snapshot_refreshes.html" target=rda_report>snapshot_refreshes</a></li>
prompt <li><a href="refresh_groups.html" target=rda_report>refresh_groups</a></li>
prompt <li><a href="index_nolog.html" target=rda_report>index_nolog</a></li>
prompt <li><a href="table_nolog.html" target=rda_report>table_nolog</a></li>
prompt <li><a href="object_tables_nolog.html" target=rda_report>object_tables_nolog</a></li>
prompt <li><a href="lobs_nolog.html" target=rda_report>lobs_nolog</a></li>
prompt <li><a href="tab_part_nolog.html" target=rda_report>tab_part_nolog</a></li>
prompt <li><a href="ind_part_nolog.html" target=rda_report>ind_part_nolog</a></li>
prompt <li><a href="tab_subpart_nolog.html" target=rda_report>tab_subpart_nolog</a></li>
prompt <li><a href="ind_subpart_nolog.html" target=rda_report>ind_subpart_nolog</a></li>
prompt <li><a href="lobs_part_nolog.html" target=rda_report>lobs_part_nolog</a></li>
prompt <li><a href="lobs_subpart_nolog.html" target=rda_report>lobs_subpart_nolog</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_ASM.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>ASM</H1>
prompt <P><UL>
prompt <li><a href="asm_alias.html" target=rda_report>asm_alias</a></li>
prompt <li><a href="asm_clients.html" target=rda_report>asm_clients</a></li>
prompt <li><a href="asm_disk1.html" target=rda_report>asm_disk1</a></li>
prompt <li><a href="asm_disk2.html" target=rda_report>asm_disk2</a></li>
prompt <li><a href="asm_disk_tree.html" target=rda_report>asm_disk_tree</a></li>
prompt <li><a href="asm_file.html" target=rda_report>asm_file</a></li>
prompt <li><a href="asm_operations.html" target=rda_report>asm_operations</a></li>
prompt <li><a href="disk_groups1.html" target=rda_report>disk_groups1</a></li>
prompt <li><a href="disk_groups2.html" target=rda_report>disk_groups2</a></li>
prompt <li><a href="disk_partner.html" target=rda_report>disk_partner</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Config_guide_unix_only.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Config_guide_unix_only</H1>
prompt <P><UL>
prompt <li><a href="unix_rgs2doc.log" target=rda_report>unix_rgs2doc.log</a></li>
prompt <li><a href="ENV_ulimit" target=rda_report>ENV_ulimit</a></li>
prompt <li><a href="chk_user_security.html" target=rda_report>chk_user_security</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_Oneoff-Patches.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>Oneoff-Patches</H1>
prompt <P><UL>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
spool ../../../out/ORADB_&inst_name/ORACONF_sub_AWR.html
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
prompt <HTML lang='en-US'><HEAD><TITLE>RDA_S010CFG Sub Index</TITLE>
prompt <LINK rel='stylesheet' type='text/css' href='RDA_rda.css'>
prompt </HEAD><BODY><DIV class='rda_index'><P><A name='Top'></A>
prompt <H1 id='Hdr1'>AWR</H1>
prompt <P><UL>
prompt <li><a href="awrinfo.txt" target=rda_report>awrinfo.txt</a></li>
prompt </UL>
prompt </div>
prompt </body>
prompt </html>
spool off
exit
