set lin 1000
select a.tablespace_name,a.file_name,b.creation_time from dba_data_files a, v$datafile b 
where a.file_name=b.name and a.tablespace_name like '&tablespace_name' order by 1,3;
