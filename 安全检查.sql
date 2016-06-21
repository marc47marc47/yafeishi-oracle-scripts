ORACLE_SID=UECDB1
export ORACLE_SID
ORACLE_HOME=/home/oracle/app/oracle
export ORACLE_HOME
cd /home/oracle/app/oracle/network/admin
cp sqlnet.ora sqlnet.ora.201205071930
vi sqlnet.ora
SQLNET.ENCRYPTION_SERVER = accepted
SQLNET.ENCRYPTION_CLIENT = accepted
SQLNET.ENCRYPTION_TYPES_SERVER = (RC4_256)
SQLNET.ENCRYPTION_TYPES_CLIENT = (RC4_256)

SQLNET.CRYPTO_CHECKSUM_SERVER = accepted
SQLNET.CRYPTO_CHECKSUM_CLIENT = accepted
SQLNET.CRYPTO_CHECKSUM_TYPES_SERVER = (MD5)
SQLNET.CRYPTO_CHECKSUM_TYPES_CLIENT = (MD5)

cd /home/oracle/app/oracle/bin
./sqlplus / as sysdba
@$ORACLE_HOME/rdbms/admin/utlpwdmg.sql
connect system/linkage
CREATE PROFILE app_user LIMIT
FAILED_LOGIN_ATTEMPTS 6    --当用户连续认证失败次数超过6次（不含6次），锁定该用户使用的账号
PASSWORD_LIFE_TIME 90      --用户密码有效时间是否不长于90天
PASSWORD_REUSE_TIME 60     --原口令可以使用的间隔时间是否不长于60天
PASSWORD_REUSE_MAX 5       --用户不能重复使用最近5次（含5次）内已使用的口令
PASSWORD_VERIFY_FUNCTION DEFAULT
PASSWORD_LOCK_TIME 1/24    --用户账号被锁1小时后，自动解锁。
PASSWORD_GRACE_TIME 90;    --密码过期警告开始到用户被锁定的时间
ALTER USER UCR_WEB1 PROFILE app_user;
ALTER USER UOP_WEB1 PROFILE app_user;
ALTER USER APPQOSSYS  PROFILE app_user;

create table system.LOGON_INFO
(
   USER_NAME    varchar2(30),
   LOGDATE      varchar2(50),
   HOST         varchar2(50),
   OS_USER      varchar2(50),
   IP           varchar2(20)
);
CREATE OR REPLACE TRIGGER system.TRI_LOGON
AFTER LOGON
ON DATABASE 
BEGIN
INSERT INTO LOGON_INFO VALUES
(SYS_CONTEXT('USERENV','SESSION_USER'),
TO_CHAR(SYSDATE,'yyyy-mm-dd hh24:mi:ss'),
SYS_CONTEXT('USERENV','HOST'),
SYS_CONTEXT('USERENV','OS_USER'),
SYS_CONTEXT('USERENV','IP_ADDRESS')
);
END;
connect system/linkage

alter system set audit_trail='DB' scope=spfile;


shutdown immediate;                               --重启之后查看修改效果
startup;

connect system/linakge

SQL> create user test identified by test;           --新建用户的密码有了检测。
create user test identified by test
*
ERROR at line 1:
ORA-28003: password verification for the specified password failed
ORA-20001: Password length less than 8

SQL> select user_name,logdate from logon_info;      --登录信息表有个数据。

USER_NAME     LOGDATE
SYSTEM       2012-05-07 19:28:44
SYS          2012-05-07 19:43:18
SYSTEM       2012-05-07 19:44:27
SYSTEM       2012-05-07 19:44:51
SYSTEM       2012-05-07 21:20:21

SQL> select profile from dba_users;                 --用户用上了新profile。

PROFILE
------------------------------
APP_USER
APP_USER
DEFAULT
DEFAULT
DEFAULT
DEFAULT
DEFAULT
APP_USER
DEFAULT
DEFAULT

10 rows selected.

SQL> select resource_name,limit from dba_profiles a where a.profile='APP_USER' and a.resource_name like 'PASSWORD%'
  2  /

RESOURCE_NAME                    LIMIT
-------------------------------- ----------------------------------------
PASSWORD_LIFE_TIME               90
PASSWORD_REUSE_TIME              60
PASSWORD_REUSE_MAX               5
PASSWORD_VERIFY_FUNCTION         DEFAULT
PASSWORD_LOCK_TIME               .0416
PASSWORD_GRACE_TIME              90

SQL> show parameter audit_trail                  --审计开了。

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_trail                          string      DB



