--������
mkgroup -'A' id='301' adms='root' oinstall
mkgroup -'A' id='302' adms='root' dba
mkgroup -'A' id='303' adms='root' asmdba
mkgroup -'A' id='304' adms='root' asmadmin
mkgroup -'A' id='305' adms='root' asmoper

--�����û� 
mkuser id='301' pgrp='oinstall' groups='dba,asmdba' home='/oracle' oracle
mkuser id='302' pgrp='oinstall' groups='asmdba,asmadmin,asmoper,dba' home='/grid' grid
\passwd oracle
\passwd grid

--�޸ĵ��û��������� 
smitty chgsys
Maximum number of processes available to a single user    [16384]

--�޸��û����� 
/usr/bin/chuser capabilities=CAP_NUMA_ATTACH,CAP_BYPASS_RAC_VMM,CAP_PROPAGATE grid
/usr/bin/chuser capabilities=CAP_NUMA_ATTACH,CAP_BYPASS_RAC_VMM,CAP_PROPAGATE oracle
 

--�����ڴ��ں˲���
vmo -p -o minperm%=3
vmo -p -o maxperm%=90
vmo -p -o maxclient%=90
vmo -p -o lru_file_repage=0
vmo -p -o strict_maxclient=1
vmo -p -o strict_maxperm=0


--grid �û� profile

umask 022
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR
ORACLE_SID=+ASM1; export ORACLE_SID
ORACLE_BASE=/grid/app; export ORACLE_BASE
ORACLE_HOME=/grid/app/11.2.0/grid; export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH; export PATH
 
 --oracle �û� profile

export AIXTHREAD_SCOPE=S
export ORACLE_BASE=/oracle/app
export ORACLE_SID=ENSEMBLE
export ORACLE_HOME=/oracle/app/product/11.2.0/dbhome_1
export ORA_CRS_HOME=/u01/app/11.2.0/grid
export PATH=$ORACLE_HOME/bin:$ORA_CRS_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
umask 022

--�����û���Դ����
\vi /etc/security/limits.conf
�ļ��м���
default:
       fsize = -1
       core = 2097151
       cpu = -1
       data = -1
       rss = -1
       stack = -1
       nofiles = -1
       stack_hard = -1
 
grid :
       core = -1
oracle :
       core = -1





--�����������
 /usr/sbin/no -a | fgrep ephemeral
tcp_ephemeral_low = 32768
tcp_ephemeral_high = 65535
udp_ephemeral_low = 32768
udp_ephemeral_high = 65535
 
�޸Ĳ�������
/usr/sbin/no -p -o tcp_ephemeral_low=9000 -o tcp_ephemeral_high=65500
/usr/sbin/no -p -o udp_ephemeral_low=9000 -o udp_ephemeral_high=65500
 



 
--������������
���ϵͳ֪��������compatibility mode
lsattr -E -l sys0 -a pre520tune
 
������� pre520tune enable Pre-520 tuning compatibility mode True
��ϵͳ������compatibility mode
 
�޸Ĳ����������£�
# no -o parameter_name=value
 
��/etc/rc.net�ļ������
if [ -f /usr/sbin/no ] ; then
/usr/sbin/no -o udp_sendspace=65536
/usr/sbin/no -o udp_recvspace=655360
/usr/sbin/no -o tcp_sendspace=65536
/usr/sbin/no -o tcp_recvspace=65536
/usr/sbin/no -o rfc1323=1
/usr/sbin/no -o sb_max=4194304
/usr/sbin/no -o ipqmaxlen=512
fi
 
������������ִ�н��Ϊ��
pre520tune disable Pre-520 tuning compatibility mode True,ϵͳδ������compatibility mode
�޸Ĳ����������£�
 
/usr/sbin/no -r -o ipqmaxlen=512
/usr/sbin/no -p -o rfc1323=1
/usr/sbin/no -p -o sb_max=4194304
/usr/sbin/no -p -o tcp_recvspace=65536
/usr/sbin/no -p -o tcp_sendspace=65536
/usr/sbin/no -p -o udp_recvspace=655360
