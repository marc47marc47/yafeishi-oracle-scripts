sqlplus ubak/ubakabc@10.238.160.86/ngcrm

alter table SST_CRM1016EXECI2 rename to SST_CRM1016EXECI2_dang;
alter table SST_CRM1016EXECI2_CBINDS rename to SST_CRM1016EXECI2_CBINDS_dang;
alter table SST_CRM1016EXECI2_CPLANS rename to SST_CRM1016EXECI2_CPLANS_dang;
nohup exp ubak/ubakabc@10.238.160.86/ngcrm file=SST_CRM1016EXECI2.dmp compress=n statistics=none tables=ubak.SST_CRM1016EXECI2 > exp-i2.out &
nohup imp ubak/UBAK@10.238.12.8/ngcrm file=SST_CRM1016EXECI2.dmp   statistics=none ignore=y fromuser=ubak touser=ubak > imp-i2.out &



tables=(
UBAK.SST_CRM1016EXECI1
UBAK.SST_CRM1016EXECI2
)
nohup impdp UBAK/UBAK directory=spa_dir network_link=to_oldcrm parfile=spa.par exclude=statistics TABLE_EXISTS_ACTION=replace > spa.out &

--------------------------------
set timing on
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_CRM1016_EXECi1', -
                  SQLSET_OWNER         => 'UBAK', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SST_CRM1016EXECI1', -
                  STAGING_SCHEMA_OWNER => 'UBAK');	

exec DBMS_SQLPA.drop_analysis_task('SPA_TASK_20141016i1');				  

VARIABLE SPA_TASK  VARCHAR2(64);
EXEC :SPA_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(  -
                             TASK_NAME    => 'SPA_TASK_20141016i1', -
                             DESCRIPTION  => 'SPA Analysis task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), -
                             SQLSET_NAME  => 'SQLSET_CRM1016_EXECi1', -
                             SQLSET_OWNER => 'UBAK');
							 
execute DBMS_SQLPA.SET_ANALYSIS_TASK_PARAMETER(task_name   => 'SPA_TASK_20141016i1', -
                                               parameter   => 'EXECUTE_FULLDML', -
                                               value       => 'TRUE');							 
							 
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_20141016i1', -
                EXECUTION_NAME => 'EXEC_10G_20141016i1', -
                EXECUTION_TYPE => 'CONVERT SQLSET', -
                EXECUTION_DESC => 'Convert 10g SQLSET for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));							 
				  
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK('SPA_TASK_20141016i1', 'TEST EXECUTE', 'EXEC_11G_20141016i1', NULL, 'Execute SQL in 11g for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
exit;
----------------------------------------

exec  DBMS_SQLTUNE.remap_stgtab_sqlset( -
    old_sqlset_name      =>'SQLSET_CRM1118_EXECi1',-
    old_sqlset_owner     =>'UBAK',-
    new_sqlset_name      =>'SQLSET_CRM1125_EXECi1',-     
    new_sqlset_owner     =>'UBAK',-    
    staging_table_name   =>'SST_CRM1118EXECI1',-
    staging_schema_owner =>'UBAK');
	
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_CRM1125_EXECi1', -
                  SQLSET_OWNER         => 'UBAK', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SST_CRM1118EXECI1', -
                  STAGING_SCHEMA_OWNER => 'UBAK');


exec DBMS_SQLPA.drop_analysis_task('SPA_TASK_20141016i1');
exec DBMS_SQLPA.drop_analysis_task('SPA_TASK_20141016i2');
alter system kill session '3718,181';


exec dbms_sqltune.drop_sqlset('SQLSET_CRM1016_EXECi2','UBAK');
exec dbms_sqltune.remove_sqlset_reference('SQLSET_CRM1016_EXECi2',7,'UBAK');
exec dbms_sqltune.remove_sqlset_reference('SQLSET_CRM1106_EXECi2',64,'UBAK');

select 'exec dbms_sqltune.remove_sqlset_reference('''||sqlset_name||''','||id||','''||owner||''');',a.*
from dba_sqlset_references@to_bjlcrmdb a

set timing on
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (-
                  SQLSET_NAME          => 'SQLSET_CRM1016_EXECi2', -
                  SQLSET_OWNER         => 'UBAK', -
                  REPLACE              => TRUE, -
                  STAGING_TABLE_NAME   => 'SST_CRM1016EXECI2', -
                  STAGING_SCHEMA_OWNER => 'UBAK');	
				  
				  
EXEC DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( -
                TASK_NAME      => 'SPA_TASK_20141016i2', -
                EXECUTION_NAME => 'EXEC_10G_20141016i2_T', -
                EXECUTION_TYPE => 'CONVERT SQLSET', -
                EXECUTION_DESC => 'Convert 10g SQLSET for SPA Task at : '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));			
exit;				
nohup sqlplus UBAK/UBAK @i2.sql > i2.out &				  
				  
				  
							 2