﻿SPO sqlhc.log
SET DEF ^ TERM OFF ECHO ON VER OFF SERVEROUT ON SIZE 1000000;
REM
REM $Header: 1366133.1 sqlhc.sql 11.4.4.1 2011/12/16 carlos.sierra $
REM
REM Copyright (c) 2000-2011, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   sqlhc.sql
REM
REM DESCRIPTION
REM   Produces an HTML report with a list of observations based on
REM   health-checks performed in and around a SQL statement that
REM   may be performing poorly.
REM
REM PRE-REQUISITES
REM   1. Execute as SYS or user with DBA role.
REM   2. The SQL for which the health-checks are performed must be
REM      memory-resident or pre-captured by AWR.
REM
REM PARAMETERS
REM   1. Oracle Pack license (Tuning or Diagnostics) Y/N
REM   2. SQL_ID of the SQL for which the health-checks are performed.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as SYS or user with DBA role.
REM   2. Execute script sqlhc.sql passing values for parameters.
REM
REM EXAMPLE
REM   # sqlplus / as sysdba
REM   SQL> START [path]sqlhc.sql [Y|N] [SQL_ID]
REM   SQL> START sqlhc.sql Y 51x6yr9ym5hdc
REM
REM NOTES
REM   1. For possible errors see sqlhc.log.
REM

/**************************************************************************************************/

SET TERM ON ECHO OFF;
PRO
PRO Parameter 1:
PRO Oracle Pack license (Tuning or Diagnostics) [Y|N] (required)
PRO
DEF input_license = '^1';
PRO
SET TERM OFF;
COL license NEW_V license FOR A1;

SELECT UPPER(SUBSTR(TRIM('^^input_license.'), 1, 1)) license FROM DUAL;

VAR license CHAR(1);
EXEC :license := '^^license.';

SET TERM ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

BEGIN
  IF '^^license.' IS NULL OR '^^license.' NOT IN ('Y', 'N') THEN
    RAISE_APPLICATION_ERROR(-20100, 'Oracle Pack license (Tuning or Diagnostics) must be specified as "Y" or "N".');
  END IF;
END;
/

WHENEVER SQLERROR CONTINUE;

PRO
PRO Parameter 2:
PRO SQL_ID of the SQL to be analyzed (required)
PRO
DEF input_sql_id = '^2';
PRO
PRO Value passed to sqlhc:
PRO ~~~~~~~~~~~~~~~~~~~~~
PRO License: "^^input_license."
PRO SQL_ID : "^^input_sql_id."
PRO
SET TERM OFF;
COL sql_id NEW_V sql_id FOR A13;

SELECT sql_id
  FROM gv$sqlarea
 WHERE sql_id = TRIM('^^input_sql_id.')
 UNION
SELECT sql_id
  FROM dba_hist_sqltext
 WHERE :license = 'Y'
   AND sql_id = TRIM('^^input_sql_id.');

VAR sql_id VARCHAR2(13);
EXEC :sql_id := '^^sql_id.';

SET TERM ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

BEGIN
  IF '^^sql_id.' IS NULL THEN
    IF :license = 'Y' THEN
      RAISE_APPLICATION_ERROR(-20200, 'SQL_ID "^^input_sql_id." not found in memory nor in AWR.');
    ELSE
      RAISE_APPLICATION_ERROR(-20200, 'SQL_ID "^^input_sql_id." not found in memory.');
    END IF;
  END IF;
END;
/

WHENEVER SQLERROR CONTINUE;
SET ECHO ON TIMI ON;

DEF mos_doc = '1366133.1';
DEF doc_ver = '11.4.4.1';
DEF doc_date = '2011/12/16';
DEF doc_link = 'https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=';
DEF bug_link = 'https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=';

/**************************************************************************************************/

/* -------------------------
 *
 * get sql_text
 *
 * ------------------------- */

VAR sql_text CLOB;
EXEC :sql_text := NULL;

-- get sql_text from memory
DECLARE
  l_sql_text VARCHAR2(32767);
BEGIN -- 10g see bug 5017909
  DBMS_OUTPUT.PUT_LINE('getting sql_text from memory');
  FOR i IN (SELECT DISTINCT piece, sql_text
              FROM gv$sqltext_with_newlines
             WHERE sql_id = '^^sql_id.'
             ORDER BY 1, 2)
  LOOP
    IF :sql_text IS NULL THEN
      DBMS_LOB.CREATETEMPORARY(:sql_text, TRUE);
      DBMS_LOB.OPEN(:sql_text, DBMS_LOB.LOB_READWRITE);
    END IF;
    l_sql_text := REPLACE(i.sql_text, CHR(00), ' ');
    DBMS_LOB.WRITEAPPEND(:sql_text, LENGTH(l_sql_text), l_sql_text);
  END LOOP;
  IF :sql_text IS NOT NULL THEN
    DBMS_LOB.CLOSE(:sql_text);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from memory: '||SQLERRM);
    :sql_text := NULL;
END;
/

-- get sql_text from awr
BEGIN
  IF :license = 'Y' AND (:sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0) THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr');
    SELECT REPLACE(sql_text, CHR(00), ' ')
      INTO :sql_text
      FROM dba_hist_sqltext
     WHERE :license = 'Y'
       AND sql_id = '^^sql_id.'
       AND sql_text IS NOT NULL
       AND ROWNUM = 1;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr: '||SQLERRM);
    :sql_text := NULL;
END;
/

SELECT :sql_text FROM DUAL;

