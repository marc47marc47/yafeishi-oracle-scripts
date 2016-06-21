
SET markup html ON spool ON pre off entmap off

set term on
set heading on
set verify off
set feedback off

set linesize 2000
set pagesize 30000
set long 999999999
set longchunksize 999999

column index_name format a30
column table_name format a30
column num_rows format 999999999
column index_type format a24
column num_rows format 999999999
column status format a8
column clustering_factor format 999999999
column degree format a10
column blevel format 9
column distinct_keys format 9999999999
column leaf_blocks format   9999999
column last_analyzed    format a10
column column_name format a25
column column_position format 9
column temporary format a2
column partitioned format a5
column partitioning_type format a7
column partition_count format 999
column program  format a30
column spid  format a6
column pid  format 99999
column sid  format 99999
column serial# format 99999
column username  format a12
column osuser    format a12
column logon_time format  date
column event    format a32
column JOB_NAME        format a30
column PROGRAM_NAME    format a32
column STATE           format a10
column window_name           format a30
column repeat_interval       format a60
column machine format a30
column program format a30
column osuser format a15
column username format a15
column event format a50
column seconds format a10
column sqltext format a100



set term on
prompt "input schema:"
define S_SCHEMA=&SCHEMA
set term off

column dbid new_value spool_dbid
column inst_num new_value spool_inst_num
select dbid from v$database where rownum = 1;
select instance_number as inst_num from v$instance where rownum = 1;
column spoolfile_name new_value spoolfile
select 'spool_'||(select name from v$database where rownum=1) ||'_'|| (select instance_name from v$instance where rownum=1)||'_'||to_char(sysdate,'yy-mm-dd_hh24.mi')||'_static' as spoolfile_name from dual;
spool &&spoolfile..html


prompt <p>�汾
select * from v$version;



prompt <p> ���ο���Oracle���в��� 
show parameter


prompt <p>���һ������ʱ�䣬�汾���Լ��Ƿ�RAC
select version,startup_time,instance_name,archiver,parallel from v$instance ;

prompt <p>���д����ж�
select t.owner, t.table_name, degree
  from dba_tables t
where t.degree > '1';

prompt <p>�����д����ж�
select t.owner, t.table_name, index_name, degree, status
  from dba_indexes t
where t.degree > '1';

prompt <p>ʧЧ-��ͨ���� 
select t.index_name,
       t.table_name,
       blevel,
       t.num_rows,
       t.leaf_blocks,
       t.distinct_keys
  from dba_indexes t
  where status = 'UNUSABLE';

prompt <p>ʧЧ-��������
select t2.owner,
       t1.blevel,
       t1.leaf_blocks,
       t1.INDEX_NAME,
       t2.table_name,
       t1.PARTITION_NAME,
       t1.STATUS
  from dba_ind_partitions t1, dba_indexes t2
where t1.index_name = t2.index_name
   and t1.STATUS = 'UNUSABLE';
   

prompt <p>ʧЧ����
select t.owner,
       t.object_type,
       t.object_name,
       'alter ' ||decode(object_type, 'PACKAGE BODY', 'PACKAGE', 'TYPE BODY','TYPE',object_type) || ' ' ||owner || '.' || object_name || ' ' ||decode(object_type, 'PACKAGE BODY', 'compile body', 'compile') || ';' hands_on
  from dba_objects t
 where  STATUS='INVALID'
 and owner ='&S_SCHEMA'
 order by 1, 2;


 
prompt <p>λͼ�����ͺ�������
select t.owner,
       t.table_name,
       t.index_name,
       t.index_type,
       t.status,
       t.blevel,
       t.leaf_blocks
  from dba_indexes t  
where  owner = '&S_SCHEMA'
  and index_type in ('BITMAP', 'FUNCTION-BASED NORMAL');

prompt <p>�����������г���4����
select table_owner,table_name, index_name, count(*)
  from dba_ind_columns
  where table_owner ='&S_SCHEMA'
 group by table_owner,table_name, index_name
having count(*) >= 4
 order by count(*) desc
 
prompt <p>���������ֳ���5���� 
select owner,table_name, count(*) cnt
  from dba_indexes
where owner ='&S_SCHEMA'
 group by owner,table_name
having count(*) >= 5
order by cnt desc 

prompt <p>��ǰ�û��£���Щ����δ����������
--�����ͨ������2GB�ı�δ���κ�������

select segment_name, bytes/1024/1024/1024 "GB", blocks, tablespace_name
  from dba_segments
 where segment_type = 'TABLE'
   and owner = '&S_SCHEMA'
   and segment_name not in (select table_name from dba_indexes where owner='&S_SCHEMA')
   and bytes / 1024 / 1024 / 1024 >= 2
 order by GB desc;
   
   
