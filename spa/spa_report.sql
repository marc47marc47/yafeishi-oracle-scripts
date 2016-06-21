EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_20141016i1', -
                EXECUTION_TYPE => 'compare performance', -
                EXECUTION_NAME => 'COMPARE_20141016i1_ET', -
                EXECUTION_PARAMS => DBMS_ADVISOR.ARGLIST( -
                                                 'COMPARISON_METRIC', 'ELAPSED_TIME', -
                                                 'EXECUTION_NAME1','EXEC_10G_20141016i1', -
                                                 'EXECUTION_NAME2','EXEC_11G_20141016i1'), -
                EXECUTION_DESC => 'Compare SQLs between 10g and 11g at :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));				

Elapsed: 00:02:55.50

EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_20141016i2', -
                EXECUTION_TYPE => 'compare performance', -
                EXECUTION_NAME => 'COMPARE_20141016i2', -
                EXECUTION_PARAMS => DBMS_ADVISOR.ARGLIST( -
                                                 'COMPARISON_METRIC', 'ELAPSED_TIME', -
                                                 'EXECUTION_NAME1','EXEC_10G_20141016i2', -
                                                 'EXECUTION_NAME2','EXEC_11G_20141016i2'), -
                EXECUTION_DESC => 'Compare SQLs between 10g and 11g at :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));				

Elapsed: 00:02:05.27

sqlplus UBAK/UBAK@10.238.12.8/ngcrm
sqlplus UBAK/UBAK@10.238.12.6/ngcrm
SET LINES 32767 PAGES 50000 LONG 1999999999 TRIM ON TRIMS ON SERVEROUTPUT ON SIZE UNLIMITED
SPOOL spai2_elapsed_all.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20141016i2',
                 'HTML',
                 'ALL',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20141016i2')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF
SPOOL spai2_elapsed_errors.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20141016i2',
                 'HTML',
                 'ERRORS',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20141016i2')).GETCLOBVAL(0,0) FROM DUAL;  --Elapsed: 00:03:16.27
SPO OFF
SPOOL spai2_elapsed_unsupported.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20141016i2',
                 'HTML',
                 'UNSUPPORTED',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20141016i2')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF	

SPOOL spai2_elapsed_unchanged.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20141016i2',
                 'HTML',
                 'UNCHANGED',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20141016i2')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF	
				