/* -------------------------
 *
 * assembly title
 *
 * ------------------------- */

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10) database_name_short FROM DUAL;
SELECT SUBSTR('^^database_name_short.', 1, INSTR('^^database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('^^database_name_short.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;
SELECT SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30) host_name_short FROM DUAL;
SELECT SUBSTR('^^host_name_short.', 1, INSTR('^^host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('^^host_name_short.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') host_name_short FROM DUAL;

-- get rdbms version
COL rdbms_version NEW_V rdbms_version FOR A17;
SELECT version rdbms_version FROM v$instance;

-- get platform
COL platform NEW_V platform FOR A80;
SELECT UPPER(TRIM(REPLACE(REPLACE(product, 'TNS for '), ':' ))) platform FROM product_component_version WHERE product LIKE 'TNS for%' AND ROWNUM = 1;

-- YYYYMMDDHH24MISS
COL time_stamp NEW_V time_stamp FOR A14;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') time_stamp FROM DUAL;

-- YYYY-MM-DD/HH24:MI:SS
COL time_stamp2 NEW_V time_stamp2 FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') time_stamp2 FROM DUAL;

-- get ofe
COL sys_ofe NEW_V sys_ofe FOR A17;
SELECT value sys_ofe FROM v$system_parameter2 WHERE LOWER(name) = 'optimizer_features_enable';

-- get ds
COL sys_ds NEW_V sys_ds FOR A10;
SELECT value sys_ds FROM v$system_parameter2 WHERE LOWER(name) = 'optimizer_dynamic_sampling';

/* -------------------------
 *
 * application vendor
 *
 * ------------------------- */

-- ebs
COL is_ebs NEW_V is_ebs FOR A1;
COL ebs_owner NEW_V ebs_owner A30;
SELECT 'Y' is_ebs, owner ebs_owner
  FROM dba_tab_columns
 WHERE table_name = 'FND_PRODUCT_GROUPS'
   AND column_name = 'RELEASE_NAME'
   AND data_type = 'VARCHAR2'
   AND ROWNUM = 1;

-- siebel
COL is_siebel NEW_V is_siebel FOR A1;
COL siebel_owner NEW_V siebel_owner A30;
SELECT 'Y' is_siebel, owner siebel_owner
  FROM dba_tab_columns
 WHERE '^^is_ebs.' IS NULL
   AND table_name = 'S_REPOSITORY'
   AND column_name = 'ROW_ID'
   AND data_type = 'VARCHAR2'
   AND ROWNUM = 1;

-- psft
COL is_psft NEW_V is_psft FOR A1;
COL psft_owner NEW_V psft_owner A30;
SELECT 'Y' is_psft, owner psft_owner
  FROM dba_tab_columns
 WHERE '^^is_ebs.' IS NULL
   AND '^^is_siebel.' IS NULL
   AND table_name = 'PSSTATUS'
   AND column_name = 'TOOLSREL'
   AND data_type = 'VARCHAR2'
   AND ROWNUM = 1;

/* -------------------------
 *
 * find tables and indexes
 *
 * ------------------------- */

SAVEPOINT sqlhc;

DELETE plan_table;

-- record tables
INSERT INTO plan_table (object_type, object_owner, object_name)
WITH object AS (
SELECT object_owner owner, object_name name
  FROM gv$sql_plan
 WHERE sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 UNION
SELECT object_owner owner, object_name name
  FROM dba_hist_sql_plan
 WHERE :license = 'Y'
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 )
 SELECT 'TABLE', t.owner, t.table_name
   FROM dba_tab_statistics t, -- include fixed objects
        object o
  WHERE t.owner = o.owner
    AND t.table_name = o.name
  UNION
 SELECT 'TABLE', i.table_owner, i.table_name
   FROM dba_indexes i,
        object o
  WHERE i.owner = o.owner
    AND i.index_name = o.name;

-- record indexes
INSERT INTO plan_table (object_type, object_owner, object_name)
SELECT 'INDEX', owner, index_name
  FROM plan_table t,
       dba_indexes i
 WHERE t.object_type = 'TABLE'
   AND t.object_owner = i.table_owner
   AND t.object_name = i.table_name
 UNION
SELECT 'INDEX', object_owner owner, object_name index_name
  FROM gv$sql_plan
 WHERE sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND (object_type LIKE '%INDEX%' OR operation LIKE '%INDEX%')
 UNION
SELECT 'INDEX', object_owner owner, object_name index_name
  FROM dba_hist_sql_plan
 WHERE :license = 'Y'
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND (object_type LIKE '%INDEX%' OR operation LIKE '%INDEX%');

/* -------------------------
 *
 * record type enumerator
 *
 * ------------------------- */

-- constants
VAR E_GLOBAL     NUMBER;
VAR E_EBS        NUMBER;
VAR E_SIEBEL     NUMBER;
VAR E_PSFT       NUMBER;
VAR E_TABLE      NUMBER;
VAR E_INDEX      NUMBER;
VAR E_1COL_INDEX NUMBER;
VAR E_TABLE_PART NUMBER;
VAR E_INDEX_PART NUMBER;
VAR E_TABLE_COL  NUMBER;

EXEC :E_GLOBAL     := 01;
EXEC :E_EBS        := 02;
EXEC :E_SIEBEL     := 03;
EXEC :E_PSFT       := 04;
EXEC :E_TABLE      := 05;
EXEC :E_INDEX      := 06;
EXEC :E_1COL_INDEX := 07;
EXEC :E_TABLE_PART := 08;
EXEC :E_INDEX_PART := 09;
EXEC :E_TABLE_COL  := 10;

/**************************************************************************************************/

/* -------------------------
 *
 * global hc
 *
 * ------------------------- */

-- 5969780 STATISTICS_LEVEL = ALL on LINUX
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'STATISTICS_LEVEL',
       'Parameter STATISTICS_LEVEL is set to ALL on ^^platform. platform.',
       'STATISTICS_LEVEL = ALL provides valuable metrics like A-Rows. Be aware of Bug <a target="MOS" href="^^bug_link.5969780">5969780</a> CPU overhead.<br>'||CHR(10)||
       'Use a value of ALL only at the session level. You could use CBO hint /*+ gather_plan_statistics */ to accomplish the same.'
  FROM v$system_parameter2
 WHERE UPPER(name) = 'STATISTICS_LEVEL'
   AND UPPER(value) = 'ALL'
   AND '^^rdbms_version.' LIKE '10%'
   AND '^^platform.' LIKE '%LINUX%';

-- cbo parameters with non-default values at sql level
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, UPPER(name),
       'CBO initialization parameter "'||name||'" with a non-default value of "'||value||'" as per V$SQL_OPTIMIZER_ENV.',
       'Review the correctness of this non-default value "'||value||'" for SQL_ID '||:sql_id||'.'
  FROM (
SELECT DISTINCT name, value
  FROM v$sql_optimizer_env
 WHERE sql_id = :sql_id
   AND isdefault = 'NO' );

-- cbo parameters with non-default values at system level
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, UPPER(g.name),
       'CBO initialization parameter "'||g.name||'" with a non-default value of "'||g.value||'" as per V$SYS_OPTIMIZER_ENV.',
       'Review the correctness of this non-default value "'||g.value||'".<br>'||CHR(10)||
       'Unset this parameter unless there is a strong reason for keeping its current value.<br>'||CHR(10)||
       'Default value is "'||g.default_value||'" as per V$SYS_OPTIMIZER_ENV.'
  FROM v$sys_optimizer_env g
 WHERE g.isdefault = 'NO'
   AND NOT EXISTS (
SELECT NULL
  FROM v$sql_optimizer_env s
 WHERE s.sql_id = :sql_id
   AND s.isdefault = 'NO'
   AND s.name = g.name
   AND s.value = g.value );

-- optimizer_features_enable != rdbms_version at system level
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'OPTIMIZER_FEATURES_ENABLE',
       'DB version ^^rdbms_version. and OPTIMIZER_FEATURES_ENABLE ^^sys_ofe. do not match as per V$SYSTEM_PARAMETER2.',
       'Be aware that you are using a prior version of the optimizer. New CBO features in your DB version may not be used.'
  FROM DUAL
 WHERE SUBSTR('^^rdbms_version.', 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH('^^sys_ofe.'))) != SUBSTR('^^sys_ofe.', 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH('^^sys_ofe.')));

-- optimizer_features_enable != rdbms_version at sql level
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'OPTIMIZER_FEATURES_ENABLE',
       'DB version ^^rdbms_version. and OPTIMIZER_FEATURES_ENABLE '||v.value||' do not match for SQL_ID '||:sql_id||' as per V$SQL_OPTIMIZER_ENV.',
       'Be aware that you are using a prior version of the optimizer. New CBO features in your DB version may not be used.'
  FROM (
SELECT DISTINCT value
  FROM v$sql_optimizer_env
 WHERE sql_id = :sql_id
   AND LOWER(name) = 'optimizer_features_enable'
   AND SUBSTR('^^rdbms_version.', 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH(value))) != SUBSTR(value, 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH(value))) ) v;

-- optimizer_dynamic_sampling between 1 and 3 at system level
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'OPTIMIZER_DYNAMIC_SAMPLING',
       'Dynamic Sampling is set to small value of ^^sys_ds. as per V$SYSTEM_PARAMETER2.',
       'Be aware that using such a small value may produce statistics of poor quality.<br>'||CHR(10)||
       'If you rely on this functionality consider using a value no smaller than 4.'
  FROM plan_table pt,
       dba_tables t
 WHERE TO_NUMBER('^^sys_ds.') BETWEEN 1 AND 3
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.temporary = 'N'
   AND (t.last_analyzed IS NULL OR t.num_rows IS NULL)
   AND ROWNUM = 1;

-- db_file_multiblock_read_count should not be set
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'DB_FILE_MULTIBLOCK_READ_COUNT',
       'MBRC Parameter is set to "'||value||'" overriding its default value.',
       'The default value of this parameter is a value that corresponds to the maximum I/O size that can be performed efficiently.<br>'||CHR(10)||
       'This value is platform-dependent and is 1MB for most platforms.<br>'||CHR(10)||
       'Because the parameter is expressed in blocks, it will be set to a value that is equal to the maximum I/O size that can be performed efficiently divided by the standard block size.'
  FROM v$system_parameter2
 WHERE UPPER(name) = 'DB_FILE_MULTIBLOCK_READ_COUNT'
   AND (isdefault = 'FALSE' OR ismodified != 'FALSE');

-- nls_sort is not binary (session)
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'NLS PARAMETER', SYSTIMESTAMP, 'NLS_SORT',
       'NLS_SORT Session Parameter is set to "'||value||'" in V$NLS_PARAMETERS.',
       'Setting NLS_SORT to anything other than BINARY causes a sort to use a full table scan, regardless of the path chosen by the optimizer.'
  FROM v$nls_parameters
 WHERE UPPER(parameter) = 'NLS_SORT'
   AND UPPER(value) != 'BINARY';

