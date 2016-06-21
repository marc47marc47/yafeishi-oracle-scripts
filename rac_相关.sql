--- 11g 
crsctl stat res | grep NAME | grep '.db' | grep -v vip | grep -v svc
crsctl stat res -t
crsctl stat res -w "TYPE = ora.database.type"
crsctl stat res -w "TYPE = ora.database.type" | grep NAME
||
crsctl stat res -w "TYPE = ora.database.type" | grep STATE
-- from internet
1,查看CRS状态
crsctl check crs
crsctl check has
crsctl check cluster
crsctl check cluster -all
crsctl stat res -t 
crsctl stat res -t -init
 
2,VOT磁盘查询
crsctl query css votedisk
 
3,Verify the integrity of OCR:
ocrcheck
 
4,查看资源状态
crsctl stat res -t
crsctl stat res -t -init
 
5，启动
crsctl start has
crsctl start cluster  
crsctl start cluster -all
crsctl start cluster -n cqracdb1 
 
[启动整个集群，包括OHASD在一个节点]
crsctl start crs
6，停止
crsctl stop cluster -n cqracdb1 
crsctl stop cluster [-f]
crsctl stop cluster -all
crsctl stop has
 
[全部停止包括OHASD]
crsctl stop crs -all -f
 
7，查看数据库状态
srvctl status database -d cqdb
查看节点资源状态
srvctl status nodeapps
查看数据库的配置
srvctl config database -d cqdb
查看asm的配置
srvctl config asm -a 
查看TNS配置
srvctl config listener -a
查看SCAN
srvctl status scan
停止数据库
srvctl stop instance -d cqdb -i "orcl3,orcl4" -o immediate
 
查询crs状态：
crsctl config crs
crsctl config has

srvctl remove database -d fltadt 
srvctl add database -d fltadt -g xjclouddb -o /oracle/app/oracle/product/11.2.0/db -s open -c RACOneNode -p +DATA/FLTADT/spfilefltadt.ora -a "DATA,CLUSTER_FS" -e nhxjclouddb16,nhxjclouddb01,nhxjclouddb02,nhxjclouddb03,nhxjclouddb04,nhxjclouddb05,nhxjclouddb06,nhxjclouddb07,nhxjclouddb08,nhxjclouddb09,nhxjclouddb10,nhxjclouddb11,nhxjclouddb12,nhxjclouddb13,nhxjclouddb14,nhxjclouddb15
srvctl add database -d fltadt -g xjclouddb -o /oracle/app/oracle/product/11.2.0/db -s open -c RACOneNode -p +DATA/FLTADT/spfilefltadt.ora -a "DATA,CLUSTER_FS" 
srvctl add database -d fltadt  -o /oracle/app/oracle/product/11.2.0/db -s open -c RACOneNode -p +DATA/FLTADT/spfilefltadt.ora -a "DATA,CLUSTER_FS" 
srvctl add database -d fltadt   -o /oracle/app/oracle/product/11.2.0/db -s open -c RACOneNode -p +DATA/FLTADT/spfilefltadt.ora -a "DATA,CLUSTER_FS" -e nhxjclouddb16,nhxjclouddb01,nhxjclouddb02,nhxjclouddb03,nhxjclouddb04,nhxjclouddb05,nhxjclouddb06,nhxjclouddb07,nhxjclouddb08,nhxjclouddb09,nhxjclouddb10,nhxjclouddb11,nhxjclouddb12,nhxjclouddb13,nhxjclouddb14,nhxjclouddb15

srvctl config database -d fltadt
srvctl modify database -d fltadt -e nhxjclouddb13,nhxjclouddb01,nhxjclouddb02,nhxjclouddb03,nhxjclouddb04,nhxjclouddb05,nhxjclouddb06,nhxjclouddb07,nhxjclouddb08,nhxjclouddb09,nhxjclouddb10,nhxjclouddb11,nhxjclouddb12,nhxjclouddb16,nhxjclouddb14,nhxjclouddb15
srvctl config database -d fltadt -m db.xjmc

crsctl status serverpool -p
srvctl config srvpool
srvctl status srvpool
srvctl add srvpool -g xjclouddb -l 0 -u 16 
srvctl modify srvpool -g xjclouddb -n "nhxjclouddb01,nhxjclouddb02,nhxjclouddb03,nhxjclouddb04,nhxjclouddb05,nhxjclouddb06,nhxjclouddb07,nhxjclouddb08,nhxjclouddb09,nhxjclouddb10,nhxjclouddb11,nhxjclouddb12,nhxjclouddb13,nhxjclouddb14,nhxjclouddb15,nhxjclouddb16"
srvctl modify srvpool -g xjclouddb -n "nhxjclouddb13"


srvctl stop database -d fltadt 
srvctl modify database -d fltadt -g xjclouddb  -- 会导致DB shutdown

srvctl add service -d fltadt -s fltadt.db.xjmc -g xjclouddb -c singleton

oracle ；srvctl add service -d fltadt -s fltadt.db.xjmc


crsctl status serverpool xjclouddb -g
 
 
 

