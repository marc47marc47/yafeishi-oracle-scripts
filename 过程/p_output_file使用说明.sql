ִ��������:select 'execute p_output_file(''UCR_CRM1'',''1'',''TABLE'',''2'','''||TABLE_NAME||''',''/archivelog/sql/part'','','',''1'',outflag => :outflag); '
FROM DBA_TABLES WHERE owner ='UCR_CRM1' AND TABLE_NAME IN (��������

umon���水�������û��������磺
var outflag varchar2(100);
execute p_output_file('UCR_LD','1','TABLE','1','','/oracle/ld/ddl',',','1',outflag => :outflag); 

         Ŀǰֻ������3�ַ�����ʽ�ķ��������Ϸ�����δ������iot��ȫ����ʱ�����ͨ������cluster��nest���ͱ��Լ����Ϸ�����Ŀǰ��֧�֣�
����ֻ��������ͨ������ȫ����ʱ��������local�����������Լ�iot������ ,����CLUSTER��LOB�������͵�indexesĿǰ��֧�� .

������Ҫ��ʾ��Ȩ.
grant select on dba_objects to umon;
grant select on dba_tab_columns to umon;
grant select on dba_tables to umon;
grant select on dba_indexes to umon;
grant select on v_$parameter to umon;
grant select on dba_source to umon;
grant select on dba_constraints to umon;

grant select on dba_tab_partitions to umon;
grant select on dba_part_key_columns to umon;
grant select on dba_ind_columns to umon;

grant select on dba_part_tables  to umon;
grant select on dba_part_indexes  to umon;
grant select on dba_ind_partitions  to umon;
grant select on dba_views  to umon;

grant select on DBA_COL_COMMENTS to umon;
grant select on dba_tab_comments to umon;


------------   danghb
var outflag varchar2(2000);
select 'execute p_output_file(''UCR_CRM1'',''1'',''TABLE'',''2'','''||TABLE_NAME||''',''OBJ_DIR'','','',''1'',outflag => :outflag); '
from dba_tables a
where a.owner='UCR_CRM1'
and a.table_name in ('TI_B_USER_COSTRECOUNT','TI_B_REMINDTYPE','TI_BH_CUST_VIPSELFDEF','TI_B_RELATION_BANK','TI_BH_RELATION_BANK','TI_B_INTEGRAL_ACCT_CEN','TI_BH_INTEGRAL_ACCT_CEN','TI_BH_USER_DEDUCT','TI_BH_USER_NETNP')

select 'cat '||a.table_name||'-IND.sql >> '||a.table_name||'.sql'
from dba_tables a
where a.owner='UCR_CRM1'
and a.table_name in ('TI_B_USER_COSTRECOUNT','TI_B_REMINDTYPE','TI_BH_CUST_VIPSELFDEF','TI_B_RELATION_BANK','TI_BH_RELATION_BANK','TI_B_INTEGRAL_ACCT_CEN','TI_BH_INTEGRAL_ACCT_CEN','TI_BH_USER_DEDUCT','TI_BH_USER_NETNP')

select 'cat '||a.table_name||'.sql >> create_table.sql'
from dba_tables a
where a.owner='UCR_CRM1'
and a.table_name in ('TI_B_USER_COSTRECOUNT','TI_B_REMINDTYPE','TI_BH_CUST_VIPSELFDEF','TI_B_RELATION_BANK','TI_BH_RELATION_BANK','TI_B_INTEGRAL_ACCT_CEN','TI_BH_INTEGRAL_ACCT_CEN','TI_BH_USER_DEDUCT','TI_BH_USER_NETNP')