-- nls_sort is not binary (instance)
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'NLS PARAMETER', SYSTIMESTAMP, 'NLS_SORT',
       'NLS_SORT Instance Parameter is set to "'||value||'" in V$SYSTEM_PARAMETER.',
       'Setting NLS_SORT to anything other than BINARY causes a sort to use a full table scan, regardless of the path chosen by the optimizer.'
  FROM v$system_parameter
 WHERE UPPER(name) = 'NLS_SORT'
   AND UPPER(value) != 'BINARY';

-- nls_sort is not binary (global)
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'NLS PARAMETER', SYSTIMESTAMP, 'NLS_SORT',
       'NLS_SORT Global Parameter is set to "'||value||'" in NLS_DATABASE_PARAMETERS.',
       'Setting NLS_SORT to anything other than BINARY causes a sort to use a full table scan, regardless of the path chosen by the optimizer.'
  FROM nls_database_parameters
 WHERE UPPER(parameter) = 'NLS_SORT'
   AND UPPER(value) != 'BINARY';

-- DBMS_STATS AUTOMATIC GATHERING on 10g
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'DBA_SCHEDULER_JOBS',
       'Automatic gathering of CBO statistics is enabled.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using FND_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Be aware that small sample sizes could produce poor quality histograms,<br>'||CHR(10)||
           'which combined with bind sensitive predicates could render suboptimal plans.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM dba_scheduler_jobs
 WHERE job_name = 'GATHER_STATS_JOB'
   AND enabled = 'TRUE';

-- DBMS_STATS AUTOMATIC GATHERING on 11g
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'DBA_AUTOTASK_CLIENT',
       'Automatic gathering of CBO statistics is enabled.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using FND_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Be aware that small sample sizes could produce poor quality histograms,<br>'||CHR(10)||
           'which combined with bind sensitive predicates could render suboptimal plans.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM dba_autotask_client
 WHERE client_name = 'auto optimizer stats collection'
   AND status = 'ENABLED';

-- high version count
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'VERSION COUNT', SYSTIMESTAMP, 'VERSION COUNT',
       'This SQL shows evidence of high version count of '||MAX(v.version_count)||'.',
       'Review Execution Plans for details.'
  FROM (
SELECT MAX(version_count) version_count
  FROM gv$sqlarea_plan_hash
 WHERE sql_id = :sql_id
 UNION
SELECT MAX(version_count) version_count
  FROM dba_hist_sqlstat
 WHERE :license = 'Y'
   AND sql_id = :sql_id ) v
HAVING MAX(v.version_count) > 100;

-- first rows
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'OPTIMZER MODE', SYSTIMESTAMP, 'FIRST_ROWS',
       'OPTIMIZER_MODE was set to FIRST_ROWS in '||v.pln_count||' Plan(s).',
       'The optimizer uses a mix of cost and heuristics to find a best plan for fast delivery of the first few rows.<br>'||CHR(10)||
       'Using heuristics sometimes leads the query optimizer to generate a plan with a cost that is significantly larger than the cost of a plan without applying the heuristic.<br>'||CHR(10)||
       'FIRST_ROWS is available for backward compatibility and plan stability; use FIRST_ROWS_n instead.'
FROM (
SELECT COUNT(*) pln_count
  FROM (
SELECT plan_hash_value
  FROM gv$sql
 WHERE sql_id = :sql_id
   AND optimizer_mode = 'FIRST_ROWS'
 UNION
SELECT plan_hash_value
  FROM dba_hist_sqlstat
 WHERE :license = 'Y'
   AND sql_id = :sql_id
   AND optimizer_mode = 'FIRST_ROWS') v) v
 WHERE v.pln_count > 0;

-- fixed objects missing stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'FIXED OBJECTS', SYSTIMESTAMP, 'DBA_TAB_COL_STATISTICS',
       'There exist(s) '||v.tbl_count||' Fixed Object(s) accessed by this SQL without CBO statistics.',
       'Consider gathering statistics for fixed objects using DBMS_STATS.GATHER_FIXED_OBJECTS_STATS.<br>'||CHR(10)||
       'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
FROM (
SELECT COUNT(*) tbl_count
  FROM plan_table pt,
       dba_tab_statistics t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.object_type = 'FIXED TABLE'
   AND NOT EXISTS (
SELECT NULL
  FROM dba_tab_cols c
 WHERE t.owner = c.owner
   AND t.table_name = c.table_name )) v
 WHERE v.tbl_count > 0;

-- system statistics not gathered
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Workload CBO System Statistics are not gathered. CBO is using default values.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_MAIN'
   AND pname = 'CPUSPEED'
   AND pval1 IS NULL;

-- mreadtim < sreadtim
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||a1.pval1||'ms seems too small compared to single-block read time of '||a2.pval1||'ms.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM and MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$ a1, sys.aux_stats$ a2
 WHERE a1.sname = 'SYSSTATS_MAIN'
   AND a1.pname = 'MREADTIM'
   AND a2.sname = 'SYSSTATS_MAIN'
   AND a2.pname = 'SREADTIM'
   AND a1.pval1 < a2.pval1;

-- sreadtim < 2
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Single-block read time of '||pval1||' milliseconds seems too small.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_MAIN'
   AND pname = 'SREADTIM'
   AND pval1 < 2;

-- mreadtim < 3
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||pval1||' milliseconds seems too small.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_MAIN'
   AND pname = 'MREADTIM'
   AND pval1 < 3;

-- sreadtim > 18
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Single-block read time of '||pval1||' milliseconds seems too large.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a> and Bug <a target="MOS" href="^^bug_link.9842771">9842771</a>.'
  FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_MAIN'
   AND pname = 'SREADTIM'
   AND pval1 > 18;

-- mreadtim > 522
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||pval1||' milliseconds seems too large.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a> and Bug <a target="MOS" href="^^bug_link.9842771">9842771</a>.'
  FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_MAIN'
   AND pname = 'MREADTIM'
   AND pval1 > 522;

-- sql with policies as per v$vpd_policy
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'VDP', SYSTIMESTAMP, 'V$VPD_POLICY',
       'Virtual Private Database. There is one or more policies affecting this SQL.',
       'Review Execution Plans and look for their injected predicates.'
  FROM v$vpd_policy
 WHERE sql_id = :sql_id
HAVING COUNT(*) > 0;

-- materialized views with rewrite enabled
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'MAT_VIEW', SYSTIMESTAMP, 'REWRITE_ENABLED',
       'There are '||COUNT(*)||' materialized views with rewrite enabled.',
       'A large number of materialized views could affect parsing time since CBO would have to evaluate each during a hard-parse.'
  FROM v$system_parameter2 p,
       dba_mviews m
 WHERE UPPER(p.name) = 'QUERY_REWRITE_ENABLED'
   AND UPPER(p.value) = 'TRUE'
   AND m.rewrite_enabled = 'Y'
HAVING COUNT(*) > 1;

-- table with bitmap index(es)
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_GLOBAL, 'INDEX', SYSTIMESTAMP, 'BITMAP',
       'Your DML statement references '||COUNT(DISTINCT pt.object_name||pt.object_owner)||' Table(s) with at least one Bitmap index.',
       'Be aware that frequent DML operations operations in a Table with Bitmap indexes may produce contention where concurrent DML operations are common. If your SQL suffers of "TX-enqueue row lock contention" suspect this situation.'
  FROM plan_table pt,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type = 'BITMAP'
   AND EXISTS (
SELECT NULL
  FROM gv$sqlarea s
 WHERE s.sql_id = :sql_id
   AND s.command_type IN (2, 6, 7)) -- INSERT, UPDATE, DELETE
HAVING COUNT(*) > 0;

-- index in plan no longer exists
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Index referenced by an Execution Plan no longer exists.',
       'If a Plan references a missing index then this Plan can no longer be generated by the CBO.'
  FROM plan_table pt
 WHERE pt.object_type = 'INDEX'
   AND NOT EXISTS (
SELECT NULL
  FROM dba_indexes i
 WHERE pt.object_owner = i.owner
   AND pt.object_name = i.index_name );

/* -------------------------
 *
 * table hc
 *
 * ------------------------- */

-- empty_blocks > blocks
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has more empty blocks ('||t.empty_blocks||') than actual blocks ('||t.blocks||') according to CBO statistics.',
       'Review Table statistics and consider re-organizing this Table.'
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.empty_blocks > t.blocks;

