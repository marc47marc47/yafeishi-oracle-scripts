1. 查询object的最后DDL时间：
select a.OWNER,a.OBJECT_NAME,a.LAST_DDL_TIME,a.OBJECT_TYPE 
from dba_objects a
where a.OWNER='YAFEISHI'
 and  a.OBJECT_NAME='TEST';

2.备份 DDL 语句：
$ORACLE_HOME/bin/sqlplus /nolog  << EOF
conn UCR_PARAM/Q3E0V9J7
set echo off;
set heading off;
set feedback off;
set verify off;
set trimspool on;
set long 90000000;
col ddl_sql for a999;
set pagesize 999;
set linesize 999;

spool /oraclelog/ch/ucr_param_procedures.sql
SELECT DBMS_METADATA.GET_DDL('PROCEDURE',object_name) FROM dba_procedures
where owner='UCR_PARAM' and object_type = 'PROCEDURE';
spool off

spool /oraclelog/ch/ucr_param_tables.sql
SELECT DBMS_METADATA.GET_DDL('TABLE',table_name) FROM dba_tables
where owner='UCR_PARAM';
spool off

spool /oraclelog/ch/ucr_param_views.sql
SELECT DBMS_METADATA.GET_DDL('VIEW',view_name) FROM dba_views
where owner='UCR_PARAM';
spool off

spool /oraclelog/ch/ucr_param_synonyms.sql
SELECT DBMS_METADATA.GET_DDL('SYNONYM',synonym_name) FROM dba_synonyms
where owner='UCR_PARAM';
spool off
exit;
nohup sh 1.sh  > 1.log 2>&1 &




 