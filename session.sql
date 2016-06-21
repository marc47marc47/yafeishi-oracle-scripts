select status,event ,count(*) from v$session group by status,event ;

SELECT a.USERNAME,COUNT(*) 
FROM v$session a
--WHERE a.STATUS='ACTIVE' 
GROUP BY a.USERNAME
ORDER BY 2 DESC; 

SELECT a.MACHINE,COUNT(*) 
FROM v$session a
--WHERE a.USERNAME='UOP_CRM1' 
GROUP BY a.MACHINE
ORDER BY 2 DESC; 