-- table dop is set
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table''s DOP is "'||TRIM(t.degree)||'".',
       'Degree of parallelism greater than 1 may cause parallel-execution PX plans.<br>'||CHR(10)||
       'Review table properties and execute "ALTER TABLE '||pt.object_owner||'.'||pt.object_name||' NOPARALLEL" to reset degree of parallelism to 1 if PX plans are not desired.'
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND TRIM(t.degree) NOT IN ('0', '1', 'DEFAULT');

-- table has indexes with dop set
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has '||COUNT(*)||' index(es) with DOP greater than 1.',
       'Degree of parallelism greater than 1 may cause parallel-execution PX plans.<br>'||CHR(10)||
       'Review index properties and execute "ALTER INDEX index_name NOPARALLEL" to reset degree of parallelism to 1 if PX plans are not desired.'
  FROM plan_table pt,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND TRIM(i.degree) NOT IN ('0', '1', 'DEFAULT')
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- index degree != table degree
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has '||COUNT(*)||' index(es) with DOP different than its table.',
       'Table has a degree of parallelism of "'||TRIM(t.degree)||'".<br>'||CHR(10)||
       'Review index properties and fix degree of parallelism of table and/or its index(es).'
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND TRIM(t.degree) != TRIM(i.degree)
 GROUP BY
       pt.object_owner,
       pt.object_name,
       TRIM(t.degree);

-- no stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table lacks CBO Statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.temporary = 'N'
   AND (t.last_analyzed IS NULL OR t.num_rows IS NULL);

-- no rows
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Number of rows equal to zero according to table''s CBO statistics.',
       CASE
         WHEN t.temporary = 'Y' THEN
           'Consider deleting table statistics on this GTT using DBMS_STATS.DELETE_TABLE_STATS.'
         WHEN '^^is_ebs.' = 'Y' THEN
           'If this table has rows consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has less than 15 rows consider deleting table statistics using DBMS_STATS.DELETE_TABLE_STATS,<br>'||CHR(10)||
           'else gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'If this table has rows consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows = 0;

-- siebel small tables
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Small table with CBO statistics.',
       'Consider deleting table statistics on this small table using DBMS_STATS.DELETE_TABLE_STATS.<br>'||CHR(10)||
       'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
  FROM plan_table pt,
       dba_tables t
 WHERE '^^is_siebel.' = 'Y'
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows < 15;

-- small sample size
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Sample size of '||v.sample_size||' rows may be too small for table with '||v.num_rows||' rows.',
       'Sample percent used was:'||TRIM(TO_CHAR(ROUND(v.ratio * 100, 2), '99999990D00'))||'%.<br>'||CHR(10)||
       'Consider gathering better quality table statistics with a sample size of '||ROUND(v.factor * 100)||'%.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows,
       t.sample_size,
       (t.sample_size / t.num_rows) ratio,
       CASE
         WHEN t.num_rows < 1e6 THEN -- up to 1M then 100%
           1
         WHEN t.num_rows < 1e7 THEN -- up to 10M then 30%
           3/10
         WHEN t.num_rows < 1e8 THEN -- up to 100M then 10%
           1/10
         WHEN t.num_rows < 1e9 THEN -- up to 1B then 3%
           3/100
         ELSE -- more than 1B then 1%
           1/100
         END factor
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.sample_size > 0
   AND t.last_analyzed IS NOT NULL ) v
 WHERE v.ratio < (9/10) * v.factor;

-- old stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table CBO statistics are '||ROUND(SYSDATE - v.last_analyzed)||' days old: '||TO_CHAR(v.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS')||'.',
       'Consider gathering fresh table statistics with a sample size of '||ROUND(v.factor * 100)||'%.<br>'||CHR(10)||
       'Old statistics could contain low/high values for which a predicate may be out of range, producing then a poor plan.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed,
       t.num_rows,
       t.sample_size,
       (t.sample_size / t.num_rows) ratio,
       CASE
         WHEN t.num_rows < 1e6 THEN -- up to 1M then 100%
           1
         WHEN t.num_rows < 1e7 THEN -- up to 10M then 30%
           3/10
         WHEN t.num_rows < 1e8 THEN -- up to 100M then 10%
           1/10
         WHEN t.num_rows < 1e9 THEN -- up to 1B then 3%
           3/100
         ELSE -- more than 1B then 1%
           1/100
         END factor
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.sample_size > 0
   AND t.last_analyzed IS NOT NULL ) v
 WHERE v.last_analyzed < SYSDATE - 49
    OR (v.num_rows BETWEEN 0 AND 1e6 AND v.last_analyzed < SYSDATE - 21)
    OR (v.num_rows BETWEEN 1e6 AND 1e7 AND v.last_analyzed < SYSDATE - 28)
    OR (v.num_rows BETWEEN 1e7 AND 1e8 AND v.last_analyzed < SYSDATE - 35)
    OR (v.num_rows BETWEEN 1e8 AND 1e9 AND v.last_analyzed < SYSDATE - 42);


-- extended statistics
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has '||COUNT(*)||' CBO statistics extension(s).',
       'Review table statistics extensions. Extensions can be used for expressions or column groups.<br>'||CHR(10)||
       'If your SQL contain matching predicates these extensions can influence the CBO.'
  FROM plan_table pt,
       dba_stat_extensions e
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = e.owner
   AND pt.object_name = e.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- columns with no stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Contains '||COUNT(*)||' column(s) with missing CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.last_analyzed IS NULL
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- columns missing low/high values
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Contains '||COUNT(*)||' column(s) with null low/high values.',
       'CBO cannot compute correct selectivity with these column statistics missing.<br>'||CHR(10)||
       'You may possibly have Bug <a target="MOS" href="^^bug_link.10248781">10248781</a><br>'||CHR(10)||
       'Consider gathering statistics for this table.'
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.last_analyzed IS NOT NULL
   AND c.num_distinct > 0
   AND (c.low_value IS NULL OR c.high_value IS NULL)
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- columns with old stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains column(s) with outdated CBO statistics for up to '||TRUNC(ABS(v.tbl_last_analyzed - v.col_last_analyzed))||' day(s).',
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table.<br>'||CHR(10)||
       'Old statistics could contain low/high values for which a predicate may be out of range, producing then a poor plan.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed tbl_last_analyzed,
       MIN(c.last_analyzed) col_last_analyzed
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.last_analyzed IS NOT NULL
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.last_analyzed ) v
 WHERE ABS(v.tbl_last_analyzed - v.col_last_analyzed) > 1;

-- more nulls than rows
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Number of nulls greater than number of rows by more than 10% in '||v.col_count||' column(s).',
       'There cannot be more rows with null value in a column than actual rows in the table.<br>'||CHR(10)||
       'Worst column shows '||v.num_nulls||' nulls while table has '||v.tbl_num_rows||' rows.<br>'||CHR(10)||
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table using a large sample size.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows tbl_num_rows,
       COUNT(*) col_count,
       MAX(c.num_nulls) num_nulls
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.num_nulls > t.num_rows
   AND (c.num_nulls - t.num_rows) > t.num_rows * 0.1
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows ) v
 WHERE v.col_count > 0;

-- more distinct values than rows
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Number of distinct values greater than number of rows by more than 10% in '||v.col_count||' column(s).',
       'There cannot be a larger number of distinct values in a column than actual rows in the table.<br>'||CHR(10)||
       'Worst column shows '||v.num_distinct||' distinct values while table has '||v.tbl_num_rows||' rows.<br>'||CHR(10)||
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table using a large sample size.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows tbl_num_rows,
       COUNT(*) col_count,
       MAX(c.num_distinct) num_distinct
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.num_distinct > t.num_rows
   AND (c.num_distinct - t.num_rows) > t.num_rows * 0.1
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows ) v
 WHERE v.col_count > 0;