--��Է���������2GB�ķ�����δ���κ�������
--�����ǽ��˾ֲ���������ȫ����������dba_indexes�����Բ鵽��ֻ��status��һ����
select segment_name, sum(bytes)/1024/1024/1024 "GB", sum(blocks)
  from dba_segments 
 where segment_type = 'TABLE PARTITION'
   and owner = '&S_SCHEMA'
   and segment_name not in (select table_name from dba_indexes where owner='&S_SCHEMA')
   group by segment_name
   having sum(bytes)/1024/1024/1024>=2
 order by GB desc;
 
prompt <p>��ǰ�û��£���Щ�����������뵥���������ڽ���������
select table_name, trunc(count(distinct(column_name)) / count(*),2) cross_idx_rate
  from dba_ind_columns
 where index_owner = '&S_SCHEMA'
 group by table_name
having count(distinct(column_name)) / count(*) < 1
order by cross_idx_rate desc;

prompt <p>��ǰ�û��£���Щ�����������ϵͳ��ռ��ϡ�
select table_name,owner from  dba_tables  where tablespace_name in('SYSTEM','SYSAUX') and owner='&S_SCHEMA';

prompt <p>��ǰ�û��£���Щ��������ϵͳ��ռ��ϡ�
select index_name,owner from  dba_indexes where tablespace_name in('SYSTEM','SYSAUX') and owner='&S_SCHEMA';

 
prompt <p>���ͳ����Ϣ�Ƿ��ռ�
--10g
select t.job_name,t.program_name,t.state,t.enabled
  from dba_scheduler_jobs t
where job_name = 'GATHER_STATS_JOB';

--11g
select client_name,status from dba_autotask_client;
select window_next_time,autotask_status from DBA_AUTOTASK_WINDOW_CLIENTS;

prompt <p>�����Щδ���ռ����ߺܾ�û�ռ�
select owner, count(*)
  from dba_tab_statistics t
where (t.last_analyzed is null or t.last_analyzed < sysdate - 100)
   and table_name not like 'BIN$%'
group by owner
order by owner;

prompt <p>���ռ�ͳ����Ϣ����ʱ��
select owner, table_name, t.last_analyzed, t.num_rows, t.blocks
  from dba_tables t
where t.temporary = 'Y'
   and last_analyzed is not null;
  
prompt <p>��־�л�Ƶ�ʷ���(ע��۲������first_time֮���ʱ�����᲻��̣ܶ��ܶ̾����л���Ƶ����
select *
  from (select thread#, sequence#, to_char(first_time, 'MM/DD/RR HH24:MI:SS')
          from v$log_history
         order by first_time desc)
 where rownum <= 50;

prompt <p>���10����ÿ����־�л�����(���ɷ���10��Ĳ��ȣ��ֿɷ���24Сʱ�ڣ��ɺ����׿����쳣���)
SELECT SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) Day,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20, 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22 , 
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23, 
       COUNT(*) TOTAL 
FROM v$log_history  a  
   where first_time>=to_char(sysdate-11)
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) 
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) DESC;



prompt <p>��־���С
select group#,bytes,status from v$log;

prompt <p>�鿴ARCHIVELOG��־ʹ���ʣ������۲�DB_RECOVERY_FILE_DEST_SIZ�������������Կ���crosscheck archivelog all; delete expired archivelog all;��
 select substr(name, 1, 30) name,
        space_limit as quota,
        space_used as used,
        space_reclaimable as reclaimable,
        number_of_files as files
   from v$recovery_file_dest;
select * from V$FLASH_RECOVERY_AREA_USAGE;

  
prompt <p>�������С��20�������һ������£�����������1000���ң�����Ĭ�ϵ�20̫С�ˣ�

select sequence_owner,
       count(*) CNT,
       sum(case when t.cache_size <= 20 then 1 else 0 end ) CNT_LESS_20,
       sum(case when t.cache_size > 20 then 1 else 0 end ) CNT_MORE_20
  from dba_sequences t
 where sequence_owner ='&S_SCHEMA'
 group by sequence_owner;

select t.sequence_owner,
       t.sequence_name,
       t.cache_size,
       'alter sequence ' || t.sequence_owner || '.' || t.sequence_name ||
       ' cache 1000;'
  from dba_sequences t
where sequence_owner ='&S_SCHEMA'
   AND CACHE_SIZE <= 20;

