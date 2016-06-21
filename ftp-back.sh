#!/bin/ksh 
HOST="10.154.50.65" 
USER="billing" 
PASSWORD="billing" 
S_DIR="/oradata4/dmp"
T_DIR="/ngboss/billing/danghb/dmp" 

if [ ! -e ${S_DIR}/* ] 
then 
        exit 0 
fi 

echo "open ${HOST} 
user ${USER} ${PASSWORD} 
lcd ${S_DIR} 
cd ${T_DIR} 
bin
prompt off
mget *.dmp
ls * 
bye"|ftp -in >> ./upload.log 
 
exit 0