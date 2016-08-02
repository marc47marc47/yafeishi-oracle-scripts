set linesize 1000 pagesize 10000 
select name, group_number , disk_number ,state ,failgroup ,path  
from v$asm_disk 
where name like 'CRS%' ; 


select a.NAME,round(a.TOTAL_MB/1024),round(a.FREE_MB/1024)
from v$asm_diskgroup  a;


alter diskgroup HDATA drop disk HDATA_0008;
alter diskgroup HDATA drop disk HDATA_0009;
alter diskgroup HDATA drop disk HDATA_0010;
alter diskgroup HDATA drop disk HDATA_0011;
alter diskgroup HDATA drop disk HDATA_0012;
alter diskgroup HDATA drop disk HDATA_0013;


alter diskgroup idx drop disk IDX_0011;

col path format a30;
set pagesize 1000;
select group_number,disk_number,path,total_mb/1024 from v$asm_disk order by 1,2;
select GROUP_NUMBER,OPERATION,state,trunc(SOFAR/EST_WORK),EST_MINUTES from v$asm_operation;
alter diskgroup data rebalance power 11;
select group_number,disk_number,path,name,total_mb/1024 from v$asm_disk order by 1,2;


alter diskgroup DATA ADD disk '/dev/rhdiskpower30';
alter diskgroup IDX ADD disk '/dev/rhdiskpower45';