prompt <p>��ռ�ʹ����� 
 SELECT A.TABLESPACE_NAME "��ռ���",
        A.TOTAL_SPACE "�ܿռ�(G)",
        NVL(B.FREE_SPACE, 0) "ʣ��ռ�(GB)",
        A.TOTAL_SPACE - NVL(B.FREE_SPACE, 0) "ʹ�ÿռ�(GB)",
        CASE WHEN A.TOTAL_SPACE=0 THEN 0 ELSE trunc(NVL(B.FREE_SPACE, 0) / A.TOTAL_SPACE * 100, 2) END "ʣ��ٷֱ�%" --�����ĸΪ0
  FROM (SELECT TABLESPACE_NAME, trunc(SUM(BYTES) / 1024 / 1024/1024 ,2) TOTAL_SPACE
          FROM DBA_DATA_FILES
         GROUP BY TABLESPACE_NAME) A,
       (SELECT TABLESPACE_NAME, trunc(SUM(BYTES / 1024 / 1024/1024  ),2) FREE_SPACE
          FROM DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) B
 WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME(+)
 ORDER BY 5;

prompt <p>�����û��ж��һ�����ֵBOSSWG)
select sum(bytes)/1024 /1024 /1024 "GB"
  from dba_segments
 where owner = '&S_SCHEMA';
 
prompt <p>�����СTOP10
select *
  from (select owner,
               segment_name,
               segment_type,
               round(sum(bytes) / 1024 / 1024) object_size
          from DBA_segments
         group by owner, segment_name, segment_type
         order by object_size desc)
where rownum <= 10;

prompt <p>����վ���(��С�������� 

select *
  from (select SUM(BYTES) / 1024 / 1024 / 1024 as recyb_size
          from DBA_SEGMENTS
         WHERE owner = '&S_SCHEMA'
           AND SEGMENT_NAME LIKE 'BIN$%') a,
       (select count(*) as recyb_cnt from dba_recyclebin);
   



prompt <p>���С����10GBδ��������
select owner,
       segment_name,
       segment_type,
       sum(bytes) / 1024 / 1024 / 1024 object_size
  from dba_segments
where owner ='&S_SCHEMA'
  and segment_type = 'TABLE'
group by owner, segment_name, segment_type
having sum(bytes) / 1024 / 1024 / 1024 >= 10
order by object_size desc;

prompt <p>��������ǰ10������
select *
  from (select table_owner, table_name, count(*) cnt
          from dba_tab_partitions
         WHERE table_owner ='&S_SCHEMA'
         group by table_owner, table_name
         order by cnt desc)
where rownum <= 10;

prompt <p>������������100���ı�
select table_owner, table_name, count(*) cnt
  from dba_tab_partitions
WHERE table_owner ='&S_SCHEMA' 
having count(*) >= 100
group by table_owner, table_name
order by cnt desc;

prompt <p>������

select OWNER, TRIGGER_NAME, TABLE_NAME, STATUS
  from dba_triggers
 where owner ='&S_SCHEMA';


prompt <p>�����δ������������г� 
select table_name,
       constraint_name,
       cname1 || nvl2(cname2, ',' || cname2, null) ||
       nvl2(cname3, ',' || cname3, null) ||
       nvl2(cname4, ',' || cname4, null) ||
       nvl2(cname5, ',' || cname5, null) ||
       nvl2(cname6, ',' || cname6, null) ||
       nvl2(cname7, ',' || cname7, null) ||
       nvl2(cname8, ',' || cname8, null) columns
  from (select b.table_name,
               b.constraint_name,
               max(decode(position, 1, column_name, null)) cname1,
               max(decode(position, 2, column_name, null)) cname2,
               max(decode(position, 3, column_name, null)) cname3,
               max(decode(position, 4, column_name, null)) cname4,
               max(decode(position, 5, column_name, null)) cname5,
               max(decode(position, 6, column_name, null)) cname6,
               max(decode(position, 7, column_name, null)) cname7,
               max(decode(position, 8, column_name, null)) cname8,
               count(*) col_cnt
          from (select substr(table_name, 1, 30) table_name,
                       substr(constraint_name, 1, 30) constraint_name,
                       substr(column_name, 1, 30) column_name,
                       position
                  from dba_cons_columns where owner='&S_SCHEMA') a,
               dba_constraints b
         where a.constraint_name = b.constraint_name
           and b.constraint_type = 'R'        
           and b.owner='&S_SCHEMA'       
         group by b.table_name, b.constraint_name) cons
 where col_cnt > ALL
 (select count(*)
          from dba_ind_columns i
         where i.table_name = cons.table_name
           and i.column_name in (cname1, cname2, cname3, cname4, cname5,
                cname6, cname7, cname8)
           and i.column_position <= cons.col_cnt
           and i.index_owner='&S_SCHEMA'
         group by i.index_name);

 
 




