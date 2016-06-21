----------------------------环境准备--------------------------------
修改主备库listener.ora 文件：
主库：
[oracle@primary_db admin]$cat listener.ora 
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orcl)
      (ORACLE_HOME = /oracle/app/oracle/product/11.2.0/db)
      (SID_NAME = orcl)
    )
    (SID_DESC =
      (GLOBAL_DBNAME = ORCL_DGMGRL)
      (ORACLE_HOME = /oracle/app/oracle/product/11.2.0/db)
      (SID_NAME = orcl)
    )
  )
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = primary_db)(PORT = 1521))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
  
备库：
[oracle@standby_db admin]$cat listener.ora 
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orcl)
      (ORACLE_HOME = /oracle/app/oracle/product/11.2.0/db)
      (SID_NAME = orcl)
    )
    (SID_DESC =
      (GLOBAL_DBNAME = ORCLDG_DGMGRL)
      (ORACLE_HOME = /oracle/app/oracle/product/11.2.0/db)
      (SID_NAME = orcl)
    )
  )
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.56.153)(PORT = 1521))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

dgmgrl监听name的规则：db_unique_name_DGMGRL 
修改完成后，lsnrctl reload,查看监听状态：
主库：
[oracle@primary_db admin]$lsnrctl status 

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 09-JAN-2015 19:19:34

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=primary_db)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                09-JAN-2015 16:02:15
Uptime                    0 days 3 hr. 17 min. 19 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /oracle/app/oracle/product/11.2.0/db/network/admin/listener.ora
Listener Log File         /oracle/app/oracle/diag/tnslsnr/primary_db/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=primary_db)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
Services Summary...
Service "ORCL_DGB" has 1 instance(s).
  Instance "orcl", status READY, has 1 handler(s) for this service...
Service "ORCL_DGMGRL" has 1 instance(s).
  Instance "orcl", status UNKNOWN, has 1 handler(s) for this service...
Service "orcl" has 2 instance(s).
  Instance "orcl", status UNKNOWN, has 1 handler(s) for this service...
  Instance "orcl", status READY, has 1 handler(s) for this service...
The command completed successfully

备库：
[oracle@standby_db admin]$lsnrctl status

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 09-JAN-2015 19:20:06

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.56.153)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                09-JAN-2015 16:01:52
Uptime                    0 days 3 hr. 18 min. 14 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /oracle/app/oracle/product/11.2.0/db/network/admin/listener.ora
Listener Log File         /oracle/app/oracle/diag/tnslsnr/standby_db/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.56.153)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
Services Summary...
Service "ORCLDG" has 1 instance(s).
  Instance "orcl", status READY, has 1 handler(s) for this service...
Service "ORCLDG_DGB" has 1 instance(s).
  Instance "orcl", status READY, has 1 handler(s) for this service...
Service "ORCLDG_DGMGRL" has 1 instance(s).
  Instance "orcl", status UNKNOWN, has 1 handler(s) for this service...
Service "orcl" has 1 instance(s).
  Instance "orcl", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully

修改主备库参数，两边都执行：
切换DG到 最大可用模式：
alter database set standby database to maximize availability;
设置 dg_broker_start 为true：
alter system set dg_broker_start=true scope=both;
执行后查看alert出现如下信息：
Fri Jan 09 16:49:47 2015
DMON started with pid=27, OS id=2402 
Starting Data Guard Broker (DMON)
Fri Jan 09 16:49:55 2015
INSV started with pid=28, OS id=2404 
Fri Jan 09 16:57:28 2015
----------------------------开始配置----------------------------------
连接到dgmgrl：
[oracle@primary_db admin]$dgmgrl sys/dang@orcl  
DGMGRL for Linux: Version 11.2.0.4.0 - 64bit Production

Copyright (c) 2000, 2009, Oracle. All rights reserved.

Welcome to DGMGRL, type "help" for information.
Connected.
DGMGRL> 

创建配置文件：
DGMGRL> create configuration 'OrclBroker' as primary database is 'orcl' connect identifier is orcl;
Configuration "OrclBroker" created with primary database "orcl"

DGMGRL> help add

Adds a standby database to the broker configuration

