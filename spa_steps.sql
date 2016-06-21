--------------------------------源库执行--------------------------------------
-- create sts
EXEC DBMS_SQLTUNE.CREATE_SQLSET (SQLSET_NAME  => 'SQLSET_20140930',DESCRIPTION  => 'SQL Set Create at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'),SQLSET_OWNER => 'DANGHB');

-----------------抓取sql
-- 从awr中去取
DECLARE
  SQLSET_CUR DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
  OPEN SQLSET_CUR FOR
    SELECT VALUE(P) FROM TABLE(
           DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY( 39535, 40271,
                        'PARSING_SCHEMA_NAME   IN (''UOP_CRM1'' ,''UOP_CEN1'')',
                        NULL, NULL, NULL, NULL, 1, NULL, 'ALL')) P;

  DBMS_SQLTUNE.LOAD_SQLSET(
               SQLSET_NAME => 'SQLSET_20140930',
               SQLSET_OWNER => 'DANGHB',
               POPULATE_CURSOR => SQLSET_CUR,
               LOAD_OPTION => 'MERGE',
               UPDATE_OPTION => 'ACCUMULATE');
END;
/

or

-- 从 cursor cache 中取
DECLARE
  SQLSET_CUR DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
  OPEN SQLSET_CUR FOR
    SELECT VALUE(P) FROM TABLE(
           DBMS_SQLTUNE.SELECT_CURSOR_CACHE( 'PARSING_SCHEMA_NAME   IN (''UOP_CRM1'' ,''UOP_CEN1'')',
                        NULL, NULL, NULL, NULL, 1, NULL, 'ALL')) P;
  DBMS_SQLTUNE.LOAD_SQLSET(
               SQLSET_NAME => 'SQLSET_20140930',
               SQLSET_OWNER => 'DANGHB',
               POPULATE_CURSOR => SQLSET_CUR,
               LOAD_OPTION => 'MERGE',
               UPDATE_OPTION => 'REPLACE');
  CLOSE SQLSET_CUR;
END;
/

or

-- 从 cursor cache 抓  持续12分钟，间隔5秒钟
dbms_sqltune.capture_cursor_cache_sqlset(
sqlset_name => 'MAC_SPA' ,
time_limit => 12*60,
repeat_interval => 5);
end ;
/

basic_filter=> q'# module like 'DWH_TEST%' and sql_text not like '%applicat%' and parsing_schema_name in ('APPS') #'

basic_filter   => 'sql_text LIKE ''%my_objects%'' and parsing_schema_name = ''SPA_TEST_USER''',

==>过滤条件使用

--查询抓到的SQL数量：
select count(*) from dba_sqlset_statements where sqlset_name = 'SQLSET_20140930';

--打包STS：
EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLSET ('SQLSET_TAB_20140930', 'DANGHB', 'SYSAUX');
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLSET ( 
                  SQLSET_NAME          => 'SQLSET_20140930',
                  SQLSET_OWNER         => 'DANGHB',
                  STAGING_TABLE_NAME   => 'SQLSET_TAB_20140930',
                  STAGING_SCHEMA_OWNER => 'DANGHB');
				  
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLSET ( SQLSET_NAME => 'SQLSET_20140930',SQLSET_OWNER => 'DANGHB',STAGING_TABLE_NAME => 'SQLSET_TAB_20140930', STAGING_SCHEMA_OWNER => 'DANGHB');
          				  
				  
-- 导出STS表 并传输到目标库
exp
ftp

------------------------------------目标库执行-----------------------------------
-- 导入STS表
imp


---解包STS表
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_20140930', -
                  SQLSET_OWNER         => 'DANGHB', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SQLSET_TAB_20140930', -
                  STAGING_SCHEMA_OWNER => 'DANGHB');	

-- 创建SPA分析任务				 
VARIABLE SPA_TASK  VARCHAR2(64);
EXEC :SPA_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(  -
                             TASK_NAME    => 'SPA_TASK_20140930', -
                             DESCRIPTION  => 'SPA Analysis task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), -
                             SQLSET_NAME  => 'SQLSET_20140930', -
                             SQLSET_OWNER => 'DANGHB');
							 
-- 从STS直接转化得到SQL在源库中的执行信息							 
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_20140930', -
                EXECUTION_NAME => 'EXEC_10G_20140930', -
                EXECUTION_TYPE => 'CONVERT SQLSET', -
                EXECUTION_DESC => 'Convert 10g SQLSET for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));							 
				
				
-- 在11g中实际执行SQL语句  --时间较长，建议后台运行
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK('SPA_TASK_20140930', 'TEST EXECUTE', 'EXEC_11G_20140930', NULL, 'Execute SQL in 11g for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));

--- 检查SPA运行情况：
V$ADVISOR_PROGRESS

---执行性能对比分析任务
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_20140930', -
                EXECUTION_TYPE => 'compare performance', -
                EXECUTION_NAME => 'COMPARE_20140930_ET', -
                EXECUTION_PARAMS => DBMS_ADVISOR.ARGLIST( 
                                                 'COMPARISON_METRIC', 'ELAPSED_TIME', -
                                                 'EXECUTION_NAME1','EXEC_10G_20140930', -
                                                 'EXECUTION_NAME2','EXEC_11G_20140930'), -
                EXECUTION_DESC => 'Compare SQLs between 10g and 11g at :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));				
				
-- 获取SPA测试报告
SET LINES 1111 PAGES 50000 LONG 1999999999 TRIM ON TRIMS ON SERVEROUTPUT ON SIZE UNLIMITED
SPOOL elapsed_all.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20140930',
                 'HTML',
                 'ALL',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20140930_ET')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF
SPOOL elapsed_errors.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20140930',
                 'HTML',
                 'ERRORS',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20140930_ET')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF
SPOOL elapsed_unsupported.html
SELECT XMLTYPE(DBMS_SQLPA.REPORT_ANALYSIS_TASK(
                 'SPA_TASK_20140930',
                 'HTML',
                 'UNSUPPORTED',
                 'ALL',
                  NULL,
                  100,
                 'COMPARE_20140930_ET')).GETCLOBVAL(0,0) FROM DUAL;
SPO OFF		

	