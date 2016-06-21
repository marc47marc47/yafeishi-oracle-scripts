#!/bin/sh
#script:vmstat
#
. /oracle/.profile

#ps -ef|grep vmstat|grep -v grep |awk '{print "kill -9 "$2}' > a.out
#sh a.out
#rm a.out

nohup vmstat 60 1400 | /oracle/hostmonit/addtime.sh > /oracle/hostmonit/statm.`date '+%Y%m%d'` &

