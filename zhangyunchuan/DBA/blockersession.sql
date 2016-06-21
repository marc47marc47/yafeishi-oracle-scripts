SELECT S.SID,
       S.USERNAME,
       S.STATUS,
       W.EVENT,
       L.TYPE,
       L.ID1,
       L.ID2,
       L.LMODE,
       L.CTIME,
       L.BLOCK
    FROM V$SESSION S, V$SESSION_WAIT W, V$LOCK L
   WHERE S.SID = W.SID
    AND S.SID = L.SID
    AND L.BLOCK > 0;
