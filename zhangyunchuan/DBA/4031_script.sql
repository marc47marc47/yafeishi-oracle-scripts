spool spinfo.txt
SET PAGESIZE 1024
SET LINESIZE 2000
set echo off;
set feedback off;
set heading on;
set trimout on;
set trimspool on;
COL BYTES FORMAT 999999999999999
COL CURRENT_SIZE FORMAT 999999999999999


/* Script Run TimeStamp */
set serveroutput on; 
exec dbms_output.put_line('Script Run TimeStamp');
select to_char(sysdate, 'dd-MON-yyyy hh24:mi:ss') "Script Run TimeStamp" from dual;

set serveroutput on; 
exec dbms_output.put_line('Instance Startup Time');


/*Instance Startup time */
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance;


/* shared pool related hidden parameter */
set serveroutput on; 
exec dbms_output.put_line('shared pool related hidden parameter ');

col name format a40
col value format a80;
select nam.ksppinm NAME,val.KSPPSTVL VALUE from x$ksppi nam,x$ksppsv val where nam.indx = val.indx and nam.ksppinm like '%shared%' order by 1;




/* SUB Pool Number */
set serveroutput on; 
exec dbms_output.put_line('SUB Pool Number ');
col 'Parameter' format a40
col 'Session Value' format a40;
col 'Instance Value' format a40;
select a.ksppinm "Parameter",
b.ksppstvl "Session Value",
c.ksppstvl "Instance Value"
from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c
where a.indx = b.indx and a.indx = c.indx
and a.ksppinm like '%_kghdsidx_count%';



/* Each Subpool Size */
set serveroutput on; 
exec dbms_output.put_line('Each Subpool Size');
select ksmchidx poolnumer , sum(ksmchsiz)  poolsize
from x$ksmsp
group by ksmchidx ;



/*  Researved Shared Pool 4031 information */
set serveroutput on; 
exec dbms_output.put_line('Researved Shared Pool 4031 information');
select REQUEST_FAILURES, LAST_FAILURE_SIZE from V$SHARED_POOL_RESERVED;


/* Reaserved Shared Pool Reserved 4031 information */
set serveroutput on; 
exec dbms_output.put_line('Reaserved Shared Pool 4031 information');
select REQUESTS, REQUEST_MISSES, free_space, avg_free_size, free_count, max_free_size from V$SHARED_POOL_RESERVED;


/* Current SGA Buffer & Pool sizes */
set serveroutput on; 
exec dbms_output.put_line('Current SGA Buffer Pool sizes');
select component, current_size from v$sga_dynamic_components;



/* Shared Pool Memory Allocations by Size */
set serveroutput on; 
exec dbms_output.put_line('Shared Pool Memory Allocations by Size');
select name, bytes from v$sgastat
where pool = 'shared pool' and (bytes > 999999 or name = 'free memory')
order by bytes desc;

set serveroutput on; 
exec dbms_output.put_line('show component of shared pool which is bigger than 10MB');

select name, round((bytes/1024/1024),0) "more than 10" from v$sgastat where pool='shared pool' and bytes > 10000000 order by bytes desc;

select sum(bytes) "SHARED POOL TOTAL SIZE" from v$sgastat where pool='shared pool';



/* Total Free of Shared Pool */
set serveroutput on; 
exec dbms_output.put_line('Total Free(not Free) of Shared Pool ');

COL 'Total Shared Pool Usage' FORMAT 999999999999999

select sum(bytes)/1024/1024 "Free MB in Shared Pool" from v$sgastat where pool = 'shared pool' and name = 'free memory';
select sum(bytes) "Not Free MB Shared Pool" from v$sgastat where pool = 'shared pool' and name != 'free memory';


/* current KGLH* usage */
set serveroutput on; 
exec dbms_output.put_line('current KGLH* usage');

select name, bytes from v$sgastat where pool = 'shared pool' and name in ('KGLHD','KGHL0');



/* Hisotry KGLH* usage */
set serveroutput on; 
exec dbms_output.put_line('Hisotry KGLH* usage');
select bytes/1024/1024 , s.snap_id, begin_interval_time START_TIME
  from dba_hist_sgastat g, dba_hist_snapshot s
  where name='KGLHD'
  and pool='shared pool'
  and trunc(begin_interval_time) >= '30-DEC-2011'
  and s.snap_id = g.snap_id
  order by 2;


set serveroutput on; 
exec dbms_output.put_line('Hisotry KGLH0* usage');
select bytes/1024/1024 , s.snap_id, begin_interval_time START_TIME
  from dba_hist_sgastat g, dba_hist_snapshot s
  where name='KGLH0'
  and pool='shared pool'
  and trunc(begin_interval_time) >= '30-DEC-2011'
  and s.snap_id = g.snap_id
  order by 2;
  


