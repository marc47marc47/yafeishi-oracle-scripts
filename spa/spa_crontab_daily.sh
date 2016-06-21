
v_sts="SQLSET_CRM"`date '+%m%d'`"_EXECi1"
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/ubakabc@10.238.160.86/ngcrm
set timing on;
exec dbms_sqltune.drop_sqlset('$v_sts','UBAK');
EXEC DBMS_SQLTUNE.CREATE_SQLSET (SQLSET_NAME=> '$v_sts',DESCRIPTION  => 'SQL Set Create at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'),SQLSET_OWNER => 'UBAK');
exec dbms_sqltune.capture_cursor_cache_sqlset(sqlset_name => '$v_sts',time_limit => 23*60*60,repeat_interval => 60*5,basic_filter=>q'# module not like 'PL%'  and module not like 'pl%' and parsing_schema_name like 'U%' #');
exit;



v_sts="SQLSET_CRM"`date '+%m%d'`"_EXECi2"
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/ubakabc@10.238.160.86/ngcrm
set timing on;
exec dbms_sqltune.drop_sqlset('$v_sts','UBAK');
EXEC DBMS_SQLTUNE.CREATE_SQLSET (SQLSET_NAME=> '$v_sts',DESCRIPTION  => 'SQL Set Create at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'),SQLSET_OWNER => 'UBAK');
exec dbms_sqltune.capture_cursor_cache_sqlset(sqlset_name => '$v_sts',time_limit => 23*60*60,repeat_interval => 60*5,basic_filter=>q'# module not like 'PL%'  and module not like 'pl%' and parsing_schema_name like 'U%' #');
exit;

0 8 * * * sh /oracle/danghb/spa/spa_execi1_8.sh > /oracle/danghb/spa/spa_execi1.out
0 8 * * * sh /oracle/danghb/spa/spa_execi2_8.sh > /oracle/danghb/spa/spa_execi2.out

