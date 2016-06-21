----------------------------------pack sst-------------------------------------------
#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/ubakabc@10.238.160.84/ngcrm
set timing on;
EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLSET('SST_CRM'||to_char(to_date(sysdate-1),'MMDD')||'EXECI1','UBAK','TBS_CRM_DEF');
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLSET( SQLSET_NAME => 'SQLSET_CRM'||to_char(to_date(sysdate-1),'MMDD')||'_EXECi1',-
                                      SQLSET_OWNER => 'UBAK',-
									  STAGING_TABLE_NAME => 'SST_CRM'||to_char(to_date(sysdate-1),'MMDD')||'EXECI1',-
									  STAGING_SCHEMA_OWNER => 'UBAK');
exit;
EOF

#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/ubakabc@10.238.160.84/ngcrm
set timing on;
EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLSET('SST_CRM'||to_char(to_date(sysdate-1),'MMDD')||'EXECI2','UBAK','TBS_CRM_DEF');
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLSET( SQLSET_NAME => 'SQLSET_CRM'||to_char(to_date(sysdate-1),'MMDD')||'_EXECi2',-
                                      SQLSET_OWNER => 'UBAK',-
									  STAGING_TABLE_NAME => 'SST_CRM'||to_char(to_date(sysdate-1),'MMDD')||'EXECI2',-
									  STAGING_SCHEMA_OWNER => 'UBAK');
									  
									  
exit;
EOF

--------------------------------exp imp sst -------------------------------------
#!/bin/bash
. /oracle/.profile
yestday=$(perl -e "use POSIX qw(strftime); print strftime '%m%d' , localtime( time()-3600*24*1) ")
tname1="SST_CRM"$yestday"EXECI1"
tname2="SST_CRM"$yestday"EXECI2"
nohup /oracle/app/product/10.2/bin/exp ubak/ubakabc@10.238.160.84/ngcrm file=/arch_ngcrm_i2/danghb/spadmp/$tname1.dmp compress=n statistics=none tables=ubak.$tname1 > /oracle/danghb/spa/auto/exp-i1.out &
nohup /oracle/app/product/10.2/bin/exp ubak/ubakabc@10.238.160.86/ngcrm file=/arch_ngcrm_i2/danghb/spadmp/$tname2.dmp compress=n statistics=none tables=ubak.$tname2 > /oracle/danghb/spa/auto/exp-i2.out &

#!/bin/bash
. /oracle/.profile
yestday=$(perl -e "use POSIX qw(strftime); print strftime '%m%d' , localtime( time()-3600*24*1) ")
tname1="SST_CRM"$yestday"EXECI1"
tname2="SST_CRM"$yestday"EXECI2"
nohup /oracle/app/product/10.2/bin/imp ubak/UBAK@10.238.12.6/ngcrm file=/arch_ngcrm_i2/danghb/spadmp/$tname1.dmp   statistics=none ignore=y fromuser=ubak touser=ubak > /oracle/danghb/spa/auto/imp-i1.out &
nohup /oracle/app/product/10.2/bin/imp ubak/UBAK@10.238.12.8/ngcrm file=/arch_ngcrm_i2/danghb/spadmp/$tname2.dmp   statistics=none ignore=y fromuser=ubak touser=ubak > /oracle/danghb/spa/auto/imp-i2.out &

-----------------------------11g node1 exec sql------------------------------
#!/bin/sh
. /home/oracle/.profile
/oracle/app/oracle/product/11.2.0/db/bin/sqlplus /nolog <<EOF
conn ubak/UBAK 
set timing on
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_CRM'||to_char(to_date(sysdate-1),'MMDD')||'_EXECi1', -
                  SQLSET_OWNER         => 'UBAK', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SST_CRM'||to_char(to_date(sysdate-1),'MMDD')||'EXECI1', -
                  STAGING_SCHEMA_OWNER => 'UBAK');	

exec DBMS_SQLPA.drop_analysis_task('SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1');				  

VARIABLE SPA_TASK  VARCHAR2(64);
EXEC :SPA_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(  -
                             TASK_NAME    => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1', -
                             DESCRIPTION  => 'SPA Analysis task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), -
                             SQLSET_NAME  => 'SQLSET_CRM'||to_char(to_date(sysdate-1),'MMDD')||'_EXECi1', -
                             SQLSET_OWNER => 'UBAK');
							 
execute DBMS_SQLPA.SET_ANALYSIS_TASK_PARAMETER(task_name   => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1', -
                                               parameter   => 'EXECUTE_FULLDML', -
                                               value       => 'TRUE');							 
							 
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1', -
                EXECUTION_NAME => 'EXEC_10G_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1', -
                EXECUTION_TYPE => 'CONVERT SQLSET', -
                EXECUTION_DESC => 'Convert 10g SQLSET for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));							 
				  
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK('SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1', 'TEST EXECUTE', 'EXEC_11G_2014'||to_char(to_date(sysdate-1),'MMDD')||'i1', NULL, 'Execute SQL in 11g for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
exit;
EOF

-----------------------------11g node2 exec sql------------------------------
#!/bin/sh
. /home/oracle/.profile
/oracle/app/oracle/product/11.2.0/db/bin/sqlplus /nolog <<EOF
conn ubak/UBAK 
set timing on
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_CRM'||to_char(to_date(sysdate-1),'MMDD')||'_EXECi2', -
                  SQLSET_OWNER         => 'UBAK', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SST_CRM'||to_char(to_date(sysdate-1),'MMDD')||'EXECI2', -
                  STAGING_SCHEMA_OWNER => 'UBAK');	

