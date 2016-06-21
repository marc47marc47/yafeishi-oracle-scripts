----单节点
shutdown immediate;
sqlplus / as sysdba
start mount;
alter database archivelog;
alter database open;
archive log list;
-----RAC
srvctl stop database -d ngpfdb -o immediate 
srvctl start instance -d ngpfdb -i ngpfdb1 -o mount
sqlplus / as sysdba
alter database archivelog; --alter database noarchivelog;
archive log list;
exit;
srvctl stop instance -d ngpfdb -i ngpfdb1 -o immediate 
srvctl start database -d ngpfdb
sqlplus / as sysdba
archive log list;

-------------------------------------
. ~/.profile
srvctl stop database -d $1 -o immediate 
srvctl start instance -d $1 -i $2 -o mount
sqlplus / as sysdba << EOF
alter database noarchivelog;
archive log list;
exit;
EOF
srvctl stop instance -d $1 -i $2 -o immediate 
srvctl start database -d $1
sqlplus / as sysdba << EOF
archive log list;
exit;
EOF
------------------------------

log_archive_format                   string      ngcrm%S_%T_%R.arc
log_archive_dest_1                   string      location=/arch_ngcrm_i2

alter system set log_archive_format='ngcrmdb1%t_%s_%r.arc' scope=both sid='*';
alter system set log_archive_dest_1='location=/archivelog' scope=both sid='*';


sqlplus / as sysdba
startup mount
rman target /
crosscheck archivelog all;
delete expired archivelog all;
DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7'; 

DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-1'; 

delete archivelog all;

list archivelog all;
sqlplus / as sysdba
alter database open




#!/bin/bash
. /home/oracle/.bash_profile
export ORACLE_HOME=/oracle/app/oracle/product/11.2.0/dbhome_1
##export ORACLE_SID=dcp_1
$ORACLE_HOME/bin/rman target sys/welcome123@zsmart <<sex
crosscheck archivelog all;
delete force archivelog all ;
YES
exit;
sex