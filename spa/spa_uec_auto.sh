#!/bin/bash  
. /oracle/.profile
v_sts="SQLSET_UEC"`date '+%m%d'`"_EXEC"
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/ubakabc@10.238.160.86/ngcrm
set timing on;
exec dbms_sqltune.drop_sqlset('$v_sts','UBAK');
EXEC DBMS_SQLTUNE.CREATE_SQLSET(SQLSET_NAME=> '$v_sts',DESCRIPTION  => 'SQL Set Create at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'),SQLSET_OWNER => 'UBAK');
exec dbms_sqltune.capture_cursor_cache_sqlset(sqlset_name => '$v_sts',-
                                              time_limit => 23*60*60,-
                                              repeat_interval => 60*2,-
                                              basic_filter=>q'# module not like 'PL%'  and module not like 'pl%' and parsing_schema_name like '%UEC%' #');
exit;
EOF

#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/ubakabc@10.238.160.86/ngcrm
set timing on;
EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLSET('SST_UEC'||to_char(to_date(sysdate-1),'MMDD')||'EXEC','UBAK','TBS_CRM_DEF');
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLSET( SQLSET_NAME => 'SQLSET_UEC'||to_char(to_date(sysdate-1),'MMDD')||'_EXEC',-
                                      SQLSET_OWNER => 'UBAK',-
                                      STAGING_TABLE_NAME => 'SST_UEC'||to_char(to_date(sysdate-1),'MMDD')||'EXEC',-
                                      STAGING_SCHEMA_OWNER => 'UBAK');
                                                                          
                                                                          
exit;
EOF

#!/bin/bash
. /oracle/.profile
yestday=$(perl -e "use POSIX qw(strftime); print strftime '%m%d' , localtime( time()-3600*24*1) ")
tname1="SST_UEC"$yestday"EXEC"
/oracle/app/product/10.2/bin/exp ubak/ubakabc@10.238.160.86/ngcrm file=/arch_ngcrm_i2/danghb/spadmp/$tname1.dmp compress=n statistic
s=none tables=ubak.$tname1 
wait
/oracle/app/product/10.2/bin/imp ubak/UBAK@ngech file=/arch_ngcrm_i2/danghb/spadmp/$tname1.dmp   statistics=none ignore=
y fromuser=ubak touser=ubak 

0 8 * * * sh /oracle/danghb/spa/uec/spa_uec.sh  > /oracle/danghb/spa/uec/spa_uec.out
03 8 * * * sh /oracle/danghb/spa/uec/spa_uec_pack.sh  > /oracle/danghb/spa/uec/spa_uec_pack.out
20 8 * * * sh /oracle/danghb/spa/uec/expimp_uec.sh  > /oracle/danghb/spa/uec/expimp_uec.out


#####################  11g  node #####################
#!/bin/sh
. /home/oracle/.bash_profile
/oracle/app/oracle/product/11.2.0/db/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@ngech 
set timing on
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_UEC'||to_char(to_date(sysdate-1),'MMDD')||'_EXEC', -
                  SQLSET_OWNER         => 'UBAK', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SST_UEC'||to_char(to_date(sysdate-1),'MMDD')||'EXEC', -
                  STAGING_SCHEMA_OWNER => 'UBAK');	

exec DBMS_SQLPA.drop_analysis_task('SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'UEC');				  

VARIABLE SPA_TASK  VARCHAR2(64);
EXEC :SPA_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(  -
                             TASK_NAME    => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'UEC', -
                             DESCRIPTION  => 'SPA Analysis task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), -
                             SQLSET_NAME  => 'SQLSET_UEC'||to_char(to_date(sysdate-1),'MMDD')||'_EXEC', -
                             SQLSET_OWNER => 'UBAK');
							 
							 
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'UEC', -
                EXECUTION_NAME => 'EXEC_10G_2014'||to_char(to_date(sysdate-1),'MMDD')||'UEC', -
                EXECUTION_TYPE => 'CONVERT SQLSET', -
                EXECUTION_DESC => 'Convert 10g SQLSET for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));							 
				  
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK('SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'UEC', 'TEST EXECUTE', 'EXEC_11G_2014'||to_char(to_date(sysdate-1),'MMDD')||'UEC', NULL, 'Execute SQL in 11g for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
exit;
EOF

20 9 * * * sh /oracle/danghb/spa/spa_11g_uec.sh  > /oracle/danghb/spa/spa_11g_uec.out


########################   report @ 10G #######################
##  report_uec.sh
#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@ngech
set timing on
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_2014$1UEC', -
                EXECUTION_TYPE => 'compare performance', -
                EXECUTION_NAME => 'COMPARE_2014$1UEC_$3', -
                EXECUTION_PARAMS => DBMS_ADVISOR.ARGLIST( -
                                                 'COMPARISON_METRIC', '$2', -
                                                 'EXECUTION_NAME1','EXEC_10G_2014$1UEC', -
                                                 'EXECUTION_NAME2','EXEC_11G_2014$1UEC'), -
                EXECUTION_DESC => 'Compare SQLs between 10g and 11g at :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));				
exit;
EOF

###  report_uec.sh

#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@ngech
set timing on
SET LINES 32767 PAGES 50000 LONG 1999999999 TRIM ON TRIMS ON SERVEROUTPUT ON SIZE UNLIMITED
SPOOL spai1_$1_$3_$2.html;
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_2014$1UEC',
                 'HTML',
                 '$2',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_2014$1UEC_$3')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF
exit;
EOF



vi gene_report_uec.sh 
sh gene_rep.sh $1 ALL $2 
sh gene_rep.sh $1 ERRORS $2 
sh gene_rep.sh $1 UNSUPPORTED $2 

sh gene_report_uec.sh 1109 time 
sh gene_report_uec.sh 1109 cpu 
sh gene_report_uec.sh 1109 bget

vi rep_uec_all.sh
sh report_uec.sh $1 ELAPSED_TIME time
sh report_uec.sh $1 CPU_TIME cpu
sh report_uec.sh $1 BUFFER_GET bget

sh rep_uec_all.sh 1109
