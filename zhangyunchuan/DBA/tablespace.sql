select a.tablespace_name, sum(b.bytes)/sum(a.bytes)*100 pct_remain_space,
                         (sum(a.bytes)-sum(b.bytes))/1024/1024 used_M,
                          sum(b.bytes)/(1024*1024)free_M
from dba_data_files a, (select file_id,sum(bytes) bytes from dba_free_space group by file_id) b
where a.file_id=b.file_id(+)
group by a.tablespace_name order by a.tablespace_name;
