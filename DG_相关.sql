主库操作：
select force_logging from v$database;
--alter database force logging;
select group#, bytes/1024/1024 from v$log;


alter database add standby logfile ('/oracle/oradata/orcl/stdb_redo01.log') size 50m;
alter database add standby logfile ('/oracle/oradata/orcl/stdb_redo02.log') size 50m;
alter database add standby logfile ('/oracle/oradata/orcl/stdb_redo03.log') size 50m;
alter database add standby logfile ('/oracle/oradata/orcl/stdb_redo04.log') size 50m;



ALTER DATABASE CLEAR LOGFILE GROUP 1;
ALTER DATABASE CLEAR LOGFILE GROUP 2;
ALTER DATABASE CLEAR LOGFILE GROUP 3;

ALTER SYSTEM SET DB_UNIQUE_NAME=orcl scope=spfile;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(orcl,orcldg)' scope=both;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=/oracle/oradata/fra/orcl VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=orcl' SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=orcldg LGWR SYNC AFFIRM  VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=orcldg' SCOPE=BOTH;
alter system set log_archive_format='orcl%S_%T_%R.arc' scope=spfile ;

ALTER SYSTEM SET standby_file_management=AUTO SCOPE=BOTH;
ALTER SYSTEM SET FAL_CLIENT='orcl';
ALTER SYSTEM SET FAL_SERVER='orcldg';
ALTER SYSTEM SET DB_FILE_NAME_CONVERT='+DATA','+DATA' SCOPE=SPFILE;
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='+DATA','+DATA' SCOPE=SPFILE;

ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/oracle/oradata/orcl/stb_ctl01.ctl';
cp '/oracle/oradata/orcl/stb_ctl01.ctl' '/oracle/oradata/orcl/stb_ctl02.ctl'

调整备库参数：
ALTER SYSTEM SET DB_UNIQUE_NAME=orcldg scope=spfile;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(orcl,orcldg)' scope=both;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=/oracle/oradata/fra/orcl VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=orcldg' SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=orcl LGWR SYNC AFFIRM  VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=orcl' SCOPE=BOTH;
alter system set log_archive_format='orcl%S_%T_%R.arc' scope=spfile ;

ALTER SYSTEM SET standby_file_management=AUTO SCOPE=BOTH;
ALTER SYSTEM SET FAL_CLIENT='orcldg';
ALTER SYSTEM SET FAL_SERVER='orcl';
ALTER SYSTEM SET DB_FILE_NAME_CONVERT='/oracle/oradata/orcl','/oracle/oradata/orcl' SCOPE=SPFILE;
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='/oracle/oradata/orcl','/oracle/oradata/orcl' SCOPE=SPFILE;

--------------------------------------------------------------------------------------------
select open_mode from v$database;
select database_role,name,OPEN_MODE,DB_UNIQUE_NAME,to_char(sysdate,'YYYYMMDD HH24:MI:SS') from v$database;
select flashback_on from v$database;
select PROTECTION_MODE from v$database;
select CURRENT_SCN from v$database;
select protection_mode,protection_level from v$database;

select group#,thread#,sequence#,archived,status from v$standby_log;
select sequence#, first_time, next_time from v$archived_log order by sequence#;
select sequence#,applied from v$archived_log order by sequence#;
select max(sequence#) from v$archived_log;
select * from V$ARCHIVE_GAP;

select message from v$dataguard_status;
select process,client_process,sequence#,status from v$managed_standby;

alter database set standby database to maximize availability;
alter database set standby database to maximize protection;
alter system set dg_broker_start=true scope=both;s
alter database recover managed standby database cancel;
alter database recover managed standby database using current logfile disconnect from session;




启动顺序：先standby,后primary
关闭顺序：先primary,后standby

SQL> select open_mode from v$database;

OPEN_MODE
--------------------
MOUNTED

SQL> alter database recover managed standby database cancel;

Database altered.

SQL> alter database open;

Database altered.

SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ ONLY

SQL> alter database recover managed standby database using current logfile disconnect;

Database altered.

SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ ONLY WITH APPLY

	 

