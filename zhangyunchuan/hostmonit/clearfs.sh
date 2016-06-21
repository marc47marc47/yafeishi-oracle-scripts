#!/usr/bin/ksh 
# ��/archivelog1�ļ�ϵͳ��ǰʹ���ʳ���90%ʱ����ļ�ϵͳ�µ��ļ�
. /oracle/.profile

CLEAR_RATE=85

# ����FS�ռ�ʹ����
ARCHLOG_USED=`df -k|grep archivelog1|awk '{print $4;} '|awk -F % '{print $1;}'`
while [ $ARCHLOG_USED -ge $CLEAR_RATE ]
do
  # ��ʼɾ���ļ�ϵͳ�µ��ļ�
  FILE_NAME=`ls -trp /archivelog1|grep -v '/'|head -1`
  if [ "NULL$FILE_NAME" = "NULL" ];then exit;fi
  echo `date +"%Y-%m-%d %H:%M:%S"`" -- Delete file "$FILE_NAME
  rm -f /archivelog1/$FILE_NAME
  if [ $? != 0 ];then echo `date +"%Y-%m-%d %H:%M:%S"`" -- failed to delete the file !!!";fi
  # ���¼���FS�ռ�ʹ����
  ARCHLOG_USED=`df -k|grep archivelog1|awk '{print $4;} '|awk -F % '{print $1;}'`
  CLEAR_RATE=60
done
exit