exec DBMS_SQLPA.drop_analysis_task('SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2');				  

VARIABLE SPA_TASK  VARCHAR2(64);
EXEC :SPA_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(  -
                             TASK_NAME    => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2', -
                             DESCRIPTION  => 'SPA Analysis task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), -
                             SQLSET_NAME  => 'SQLSET_CRM'||to_char(to_date(sysdate-1),'MMDD')||'_EXECi2', -
                             SQLSET_OWNER => 'UBAK');
							 
execute DBMS_SQLPA.SET_ANALYSIS_TASK_PARAMETER(task_name   => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2', -
                                               parameter   => 'EXECUTE_FULLDML', -
                                               value       => 'TRUE');							 
							 
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2', -
                EXECUTION_NAME => 'EXEC_10G_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2', -
                EXECUTION_TYPE => 'CONVERT SQLSET', -
                EXECUTION_DESC => 'Convert 10g SQLSET for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));							 
				  
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK('SPA_TASK_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2', 'TEST EXECUTE', 'EXEC_11G_2014'||to_char(to_date(sysdate-1),'MMDD')||'i2', NULL, 'Execute SQL in 11g for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
exit;
EOF




-------------------------crontab -e on rcrmdb------------------------
03 8 * * * sh /oracle/danghb/spa/auto/pack1.sh > /oracle/danghb/spa/auto/pack1.out
03 8 * * * sh /oracle/danghb/spa/auto/pack2.sh > /oracle/danghb/spa/auto/pack2.out
20 8 * * * sh /oracle/danghb/spa/auto/exp_sst.sh >/dev/null 2>&1
0  9 * * * sh /oracle/danghb/spa/auto/imp_sst.sh >/dev/null 2>&1


-------------------------crontab -e on bjlcrmdb1------------------------
30 9 * * * sh /home/oracle/danghb/spa/auto/exec_spa_1.sh > /home/oracle/danghb/spa/auto/spa_execi1.out


-------------------------crontab -e on bjlcrmdb2------------------------
30 9 * * * sh /home/oracle/danghb/spa/auto/exec_spa_2.sh > /home/oracle/danghb/spa/auto/spa_execi2.out

 
----------------------- report -------------------------------------------
#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@10.238.12.6/ngcrm
set timing on
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_2014$1i1', -
                EXECUTION_TYPE => 'compare performance', -
                EXECUTION_NAME => 'COMPARE_2014$1i1_$3', -
                EXECUTION_PARAMS => DBMS_ADVISOR.ARGLIST( -
                                                 'COMPARISON_METRIC', '$2', -
                                                 'EXECUTION_NAME1','EXEC_10G_2014$1i1', -
                                                 'EXECUTION_NAME2','EXEC_11G_2014$1i1'), -
                EXECUTION_DESC => 'Compare SQLs between 10g and 11g at :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));				
exit;
EOF

sh report_1.sh 1101 ELAPSED_TIME time
				
#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@10.238.12.8/ngcrm
set timing on
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_2014$1i2', -
                EXECUTION_TYPE => 'compare performance', -
                EXECUTION_NAME => 'COMPARE_2014$1i2_$3', -
                EXECUTION_PARAMS => DBMS_ADVISOR.ARGLIST( -
                                                 'COMPARISON_METRIC', '$2', -
                                                 'EXECUTION_NAME1','EXEC_10G_2014$1i2', -
                                                 'EXECUTION_NAME2','EXEC_11G_2014$1i2'), -
                EXECUTION_DESC => 'Compare SQLs between 10g and 11g at :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));				
exit;
EOF

sh report_2.sh 1101 ELAPSED_TIME time
 
 
#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@10.238.12.6/ngcrm
set timing on
SET LINES 32767 PAGES 50000 LONG 1999999999 TRIM ON TRIMS ON SERVEROUTPUT ON SIZE UNLIMITED
SPOOL spai1_$1_$3_$2.html;
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_2014$1i1',
                 'HTML',
                 '$2',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_2014$1i1_$3')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF
exit;
EOF 


sh gene_rep_1.sh 1101 ALL time  
sh gene_rep_1.sh 1101 ERRORS time  



#!/bin/bash
. /oracle/.profile
/oracle/app/product/10.2/bin/sqlplus /nolog <<EOF
conn ubak/UBAK@10.238.12.8/ngcrm
set timing on
SET LINES 32767 PAGES 50000 LONG 1999999999 TRIM ON TRIMS ON SERVEROUTPUT ON SIZE UNLIMITED
SPOOL spai2_$1_$3_$2.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_2014$1i2',
                 'HTML',
                 '$2',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_2014$1i2_$3')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF
exit;
EOF


sh gene_rep_2.sh 1028 ALL time  
sh gene_rep_2.sh 1028 ERRORS time  


sh report_2.sh 1101 ALL time
