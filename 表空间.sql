--表空间使用情况
select b.tablespace_name              "表空间名",
       round(b.all_byte)              "总空间(M)",
       round(b.all_byte-a.free_byte)  "已使用(M)",
       nvl(round(a.free_byte),0)             "剩余空间(M)",
       round((a.free_byte/b.all_byte)* 100,2)  "剩余百分比"
  from ( select tablespace_name,sum (nvl(bytes,0))/ 1024/1024 free_byte from dba_free_space group by tablespace_name) a,
       ( select tablespace_name,sum (nvl(bytes,0))/ 1024/1024 all_byte from dba_data_files group by tablespace_name) b
 where b.tablespace_name = a.tablespace_name(+)
 AND b.tablespace_name= 'TBS_ACT_DEF'
 order by 2;
 
 
set linesize 1000
set pagesize 1000
select b.tablespace_name              "tablespace_name",
       round(b.all_byte)              "total_size(G)",
       round(b.all_byte-a.free_byte)  "used_size(G)",
       nvl(round(a.free_byte),0)             "free_size(G)",
       round((a.free_byte/b.all_byte)* 100,2)  "free_ration"
  from ( select tablespace_name,sum (nvl(bytes,0))/ 1024/1024/1024 free_byte from dba_free_space group by tablespace_name) a,
       ( select tablespace_name,sum (nvl(bytes,0))/ 1024/1024/1024 all_byte from dba_data_files group by tablespace_name) b
 where b.tablespace_name = a.tablespace_name(+)
 --and b.tablespace_name like 'TBS_CRM_DUSR%'
 order by 5 desc ; 
 
select  a.tablespace_name "表空间名字",
       round(a.bytes_alloc / 1024 /1024/1024) "已分配空间(G)",
       round((a.bytes_alloc - nvl(b.bytes_free, 0)) / 1024 / 1024/1024) "已使用空间(G)",
       round(nvl(b.bytes_free, 0) / 1024 / 1024) "剩余空间(M)",
       round((nvl(b.bytes_free, 0) / a.bytes_alloc) * 100,2) "剩余比例",
       round(nvl((maxbytes-a.bytes_alloc+b.bytes_free)/1024/1024/1024,0)) "总剩余空间大小(G)",
       round(maxbytes/1024/1024/1024) "表空间最大可分配大小(G)",
       round((maxbytes-a.bytes_alloc)/1024/1024/1024) "还可自动扩展大小(G)"
from  ( select  f.tablespace_name,
               sum(f.bytes) bytes_alloc,
               sum(decode(f.autoextensible, 'YES',f.maxbytes,'NO', f.bytes)) maxbytes
        from dba_data_files f
        group by tablespace_name) a,
      ( select  f.tablespace_name,
               sum(f.bytes)  bytes_free
        from dba_free_space f
        group by tablespace_name) b
where a.tablespace_name = b.tablespace_name (+)
--and a.tablespace_name like 'TBS_CEN_HIUIF'
order by 5;
 
--asmdg大小：
select a.NAME,round(a.TOTAL_MB/1024),round(a.FREE_MB/1024)
from v$asm_diskgroup  a;

SELECT p.tablespace_name,
       ROUND(SUM(p.bytes_cached) / 1024 / 1024) BYTES_CACHED,
       ROUND(SUM(p.bytes_used) / 1024 / 1024) BYTES_USED
  FROM gv$temp_extent_pool p
 GROUP BY p.tablespace_name;

--TEMP表空间：
SELECT D.TABLESPACE_NAME,SPACE "SUM_SPACE(M)",BLOCKS SUM_BLOCKS,
USED_SPACE "USED_SPACE(M)",ROUND(NVL(USED_SPACE, 0)/SPACE *100, 2) "USED_RATE(%)",
NVL(FREE_SPACE,0) "FREE_SPACE(M)"
FROM
(SELECT TABLESPACE_NAME,ROUND( SUM(BYTES)/(1024 *1024), 2) SPACE,SUM (BLOCKS) BLOCKS
FROM DBA_TEMP_FILES
GROUP BY TABLESPACE_NAME) D,
(SELECT TABLESPACE_NAME,ROUND( SUM(BYTES_USED)/(1024 *1024), 2) USED_SPACE,
ROUND(SUM(BYTES_FREE)/( 1024*1024 ),2) FREE_SPACE
FROM V$TEMP_SPACE_HEADER
GROUP BY TABLESPACE_NAME) F
WHERE  D.TABLESPACE_NAME = F.TABLESPACE_NAME(+);


select h.tablespace_name,
       round(sum(h.bytes_free + h.bytes_used) / 1048576) megs_alloc,
       round(sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) /
             1048576) megs_free,
       round(sum(nvl(p.bytes_used, 0)) / 1048576) megs_used,
       round((sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) /
             sum(h.bytes_used + h.bytes_free)) * 100) Pct_Free,
       100 -
       round((sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) /
             sum(h.bytes_used + h.bytes_free)) * 100) pct_used,
       round(sum(f.maxbytes) / 1048576) max
  from sys.v_$TEMP_SPACE_HEADER h,
       sys.v_$Temp_extent_pool  p,
       dba_temp_files           f
 where p.file_id(+) = h.file_id
   and p.tablespace_name(+) = h.tablespace_name
   and f.file_id = h.file_id
   and f.tablespace_name = h.tablespace_name
 group by h.tablespace_name
 ORDER BY 1