/*  History of Shared pool allocations in a speciifed Day*/
set serveroutput on; 
exec dbms_output.put_line('history of Shared pool allocations in a speciifed Day');
col name format a30
select n,
  max(decode(to_char(begin_interval_time, 'hh24'), 1,bytes, null)) "1",
  max(decode(to_char(begin_interval_time, 'hh24'), 2,bytes, null)) "2",
  max(decode(to_char(begin_interval_time, 'hh24'), 3,bytes, null)) "3",
  max(decode(to_char(begin_interval_time, 'hh24'), 4,bytes, null)) "4",
  max(decode(to_char(begin_interval_time, 'hh24'), 5,bytes, null)) "5",
  max(decode(to_char(begin_interval_time, 'hh24'), 6,bytes, null)) "6",
  max(decode(to_char(begin_interval_time, 'hh24'), 7,bytes, null)) "7",
  max(decode(to_char(begin_interval_time, 'hh24'), 8,bytes, null)) "8",
  max(decode(to_char(begin_interval_time, 'hh24'), 9,bytes, null)) "9",
  max(decode(to_char(begin_interval_time, 'hh24'), 10,bytes, null)) "10",
  max(decode(to_char(begin_interval_time, 'hh24'), 11,bytes, null)) "11",
  max(decode(to_char(begin_interval_time, 'hh24'), 12,bytes, null)) "12",
  max(decode(to_char(begin_interval_time, 'hh24'), 13,bytes, null)) "13",
  max(decode(to_char(begin_interval_time, 'hh24'), 14,bytes, null)) "14",
  max(decode(to_char(begin_interval_time, 'hh24'), 15,bytes, null)) "15",
  max(decode(to_char(begin_interval_time, 'hh24'), 16,bytes, null)) "16",
  max(decode(to_char(begin_interval_time, 'hh24'), 17,bytes, null)) "17",
  max(decode(to_char(begin_interval_time, 'hh24'), 18,bytes, null)) "18",
  max(decode(to_char(begin_interval_time, 'hh24'), 19,bytes, null)) "19",
  max(decode(to_char(begin_interval_time, 'hh24'), 20,bytes, null)) "20",
  max(decode(to_char(begin_interval_time, 'hh24'), 21,bytes, null)) "21",
  max(decode(to_char(begin_interval_time, 'hh24'), 22,bytes, null)) "22",
  max(decode(to_char(begin_interval_time, 'hh24'), 23,bytes, null)) "23",
  max(decode(to_char(begin_interval_time, 'hh24'), 24,bytes, null)) "24"
from (select '"'||name||'"' n, begin_interval_time, bytes from dba_hist_sgastat a, dba_hist_snapshot b
where pool='shared pool' and a.snap_id=b.snap_id
and to_char(begin_interval_time,'hh24:mi') between '01:00' and '24:00'
and to_char(begin_interval_time,'dd-mon')  = to_char(sysdate-1, 'dd-mon'))
group by n;



/* Each Subpool sumary usage for free memory , may slow ,it depends on custoemr database workload   */
set serveroutput on; 
exec dbms_output.put_line('Each Subpool sumary usage for free memory');
col subpool format a20
col name format a40
SELECT
        subpool
      , name
      , SUM(bytes)
      , ROUND(SUM(bytes)/1048576,2) MB
    FROM (
        SELECT
            'shared pool ('||DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx)||'):'      subpool
          , ksmssnam      name
         , ksmsslen      bytes
       FROM
           x$ksmss
       WHERE
           ksmsslen > 0
       AND LOWER(ksmssnam) LIKE LOWER('%free memory%')
   )
   GROUP BY
       subpool
     , name
   ORDER BY
       subpool    ASC
     , SUM(bytes) DESC ;
     


/* Memory  fragment and  chunk allocation like  0-1K,1-2K, may slow ,it depends on custoemr database workload */

set serveroutput on; 
exec dbms_output.put_line('Memory  fragment and  chunk allocation like  0-1K,1-2K');

col SubPool format 999
col mb format 999,999
col name heading "Name"

SELECT ksmchidx "SubPool",
       'sga heap(' || ksmchidx || ',0)' sga_heap,
       ksmchcom chunkcomment,
       DECODE(ROUND(ksmchsiz / 1000),
              0,
              '0-1K',
              1,
              '1-2K',
              2,
              '2-3K',
              3,
              '3-4K',
              4,
              '4-5K',
              5,
              '5-6k',
              6,
              '6-7k',
              7,
              '7-8k',
              8,
              '8-9k',
              9,
              '9-10k',
              '> 10K'
              ) "size",
       COUNT(*),
       ksmchcls status,
       SUM(ksmchsiz) BYTES
  FROM x$ksmsp
 WHERE ksmchcom = 'free memory'
 GROUP BY ksmchidx,
          ksmchcls,
          'sga heap(' || ksmchidx || ',0)',
          ksmchcom,
          ksmchcls,
          DECODE(ROUND(ksmchsiz / 1000),
                 0,
                 '0-1K',
                 1,
                 '1-2K',
                 2,
                 '2-3K',
                 3,
                 '3-4K',
                 4,
                 '4-5K',
                 5,
                 '5-6k',
                 6,
                 '6-7k',
                 7,
                 '7-8k',
                 8,
                 '8-9k',
                 9,
                 '9-10k',
                 '> 10K');


