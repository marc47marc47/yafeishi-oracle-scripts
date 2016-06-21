create or replace procedure p_import_par_tab_annalyze
(
ip_owner in varchar2,
ip_table_name in varchar2,
ip_from_par_position in number,
ip_to_par_position   in number,
o_info          OUT VARCHAR2
)
is
iv_owner varchar2(40);
iv_table_name varchar2(30);
iv_from_posi number;
iv_to_posi   number;
iv_from_par_name  varchar2(30);
iv_to_par_name  varchar2(30);
iv_sql varchar2(2000);
iv_indx_to_par_name varchar2(30);
begin
  o_info :='';

  select table_owner,table_name,a.partition_name,partition_position
  into iv_owner, iv_table_name,iv_from_par_name,iv_from_posi
  from dba_tab_partitions a
  where a.table_owner=ip_owner
  and a.table_name=ip_table_name
  and a.partition_position=ip_from_par_position;

  if iv_table_name is not null then
       /* 
       先要在用户下建好表 STAT_TABLE  BRANDON 统计信息表用户名也要修改
       execute dbms_stats.create_stat_table(ownname => 'BRANDON',stattab => 'STAT_TABLE',tblspace => 'TBS_EXPORT');
       */
      begin
        dbms_stats.export_table_stats(ownname => iv_owner,tabname => iv_table_name,partname => iv_from_par_name,stattab => 'STAT_TABLE',statown => 'BRANDON');
      end;

        select table_owner,table_name,a.partition_name,partition_position
        into iv_owner, iv_table_name,iv_to_par_name,iv_to_posi
        from dba_tab_partitions a
        where a.table_owner=ip_owner
        and a.table_name=ip_table_name
        and a.partition_position=ip_to_par_position;

       if iv_table_name is not null then
           update STAT_TABLE stat
           set stat.c2=iv_to_par_name
           where stat.c1=iv_table_name
           and stat.c2=iv_from_par_name
           and stat.c5= iv_owner;
           commit;
           for cur_indx_from in ( select p.index_owner,p.index_name,p.partition_name  from dba_indexes i,dba_ind_partitions p where i.owner=p.index_owner and i.index_name=p.index_name and i.owner=ip_owner and i.table_name=ip_table_name and p.partition_position=ip_from_par_position) loop
               
               if cur_indx_from.index_name is not null then
                 
                   select p.partition_name 
                   into iv_indx_to_par_name
                   from dba_indexes i,dba_ind_partitions p
                   where i.owner=cur_indx_from.index_owner
                   and i.index_name= cur_indx_from.index_name
                   and i.table_name=ip_table_name
                   and i.owner=p.index_owner
                   and i.index_name=p.index_name
                   and p.partition_position=ip_to_par_position ;
                   
                  

                      if iv_indx_to_par_name is not null then
                         update STAT_TABLE stat
                         set stat.c2=iv_indx_to_par_name
                         where stat.c1=cur_indx_from.index_name
                         and stat.c5= cur_indx_from.index_owner
                         and stat.c2 = cur_indx_from.partition_name;
                         commit;
                      else
                        o_info := o_info||' partition index to_partition-'||ip_to_par_position||' does not exist';
                      end if;

               else
                 o_info := o_info||' table  does not have partition indexs';
               end if;
           end loop;
           begin
           dbms_stats.import_table_stats(ownname => iv_owner,
                                         tabname => iv_table_name,
                                         partname => iv_to_par_name,
                                         stattab => 'STAT_TABLE',
                                         cascade => true,
                                         statown => 'BRANDON',
                                         no_invalidate => false);
           end;
           o_info := o_info||'import ok !';
        else
           o_info := o_info||'to表或者分区不存在';
        end if;

  else
     o_info := o_info||'from 表或者分区不存在';
  end if;

EXCEPTION
WHEN OTHERS THEN
   o_info := 'p_import_par_tab_annalyze-Error:'||SQLERRM;
   ROLLBACK;
END p_import_par_tab_annalyze;
/
