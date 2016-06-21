PROCEDURE p_dcl_remove_method
(
  v_achannelid      IN NUMBER,
   v_resultcode      OUT NUMBER,
  v_resulterrinfo    OUT VARCHAR2
)
-----------------------------------------------------------------------
-- v_achannelid      dcl_id
-- v_ResultErrInfo   错误信息
-- v_ResultCode      -1 异常返回
--必须在建表用户编译存储过程
--对数据进行搬迁
--按照REMOVE_METHOD支持以下4种搬迁方式:
--1:按分区搬迁，此时REMOVE_CYCLE表示月份，按月执行：
--将table_name_s中的REMOVE_CYCLE前的分区交换到table_name_m，再从table_name_m交换到table_name_e
--2:直接根据remove_column字段delete，此时REMOVE_CYCLE表示天数，按天执行：
--将table_name_s中REMOVE_CYCLE天前的数据根据remove_column字段直接删除
--3:根据remove_column字段insert和delete方式搬迁数据，此时REMOVE_CYCLE表示天数，按天执行：
--将table_name_s中REMOVE_CYCLE天前的数据根据remove_column字段插入到table_name_e，然后再删除
--4:按分区truncate，此时REMOVE_CYCLE表示月份,按月执行：
--将table_name_s中的REMOVE_CYCLE前的分区truncate
--REMOVE_METHOD为'1'时采用以下方式搬迁
--数据存放方式，以tf_a_paylog为例：
--tm_a_paylog：普通表，在交换分区时使用
--tf_a_paylog：分区表，存放最近12个月分区的数据
--tf_ahb_paylog_2003：分区表，存放2004年以前的所有缴费记录
--tf_ahb_paylog_2004：分区表，存放2004年的分区缴费记录
--tf_ahb_paylog_2005：分区表，存放2005年的分区缴费记录
--tf_ahb_paylog_2006：分区表，存放2006年的分区缴费记录
--tf_ahb_paylog_2007：分区表，存放2007年的分区缴费记录
--tf_ahb_paylog_2008：分区表，存放2008年的分区缴费记录
--
--tm_a_paylog_d：普通表，在交换分区时使用
--tf_a_paylog_d：分区表，存放最近12个月分区的抵扣数据
--tf_ahb_paylog_d_2003：分区表，存放2004年以前的所有缴费抵扣记录
--tf_ahb_paylog_d_2004：分区表，存放2004年的分区缴费抵扣记录
--tf_ahb_paylog_d_2005：分区表，存放2005年的分区缴费抵扣记录
--tf_ahb_paylog_d_2006：分区表，存放2006年的分区缴费抵扣记录
--tf_ahb_paylog_d_2007：分区表，存放2007年的分区缴费抵扣记录
--tf_ahb_paylog_d_2008：分区表，存放2008年的分区缴费抵扣记录
--
--数据清理步骤：
--1、查询tf_a_paylog中12月前的分区和索引所在的表空间，使用以下语句：
--将tm_a_paylog移动到该表空间，并且将索引rebuild到该表空间
--2、将该分区切换到tm_a_paylog，要使用including indexes选项
--3、将tm_a_paylog中的数据切换到tf_ahb_paylog_200x，x表示切换的分区所在的年份，不使用including indexes选项,update global indexes
--
--注意：
--1、分区表必须全部是local索引，不能有全局索引
--2、销帐只需用到tf_a_paylog，其它表都不用访问
--3、日志查询也只查tf_a_paylog，查不到一年以前的缴费历史，除非直接访问tf_ahb_paylog_200x表
--4、同一套表包括在线、中间、历史表，必须建在同一个表空间上，否则交换分区后会落在别的表空间上
--5、tm表的索引必须和在线表的索引一致
--6、同一个表的索引的同一个分区必须建在同一个表空间上
--
--如果remove_column='SELECTALLDATA'，则切换分区时包括索引。
-----------------------------------------------------------------------
IS
    --iv_acyc_id      NUMBER(6);
    iv_cycle_id      NUMBER(6);
    v_table_name_s   td_s_dcl.table_name_s%TYPE;
    v_table_name_m   td_s_dcl.table_name_s%TYPE;
    v_table_name_e   td_s_dcl.table_name_s%TYPE;
    v_remove_cycle   td_s_dcl.remove_cycle%TYPE;
    v_remove_method   td_s_dcl.remove_method%TYPE;
    v_remove_column   td_s_dcl.remove_column%TYPE;
    v_last_update_time td_s_dcl.last_update_time%TYPE;
    iv_year          CHAR(4);
    iv_partition    NUMBER(2);
    iv_sql          VARCHAR2(1000);
    TYPE t_cursor    IS ref CURSOR;
    v_cursor          t_cursor;
    v_tablespace_name user_tab_partitions.tablespace_name%TYPE;
    v_i_tablespace_name user_tab_partitions.tablespace_name%TYPE;
    v_partition_name  user_tab_partitions.partition_name%TYPE;
    v_partition_name_e  user_tab_partitions.partition_name%TYPE;
    v_index_name      user_indexes.index_name%TYPE;
    iv_Cursor        NUMBER;
    iv_number        NUMBER(1);
    iv_RowCount      NUMBER;
    iv_RowCount_b    NUMBER;
    iv_RowCount_a    NUMBER;
    v_username      VARCHAR2(30);
