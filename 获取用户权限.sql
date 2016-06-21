查看用户对表拥有的权限：
SELECT   * FROM dba_tab_privs  a WHERE a.table_name ='TF_F_USER_NETNP' AND a.grantee= 'UOP_CRM1';
查看用户的系统权限：
SELECT * FROM dba_sys_privs a WHERE a.grantee ='UOP_CRM1';
查看用户的角色权限:
SELECT * FROM Dba_Role_Privs a WHERE a.grantee ='UOP_CRM1';

undefine user_name
set pagesize 1000
select 'grant '||tt.granted_role||' to '||tt.grantee||';' as SQL_text
from dba_role_privs tt where tt.grantee=(upper('&&user_name'))
union all
select 'grant '||tt.privilege||' to '||tt.grantee||';'
from dba_sys_privs tt where tt.grantee=(upper('&&user_name'))
union all
select 'grant '||tt.privilege||' on '||owner||'.'||table_name||' to '||tt.grantee||';'
from dba_tab_privs tt where tt.grantee=(upper('&&user_name'))


set serveroutput on size 1000000
set verify off
undefine user_name
declare
 v_name varchar2(30) := upper('&user_name');
 no_grant exception;
 pragma exception_init( no_grant, -31608 );
begin
 dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
 dbms_output.enable(1000000);
 dbms_output.put_line(dbms_metadata.get_ddl('USER',v_name));
 begin
   dbms_output.put_line(dbms_metadata.get_granted_ddl('SYSTEM_GRANT',v_name));
 exception
   when no_grant then dbms_output.put_line('-- No system privs granted');
 end;
 begin
   dbms_output.put_line(dbms_metadata.get_granted_ddl('ROLE_GRANT',v_name));
 exception
   when no_grant then dbms_output.put_line('-- No role privs granted');
 end;
 begin
   dbms_output.put_line(dbms_metadata.get_granted_ddl('OBJECT_GRANT',v_name));
 exception
   when no_grant then dbms_output.put_line('-- No object privs granted');
 end;
 begin
  dbms_output.put_line(dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA',v_name));
 exception
   when no_grant then dbms_output.put_line('-- No tablespace quota specified');
 end;
 dbms_output.put_line(dbms_metadata.get_granted_ddl('DEFAULT_ROLE', v_name ));
exception
 when others then
  if SQLCODE = -31603 then dbms_output.put_line('-- User does not exists');
  else raise;
  end if;
end;
/