Syntax:

  ADD DATABASE <database name>
    [AS CONNECT IDENTIFIER IS <connect identifier>]
    [MAINTAINED AS {PHYSICAL|LOGICAL}];

将备库信息添加到配置文件：
DGMGRL> 
DGMGRL> add database orcldg as connect identifier is orcldg maintained as physical;
Database "orcldg" added
DGMGRL> 

配置文件位置：
SYS@ orcl >show parameter dg_broker_config_file

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
dg_broker_config_file1               string      /oracle/app/oracle/product/11.
                                                 2.0/db/dbs/dr1ORCL.dat
dg_broker_config_file2               string      /oracle/app/oracle/product/11.
                                                 2.0/db/dbs/dr2ORCL.dat
												 											 
[oracle@primary_db dbs]$pwd
/oracle/app/oracle/product/11.2.0/db/dbs
[oracle@primary_db dbs]$ls -lrt
total 9860
-rw-r--r-- 1 oracle dba     2851 May 15  2009 init.ora
-rw-r----- 1 oracle dba     1536 Jan  5 22:54 orapworcl
-rw-r----- 1 oracle dba       24 Jan  5 22:54 lkORCL
-rw-rw---- 1 oracle dba     1544 Jan  9 16:47 hc_orcl.dat
-rw-r----- 1 oracle dba     3584 Jan  9 16:49 spfileorcl.ora
-rw-r----- 1 oracle dba 10043392 Jan  9 16:56 snapcf_orcl.f
-rw-r----- 1 oracle dba    12288 Jan  9 17:00 dr2ORCL.dat
-rw-r----- 1 oracle dba    20480 Jan  9 17:02 dr1ORCL.dat
										 
主库启用配置:
DGMGRL> enable configuration;
Enabled.
DGMGRL>

之后在备库的相同目录可看到配置文件：												 
SYS@ orcldg >show parameter dg_broker

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
dg_broker_config_file1               string      /oracle/app/oracle/product/11.
                                                 2.0/db/dbs/dr1ORCLDG.dat
dg_broker_config_file2               string      /oracle/app/oracle/product/11.
                                                 2.0/db/dbs/dr2ORCLDG.dat
dg_broker_start                      boolean     TRUE	

主库查看配置状态:
DGMGRL> show configuration;

Configuration - OrclBroker

  Protection Mode: MaxAvailability
  Databases:
    orcl   - Primary database
    orcldg - Physical standby database

Fast-Start Failover: DISABLED

Configuration Status:
SUCCESS											 

查看数据库配置：		
DGMGRL> show database verbose orcl

Database - orcl

  Role:            PRIMARY
  Intended State:  TRANSPORT-ON
  Instance(s):
    orcl

  Properties:
    DGConnectIdentifier             = 'orcl'
    ObserverConnectIdentifier       = ''
    LogXptMode                      = 'SYNC'
    DelayMins                       = '0'
    Binding                         = 'optional'
    MaxFailure                      = '0'
    MaxConnections                  = '1'
    ReopenSecs                      = '300'
    NetTimeout                      = '30'
    RedoCompression                 = 'DISABLE'
    LogShipping                     = 'ON'
    PreferredApplyInstance          = ''
    ApplyInstanceTimeout            = '0'
    ApplyParallel                   = 'AUTO'
    StandbyFileManagement           = 'AUTO'
    ArchiveLagTarget                = '0'
    LogArchiveMaxProcesses          = '4'
    LogArchiveMinSucceedDest        = '1'
    DbFileNameConvert               = '/oracle/oradata/orcl, /oracle/oradata/orcl'
    LogFileNameConvert              = '/oracle/oradata/orcl, /oracle/oradata/orcl'
    FastStartFailoverTarget         = ''
    InconsistentProperties          = '(monitor)'
    InconsistentLogXptProps         = '(monitor)'
    SendQEntries                    = '(monitor)'
    LogXptStatus                    = '(monitor)'
    RecvQEntries                    = '(monitor)'
    ApplyLagThreshold               = '0'
    TransportLagThreshold           = '0'
    TransportDisconnectedThreshold  = '30'
    SidName                         = 'orcl'
    StaticConnectIdentifier         = '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=primary_db)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=ORCL_DGMGRL)(INSTANCE_NAME=orcl)(SERVER=DEDICATED)))'
    StandbyArchiveLocation          = '/oracle/oradata/fra/orcl'
    AlternateLocation               = ''
    LogArchiveTrace                 = '0'
    LogArchiveFormat                = 'orcl%S_%T_%R.arc'
    TopWaitEvents                   = '(monitor)'

