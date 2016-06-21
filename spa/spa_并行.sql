spa在执行的时候，是从sqlset中取出一条sql执行一条，这样不仅没有模拟到
真实的生产情况，而且新库的性能也没充分利用。故考虑并行执行sqlset中的sql。
基本思路：
1. 拆分sqlset为32份：
DECLARE
  L_CURR_TABLE_TIPS   NUMBER   :=0;
BEGIN
  FOR X IN (SELECT sql_id FROM SQLSET_TAB_20141003 ORDER BY ELAPSED_TIME/EXECUTIONS) LOOP
    UPDATE SQLSET_TAB_20141003 SET NAME='SQLSET_20141003_'||L_CURR_TABLE_TIPS WHERE sql_id = X.sql_id;
    L_CURR_TABLE_TIPS := MOD(L_CURR_TABLE_TIPS + 1, 32);
  END LOOP;
END;
/

2. 产生批量创建和删除并行SQL Set Table的语句
select 'create table SQLSET_TAB_20141003_'||(ROWNUM-1)|| '
        NESTED TABLE "BIND_LIST" STORE AS "SQLSET_TAB_20141003_B_'||(ROWNUM-1)||'"
        NESTED TABLE "PLAN" STORE AS "SQLSET_TAB_20141003_P_'||(ROWNUM-1) || '"
        as select * from SQLSET_TAB_20141003 where name=''SQLSET_20141003_'||(ROWNUM-1)||''';'
  FROM dba_objects where rownum &lt;= 32;

select 'drop table SQLSET_TAB_20140507_'||(ROWNUM-1)|| ' purge;'
  FROM dba_objects where rownum &lt;= 32;
