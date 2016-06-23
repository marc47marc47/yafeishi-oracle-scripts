-- Usage:      @sql_profile_plan sql_id child_no [true|false]
--
--              sql_id: the sql_id of the statement to attach the profile to (
-- must be in the shared pool)
--
--              child_no: the child_no of the statement from v$sql
-- 1. 查询需要绑profile的sql_id 和 child number.
-- 2. 新开一个session,执行 explain plan for
-- 3. 在 explain plan for 的session中 执行 
--    @sql_profile_plan sql_id child_no [true|false]
-- 4. 执行SQL进行验证.
--               
-- 目前 profilename: coe_sqlid_plan_hash_value 中 plan_hash_value来自于 bad plan hash value
-- import_sql_profile 中的参数 force_match  默认为 false ,可改为传参模式
--
--
--

SET feedback OFF
SET sqlblanklines ON
set verify off
set serveroutput on
PRO parameter 1 :bad_sql_id 
DEF bad_sql_id = '&1'
PRO parameter 2 :bad_child_no 
DEF bad_child_no = '&2'
PRO parameter 3 :force_matching 
DEF force_matching = '&3'

DECLARE
  ar_profile_hints sys.sqlprof_attr;
  cl_sql_text CLOB;
  l_profile_name VARCHAR2(200);
  l_plan_hash_value number(22);
  l_signature  VARCHAR2(200);
BEGIN
  DBMS_OUTPUT.ENABLE(200000);
  -- get good sql plan 
  SELECT
    extractvalue(value(d), '/hint') AS outline_hints bulk collect
  INTO
    ar_profile_hints
  FROM
    xmltable('/*/outline_data/hint' passing
    (
      SELECT
        xmltype(other_xml) AS xmlval
      FROM
        plan_table
      WHERE 1=1
      AND other_xml IS NOT NULL
    )
    ) d;

    
    -- get plan_hash_value
    select 
      plan_hash_value
    into 
      l_plan_hash_value
    from 
      v$sql
      WHERE
        sql_id         = '&&bad_sql_id'
      AND child_number =
        &&bad_child_no
        ;
    
    -- generate profile name    
    select 'yhem_'||'&&bad_sql_id'||'_'||to_char(l_plan_hash_value) 
    into  l_profile_name
    from dual;
    
  
  -- get bad sql text
  SELECT
    sql_fulltext
  INTO
    cl_sql_text
  FROM
    v$sql
  WHERE
    sql_id         = '&&bad_sql_id'
  AND child_number =
    &&bad_child_no;
    
  -- generate signature
    select DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(cl_sql_text)
    into l_signature
    from dual;
    
        
  -- import sql profile  
  dbms_sqltune.import_sql_profile( 
    sql_text => cl_sql_text, 
    profile =>ar_profile_hints, 
    category => 'DEFAULT', 
    name => l_profile_name,
    description => l_profile_name||' '||to_char(l_signature),
    replace => true,
    validate => true,
    force_match => &&force_matching
  );
  dbms_output.put_line(' ');
  dbms_output.put_line('SQL Profile '||l_profile_name||' created.');
  dbms_output.put_line(' ');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'&&bad_sql_id'||' Child: '||'&&bad_child_no'
  ||' not found in v$sql.');
  dbms_output.put_line(' ');
END;
/

undef bad_sql_id undef bad_child_no 
undef good_sql_id undef good_child_no
undef l_profile_name   undef force_matching
SET sqlblanklines OFF
SET feedback ON
set serveroutput off;