-- zero distinct values on columns with value
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Number of distinct values is zero in at least '||v.col_count||' column(s) with value.',
       'There should not be columns with value ((num_rows - num_nulls) greater than 0) where the number of distinct values for the same column is zero.<br>'||CHR(10)||
       'Worst column shows '||(v.tbl_num_rows - v.num_nulls)||' rows with value while the number of distinct values for it is zero.<br>'||CHR(10)||
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table using a large sample size.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows tbl_num_rows,
       COUNT(*) col_count,
       MIN(c.num_nulls) num_nulls
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND t.num_rows > c.num_nulls
   AND c.num_distinct = 0
   AND (t.num_rows - c.num_nulls) > t.num_rows * 0.1
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows ) v
 WHERE v.col_count > 0;

 -- 9885553 incorrect ndv in long char column with histogram
 INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
 SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
        'Table contains '||v.col_count||' long CHAR column(s) with Histogram. Number of distinct values (NDV) could be incorrect.',
        'Possible Bug <a target="MOS" href="^^bug_link.9885553">9885553</a>.<br>'||CHR(10)||
        'When building histogram for a varchar column that is long, we only use its first 32 characters.<br>'||CHR(10)||
        'Two distinct values that share the same first 32 characters are deemed the same in the histogram.<br>'||CHR(10)||
        'Therefore the NDV derived from the histogram is inaccurate.'||CHR(10)||
        'If NDV is wrong then drop the Histogram.'
   FROM (
 SELECT pt.object_owner,
        pt.object_name,
        COUNT(*) col_count
   FROM plan_table pt,
        dba_tab_cols c
  WHERE pt.object_type = 'TABLE'
    AND pt.object_owner = c.owner
    AND pt.object_name = c.table_name
    AND c.num_distinct > 0
    AND c.data_type LIKE '%CHAR%'
    AND c.avg_col_len > 32
    AND c.histogram IN ('FREQUENCY', 'HEIGHT BALANCED')
    AND '^^rdbms_version.' < '11.2.0.3'
  GROUP BY
        pt.object_owner,
        pt.object_name ) v
  WHERE v.col_count > 0;

-- 10174050 frequency histograms with less buckets than ndv
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' column(s) where the number of distinct values does not match the number of buckets.',
       'Review column statistics for this table and look for "Num Distinct" and "Num Buckets". If there are values missing from the frecuency histogram you may have Bug <a target="MOS" href="^^bug_link.10174050">10174050</a>.<br>'||CHR(10)||
       'If you are referencing in your predicates one of the missing values the CBO can over estimate table cardinality, and this may produce a sub-optimal plan.<br>'||CHR(10)||
       'You can either gather statistics with 100% or as a workaround: ALTER system/session "_fix_control"=''5483301:OFF'';'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) col_count
  FROM plan_table pt,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.histogram = 'FREQUENCY'
   AND c.num_distinct != c.num_buckets
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.col_count > 0;

-- frequency histogram with 1 bucket
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' column(s) where the number of buckets is 1 for a "FREQUENCY" histogram.',
       'Review column statistics for this table and look for "Num Buckets" and "Histogram". Possible Bugs '||
       '<a target="MOS" href="^^bug_link.1386119">1386119</a>, '||
       '<a target="MOS" href="^^bug_link.4406309">4406309</a>, '||
       '<a target="MOS" href="^^bug_link.4495422">4495422</a>, '||
       '<a target="MOS" href="^^bug_link.4567767">4567767</a>, '||
       '<a target="MOS" href="^^bug_link.5483301">5483301</a> or '||
       '<a target="MOS" href="^^bug_link.6082745">6082745</a>.<br>'||CHR(10)||
       'If you are referencing in your predicates one of the missing values the CBO can over estimate table cardinality, and this may produce a sub-optimal plan.<br>'||CHR(10)||
       'You can either gather statistics with 100% or as a workaround: ALTER system/session "_fix_control"=''5483301:OFF'';'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) col_count
  FROM plan_table pt,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.histogram = 'FREQUENCY'
   AND c.num_buckets = 1
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.col_count > 0;

-- height balanced histogram with no popular values
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' column(s) with no popular values on a "HEIGHT BALANCED" histogram.',
       'A Height-balanced histogram with no popular values is not helpful nor desired. Consider dropping this histogram by collecting new CBO statistics while using METHOD_OPT with SIZE 1.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) col_count
  FROM plan_table pt,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.histogram = 'HEIGHT BALANCED'
   AND c.num_buckets > 253
   AND (SELECT COUNT(*)
          FROM dba_tab_histograms h
         WHERE h.owner = c.owner
           AND h.table_name = c.table_name
           AND h.column_name = c.column_name) > 253
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.col_count > 0;

-- analyze 236935.1
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'CBO statistics were either gathered using deprecated ANALYZE command or derived by aggregation from lower level objects.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using FND_STATS instead.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using coe_siebel_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using pscbo_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using DBMS_STATS instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND t.partitioned = 'NO'
   AND t.global_stats = 'NO';

-- Bug 3620168
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Average row length is 100.',
       'Possible Bug <a target="MOS" href="^^bug_link.3620168">3620168</a>3620168.<br>'||CHR(10)||
       'Consider gathering table statistics for this table using METHOD_OPT => FOR ALL COLUMNS...'
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.avg_row_len = 100;

-- tables with stale statistics
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has stale statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tab_statistics t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.object_type = 'TABLE'
   AND t.stale_stats = 'YES';

-- sql with policies as per dba_policies
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'DBA_POLICIES', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Virtual Private Database. There is one or more policies affecting this table.',
       'Review Execution Plans and look for their injected predicates.'
  FROM plan_table pt,
       dba_policies p
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = p.object_owner
   AND pt.object_name = p.object_name
 GROUP BY
       pt.object_owner,
       pt.object_name
HAVING COUNT(*) > 0
 ORDER BY
       pt.object_owner,
       pt.object_name;

-- sql with policies as per dba_audit_policies
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE, 'DBA_AUDIT_POLICIES', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Fine-Grained Auditing. There is one or more audit policies affecting this table.',
       'Review Execution Plans and look for their injected predicates.'
  FROM plan_table pt,
       dba_audit_policies p
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = p.object_schema
   AND pt.object_name = p.object_name
 GROUP BY
       pt.object_owner,
       pt.object_name
HAVING COUNT(*) > 0
 ORDER BY
       pt.object_owner,
       pt.object_name;

-- table partitions with no stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.no_stats||' out of '||v.par_count||' partition(s) lack(s) CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering statistics using FND_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Consider gathering statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering statistics using DBMS_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.last_analyzed IS NULL OR p.num_rows IS NULL THEN 1 ELSE 0 END) no_stats
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions p
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = p.table_owner
   AND pt.object_name = p.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.no_stats > 0;

-- table partitions where num rows = 0
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.num_rows_zero||' out of '||v.par_count||' partition(s) with number of rows equal to zero according to partition''s CBO statistics.',
       'If these table partitions are not empty, consider gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.num_rows = 0 THEN 1 ELSE 0 END) num_rows_zero
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions p
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = p.table_owner
   AND pt.object_name = p.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.num_rows_zero > 0;

-- table partitions with oudated stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains partition(s) with table/partition CBO statistics out of sync for up to '||TRUNC(ABS(v.tbl_last_analyzed - v.par_last_analyzed))||' day(s).',
       'Table and partition statistics were gathered up to '||TRUNC(ABS(v.tbl_last_analyzed - v.par_last_analyzed))||' day(s) appart, so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
       'Consider re-gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed tbl_last_analyzed,
       COUNT(*) par_count,
       MIN(p.last_analyzed) par_last_analyzed
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions p
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = p.table_owner
   AND pt.object_name = p.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.last_analyzed ) v
 WHERE ABS(v.tbl_last_analyzed - v.par_last_analyzed) > 1;

-- partitions with no stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.no_stats||' column(s) lack(s) partition level CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering statistics using FND_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Consider gathering statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering statistics using DBMS_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       (SELECT COUNT(DISTINCT c.column_name)
          FROM dba_part_col_statistics c
         WHERE c.owner = pt.object_owner
           AND c.table_name = pt.object_name
           AND c.last_analyzed IS NULL) no_stats
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.no_stats > 0;

-- partition columns with oudated stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains column(s) with table/partition CBO statistics out of sync for up to '||TRUNC(ABS(v.tbl_last_analyzed - v.col_last_analyzed))||' day(s).',
       'Table and partition statistics were gathered up to '||TRUNC(ABS(v.tbl_last_analyzed - v.col_last_analyzed))||' day(s) appart, so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
       'Consider re-gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed tbl_last_analyzed,
       (SELECT MIN(c.last_analyzed)
          FROM dba_part_col_statistics c
         WHERE c.owner = pt.object_owner
           AND c.table_name = pt.object_name
           AND c.last_analyzed IS NOT NULL) col_last_analyzed
  FROM plan_table pt,
       dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.last_analyzed ) v
 WHERE ABS(v.tbl_last_analyzed - v.col_last_analyzed) > 1;

