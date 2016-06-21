#!/usr/bin/ksh 
# 当/archivelog1文件系统当前使用率超过90%时清除文件系统下的文件
. /oracle/.profile

CLEAR_RATE=85

# 计算FS空间使用率
ARCHLOG_USED=`df -k|grep archivelog1|awk '{print $4;} '|awk -F % '{print $1;}'`
while [ $ARCHLOG_USED -ge $CLEAR_RATE ]
do
  # 开始删除文件系统下的文件
  FILE_NAME=`ls -trp /archivelog1|grep -v '/'|head -1`
  if [ "NULL$FILE_NAME" = "NULL" ];then exit;fi
  echo `date +"%Y-%m-%d %H:%M:%S"`" -- Delete file "$FILE_NAME
  rm -f /archivelog1/$FILE_NAME
  if [ $? != 0 ];then echo `date +"%Y-%m-%d %H:%M:%S"`" -- failed to delete the file !!!";fi
  # 重新计算FS空间使用率
  ARCHLOG_USED=`df -k|grep archivelog1|awk '{print $4;} '|awk -F % '{print $1;}'`
  CLEAR_RATE=60
done
exit
