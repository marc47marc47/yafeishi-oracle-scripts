#!/usr/bin/sh
. /oracle/.profile

ALERT_HOME=/oraclelog/admin/ngcrmdb1/bdump;export ALERT_HOME
CUR_MONTH=`date +%m`;export CUR_MONTH
CUR_YEAR=`date +%Y`;export CUR_YEAR

LAST_MONTH=`expr $CUR_MONTH - 1`
if [ $LAST_MONTH -eq 0 ]
  then
    LAST_MONTH="12"   
    CUR_YEAR=`expr $CUR_YEAR - 1` 
  elif [ $LAST_MONTH -lt 10 ]
  then
    LAST_MONTH="0$LAST_MONTH"
  else
    LAST_MONTH="$LAST_MONTH"
fi

    LAST_MONTH="$CUR_YEAR""$LAST_MONTH"

if [ -s $ALERT_HOME/alert_$ORACLE_SID.log ]; then
  cp -f $ALERT_HOME/alert_$ORACLE_SID.log $ALERT_HOME/alert_$ORACLE_SID.log_$LAST_MONTH
  if [ $? -eq 0 ]
  then
     > $ALERT_HOME/alert_$ORACLE_SID.log
     compress $ALERT_HOME/alert_$ORACLE_SID.log_$LAST_MONTH
  fi
else
  echo "目标文件不存在   -- "$ALERT_HOME
  exit
fi
