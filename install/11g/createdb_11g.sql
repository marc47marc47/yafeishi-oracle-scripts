#!/bin/sh

OLD_UMASK=`umask`
umask 0027
mkdir -p /cj2data01/j2eeactt
mkdir -p /cj2data02/j2eeactt
mkdir -p /cj2data03/j2eeactt
mkdir -p /cj2data04/j2eeactt

mkdir -p $ORACLE_HOME/dbs
mkdir -p /oracle/admin/j2eeactt/adump
mkdir -p /oracle/admin/j2eeactt/dpdump
mkdir -p /oracle/admin/j2eeactt/pfile
mkdir -p /oracle/cfgtoollogs/dbca/j2eeactt
umask ${OLD_UMASK}
ORACLE_SID=j2eeactt; export ORACLE_SID
PATH=$ORACLE_HOME/bin:$PATH; export PATH
echo You should Add this entry in the /etc/oratab: j2eeactt:$ORACLE_HOME:Y


$ORACLE_HOME/bin/sqlplus /nolog  << EOF

host $ORACLE_HOME/bin/orapwd file=$ORACLE_HOME/dbs/orapwj2eeactt password=linkage force=y


SET VERIFY OFF
connect "SYS"/"linkage" as SYSDBA
set echo on
spool /oracle/admin/j2eeactt/scripts/CreateDB.log append
startup nomount pfile="/oracle/admin/j2eeactt/scripts/init.ora";
CREATE DATABASE "j2eeactt"
MAXINSTANCES 8
MAXLOGHISTORY 32
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 4096
DATAFILE '/cj2data01/j2eeactt/system01.dbf' SIZE 4G REUSE AUTOEXTEND OFF
EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '/cj2data02/j2eeactt/sysaux01.dbf' SIZE 8G REUSE AUTOEXTEND OFF
SMALLFILE DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '/cj2data01/j2eeactt/temp01.dbf' SIZE 16G,
'/cj2data02/j2eeactt/temp02.dbf' SIZE 16G,
'/cj2data03/j2eeactt/temp03.dbf' SIZE 16G
AUTOEXTEND OFF
SMALLFILE UNDO TABLESPACE "UNDOTBS1" DATAFILE '/cj2data01/j2eeactt/undotbs01.dbf' SIZE 16G,
'/cj2data02/j2eeactt/undotbs02.dbf' SIZE 16G,
'/cj2data03/j2eeactt/undotbs03.dbf' SIZE 16G
AUTOEXTEND OFF
CHARACTER SET ZHS16GBK
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1 ('/cj2data01/j2eeactt/redo11.log','/cj2data01/j2eeactt/redo21.log') SIZE 2G,
        GROUP 2 ('/cj2data02/j2eeactt/redo12.log','/cj2data02/j2eeactt/redo22.log') SIZE 2G,
        GROUP 3 ('/cj2data03/j2eeactt/redo13.log','/cj2data03/j2eeactt/redo23.log') SIZE 2G
USER SYS IDENTIFIED BY "linakge" USER SYSTEM IDENTIFIED BY "linkage";
spool off

SET VERIFY OFF
connect "SYS"/"linkage" as SYSDBA
set echo on
spool /oracle/admin/j2eeactt/scripts/CreateDBCatalog.log append
@$ORACLE_HOME/rdbms/admin/catalog.sql;
@$ORACLE_HOME/rdbms/admin/catblock.sql;
@$ORACLE_HOME/rdbms/admin/catproc.sql;
@$ORACLE_HOME/rdbms/admin/catoctk.sql;
@$ORACLE_HOME/rdbms/admin/owminst.plb;
connect "SYSTEM"/"linkage"
@$ORACLE_HOME/sqlplus/admin/pupbld.sql;
connect "SYSTEM"/"linkage"
set echo on
spool /oracle/admin/j2eeactt/scripts/sqlPlusHelp.log append
@$ORACLE_HOME/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off
spool off



SET VERIFY OFF
connect "SYS"/"linakge" as SYSDBA
set echo on
spool /oracle/admin/j2eeactt/scripts/other.log append
@$ORACLE_HOME/javavm/install/initjvm.sql;
@$ORACLE_HOME/xdk/admin/initxml.sql;
@$ORACLE_HOME/xdk/admin/xmlja.sql;
@$ORACLE_HOME/rdbms/admin/catjava.sql;
@$ORACLE_HOME/rdbms/admin/catexf.sql;


@$ORACLE_HOME/ctx/admin/catctx change_on_install SYSAUX TEMP NOLOCK;
connect "CTXSYS"/"change_on_install"
@$ORACLE_HOME/ctx/admin/defaults/dr0defin.sql "AMERICAN";

connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/rdbms/admin/catqm.sql change_on_install SYSAUX TEMP;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/rdbms/admin/catxdbj.sql;
@$ORACLE_HOME/rdbms/admin/catrul.sql;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/ord/admin/ordinst.sql SYSAUX SYSAUX;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/ord/im/admin/iminst.sql;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/olap/admin/olap.sql SYSAUX TEMP;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/md/admin/mdinst.sql;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/apex/catapx.sql change_on_install SYSAUX SYSAUX TEMP /i/ NONE;
connect "SYS"/"linakge" as SYSDBA
@$ORACLE_HOME/owb/UnifiedRepos/cat_owb.sql SYSAUX TEMP;

spool off



set echo on
spool /oracle/admin/j2eeactt/scripts/lockAccount.log append
BEGIN 
 FOR item IN ( SELECT USERNAME FROM DBA_USERS WHERE ACCOUNT_STATUS IN ('OPEN', 'LOCKED', 'EXPIRED') AND USERNAME NOT IN ( 
'SYS','SYSTEM') ) 
 LOOP 
  dbms_output.put_line('Locking and Expiring: ' || item.USERNAME); 
  execute immediate 'alter user ' ||
         sys.dbms_assert.enquote_name(
         sys.dbms_assert.schema_name(
         item.USERNAME),false) || ' password expire account lock' ;
 END LOOP;
END;
/
spool off


SET VERIFY OFF
connect "SYS"/"linakge" as SYSDBA
set echo on
spool /oracle/admin/j2eeactt/scripts/postDBCreation.log append
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
connect "SYS"/"linakge" as SYSDBA
set echo on
create spfile='$ORACLE_HOME/dbs/spfilej2eeactt.ora' FROM pfile='/oracle/admin/j2eeactt/scripts/init.ora';
shutdown immediate;
connect "SYS"/"linakge" as SYSDBA
startup ;
spool off

exit;