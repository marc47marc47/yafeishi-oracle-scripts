#  hostname ytechdb01  ngechdb02
echo "----------  Create group user "
mkgroup -'A' id='1000' adms='root' oinstall
mkgroup -'A' id='1100' adms='root' asmadmin
mkgroup -'A' id='1200' adms='root' dba
mkgroup -'A' id='1300' adms='root' asmdba
mkgroup -'A' id='1301' adms='root' asmoper

mkdir -p /home/oracle

mkuser id='1101' pgrp='oinstall' groups='dba,asmdba' home='/home/oracle' oracle


chown -R oracle:dba /home/oracle 

usermod -g oinstall  -G dba,asmdba -d /home/oracle oracle

chuser capabilities=CAP_BYPASS_RAC_VMM,CAP_PROPAGATE,CAP_NUMA_ATTACH oracle   
lsuser -a capabilities oracle

echo "----------  Create Required Software Directories  " 
mkdir -p /oracle/app/oracle/product/11.2.0/db
chown -R grid:oinstall /oracle
chown -R oracle:oinstall /oracle/app/oracle
chmod -R 775 /oracle
mkdir -p /oracle/soft
chown -R grid:oinstall /oracle/soft

echo "----------  Configure UDP and TCP Kernel Parameters "
/usr/sbin/no -p -o tcp_ephemeral_low=9000
/usr/sbin/no -p -o tcp_ephemeral_high=65535
/usr/sbin/no -p -o udp_ephemeral_low=9000
/usr/sbin/no -p -o udp_ephemeral_high=65535
/usr/sbin/no -p -o tcp_recvspace=65536
/usr/sbin/no -p -o tcp_sendspace=65536
/usr/sbin/no -p -o udp_sendspace=65536
/usr/sbin/no -p -o udp_recvspace=65536
/usr/sbin/no -p -o rfc1323=1
/usr/sbin/no -p -o sb_max=4194304 
/usr/sbin/no -p -o ipqmaxlen=512

echo "----------  Configure VMO Parameters "
/usr/sbin/vmo -p -o maxperm%=90
/usr/sbin/vmo -p -o minperm%=3
/usr/sbin/vmo -p -o maxclient%=90
/usr/sbin/vmo -p -o maxpin%=90
/usr/sbin/vmo -p -o strict_maxperm=0
/usr/sbin/vmo -p -o strict_maxclient=1
/usr/sbin/vmo -p -o lru_file_repage=0
/usr/sbin/vmo -p -o page_steal_method=1

echo "----------  Configure System Configuration Parameters "
/usr/sbin/chdev -l sys0 -a maxuproc=16384
/usr/sbin/chdev -l sys0 -a ncargs=256
/usr/sbin/chdev -l sys0 -a minpout=4096
/usr/sbin/chdev -l sys0 -a maxpout=8193


##   cat >> /etc/hosts << "EOF"
##   #########################################
##   10.143.3.151   ytechdb01
##   10.143.0.151   ytechdb01-priv
##   10.143.3.153   ytechdb01-vip
##   10.143.3.152   ngechdb02
##   10.143.0.152   ngechdb02-priv
##   10.143.3.154   ngechdb02-vip
##   10.143.3.155   echdb-scan
##   EOF

echo "------------  Configure Shell Limits"
cat >> /etc/security/limits  << "EOF"
############  for rac #######
oracle:
        stack = -1
        stack_hard = -1
EOF


echo "----------  Configure Oracle User Profile "
cat >> /home/oracle/.profile << "EOF"

# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR
export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=/oracle/app/oracle/product/11.2.0/db
export GRID_HOME=/oracle/app/11.2.0/grid
#export ORACLE_SID=ngcusdb2
#export ORACLE_UNQNAME=xjdb
BASE_PATH=/usr/sbin:$PATH; export BASE_PATH
PATH=.:/opt/oracle/monitor:$ORACLE_HOME/bin:$GRID_HOME/bin:$BASE_PATH:$ORACLE_HOME/jdk/bin:/splog/shareplex/prodir/bin:; export PATH
LD_LIBRARY_PATH=$ORACLE_HOME/lib:$GRID_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK; export NLS_LANG
export NLS_DATE_FORMAT='YYYY-MM-DD HH:MI:SS'
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$GRID_HOME/jlib; export CLASSPATH
stty erase ^?
export SSH_ENV=~/.ssh/environment
export DISPLAY=127.0.0.1:0.0
umask 022
export PS1='['`hostname`':$LOGIN:$PWD]'
set -o vi
EOF

chown oracle:oinstall /home/oracle/.profile