/* already commented, Each Subpool sumary usage in Detail ,might slow ,it depends on custoemr database workload */
/*
set serveroutput on; 
exec dbms_output.put_line('already commented, Each Subpool sumary usage in Detail');
col name format a40
SELECT
        subpool
      , name
      , SUM(bytes)
      , ROUND(SUM(bytes)/1048576,2) MB
    FROM (
        SELECT
            'shared pool ('||DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx)||'):'      subpool
          , ksmssnam      name
         , ksmsslen      bytes
       FROM
           x$ksmss
       WHERE
           ksmsslen > 0
   )
   GROUP BY
       subpool
     , name
   ORDER BY
       subpool    ASC
     , SUM(bytes) DESC;
*/
     
 
/* Already commented, Memory  fragment and  chunk allocation ,may slow ,it depends on custoemr database workload */
/*
set serveroutput on; 
exec dbms_output.put_line('Memory  fragment and  chunk allocation');
select
   '0 (<140)' BUCKET, KSMCHCLS, KSMCHIDX,
   10*trunc(KSMCHSIZ/10) "From",
   count(*) "Count" ,
   max(KSMCHSIZ) "Biggest",
   trunc(avg(KSMCHSIZ)) "AvgSize",
   trunc(sum(KSMCHSIZ)) "Total"
from
   x$ksmsp
where
   KSMCHSIZ<140
and
   KSMCHCLS='free'
group by
   KSMCHCLS, KSMCHIDX, 10*trunc(KSMCHSIZ/10)
UNION ALL
select
   '1 (140-267)' BUCKET,
   KSMCHCLS,
   KSMCHIDX,
   20*trunc(KSMCHSIZ/20) ,
   count(*) ,
   max(KSMCHSIZ) ,
   trunc(avg(KSMCHSIZ)) "AvgSize",
   trunc(sum(KSMCHSIZ)) "Total"
from
   x$ksmsp
where
   KSMCHSIZ between 140 and 267
and
   KSMCHCLS='free'
group by
   KSMCHCLS, KSMCHIDX, 20*trunc(KSMCHSIZ/20)
UNION ALL
select
   '2 (268-523)' BUCKET,
   KSMCHCLS,
   KSMCHIDX,
   50*trunc(KSMCHSIZ/50) ,
   count(*) ,
   max(KSMCHSIZ) ,
   trunc(avg(KSMCHSIZ)) "AvgSize",
   trunc(sum(KSMCHSIZ)) "Total"
from
   x$ksmsp
where
   KSMCHSIZ between 268 and 523
and
   KSMCHCLS='free'
group by
   KSMCHCLS, KSMCHIDX, 50*trunc(KSMCHSIZ/50)
UNION ALL
select
   '3-5 (524-4107)' BUCKET,
   KSMCHCLS,
   KSMCHIDX,
   500*trunc(KSMCHSIZ/500) ,
   count(*) ,
   max(KSMCHSIZ) ,
   trunc(avg(KSMCHSIZ)) "AvgSize",
   trunc(sum(KSMCHSIZ)) "Total"
from
   x$ksmsp
where
   KSMCHSIZ between 524 and 4107
and
   KSMCHCLS='free'
group by
   KSMCHCLS, KSMCHIDX, 500*trunc(KSMCHSIZ/500)
UNION ALL
select
   '6+ (4108+)' BUCKET,
   KSMCHCLS,
   KSMCHIDX,
   1000*trunc(KSMCHSIZ/1000) ,
   count(*) ,
   max(KSMCHSIZ) ,
   trunc(avg(KSMCHSIZ)) "AvgSize",
   trunc(sum(KSMCHSIZ)) "Total"
from
   x$ksmsp
where
   KSMCHSIZ >= 4108
and
   KSMCHCLS='free'
group by
   KSMCHCLS, KSMCHIDX, 1000*trunc(KSMCHSIZ/1000);
*/


     
/*  Already commented, Each Subpool detail allocation Size ,just a complement ,too many lines output, least important*/
/*
set serveroutput on; 
exec dbms_output.put_line('Already commented, Each Subpool detail allocation Size');

select  ksmchcom ChunkComment, ksmchcls Status, sum(ksmchsiz) Bytes
from x$ksmsp
group by ksmchcom, ksmchcls;
/*


/* current END time CLTTIME */

select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') "Script END TimeStamp"  from dual;


spool off;