/* -------------------------
 *
 * index hc
 *
 * ------------------------- */

-- no stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index lacks CBO Statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND (i.last_analyzed IS NULL OR i.num_rows IS NULL);

-- more rows in index than its table
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index appears to have more rows ('||i.num_rows||') than its table ('||t.num_rows||') by '||ROUND(100 * (i.num_rows - t.num_rows) / t.num_rows)||'%.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.num_rows > t.num_rows
   AND (i.num_rows - t.num_rows) > t.num_rows * 0.1;

-- clustering factor > rows in table
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Clustering factor of '||i.clustering_factor||' is larger than number of rows in its table ('||t.num_rows||') by more than '||ROUND(100 * (i.clustering_factor - t.num_rows) / t.num_rows)||'%.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.clustering_factor > t.num_rows
   AND (i.clustering_factor - t.num_rows) > t.num_rows * 0.1;

-- stats on zero while columns have value
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index CBO statistics on 0 with indexed columns with value.',
       'This index with zeroes in CBO index statistics contains columns for which there are values, so the index should not have statistics in zeroes.<br>'||CHR(10)||
       'Possible Bug <a target="MOS" href="^^bug_link.4055596">4055596</a>. Consider gathering table statistics, or DROP and RE-CREATE index.'
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.num_rows = 0
   AND i.distinct_keys = 0
   AND i.leaf_blocks = 0
   AND i.blevel = 0
   AND EXISTS (
SELECT NULL
  FROM dba_ind_columns ic,
       dba_tab_cols tc
 WHERE ic.index_owner = i.owner
   AND ic.index_name = i.index_name
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND t.num_rows > tc.num_nulls
   AND (t.num_rows - tc.num_nulls) > t.num_rows * 0.1);

-- table/index stats out of sync
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Table/Index CBO statistics out of sync.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS using CASCADE=>TRUE.'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND ABS(t.last_analyzed - i.last_analyzed) > 1;

-- analyze 236935.1
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'CBO statistics were either gathered using deprecated ANALYZE command or derived by aggregation from lower level objects.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using FND_STATS instead.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using coe_siebel_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using pscbo_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Same is true when statistics were derived by aggregation from lower level objects.<br>'||CHR(10)||
           'Consider gathering statistics using DBMS_STATS instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type = 'NORMAL'
   AND i.last_analyzed IS NOT NULL
   AND i.partitioned = 'NO'
   AND i.global_stats = 'NO';

-- no column stats in single-column index
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Lack of CBO statistics in column of this single-column index.',
       'To avoid CBO guessed statistics on this indexed column, gather table statistics and include this column in METHOD_OPT used.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND (tc.last_analyzed IS NULL OR tc.num_distinct IS NULL OR tc.num_nulls IS NULL)
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- ndv on column > num_rows in single-column index
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Single-column index with number of distinct values greater than number of rows by '||ROUND(100 * (tc.num_distinct - i.num_rows) / i.num_rows)||'%.',
       'There cannot be a larger number of distinct values ('||tc.num_distinct||') in a column than actual rows ('||i.num_rows||') in the index.<br>'||CHR(10)||
       'This is an inconsistency on this indexed column. Consider gathering table statistics using a large sample size.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.num_distinct > i.num_rows
   AND (tc.num_distinct - i.num_rows) > i.num_rows * 0.1
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- ndv is zero but column has values in single-column index
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Single-column index with number of distinct value equal to zero in column with value.',
       'There should not be columns with value where the number of distinct values for the same column is zero.<br>'||CHR(10)||
       'Column has '||(i.num_rows - tc.num_nulls)||' rows with value while the number of distinct values for it is zero.<br>'||CHR(10)||
       'This is an inconsistency on this indexed column. Consider gathering table statistics using a large sample size.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.num_distinct = 0
   AND i.num_rows > tc.num_nulls
   AND (i.num_rows - tc.num_nulls) > i.num_rows * 0.1
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- Bugs 4495422 or 9885553 in single-column index
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Number of distinct values ('||tc.num_distinct||') does not match number of distinct keys ('||i.distinct_keys||') by '||ROUND(100 * (i.distinct_keys - tc.num_distinct) / tc.num_distinct)||'%.',
       CASE
         WHEN tc.data_type LIKE '%CHAR%' AND tc.num_buckets > 1 THEN
           'Possible Bug <a target="MOS" href="^^bug_link.4495422">4495422</a> or <a target="MOS" href="^^bug_link.9885553">9885553</a>.<br>'||CHR(10)||
           'This is an inconsistency on this indexed column. Gather fresh statistics with no histograms or adjusting DISTCNT and DENSITY using SET_COLUMN_statistics APIs.'
         ELSE
           'This is an inconsistency on this indexed column. Gather fresh statistics or adjusting DISTCNT and DENSITY using SET_COLUMN_statistics APIs.'
         END
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.num_distinct > 0
   AND i.distinct_keys > 0
   AND i.distinct_keys > tc.num_distinct
   AND (i.distinct_keys - tc.num_distinct) > tc.num_distinct * 0.1
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- index partitions with no stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.no_stats||' out of '||v.par_count||' partition(s) lack(s) CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering statistics using FND_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Consider gathering statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering statistics using DBMS_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.last_analyzed IS NULL OR p.num_rows IS NULL THEN 1 ELSE 0 END) no_stats
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND i.num_rows > 0
   AND i.last_analyzed IS NOT NULL
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.no_stats > 0;

-- index partitions where num rows = 0
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.num_rows_zero||' out of '||v.par_count||' partition(s) with number of rows equal to zero according to partition''s CBO statistics.',
       'If these index partitions are not empty, consider gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.num_rows = 0 THEN 1 ELSE 0 END) num_rows_zero
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND i.num_rows > 0
   AND i.last_analyzed IS NOT NULL
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE v.num_rows_zero > 0;

-- index partitions with oudated stats
INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
SELECT :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Index contains partition(s) with index/partition CBO statistics out of sync for up to '||TRUNC(ABS(v.idx_last_analyzed - v.par_last_analyzed))||' day(s).',
       'Index and partition statistics were gathered up to '||TRUNC(ABS(v.idx_last_analyzed - v.par_last_analyzed))||' day(s) appart, so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
       'Consider re-gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       i.last_analyzed idx_last_analyzed,
       COUNT(*) par_count,
       MIN(p.last_analyzed) par_last_analyzed
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND i.num_rows > 0
   AND i.last_analyzed IS NOT NULL
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
 GROUP BY
       pt.object_owner,
       pt.object_name,
       i.last_analyzed ) v
 WHERE ABS(v.idx_last_analyzed - v.par_last_analyzed) > 1;

/**************************************************************************************************/

/* -------------------------
 *
 * hc report
 *
 * ------------------------- */

-- setup to produce report
SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF;

/* -------------------------
 *
 * heading
 *
 * ------------------------- */
SPO sqlhc_^^database_name_short._^^host_name_short._^^rdbms_version._^^sql_id._^^time_stamp..html;

PRO <html>
PRO <!-- $Header: ^^mos_doc. sqlhc.html ^^doc_ver. ^^doc_date. carlos.sierra $ -->
PRO <!-- Copyright (c) 2000-2011, Oracle Corporation. All rights reserved. -->
PRO <!-- Author: carlos.sierra@oracle.com -->
PRO
PRO <head>
PRO <title>sqlhc_^^database_name_short._^^host_name_short._^^rdbms_version._^^sql_id._^^time_stamp..html</title>
PRO

