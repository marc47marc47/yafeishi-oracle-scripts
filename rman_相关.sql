

全库备份：
show all;
configure default device type to disk; 
configure channel 1 device type disk format '/oracle/oradata/backup/orcl_fulldb_%U';
configure controlfile autobackup on; 
configure controlfile autobackup format for device type disk to '/oracle/oradata/backup/orcl_ctl_%F';
backup database plus archivelog delete input;


scp scp * standby_db:/oracle/oradata/backup/

restore spfile to '/oracle/app/oracle/product/11.2.0/db/dbs/spfileorcl.ora' from '/oracle/oradata/backup/orcl_ctl_c-1396010433-20150107-01';
restore controlfile from '/oracle/oradata/backup/orcl_ctl_c-1396010433-20150107-01';

backup datafile '/oracle/oradata/orcl/system01.dbf';

restore datafile 1 ;






