drop table t_part;
truncate table t_part;
create table t_part (
owner varchar2(30),
tab_name varchar2(30),
part_name varchar2(30),
part_position number,
l_vaule varchar2(30),
h_value varchar2(30),
high_value clob);

alter table t_part add condition varchar2(200);

insert into t_part 
  select a.table_owner,
         a.table_name,
         a.partition_name,
         a.partition_position,
         '',
         '',
          to_lob(high_value)
    from dba_tab_partitions a
   where a.table_owner = 'UCR_CRM1';
   
   update t_part a
   set a.h_value=dbms_lob.substr(a.high_value);
   
   select a.* from t_part a where a.tab_name='TF_F_USER';
   
   
   
  update t_part b
  set b.l_vaule=
  (select a.h_value
   from t_part a
   where a.owner=b.owner
   and a.tab_name=b.tab_name
   --and a.part_name=b.part_name
   and a.part_position=b.part_position-1
   and b.part_position > 1);
 
  update t_part a
  set a.condition='partition_id >= '||a.l_vaule||' and partition_id < '||a.h_value
  where a.l_vaule is not  null
  and a.h_value<>'MAXVALUE';
  
   update t_part a
  set a.condition='partition_id < '||a.h_value
  where a.l_vaule is    null;
  
  update t_part a
  set a.condition='partition_id >= '||a.l_vaule
  where a.h_value='MAXVALUE';
  
  select * from t_part a where a.condition is null;
  
   
   select l_vaule, h_value,condition from t_part;