PRO <style type="text/css">
PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO a {font-weight:bold; color:#663300;}
PRO pre {font:8pt Monaco,"Courier New",Courier,monospace;} /* for code */
PRO h1 {font-size:16pt; font-weight:bold; color:#336699;}
PRO h2 {font-size:14pt; font-weight:bold; color:#336699;}
PRO h3 {font-size:12pt; font-weight:bold; color:#336699;}
PRO li {font-size:10pt; font-weight:bold; color:#336699; padding:0.1em 0 0 0;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td.c {text-align:center;} /* center */
PRO td.l {text-align:left;} /* left (default) */
PRO td.r {text-align:right;} /* right */
PRO font.n {font-size:8pt; font-style:italic; color:#336699;} /* table footnote in blue */
PRO font.f {font-size:8pt; color:#999999;} /* footnote in gray */
PRO </style>
PRO

PRO </head>
PRO <body>
PRO <h1><a target="MOS" href="^^doc_link.^^mos_doc.">^^mos_doc.</a> SQLHC
PRO ^^doc_ver. Report: sqlhc_^^database_name_short._^^host_name_short._^^rdbms_version._^^sql_id._^^time_stamp..html</h1>
PRO

PRO <pre>
PRO License : "^^input_license."
PRO SQL_ID  : "^^input_sql_id."
PRO RDBMS   : "^^rdbms_version."
PRO Platform: "^^platform."
PRO OFE     : "^^sys_ofe."
PRO DYN_SAMP: "^^sys_ds."
PRO EBS:      "^^is_ebs."
PRO SIEBEL  : "^^is_siebel."
PRO PSFT    : "^^is_psft."
PRO Date    : "^^time_stamp2."
PRO </pre>

/* -------------------------
 *
 * observations
 *
 * ------------------------- */
PRO <h2>Observations</h2>
PRO
PRO Observations below are the outcome of several heath-checks on the schema objects accessed by your SQL and its environment.
PRO Review them carefully and take action when appropriate. Then re-execute your SQL and generate this report again.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Type</th>
PRO <th>Name</th>
PRO <th>Observation</th>
PRO <th>More</th>
PRO </tr>

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.object_type||'</td>'||CHR(10)||
       '<td>'||v.object_name||'</td>'||CHR(10)||
       '<td>'||v.observation||'</td>'||CHR(10)||
       '<td>'||v.more||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT operation object_type,
       other_tag object_name,
       remarks observation,
       projection more
  FROM plan_table
 WHERE id IS NOT NULL
   AND operation IS NOT NULL
   AND object_alias IS NOT NULL
   AND other_tag IS NOT NULL
   AND remarks IS NOT NULL
 ORDER BY
       id,
       operation,
       other_tag,
       object_alias ) v;

PRO
PRO </table>
PRO

/* -------------------------
 *
 * sql_text
 *
 * ------------------------- */
PRO <h2>SQL Text</h2>
PRO
PRO <pre>

DECLARE
  l_pos NUMBER;
BEGIN
  WHILE NVL(LENGTH(:sql_text), 0) > 0
  LOOP
    l_pos := INSTR(:sql_text, CHR(10));
    IF l_pos > 0 THEN
      DBMS_OUTPUT.PUT_LINE(SUBSTR(:sql_text, 1, l_pos - 1));
      :sql_text := SUBSTR(:sql_text, l_pos + 1);
    ELSE
      DBMS_OUTPUT.PUT_LINE(:sql_text);
      :sql_text := NULL;
    END IF;
  END LOOP;
END;
/

PRO </pre>

/* -------------------------
 *
 * tables summary
 *
 * ------------------------- */
PRO <h2>Tables Summary</h2>
PRO
PRO Values below have two purposes:<br>
PRO 1. Provide a quick view of the state of Table level CBO statistics, as well as their indexes and columns.<br>
PRO 2. Ease a compare between two systems that are believed to be similar.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Num Rows</th>
PRO <th>Table<br>Sample Size</th>
PRO <th>Last Analyzed</th>
PRO <th>Indexes</th>
PRO <th>Avg Index<br>Sample Size</th>
PRO <th>Table<br>Columns</th>
PRO <th>Columns with<br>Histogram</th>
PRO <th>Avg Column<br>Sample Size</th>
PRO </tr>

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.table_name||'</td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.table_sample_size||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.indexes||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_index_sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.columns||'</td>'||CHR(10)||
       '<td class="r">'||v.columns_with_histograms||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_column_sample_size||'</td>'||CHR(10)||
       '</tr>'
  FROM (
WITH
t AS (
SELECT pt.object_owner owner,
       pt.object_name table_name,
       t.num_rows,
       t.sample_size table_sample_size,
       TO_CHAR(t.last_analyzed, 'DD-MON-YY HH24:MI:SS') last_analyzed,
       COUNT(*) indexes,
       ROUND(AVG(i.sample_size)) avg_index_sample_size
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows,
       t.sample_size,
       t.last_analyzed ),
c AS (
SELECT pt.object_owner owner,
       pt.object_name table_name,
       COUNT(*) columns,
       SUM(CASE WHEN NVL(c.histogram, 'NONE') = 'NONE' THEN 0 ELSE 1 END) columns_with_histograms,
       ROUND(AVG(c.sample_size)) avg_column_sample_size
  FROM plan_table pt,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name )
SELECT t.table_name,
       t.owner,
       t.num_rows,
       t.table_sample_size,
       t.last_analyzed,
       t.indexes,
       t.avg_index_sample_size,
       c.columns,
       c.columns_with_histograms,
       c.avg_column_sample_size
  FROM t, c
 WHERE t.table_name = c.table_name
   AND t.owner = c.owner
 ORDER BY
       t.table_name,
       t.owner ) v;

PRO
PRO </table>
PRO

/* -------------------------
 *
 * indexes summary
 *
 * ------------------------- */
PRO <h2>Indexes Summary</h2>
PRO
PRO Values below have two purposes:<br>
PRO 1. Provide a quick view of the state of Index level CBO statistics, as well as their columns.<br>
PRO 2. Ease a compare between two systems that are believed to be similar.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Table<br>Owner</th>
PRO <th>Index Name</th>
PRO <th>Index<br>Owner</th>
PRO <th>In MEM<br>Plan</th>
PRO <th>In AWR<br>Plan</th>
PRO <th>Num Rows</th>
PRO <th>Index<br>Sample Size</th>
PRO <th>Last Analyzed</th>
PRO <th>Index<br>Columns</th>
PRO <th>Columns with<br>Histogram</th>
PRO <th>Avg Column<br>Sample Size</th>
PRO </tr>

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.table_name||'</td>'||CHR(10)||
       '<td>'||v.table_owner||'</td>'||CHR(10)||
       '<td>'||v.index_name||'</td>'||CHR(10)||
       '<td>'||v.index_owner||'</td>'||CHR(10)||
       '<td class="c">'||v.in_mem_plan||'</td>'||CHR(10)||
       '<td class="c">'||v.in_awr_plan||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.table_sample_size||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.columns||'</td>'||CHR(10)||
       '<td class="r">'||v.columns_with_histograms||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_column_sample_size||'</td>'||CHR(10)||
       '</tr>'
  FROM (
WITH
i AS (
SELECT pt.object_owner table_owner,
       pt.object_name table_name,
       i.owner index_owner,
       i.index_name,
       i.num_rows,
       i.sample_size table_sample_size,
       TO_CHAR(i.last_analyzed, 'DD-MON-YY HH24:MI:SS') last_analyzed,
       (SELECT 'YES'
          FROM gv$sql_plan p1
         WHERE p1.sql_id = :sql_id
           AND (p1.object_type LIKE '%INDEX%' OR p1.operation LIKE '%INDEX%')
           AND i.owner = p1.object_owner
           AND i.index_name = p1.object_name
           AND ROWNUM = 1) in_mem_plan,
       (SELECT 'YES'
          FROM dba_hist_sql_plan p2
         WHERE :license = 'Y'
           AND p2.sql_id = :sql_id
           AND (p2.object_type LIKE '%INDEX%' OR p2.operation LIKE '%INDEX%')
           AND i.owner = p2.object_owner
           AND i.index_name = p2.object_name
           AND ROWNUM = 1) in_awr_plan
  FROM plan_table pt,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name ),
c AS (
SELECT ic.index_owner,
       ic.index_name,
       COUNT(*) columns,
       SUM(CASE WHEN NVL(c.histogram, 'NONE') = 'NONE' THEN 0 ELSE 1 END) columns_with_histograms,
       ROUND(AVG(c.sample_size)) avg_column_sample_size
  FROM plan_table pt,
       dba_ind_columns ic,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = ic.table_owner
   AND pt.object_name = ic.table_name
   AND ic.table_owner = c.owner
   AND ic.table_name = c.table_name
   AND ic.column_name = c.column_name
 GROUP BY
       ic.index_owner,
       ic.index_name )
SELECT i.table_name,
       i.table_owner,
       i.index_name,
       i.index_owner,
       i.num_rows,
       i.table_sample_size,
       i.last_analyzed,
       i.in_mem_plan,
       i.in_awr_plan,
       c.columns,
       c.columns_with_histograms,
       c.avg_column_sample_size
  FROM i, c
 WHERE i.index_name = c.index_name
   AND i.index_owner = c.index_owner
 ORDER BY
       i.table_name,
       i.table_owner,
       i.index_name,
       i.index_owner ) v;

PRO
PRO </table>
PRO

/* -------------------------
 *
 * gv$sql
 *
 * ------------------------- */
PRO <h2>Current SQL Statistics (GV$SQL)</h2>
PRO
PRO Performance metrics of child cursors of ^^sql_id. while still in memory.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Inst<br>ID</th>
PRO <th>Child<br>Num</th>
PRO <th>Plan HV</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Outline</th>
PRO <th>Profile</th>
PRO <th>First Load</th>
PRO <th>Last Load</th>
PRO <th>Last Active</th>
PRO </tr>

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||inst_id||'</td>'||CHR(10)||
       '<td class="r">'||child_number||'</td>'||CHR(10)||
       '<td class="r">'||plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||executions||'</td>'||CHR(10)||
       '<td class="r">'||fetches||'</td>'||CHR(10)||
       '<td class="r">'||loads||'</td>'||CHR(10)||
       '<td class="r">'||invalidations||'</td>'||CHR(10)||
       '<td class="r">'||parse_calls||'</td>'||CHR(10)||
       '<td class="r">'||buffer_gets||'</td>'||CHR(10)||
       '<td class="r">'||disk_reads||'</td>'||CHR(10)||
       '<td class="r">'||direct_writes||'</td>'||CHR(10)||
       '<td class="r">'||rows_processed||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(elapsed_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(cpu_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(user_io_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(concurrency_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(application_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(cluster_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(plsql_exec_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(java_exec_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td>'||optimizer_mode||'</td>'||CHR(10)||
       '<td class="r">'||optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td>'||parsing_schema_name||'</td>'||CHR(10)||
       '<td>'||module||'</td>'||CHR(10)||
       '<td>'||action||'</td>'||CHR(10)||
       '<td>'||outline_category||'</td>'||CHR(10)||
       '<td>'||sql_profile||'</td>'||CHR(10)||
       '<td nowrap>'||first_load_time||'</td>'||CHR(10)||
       '<td nowrap>'||last_load_time||'</td>'||CHR(10)||
       '<td nowrap>'||TO_CHAR(last_active_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '</tr>'
  FROM gv$sql
 WHERE sql_id = :sql_id
 ORDER BY
       inst_id,
       child_number;

PRO
PRO </table>
PRO

/* -------------------------
 *
 * dba_hist_sqlstat
 *
 * ------------------------- */
PRO <h2>Historical SQL Statistics (DBA_HIST_SQLSTAT)</h2>
PRO
PRO Performance metrics of execution plans of ^^sql_id. captured by AWR.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Snap<br>ID</th>
PRO <th>Snaphot</th>
PRO <th>Inst<br>ID</th>
PRO <th>Plan HV</th>
PRO <th>Vers<br>Cnt</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO </tr>

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.snap_id||'</td>'||CHR(10)||
       '<td nowrap>'||TO_CHAR(v.end_interval_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '<td class="r">'||v.instance_number||'</td>'||CHR(10)||
       '<td class="r">'||v.plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||v.version_count||'</td>'||CHR(10)||
       '<td class="r">'||v.executions_total||'</td>'||CHR(10)||
       '<td class="r">'||v.fetches_total||'</td>'||CHR(10)||
       '<td class="r">'||v.loads_total||'</td>'||CHR(10)||
       '<td class="r">'||v.invalidations_total||'</td>'||CHR(10)||
       '<td class="r">'||v.parse_calls_total||'</td>'||CHR(10)||
       '<td class="r">'||v.buffer_gets_total||'</td>'||CHR(10)||
       '<td class="r">'||v.disk_reads_total||'</td>'||CHR(10)||
       '<td class="r">'||v.direct_writes_total||'</td>'||CHR(10)||
       '<td class="r">'||v.rows_processed_total||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.elapsed_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.cpu_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.iowait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.ccwait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.apwait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.clwait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.plsexec_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.javexec_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td>'||v.optimizer_mode||'</td>'||CHR(10)||
       '<td class="r">'||v.optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||v.optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td>'||v.parsing_schema_name||'</td>'||CHR(10)||
       '<td>'||v.module||'</td>'||CHR(10)||
       '<td>'||v.action||'</td>'||CHR(10)||
       '<td>'||v.sql_profile||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT
       h.snap_id,
       s.end_interval_time,
       h.instance_number,
       h.plan_hash_value,
       h.optimizer_cost,
       h.optimizer_mode,
       h.optimizer_env_hash_value,
       h.version_count,
       h.module,
       h.action,
       h.sql_profile,
       h.parsing_schema_name,
       h.fetches_total,
       h.executions_total,
       h.loads_total,
       h.invalidations_total,
       h.parse_calls_total,
       h.disk_reads_total,
       h.buffer_gets_total,
       h.rows_processed_total,
       h.cpu_time_total,
       h.elapsed_time_total,
       h.iowait_total,
       h.clwait_total,
       h.apwait_total,
       h.ccwait_total,
       h.direct_writes_total,
       h.plsexec_time_total,
       h.javexec_time_total
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.sql_id = :sql_id
   AND h.snap_id = s.snap_id
   AND h.dbid = s.dbid
   AND h.instance_number = s.instance_number
 ORDER BY
       s.end_interval_time,
       h.instance_number,
       h.plan_hash_value ) v;

PRO
PRO </table>
PRO

/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_CURSOR OUTLINE ALLSTATS LAST
 *
 * ------------------------- */
COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;

PRO <h2>Current Execution Plans (last execution)</h2>
PRO
PRO Captured while still in memory. Metrics below are for the last execution of each child cursor.<br>
PRO If STATISTICS_LEVEL was set to ALL at the time of the hard-parse then A-Rows column is populated.
PRO
PRO <pre>

SELECT RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, t.plan_table_output
  FROM gv$sql v,
       TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
 WHERE v.sql_id = :sql_id
   AND v.loaded_versions > 0;

PRO </pre>

/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_CURSOR OUTLINE ALLSTATS
 *
 * ------------------------- */
PRO <h2>Current Execution Plans (all executions)</h2>
PRO
PRO Captured while still in memory. Metrics below are an aggregate for all the execution of each child cursor.<br>
PRO If STATISTICS_LEVEL was set to ALL at the time of the hard-parse then A-Rows column is populated.
PRO
PRO <pre>

SELECT RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, t.plan_table_output
  FROM gv$sql v,
       TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS -PROJECTION', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
 WHERE v.sql_id = :sql_id
   AND v.loaded_versions > 0
   AND v.executions > 1;

PRO </pre>

/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_AWR OUTLINE
 *
 * ------------------------- */
PRO <h2>Historical Execution Plans</h2>
PRO
PRO Captured by AWR.
PRO
PRO <pre>

SELECT t.plan_table_output
  FROM (SELECT DISTINCT sql_id, plan_hash_value, dbid
          FROM dba_hist_sql_plan WHERE :license = 'Y' AND sql_id = :sql_id) v,
       TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED -PROJECTION')) t;

PRO </pre>

/* -------------------------
 *
 * footer
 *
 * ------------------------- */
PRO
PRO <hr size="3">
PRO <font class="f">^^mos_doc. SQLHC ^^doc_ver. ^^time_stamp2.</font>
PRO </body>
PRO </html>

SPO OFF;

-- nothing is updated in the db
ROLLBACK TO sqlhc;

SET TERM ON ECHO OFF FEED 6 VER ON SHOW OFF HEA ON LIN 80 NEWP 1 PAGES 14 SQLC MIX TAB ON TRIMS OFF TI OFF TIMI OFF ARRAY 15 NUMF "" SQLP SQL> SUF sql BLO . RECSEP WR APPI OFF SERVEROUT OFF;
PRO
PRO SQLTH file has been created:
PRO sqlhc_^^database_name_short._^^host_name_short._^^rdbms_version._^^sql_id._^^time_stamp..html.
PRO Review this file and act upon its content.
PRO
CL COL;
SET DEF ON;
UNDEFINE 1 2 mos_doc doc_ver doc_date doc_link bug_link input_sql_id input_license sql_id license;