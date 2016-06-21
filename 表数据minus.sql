drop table dang_cen1_tiqian;
create table dang_cen1_tiqian
(old_owner varchar2(30),
table_name varchar2(30),
new_owner varchar2(30)
);
drop table dang_cen1_tiqian_minus;
create table dang_cen1_tiqian_minus
(old_owner varchar2(30),
new_owner varchar2(30),
table_name varchar2(30),
zhun_cnt number,
prod_cnt number,
minus_zhun_prod number,
minus_prod_zhun number,
minus_date date,
result_info  varchar2(1000),
err_sql  varchar2(1000),
);

truncate table dang_cen1_tiqian;
select a.*,a.rowid 
from dang_cen1_tiqian a;

update dang_cen1_tiqian
set table_name=trim(table_name);

update dang_cen1_tiqian
set old_owner='UCR_PARAM',
    NEW_owner='FUYL_PARAM';

truncate table dang_cen1_tiqian_minus;
insert into dang_cen1_tiqian_minus (old_owner,new_owner,table_name)
select old_owner,new_owner,table_name from dang_cen1_tiqian;


CREATE OR REPLACE PROCEDURE param_minus_1
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
IS
  iv_tablename  varchar2(40);
  iv_sql        varchar2(2000);
  iv_cur_count  NUMBER;
  iv_base_count NUMBER;
  iv_minus_z    NUMBER;
  iv_minus_f    NUMBER;
  iv_exp_info   VARCHAR2(2000);
  iv_dealDate NUMBER;
  iv_rowcount NUMBER ;
BEGIN
   v_resultcode := 0;
   v_resulterrinfo := '正确执行！';
  DECLARE
     CURSOR cur_tables IS select * from dang_cen1_tiqian;
     c_row cur_tables%rowtype;
  BEGIN
    iv_sql := 'SELECT to_number(to_char(SYSDATE,''yyyymmdd'')) FROM dual';
    --dbms_output.put_line(iv_sql);
    execute immediate iv_sql into iv_dealDate;

    OPEN cur_tables;
        LOOP
            <<next>>
            iv_cur_count := 0;
            iv_base_count := 0;
            iv_minus_f := 0;
            iv_minus_z := 0;
            FETCH cur_tables INTO c_row;
            EXIT WHEN cur_tables%NOTFOUND;
             iv_tablename := c_row.table_name;
             iv_sql := 'select COUNT(1) from dang_cen1_tiqian_minus a where a.table_name = '''||iv_tablename||''''||' and zhun_cnt is not null';
             EXECUTE IMMEDIATE iv_sql INTO iv_rowcount;
             IF iv_rowcount > 0 THEN
               GOTO NEXT;
             END IF;

             BEGIN
             iv_sql := 'select /*+parallel(a,10)*/ count(1) from '||c_row.new_owner||'.'||iv_tablename|| ' a';
             --dbms_output.put_line(iv_sql);
             execute immediate iv_sql into iv_cur_count;


             iv_sql := 'select /*+parallel(a,10)*/ count(1) from '||c_row.old_owner||'.'||iv_tablename|| '@dblnk_prod_cendb21 a';
             --dbms_output.put_line(iv_sql);
             execute immediate iv_sql into iv_base_count;


             update dang_cen1_tiqian_minus
       set zhun_cnt=iv_cur_count,
         prod_cnt=iv_base_count
       where table_name=iv_tablename;
             COMMIT;


             iv_sql := 'select count(1) from (' ||
                   'select * from '||c_row.new_owner||'.' || iv_tablename || ' b minus ' ||
                   'select * from '||c_row.old_owner||'.' || iv_tablename || '@dblnk_prod_cendb21 c) a';
             --dbms_output.put_line(iv_sql);
             execute immediate iv_sql into iv_minus_z;


             iv_sql := 'select count(1) from (' ||
                   'select * from '||c_row.old_owner||'.' || iv_tablename || '@dblnk_prod_cendb21 minus ' ||
                   'select * from '||c_row.new_owner||'.' || iv_tablename || ')';
             --dbms_output.put_line(iv_sql);
             execute immediate iv_sql into iv_minus_f;


             update dang_cen1_tiqian_minus
       set minus_zhun_prod=iv_minus_z,
         minus_prod_zhun=iv_minus_f,
         minus_date=sysdate
       where table_name=iv_tablename;
             COMMIT;

             EXCEPTION
             WHEN OTHERS THEN
               iv_exp_info := SUBSTR(SQLERRM,1,1000);
               update dang_cen1_tiqian_minus
         set result_info=iv_exp_info,
             err_sql=iv_sql
         where table_name=iv_tablename;
             COMMIT;

               NULL;
             END;
        END LOOP;
     CLOSE cur_tables;
  END;
END;

