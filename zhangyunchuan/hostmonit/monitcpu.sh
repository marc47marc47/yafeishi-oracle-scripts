date >> /oracle/hostmonit/pscpu.`date '+%Y%m%d'`
nohup ps aux |grep -v root | sort -rn +2  |head -10  >> /oracle/hostmonit/pscpu.`date '+%Y%m%d'` &
nohup ps -ef | grep oracle | wc >> /oracle/hostmonit/pscpu.`date '+%Y%m%d'` &