BEGIN
  v_ResultCode:=0;
  v_ResultErrInfo:='存储过程正确执行';
  BEGIN
    SELECT upper(table_name_s),upper(table_name_m),upper(table_name_e),remove_cycle,remove_method,upper(remove_column),last_update_time
    INTO v_table_name_s,v_table_name_m,v_table_name_e,v_remove_cycle,v_remove_method,v_remove_column,v_last_update_time
    FROM td_s_dcl
    WHERE dcl_id=v_achannelid;
  EXCEPTION
    WHEN OTHERS THEN
    v_ResultCode:=-1;
    v_ResultErrInfo:=substrb('err_000:'||SQLERRM,1,80);
     RETURN;
  END;
   IF (v_remove_method='1' OR v_remove_method='4') AND (v_remove_cycle >12 OR v_remove_cycle <7)  THEN
    UPDATE td_s_dcl
    SET return_info='清理周期大于1年或者小于6个月，请检查参数!'
    WHERE dcl_id=v_achannelid;
    COMMIT;
     v_ResultCode:=-1;
    v_ResultErrInfo:='清理周期大于1年或者小于6个月，请检查参数!';
     RETURN;
  END IF;
   IF (v_remove_method='2' OR v_remove_method='3') AND (v_remove_cycle >365 OR v_remove_cycle <5) THEN
    UPDATE td_s_dcl
    SET return_info='清理周期大于1年或者小于5天，请检查参数!'
    WHERE dcl_id=v_achannelid;
    COMMIT;
     v_ResultCode:=-1;
    v_ResultErrInfo:='清理周期大于1年或者小于5天，请检查参数!';
     RETURN;
  END IF;
  IF (v_remove_method='1' OR v_remove_method='4') AND to_char(v_last_update_time,'yyyymm')=to_char(sysdate,'yyyymm') THEN
    UPDATE td_s_dcl
    SET return_info='本月已经运行过该清理，不再运行该清理!'
    WHERE dcl_id=v_achannelid;
    COMMIT;
--     v_ResultCode:=-1;
    v_ResultErrInfo:='本月已经运行过该清理，不再运行该清理!';
     RETURN;
  END IF;
  IF v_remove_method='1' THEN
    IF v_table_name_s is null or v_table_name_m is null or v_table_name_e is null or v_remove_cycle is null or (v_remove_column is not null and v_remove_column<>'SELECTALLDATA') THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:='参数配置错误，请检查参数!';
       RETURN;
    END IF;
    --找出需要搬迁的分区
    BEGIN