Database Status:
SUCCESS


DGMGRL> show database verbose orcldg

Database - orcldg

  Role:            PHYSICAL STANDBY
  Intended State:  APPLY-ON
  Transport Lag:   0 seconds (computed 1 second ago)
  Apply Lag:       0 seconds (computed 1 second ago)
  Apply Rate:      0 Byte/s
  Real Time Query: ON
  Instance(s):
    orcl

  Properties:
    DGConnectIdentifier             = 'orcldg'
    ObserverConnectIdentifier       = ''
    LogXptMode                      = 'SYNC'
    DelayMins                       = '0'
    Binding                         = 'OPTIONAL'
    MaxFailure                      = '0'
    MaxConnections                  = '1'
    ReopenSecs                      = '300'
    NetTimeout                      = '30'
    RedoCompression                 = 'DISABLE'
    LogShipping                     = 'ON'
    PreferredApplyInstance          = ''
    ApplyInstanceTimeout            = '0'
    ApplyParallel                   = 'AUTO'
    StandbyFileManagement           = 'AUTO'
    ArchiveLagTarget                = '0'
    LogArchiveMaxProcesses          = '4'
    LogArchiveMinSucceedDest        = '1'
    DbFileNameConvert               = '/oracle/oradata/orcl, /oracle/oradata/orcl'
    LogFileNameConvert              = '/oracle/oradata/orcl, /oracle/oradata/orcl'
    FastStartFailoverTarget         = ''
    InconsistentProperties          = '(monitor)'
    InconsistentLogXptProps         = '(monitor)'
    SendQEntries                    = '(monitor)'
    LogXptStatus                    = '(monitor)'
    RecvQEntries                    = '(monitor)'
    ApplyLagThreshold               = '0'
    TransportLagThreshold           = '0'
    TransportDisconnectedThreshold  = '30'
    SidName                         = 'orcl'
    StaticConnectIdentifier         = '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=standby_db)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=ORCLDG_DGMGRL)(INSTANCE_NAME=orcl)(SERVER=DEDICATED)))'
    StandbyArchiveLocation          = '/oracle/oradata/fra/orcl'
    AlternateLocation               = ''
    LogArchiveTrace                 = '0'
    LogArchiveFormat                = 'orcl%S_%T_%R.arc'
    TopWaitEvents                   = '(monitor)'

Database Status:
SUCCESS

DGMGRL> 
	
启用fast_start failover:
DGMGRL> enable fast_start failover;
Enabled.
DGMGRL> show configuration verbose;

Configuration - OrclBroker

  Protection Mode: MaxAvailability
  Databases:
    orcl   - Primary database
      Warning: ORA-16819: fast-start failover observer not started

    orcldg - (*) Physical standby database
      Warning: ORA-16819: fast-start failover observer not started

  (*) Fast-Start Failover target

  Properties:
    FastStartFailoverThreshold      = '30'
    OperationTimeout                = '30'
    FastStartFailoverLagLimit       = '30'
    CommunicationTimeout            = '180'
    ObserverReconnect               = '0'
    FastStartFailoverAutoReinstate  = 'TRUE'
    FastStartFailoverPmyShutdown    = 'TRUE'
    BystandersFollowRoleChange      = 'ALL'
    ObserverOverride                = 'FALSE'
    ExternalDestination1            = ''
    ExternalDestination2            = ''
    PrimaryLostWriteAction          = 'CONTINUE'

Fast-Start Failover: ENABLED

  Threshold:          30 seconds
  Target:             orcldg
  Observer:           (none)
  Lag Limit:          30 seconds (not in use)
  Shutdown Primary:   TRUE
  Auto-reinstate:     TRUE
  Observer Reconnect: (none)
  Observer Override:  FALSE

