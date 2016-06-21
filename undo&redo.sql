--- undo 产生量
SELECT cur_stat.snap_id CurID,
       prev_stat.snap_id PrevID,
       To_char(sn.begin_interval_time, 'YYYY-MM-DD HH24:MI') BeginTime,
       To_char(sn.end_interval_time, 'YYYY-MM-DD HH24:MI') EndTime,
       cur_stat.VALUE                       curval,
       prev_stat.VALUE                      prevval,
       ROUND(( cur_stat.VALUE - prev_stat.VALUE )/ 1024/1024 ,2) "UNDO Gen(MB/Hour)"
FROM   dba_hist_snapshot sn,
       ( SELECT snap_id, VALUE
        FROM   dba_hist_sysstat
        WHERE  stat_name = 'undo change vector size' ) cur_stat,
       ( SELECT snap_id,VALUE
        FROM   dba_hist_sysstat
        WHERE  stat_name = 'undo change vector size' ) prev_stat
WHERE  sn.snap_id = cur_stat.snap_id
       AND cur_stat.snap_id = prev_stat.snap_id + 1
       AND sn.begin_interval_time > sysdate -3
ORDER  BY 1;

---SELECT * FROM V$UNDOSTAT;

--当前时刻谁消耗了多少UNDO空间
SELECT SESS.SID,
       SESS.SERIAL#, 
       SESS.OSUSER, 
       SESS.USERNAME, 
       RSEG.SEGMENT_NAME SEGMENT, 
       RSEG.TABLESPACE_NAME, 
       TRANS.USED_UBLK, 
       TRANS.USED_UBLK * 8 "UNDO SIZE(KB)" ,
       RSEG.STATUS, 
       SA.SQL_TEXT
  FROM V$SESSION         SESS ,
       V$TRANSACTION     TRANS,
       DBA_ROLLBACK_SEGS RSEG, 
       V$SQL             SA
WHERE SESS.TADDR = TRANS.ADDR
   AND TRANS.XIDUSN = RSEG.SEGMENT_ID (+)
   AND (SESS.SQL_HASH_VALUE = SA.HASH_VALUE OR
       SESS.PREV_HASH_VALUE = SA.HASH_VALUE)
ORDER BY SQL_TEXT ;



 ALTER DATABASE ADD LOGFILE MEMBER
        '/dev/vx/rdsk/smpdg1/smpdg1_1_rd12' TO GROUP 1,
        '/dev/vx/rdsk/smpdg1/smpdg1_1_rd22' TO GROUP 2,
        '/dev/vx/rdsk/smpdg1/smpdg1_1_rd32' TO GROUP 3;


