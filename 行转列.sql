WITH x AS
 (SELECT 1 nu, 'a' AS str
    FROM dual
  UNION ALL
  SELECT 1 nu, 'b' AS str
    FROM dual
  UNION ALL
  SELECT 1 nu, 'c' AS str
    FROM dual
  UNION ALL
  SELECT 2 nu, 'd' AS str
    FROM dual
  UNION ALL
  SELECT 2 nu, 'e' AS str
    FROM dual),
x1 AS
 (SELECT nu, str, row_number() over(PARTITION BY nu ORDER BY str) rn FROM x)
SELECT nu,
       MAX(CASE
             WHEN rn = 1 THEN
              str
           END) str1,
       MAX(CASE
             WHEN rn = 2 THEN
              str
           END) str2,
       MAX(CASE
             WHEN rn = 3 THEN
              str
           END) str3
  FROM x1
 GROUP BY nu;
 
---------------------------------------------------------------------------------------
with tmp as
(select trade_id,head1, row_number() over( partition by trade_id order by head1) rn from aab_report_head)
SELECT trade_id,
       MAX(CASE
             WHEN rn = 1 THEN
              head1
           END) param1,
       MAX(CASE
             WHEN rn = 2 THEN
              head1
           END) param2,
       MAX(CASE
             WHEN rn = 3 THEN
              head1
           END) param3,
       MAX(CASE
             WHEN rn = 4 THEN
              head1
           END) param4,
       MAX(CASE
             WHEN rn = 5 THEN
              head1
           END) param5        
  FROM tmp
 GROUP BY trade_id; 