SELECT A.tablespace_name tablespace,
       D.mb_total/1024,
       SUM(A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
       D.mb_total - SUM(A.used_blocks * D.block_size) / 1024 / 1024 mb_free
  FROM v$sort_segment A,
       (SELECT B.name, C.block_size, SUM(C.bytes) / 1024 / 1024 mb_total
          FROM v$tablespace B, v$tempfile C
         WHERE B.ts# = C.ts#
         GROUP BY B.name, C.block_size) D
 WHERE A.tablespace_name = D.name
 GROUP by A.tablespace_name, D.mb_total;
 
 
 
SELECT d.tablespace_name "Name", 
            TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)", 
            TO_CHAR(NVL(t.hwm, 0)/1024/1024,'99999999.999')  "HWM (M)",
            TO_CHAR(NVL(t.hwm / a.bytes * 100, 0), '990.00') "HWM % " ,
            TO_CHAR(NVL(t.bytes/1024/1024, 0),'99999999.999') "Using (M)", 
      TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "Using %" 
       FROM sys.dba_tablespaces d, 
            (select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a,
            (select tablespace_name, sum(bytes_cached) hwm, sum(bytes_used) bytes from v$temp_extent_pool group by tablespace_name) t
      WHERE d.tablespace_name = a.tablespace_name(+) 
        AND d.tablespace_name = t.tablespace_name(+) 
        AND d.extent_management like 'LOCAL' 
        AND d.contents like 'TEMPORARY';
 
select tablespace_name,total_extents,total_blocks*8192/1024/1024 total_m,max_blocks*8192/1024/1024 max_m,max_size,max_used_size,max_sort_size,FREE_BLOCKS*8192/1024/1024 free_m
from v$sort_segment
ORDER BY total_extents;

--占用temp段较多的session
SELECT se.inst_id,se.username,
       sid,
       serial#,
       sql_address,
       machine,
       program,
       tablespace,
       segtype,
       contents,
       blocks,
       blocks*8/1024/1024 "size_G",
       s.SQL_TEXT,
        'alter system kill session ' || '''' || se.sid || ',' || se.serial# || '''' ||
       ' immediate;'
  FROM gv$session se, gv$sort_usage su,gv$sql s
 WHERE 1=1
 and se.INST_ID=su.INST_ID
 and se.INST_ID=s.INST_ID
 and se.saddr = su.session_addr
 and se.SQL_ID=s.SQL_ID;


--segment 所占表空间大小：
select tablespace_name,sum (bytes)/1024/ 1024/1024 "size(G)"
from dba_segments
where segment_name in
(
 select table_name
  from dba_tables
  where owner in ('UCR_CRM1' ,'UCR_CEN1')
  and table_name like 'TF_F%'
)
group by tablespace_name;

select tablespace_name,sum (bytes)/1024/ 1024/1024 "size(G)"
from dba_segments
where segment_name in
(
 select index_name
  from dba_indexes
  where owner in ('UCR_CRM1' ,'UCR_CEN1')
  and table_name like 'TF_F%'
)
group by tablespace_name;


--查看数据文件使用情况，如果要resize,必须高于HWMSIZE值
select *
  from (select /*+ ordered use_hash(a,b,c) */
         a.file_id,
         a.file_name,
         a.filesize,
         b.freesize,
         (a.filesize - b.freesize) usedsize,
         c.hwmsize,
         c.hwmsize - (a.filesize - b.freesize) unsedsize_belowhwm,
         a.filesize - c.hwmsize canshrinksize
          from (select file_id,
                       file_name,
                       round(bytes / 1024 / 1024) filesize
                  from dba_data_files) a,
               (select file_id, round(sum(dfs.bytes) / 1024 / 1024) freesize
                  from dba_free_space dfs
                 group by file_id) b,
               (select file_id, round(max(block_id) * 8 / 1024) HWMsize
                  from dba_extents
                 group by file_id) c
         where a.file_id = b.file_id
           and a.file_id = c.file_id
         order by unsedsize_belowhwm desc)
 where file_id in (select file_id
                     from dba_data_files
                    where tablespace_name = 'IOM_HIS_DATA')
 order by file_id;


------- undo
ALTER SYSTEM SET "_undo_autotune"=true SCOPE=both;
ALTER SYSTEM SET undo_retention=3600 SCOPE=both;

select AUTOEXTENSIBLE,RETENTION
from dba_tablespaces,dba_data_files
where dba_data_files.TABLESPACE_NAME=dba_tablespaces.TABLESPACE_NAME
and dba_data_files.TABLESPACE_NAME like '%UNDO%';