--       SELECT bcyc_id,acyc_id INTO iv_cycle_id,iv_acyc_id
--       FROM td_a_acycpara
--       WHERE acyc_id =(SELECT acyc_id-v_remove_cycle+1
--                       FROM td_a_acycpara
--                       WHERE acyc_start_time<=sysdate
--                        AND  acyc_end_time>=sysdate);
      --iv_acyc_id := to_number(substr(to_char(sysdate,'yyyymm')-198000,1,length(to_char(sysdate,'yyyymm')-198000)-2))*12+substr(to_char(sysdate,'yyyymm')-198000,-2,2)-v_remove_cycle+1;
      iv_cycle_id := to_char(add_months(sysdate,-v_remove_cycle+1),'yyyymm');
       iv_year := substr(iv_cycle_id,1,4);
       iv_partition := to_number(substr(iv_cycle_id,5,2));
    EXCEPTION
       WHEN OTHERS THEN
       v_ResultCode:=-1;
       v_ResultErrInfo:=substrb('err_00a:'||SQLERRM,1,80);
       RETURN;
    END;
    --将中间表的表空间移到相应的分区所在的表空间
    BEGIN
      SELECT tablespace_name,partition_name
      INTO v_tablespace_name,v_partition_name
      FROM user_tab_partitions
      WHERE table_name=v_table_name_s
        AND partition_position=iv_partition;
      SELECT partition_name
      INTO v_partition_name_e
      FROM user_tab_partitions
      WHERE table_name=v_table_name_e||'_'||iv_year
        AND partition_position=iv_partition;
      BEGIN
        iv_Cursor:=DBMS_SQL.OPEN_CURSOR;
        iv_Sql:='select /*+ full(b) */ count(*) a from '||v_table_name_m||' b where rownum<2 ';
        DBMS_SQL.PARSE(iv_cursor,iv_SQL,DBMS_SQL.V7);
        DBMS_SQL.DEFINE_COLUMN(iv_cursor,1,iv_number);
        iv_rowcount := DBMS_SQL.EXECUTE(iv_cursor);
        IF DBMS_SQL.FETCH_ROWS(iv_cursor) > 0 THEN
          DBMS_SQL.COLUMN_VALUE(iv_cursor,1,iv_number);
        ELSE
          iv_number := 0;
        END IF;
         DBMS_SQL.CLOSE_CURSOR(iv_Cursor);
        IF iv_number <> 0 THEN
          UPDATE td_s_dcl
          SET return_info='中间表或者历史分区表已经有数据了，请检查!'
          WHERE dcl_id=v_achannelid;
          COMMIT;
           v_ResultCode:=-1;
          v_ResultErrInfo:='中间表或者历史分区表已经有数据了，请检查!';
          RETURN;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
         DBMS_SQL.CLOSE_CURSOR(iv_Cursor);
         v_ResultCode:=-1;
        v_ResultErrInfo:=substrb('err_00b:'||SQLERRM,1,80);
        RETURN;
      END;
      BEGIN
        iv_Cursor:=DBMS_SQL.OPEN_CURSOR;
        iv_Sql:='select /*+ full(b) */ count(*) a from '||v_table_name_e||'_'||iv_year||' partition ('||v_partition_name_e||') b where rownum<2';
        DBMS_SQL.PARSE(iv_cursor,iv_SQL,DBMS_SQL.V7);
        DBMS_SQL.DEFINE_COLUMN(iv_cursor,1,iv_number);
        iv_rowcount := DBMS_SQL.EXECUTE(iv_cursor);
        IF DBMS_SQL.FETCH_ROWS(iv_cursor) > 0 THEN
          DBMS_SQL.COLUMN_VALUE(iv_cursor,1,iv_number);
        ELSE
          iv_number := 0;
        END IF;
         DBMS_SQL.CLOSE_CURSOR(iv_Cursor);
        IF iv_number <> 0 THEN
          UPDATE td_s_dcl
          SET return_info='中间表或者历史分区表已经有数据了，请检查!'
          WHERE dcl_id=v_achannelid;
          COMMIT;
           v_ResultCode:=-1;
          v_ResultErrInfo:='中间表或者历史分区表已经有数据了，请检查!';
          RETURN;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
         DBMS_SQL.CLOSE_CURSOR(iv_Cursor);
         v_ResultCode:=-1;
        v_ResultErrInfo:=substrb('err_00bb:'||SQLERRM,1,80);
        RETURN;
      END;
      --删除中间表分析数据
      BEGIN
        SELECT username
        INTO v_username
        FROM user_users;
        iv_sql := 'begin dbms_stats.delete_table_stats('''||v_username||''','''||v_table_name_m||'''); end;';
        EXECUTE IMMEDIATE iv_sql;
      EXCEPTION
         WHEN OTHERS THEN
        v_ResultCode:=-1;
        v_ResultErrInfo:=substrb('err_00c:'||SQLERRM,1,80);
        UPDATE td_s_dcl
        SET return_info=v_ResultErrInfo
        WHERE dcl_id=v_achannelid;
        COMMIT;
        RETURN;
      END;
      iv_sql := 'alter table '||v_table_name_m||' move tablespace '||v_tablespace_name;
      EXECUTE IMMEDIATE iv_sql;
      --找出分区表的索引所在的表空间
       BEGIN
         SELECT index_name
         INTO v_index_name
         FROM user_indexes
         WHERE table_name=v_table_name_s
           AND rownum<2;
        SELECT tablespace_name
        INTO v_i_tablespace_name
        FROM user_ind_partitions
         WHERE index_name=v_index_name
          AND partition_position=iv_partition;
      EXCEPTION
         WHEN OTHERS THEN
        GOTO label1;
      END;
      --将中间表的索引表空间移到相应的分区所在的表空间
       OPEN v_cursor FOR
         SELECT index_name
         FROM user_indexes
        WHERE table_name=v_table_name_m;
      LOOP
         FETCH v_cursor INTO v_index_name;
         EXIT WHEN v_cursor%notfound;
        iv_sql := 'alter index '||v_index_name||' rebuild tablespace '||v_i_tablespace_name;
        EXECUTE IMMEDIATE iv_sql;
       END LOOP;
       CLOSE v_cursor;
      <<label1>>
      --将分区表的分区和中间表进行交换
      iv_sql := 'alter table '||v_table_name_s||' exchange partition '||v_partition_name||' with table '||v_table_name_m||' including indexes';
      EXECUTE IMMEDIATE iv_sql;
      --将历史分区表的分区和中间表进行交换
      IF v_remove_column='SELECTALLDATA' then
        iv_sql := 'alter table '||v_table_name_e||'_'||iv_year||' exchange partition '||v_partition_name_e||' with table '||v_table_name_m||' excluding indexes';
        EXECUTE IMMEDIATE iv_sql;
        iv_sql := 'alter table '||v_table_name_e||'_'||iv_year||' modify partition '||v_partition_name_e||' rebuild unusable local indexes';
        EXECUTE IMMEDIATE iv_sql;
      ELSE
        iv_sql := 'alter table '||v_table_name_e||'_'||iv_year||' exchange partition '||v_partition_name_e||' with table '||v_table_name_m;
        EXECUTE IMMEDIATE iv_sql;
        iv_sql := 'alter table '||v_table_name_e||'_'||iv_year||' modify partition '||v_partition_name_e||' rebuild unusable local indexes';
        EXECUTE IMMEDIATE iv_sql;
      END IF;
      UPDATE td_s_dcl
      SET return_info='成功执行',last_update_time=sysdate
      WHERE dcl_id=v_achannelid;
      COMMIT;
      RETURN;
    EXCEPTION
       WHEN OTHERS THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:=substrb('err_002:'||SQLERRM,1,80);
      UPDATE td_s_dcl
      SET return_info=v_ResultErrInfo
      WHERE dcl_id=v_achannelid;
      COMMIT;
      RETURN;
    END;
  END IF;
  IF v_remove_method='2' THEN
    IF v_table_name_s is null or v_remove_cycle is null or v_remove_column is null or v_table_name_m is not null or v_table_name_e is not null THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:='参数配置错误，请检查参数!';
       RETURN;
    END IF;
    BEGIN
      iv_sql := 'delete from '||v_table_name_s||' where '||v_remove_column||'<=trunc(sysdate)-'||v_remove_cycle;
       EXECUTE IMMEDIATE iv_sql;
      UPDATE td_s_dcl
      SET return_info='成功执行',last_update_time=sysdate
      WHERE dcl_id=v_achannelid;
      COMMIT;
    EXCEPTION
       WHEN OTHERS THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:=substrb('err_002:'||SQLERRM,1,80);
      UPDATE td_s_dcl
      SET return_info=v_ResultErrInfo,last_update_time=sysdate
      WHERE dcl_id=v_achannelid;
      COMMIT;
    END;
  END IF;
  IF v_remove_method='3' THEN
    IF v_table_name_s is null or v_table_name_e is null or v_remove_cycle is null or v_remove_column is null or v_table_name_m is not null THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:='参数配置错误，请检查参数!';
       RETURN;
    END IF;
    BEGIN
      iv_sql := 'insert into '||v_table_name_e||
                ' select * from '||v_table_name_s||
                ' where '||v_remove_column||'<=trunc(sysdate)-'||v_remove_cycle;
           EXECUTE IMMEDIATE iv_sql;
      iv_RowCount_b:=SQL%ROWCOUNT;
      iv_sql := 'delete from '||v_table_name_s||' where '||v_remove_column||'<=trunc(sysdate)-'||v_remove_cycle;
           EXECUTE IMMEDIATE iv_sql;
      iv_RowCount_a:=SQL%ROWCOUNT;
      IF iv_RowCount_b=iv_RowCount_a THEN
        UPDATE td_s_dcl
        SET return_info='成功执行',last_update_time=sysdate
        WHERE dcl_id=v_achannelid;
        COMMIT;
        RETURN;
      ELSE
        ROLLBACK;
        UPDATE td_s_dcl
        SET return_info='插入数据和删除数据不等，退出!'
        WHERE dcl_id=v_achannelid;
        COMMIT;
         v_ResultCode:=-1;
        v_ResultErrInfo:='插入数据和删除数据不等，退出';
         RETURN;
      END IF;
    EXCEPTION
       WHEN OTHERS THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:=substrb('err_002:'||SQLERRM,1,80);
      ROLLBACK;
      UPDATE td_s_dcl
      SET return_info=v_ResultErrInfo,last_update_time=sysdate
      WHERE dcl_id=v_achannelid;
      COMMIT;
    END;
  END IF;
  IF v_remove_method='4' THEN
    IF v_table_name_s is null or v_remove_cycle is null or v_table_name_m is not null or v_table_name_e is not null or v_remove_column is not null THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:='参数配置错误，请检查参数!';
       RETURN;
    END IF;
    --找出需要清除的分区
    BEGIN
--       SELECT bcyc_id,acyc_id INTO iv_cycle_id,iv_acyc_id
--       FROM td_a_acycpara
--       WHERE acyc_id =(SELECT acyc_id-v_remove_cycle+1
--                       FROM td_a_acycpara
--                       WHERE acyc_start_time<=sysdate
--                        AND  acyc_end_time>=sysdate);
      --iv_acyc_id := to_number(substr(to_char(sysdate,'yyyymm')-198000,1,length(to_char(sysdate,'yyyymm')-198000)-2))*12+substr(to_char(sysdate,'yyyymm')-198000,-2,2)-v_remove_cycle+1;
      iv_cycle_id := to_char(add_months(sysdate,-v_remove_cycle+1),'yyyymm');
       iv_year := substr(iv_cycle_id,1,4);
       iv_partition := to_number(substr(iv_cycle_id,5,2));
    EXCEPTION
       WHEN OTHERS THEN
       v_ResultCode:=-1;
       v_ResultErrInfo:=substrb('err_00a:'||SQLERRM,1,80);
       RETURN;
    END;
    BEGIN
      SELECT tablespace_name,partition_name
      INTO v_tablespace_name,v_partition_name
      FROM user_tab_partitions
      WHERE table_name=v_table_name_s
        AND partition_position=iv_partition;
      iv_sql := 'alter table '||v_table_name_s||' truncate partition '||v_partition_name;
      EXECUTE IMMEDIATE iv_sql;
      UPDATE td_s_dcl
      SET return_info='成功执行',last_update_time=sysdate
      WHERE dcl_id=v_achannelid;
      COMMIT;
      RETURN;
    EXCEPTION
       WHEN OTHERS THEN
      v_ResultCode:=-1;
      v_ResultErrInfo:=substrb('err_002:'||SQLERRM,1,80);
      UPDATE td_s_dcl
      SET return_info=v_ResultErrInfo
      WHERE dcl_id=v_achannelid;
      COMMIT;
      RETURN;
    END;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    v_ResultCode:=-1;
    v_ResultErrInfo:=substrb('err_003:'||SQLERRM,1,80);
END;