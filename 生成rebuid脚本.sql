select a.tablespace_name,'alter table '||a.owner||'.'||a.table_name||' move tablespace '||
    (case a.tablespace_name
     when 'TBS_CRM_DUSR1' then 'TBS_CRM_HDTRA3'
     when 'TBS_CRM_DUSR2' then 'TBS_CRM_HDTRA4'
     when 'TBS_CRM_DUSR3' then 'TBS_CRM_HDTRA2'
     when 'TBS_CRM_DUSR4' then 'TBS_CEN_DUSR'
     when 'TBS_CRM_DUSR5' then 'TBS_CEN_DUSR'
     else 's' end)||' parallel 20;'
from dba_tables a
where a.owner in ('IMP_CRM4','UCR_CRM4')
and a.partitioned='NO'
and a.table_name in ('TF_B_TRADEFEE_DEFER','TF_B_TRADE_SHARE_INFO','TF_F_ACCOUNT_CONSIGN','TF_F_CUST_GROUPMEMBER','TF_F_CUST_PERSON','TF_F_CUST_VIP','TF_F_INTEGRAL_ACCT','TF_F_INTEGRAL_PLAN','TF_F_POSTINFO','TF_F_RELATION_AA','TF_F_SCORERELATION','TF_F_USER_BRANDCHANGE','TF_F_USER_FOREGIFT','TF_F_USER_GRP_CENPAY','TF_F_USER_GRP_MEB_PLATSVC','TF_F_USER_IMPU','TF_F_USER_MEB_CENPAY','TF_F_USER_OCS','TF_F_USER_PLATSVC_TRACE','TF_F_USER_SHARE','TF_F_USER_SHARE_RELA','TL_F_USER_SERTRACK_LOG','TF_F_RELATION_UU','TF_F_USER_ATTR','TF_F_USER_INFOCHANGE','TF_F_USER_OTHER','TF_F_CUSTOMER','TF_F_ACCOUNT_ACCTDAY','TF_F_USER_GRP_PLATSVC','TF_F_USER_ACCTDAY','TF_A_PAYRELATION','TF_F_ACCOUNT','TF_F_USER_DISCNT','TF_F_USER_SVC','TF_F_USER_SVCSTATE','TF_F_CUST_GROUP','TF_F_USER','TF_F_USER_PLATSVC','TF_F_USER_PLATSVC_ATTR')
order by a.tablespace_name;

select b.tablespace_name,'alter index '||b.owner||'.'||b.index_name||' rebuild tablespace '||
    (case b.tablespace_name
     when 'TBS_CRM_IUSR1' then 'TBS_CRM_HDUIF'
     when 'TBS_CRM_IUSR2' then 'TBS_CRM_DTRA'
     when 'TBS_CRM_IUSR3' then 'TBS_CRM_DRES'
     when 'TBS_CRM_IUSR4' then 'TBS_CRM_HDUSR1'
     when 'TBS_CRM_IUSR5' then 'TBS_CRM_ITRA'
     else 's' end)||' parallel 20;'
from dba_tables a,dba_indexes b
where a.owner in ('IMP_CRM4','UCR_CRM4')
and a.owner=b.owner
and a.partitioned='NO'
and b.table_name=a.table_name
and b.table_owner=a.owner
and a.table_name in ('TF_B_TRADEFEE_DEFER','TF_B_TRADE_SHARE_INFO','TF_F_ACCOUNT_CONSIGN','TF_F_CUST_GROUPMEMBER','TF_F_CUST_PERSON','TF_F_CUST_VIP','TF_F_INTEGRAL_ACCT','TF_F_INTEGRAL_PLAN','TF_F_POSTINFO','TF_F_RELATION_AA','TF_F_SCORERELATION','TF_F_USER_BRANDCHANGE','TF_F_USER_FOREGIFT','TF_F_USER_GRP_CENPAY','TF_F_USER_GRP_MEB_PLATSVC','TF_F_USER_IMPU','TF_F_USER_MEB_CENPAY','TF_F_USER_OCS','TF_F_USER_PLATSVC_TRACE','TF_F_USER_SHARE','TF_F_USER_SHARE_RELA','TL_F_USER_SERTRACK_LOG','TF_F_RELATION_UU','TF_F_USER_ATTR','TF_F_USER_INFOCHANGE','TF_F_USER_OTHER','TF_F_CUSTOMER','TF_F_ACCOUNT_ACCTDAY','TF_F_USER_GRP_PLATSVC','TF_F_USER_ACCTDAY','TF_A_PAYRELATION','TF_F_ACCOUNT','TF_F_USER_DISCNT','TF_F_USER_SVC','TF_F_USER_SVCSTATE','TF_F_CUST_GROUP','TF_F_USER','TF_F_USER_PLATSVC','TF_F_USER_PLATSVC_ATTR')
order by b.tablespace_name;



--move table subpartition 
select 'alter table '||a.table_name||' move subpartition '||a.subpartition_name||'  ;',a.*
from dba_tab_subpartitions a
where a.table_owner='UCR_PF1'
and a.table_name='TI_C_SUBSCRIBE';
--move part
select 'alter table ' || A.TABLE_OWNER || '.' || a.table_name ||
       ' move partition ' || a.partition_name ||
       ' tablespace TBS_CRM_HDTRA1 nologging;',
       a.*
  from dba_tab_partitions a
 where a.table_owner = 'UCR_CRM1'
   and a.table_name in ('TF_B_TRADE_ATTR_BAK')