Configuration Status:
WARNING

DGMGRL> show configuration;

Configuration - OrclBroker

  Protection Mode: MaxAvailability
  Databases:
    orcl   - Primary database
      Warning: ORA-16819: fast-start failover observer not started

    orcldg - (*) Physical standby database
      Warning: ORA-16819: fast-start failover observer not started

Fast-Start Failover: ENABLED

Configuration Status:
WARNING

DGMGRL> 	

修改FastStartFailoverThreshold 参数值：
DGMGRL> edit configuration set property FastStartFailoverThreshold=120;
Property "faststartfailoverthreshold" updated

启动observer:
DGMGRL> start observer;
Observer started

-----下面步骤新开窗口进行------
switchover 测试：
查看当前主备库角色:
SYS@ orcl >select name,open_mode,database_role,switchover_status from v$database;  

NAME      OPEN_MODE            DATABASE_ROLE    SWITCHOVER_STATUS
--------- -------------------- ---------------- --------------------
ORCL      READ WRITE           PRIMARY          TO STANDBY

SYS@ orcldg >select name,open_mode,database_role,switchover_status from v$database;  

NAME      OPEN_MODE            DATABASE_ROLE    SWITCHOVER_STATUS
--------- -------------------- ---------------- --------------------
ORCL      READ ONLY WITH APPLY PHYSICAL STANDBY NOT ALLOWED

SYS@ orcldg >

dgmgrl 执行切换：
DGMGRL> switchover to orcldg;
Performing switchover NOW, please wait...
Operation requires a connection to instance "orcl" on database "orcldg"
Connecting to instance "orcl"...
Connected.
New primary database "orcldg" is opening...
Operation requires startup of instance "orcl" on database "orcl"
Starting instance "orcl"...
ORACLE instance started.
Database mounted.
Database opened.
Switchover succeeded, new primary is "orcldg"
DGMGRL> 

查看dgmgrl 日志：
01/09/2015 17:40:10
SWITCHOVER TO orcldg
Command SWITCHOVER TO orcldg completed with warning ORA-16523
SWITCHOVER TO orcldg
Notifying Oracle Clusterware to teardown primary database for SWITCHOVER
01/09/2015 17:40:21
Command SWITCHOVER TO orcldg completed
Shutting down instance after CTL_SWITCH

01/09/2015 17:40:34
Creating Data Guard Broker Monitor Process (DMON)
01/09/2015 17:40:47
>> Starting Data Guard Broker bootstrap <<
Broker Configuration File Locations:
      dg_broker_config_file1 = "/oracle/app/oracle/product/11.2.0/db/dbs/dr1ORCL.dat"
      dg_broker_config_file2 = "/oracle/app/oracle/product/11.2.0/db/dbs/dr2ORCL.dat"
01/09/2015 17:40:51
DMON Registering service ORCL_DGB with listener(s)
Broker Configuration:       "OrclBroker"
      Protection Mode:            Maximum Availability
      Fast-Start Failover (FSFO): Enabled, flags=0x41001, version=2
      Primary Database:           orcldg (0x02010000)
      Standby Database:           orcl, Enabled Physical Standby (FSFO target) (0x01010000)
01/09/2015 17:40:58
Creating process RSM0
01/09/2015 17:41:12
Notifying Oracle Clusterware to buildup standby database after SWITCHOVER
Command SWITCHOVER TO orcl completed


再次查看当前主备库角色：
原来的主库：
SYS@ orcl >select name,open_mode,database_role,switchover_status from v$database;  

NAME      OPEN_MODE            DATABASE_ROLE    SWITCHOVER_STATUS
--------- -------------------- ---------------- --------------------
ORCL      READ ONLY WITH APPLY PHYSICAL STANDBY NOT ALLOWED

SYS@ orcl >
已经变成备库。

原来的备库：
SYS@ orcldg >select name,open_mode,database_role,switchover_status from v$database;  

NAME      OPEN_MODE            DATABASE_ROLE    SWITCHOVER_STATUS
--------- -------------------- ---------------- --------------------
ORCL      READ WRITE           PRIMARY          TO STANDBY

SYS@ orcldg >

已经变成主库。