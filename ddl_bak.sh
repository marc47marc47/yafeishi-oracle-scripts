#
# usage:  sh ddl_bak.sh user passwd /oracle/ddlsql
#                        $1    $2      $3
$ORACLE_HOME/bin/sqlplus -silent /nolog <<EOF
conn $1/$2
set echo off;
set heading off;
set feedback off;
set verify off;
set trimspool on;
set long 90000000;
col ddl_sql for a999;
set pagesize 0;
set linesize 20000;
set serveroutput off;
set longchunksize 20000;

spool $3/$1_procedures.sql
SELECT DBMS_METADATA.GET_DDL('PROCEDURE',object_name)||'/' FROM dba_procedures
where owner= upper('$1') and object_type = 'PROCEDURE';
spool off

spool  $3/$1_types.sql
SELECT DBMS_METADATA.GET_DDL('TYPE',object_name)||'/' FROM dba_procedures
where owner= upper('$1') and object_type = 'TYPE'; 
spool off

spool  $3/$1_functions.sql
SELECT DBMS_METADATA.GET_DDL('FUNCTION',object_name) ||'/' FROM dba_procedures
where owner= upper('$1') and object_type = 'FUNCTION';
spool off

spool  $3/$1_triggeres.sql
SELECT DBMS_METADATA.GET_DDL('TRIGGER',object_name)||'/' FROM dba_procedures
where owner= upper('$1') and object_type = 'TRIGGER';
spool off

spool $3/$1_packages.sql
SELECT DBMS_METADATA.GET_DDL('PACKAGE',object_name)||'/' FROM dba_procedures
where owner= upper('$1') and object_type = 'PACKAGE';
spool off

spool  $3/$1_tables.sql
SELECT DBMS_METADATA.GET_DDL('TABLE',table_name)||'; ' FROM dba_tables
where owner= upper('$1') ;
spool off

spool  $3/$1_indexes.sql
SELECT DBMS_METADATA.GET_DDL('INDEX',INDEX_NAME)||' parallel 20 ;' FROM dba_INDEXES
where owner= upper('$1') ;
spool off

spool  $3/$1_views.sql
SELECT DBMS_METADATA.GET_DDL('VIEW',view_name)||'; ' FROM dba_views
where owner= upper('$1') ;
spool off

spool  $3/$1_synonyms.sql
SELECT DBMS_METADATA.GET_DDL('SYNONYM',synonym_name)||'; ' FROM dba_synonyms
where owner= upper('$1') ;
spool off
exit;

