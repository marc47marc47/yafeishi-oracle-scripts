#!/bin/sh

mkdir -p /oraclelog/ngact_dr01/adump 
mkdir -p /oraclelog/ngact_dr01/bdump 
mkdir -p /oraclelog/ngact_dr01/cdump 
mkdir -p /oraclelog/ngact_dr01/dpdump 
mkdir -p /oraclelog/ngact_dr01/pfile 
mkdir -p /oraclelog/ngact_dr01/udump  
mkdir -p /oraclelog/ngact_dr01/scripts 
mkdir -p $ORACLE_HOME/cfgtoollogs/dbca/ngact_dr01
ORACLE_SID=ngact_dr01; export ORACLE_SID
echo You should Add this entry in the /etc/oratab: 2:$ORACLE_HOME:Y


$ORACLE_HOME/bin/sqlplus /nolog  << EOF

host $ORACLE_HOME/bin/orapwd file=$ORACLE_HOME/dbs/orapwngactdr password=linkage force=y

connect sys/linkage as SYSDBA
set echo on
spool /oraclelog/ngact_dr01/scripts/CreateDB.log
startup nomount pfile="/oraclelog/ngact_dr01/scripts/initngact_dr01.ora";
CREATE DATABASE "ngactdr" 
MAXINSTANCES 8 
MAXLOGHISTORY 32 
MAXLOGFILES 16 
MAXLOGMEMBERS 3 
MAXDATAFILES 4096 
DATAFILE '/dev/rractvg5_4_sys' SIZE 4094M  AUTOEXTEND OFF 
EXTENT MANAGEMENT LOCAL 
SYSAUX DATAFILE '/dev/rractvg4_4_aux' SIZE 4094M AUTOEXTEND OFF 
SMALLFILE DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '/dev/rractvg6_8_tmp01' SIZE 8190M AUTOEXTEND OFF  
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 8M 
SMALLFILE UNDO TABLESPACE "UNDOTBS1" DATAFILE '/dev/rractvg1_8_udo01' SIZE 8190M  AUTOEXTEND OFF  
CHARACTER SET ZHS16GBK 
NATIONAL CHARACTER SET AL16UTF16 
LOGFILE GROUP 1 ('/dev/rractvg1_1_rd11','/dev/rractvg2_1_rd12') SIZE 1022M,
        GROUP 2 ('/dev/rractvg4_1_rd21','/dev/rractvg5_1_rd22') SIZE 1022M,
        GROUP 3 ('/dev/rractvg3_1_rd31','/dev/rractvg1_1_rd32') SIZE 1022M 
USER SYS IDENTIFIED BY linkage USER SYSTEM IDENTIFIED BY linkage;
spool off

connect sys/linkage as SYSDBA
set echo on
spool /oraclelog/ngact_dr01/scripts/CreateDBCatalog.log
@$ORACLE_HOME/rdbms/admin/catalog.sql;
@$ORACLE_HOME/rdbms/admin/catblock.sql;
@$ORACLE_HOME/rdbms/admin/catproc.sql;
@$ORACLE_HOME/rdbms/admin/catoctk.sql;
@$ORACLE_HOME/rdbms/admin/owminst.plb;
connect system/linkage
@$ORACLE_HOME/sqlplus/admin/pupbld.sql;
connect system/linkage
set echo on
spool /oraclelog/ngact_dr01/scripts/sqlPlusHelp.log
@$ORACLE_HOME/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off
spool off


connect sys/linkage as SYSDBA
set echo on'
spool /oraclelog/ngact_dr01/scripts/postDBCreation.log
connect sys/linkage as SYSDBA
set echo on
create spfile='/dev/rractvg3_05_spf' FROM pfile='/oraclelog/ngact_dr01/scripts/initngact_dr01.ora';
shutdown immediate;
connect sys/linkage as SYSDBA
startup ;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
spool off
exit;