--move lob
select 'alter table ' || a.OWNER || '.' || a.TABLE_NAME ||
       ' move tablespace TBS_CEN_DEF lob(' || a.COLUMN_NAME ||
       ') store as (tablespace TBS_CEN_DEF);'
  from dba_tab_columns a
 where a.OWNER like 'UCR_CRM1%'
   and a.DATA_TYPE like '%LOB%';

select a.tablespace_name,'alter table ' || a.OWNER || '.' || a.TABLE_NAME ||
       ' move tablespace TBS_CEN_DEF lob(' || a.COLUMN_NAME ||
       ') store as (tablespace TBS_CEN_DEF);'

  from dba_lobs a
 where a.owner like 'U%';
 
-- move lob partition   note:761388.1
select a.tablespace_name,b.tablespace_name,'alter table ' || a.OWNER || '.' || a.TABLE_NAME ||
       ' move partition '||b.partition_name||'  lob(' || a.COLUMN_NAME ||
       ') store as (tablespace TBS_CRM_HDUSR1);'

  from dba_lobs a ,DBA_TAB_PARTITIONS B
 where a.owner like 'UCR_SQM1'
 and a.owner=b.table_owner
 and a.table_name = b.table_name 
 and b.tablespace_name like 'TBS_CRM_HDUSR_'

 

--根据表名
select 'alter index '||a.index_owner||'.'||a.index_name||' rebuild partition '||a.partition_name||
'   tablespace TBS_CRM_HITRA1 nologging;'
from Dba_Ind_Partitions a,dba_indexes b
where 1=1
and a.index_owner=b.table_owner
and b.table_owner='UCR_CRM1'
and b.table_name='TF_B_TRADE_ATTR_BAK'
and a.index_name=b.index_name
order by a.index_owner,a.index_name,a.partition_name;

select 'alter index '||a.owner||'.'||a.index_name||' unusable;' 
from dba_indexes a
where a.owner like 'UCR_OLCOM%'
and a.table_name='TI_CH_OLCOMWORK'

--rebuild partitioned UNUSABLE  index
select 'alter index ' || a.index_owner || '.' || a.index_name ||
       ' rebuild partition ' || a.partition_name || ' parallel 20;'
  from dba_ind_partitions a
 where a.index_owner like 'U%'
   and a.status = 'UNUSABLE'
   and a.index_name not like 'BIN$%';
   
select 'alter index ' || a.index_name || ' rebuild subpartition ' ||
       a.subpartition_name || ' parallel 20;',
       a.status,
       a.*
  from dba_ind_subpartitions a
 where a.index_owner like 'U%'
   and a.index_name not like 'BIN$%'
   and a.status = 'UNUSABLE';

--rebuild no partition unusable index
select 'alter index ' || owner || '.' || a.index_name ||
       ' rebuild parallel 20;'
  from dba_indexes a
 where owner like 'U%'
   and a.status = 'UNUSABLE'
   and a.partitioned = 'NO'
   and a.index_name not like 'BIN$%';

select a.degree,'alter index '||a.owner||'.'||a.index_name||' noparallel ;'
from dba_indexes a
where a.degree > '1'
and a.index_name not like 'BIN$%';


select 'alter table '||a.owner||'.'||a.table_name||' enable constraint '||a.constraint_name||';'
from dba_constraints a
where a.owner like 'U%'
and a.status<>'ENABLED';


--检查分区表的非分区索引
select a.owner,a.index_name,a.partitioned,a.table_name,b.partitioned
from dba_indexes a,dba_tables b
where a.owner=b.OWNER
and a.table_name=b.TABLE_NAME
and a.owner like 'UCR_CRM__'
and b.PARTITIONED='YES'
and a.partitioned='NO'
order by a.owner,a.table_name;


select 'alter index '||a.index_owner||'.'||a.index_name||' rebuild partition '||a.partition_name||' parallel 20;' 
from dba_ind_partitions a,dba_indexes b
where a.index_owner='UCR_ACT11' 
and a.index_owner=b.owner
and a.index_name=b.index_name
and a.status='UNUSABLE' 
and a.index_name not like 'BIN$%'
and b.table_name in 


select A.TABLESPACE_NAME,
       'alter table ' || a.table_owner || '.' || a.table_name ||
       ' move partition ' || a.partition_name || ' tablespace ' ||
       (case mod(a.partition_position, 5) 
             when 1 then 'TBS_ACT_DUSR1' 
             when 2 then 'TBS_ACT_DUSR2'
             when 3 then 'TBS_ACT_DUSR3'
             when 4 then 'TBS_ACT_DUSR4'
             when 0 then 'TBS_ACT_DUSR5'
             else 'SDS' end)||' parallel 10;'
  from dba_tab_partitions a
 where a.Table_Owner IN ('IMP_ACT11','IMP_ACT33','UCR_ACT11','UCR_ACT33')
   and a.table_name in
   
   
select A.TABLESPACE_NAME,
       'alter index ' || a.index_owner || '.' || a.index_name ||
       ' rebuild partition ' || a.partition_name || ' tablespace ' ||
       (case mod(a.partition_position, 5) 
             when 1 then 'TBS_ACT_IUSR1' 
             when 2 then 'TBS_ACT_IUSR2'
             when 3 then 'TBS_ACT_IUSR3'
             when 4 then 'TBS_ACT_IUSR4'
             when 0 then 'TBS_ACT_IUSR5'
             else 'SDS' end)||' parallel 10;'
  from dba_ind_partitions a,dba_indexes b
 where a.index_Owner IN ('IMP_ACT11','IMP_ACT33','UCR_ACT11','UCR_ACT33')
   and b.table_name in 
   and a.tablespace_name not like 'TBS_ACT__USR_'
   and a.index_owner=b.owner
   and a.index_name=b.index_name   