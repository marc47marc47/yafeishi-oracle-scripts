execute dbms_logmnr_d.build ('dict.ora','/oracle/dba/logminer',dbms_logmnr_d.store_in_flat_file);

execute dbms_logmnr.add_logfile(logfilename=>'/archivelog/ngcusdb1_341_887474776.arc',options=>dbms_logmnr.new);
execute dbms_logmnr.add_logfile(logfilename=>'/archivelog/ngcusdb1_442_887474776.arc',options=>dbms_logmnr.new);

execute dbms_logmnr.start_logmnr(dictfilename=>'/oracle/dba/logminer/dict.ora',options=>dbms_logmnr.ddl_dict_tracking);

select username,scn,timestamp,sql_redo 
from v$logmnr_contents  
where lower(sql_redo) like '%ct_sign_201509%';

select username,scn,timestamp,sql_redo 
from v$logmnr_contents  
where lower(sql_redo) like '%drop%';


execute dbms_logmnr.end_logmnr;

