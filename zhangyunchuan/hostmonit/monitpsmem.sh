. /oracle/.profile

echo "\n" >> /oracle/hostmonit/psmem.`date '+%Y%m%d'`
date >> /oracle/hostmonit/psmem.`date '+%Y%m%d'`
ps aux |sort -rn +5  |head -10  >> /oracle/hostmonit/psmem.`date '+%Y%m%d'` 

