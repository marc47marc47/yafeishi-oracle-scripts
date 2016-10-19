select a.owner,a.table_name,a.partition_count
from dba_part_tables a
where a.owner='UCR_CEN1'
and a.table_name in 


select a.table_owner,a.table_name,a.partition_name,a.partition_position,to_number(substr(a.partition_name,(length(a.partition_name)),1))
from dba_tab_partitions a
where a.table_owner='UCR_CEN1'
and to_number(substr(a.partition_name,(length(a.partition_name)),1))<>a.partition_position
and a.partition_position < 10
and a.table_name in 


select 'alter index '||A.INDEX_OWNER||'.'||a.index_name||' modify partition '||a.partition_name||' unusable ;'
from Dba_Ind_Partitions a,dba_indexes b
where a.index_owner='UCR_CRM21'
and b.owner=a.index_owner
and a.index_name=b.index_name
and b.uniqueness<>'UNIQUE'
and (a.partition_position <>10 and a.partition_position <>11)
and b.table_name in ()

select 'alter index '||a.owner||'.'||a.index_name||' unusable ;',a.uniqueness
from dba_indexes a
where a.owner='UCR_UIF1' 
and a.uniqueness<>'UNIQUE';

create table ts_tab_hist_size
(
owner varchar2(20),
tabname varchar2(30),
partname varchar2(30),
count number
);

select 'insert into ts_tab_hist_size select '''||a.table_owner||''','''||a.table_name||''','''||a.partition_name||''',count(*) from '||
a.table_owner||'.'||a.table_name||' partition ('||a.partition_name||') ;'
from dba_tab_partitions a
where a.table_owner like 'UCR_CRM__'
and (a.partition_position <>10 and a.partition_position <>11)
and a.table_name in ('TF_BH_TRADE','TI_BH_CUST_GROUP_BAK','TF_B_TRADE_SVC_BAK','TF_B_TRADE_SYSCODE','TF_B_TRADE_USER_ACCTDAY_BAK','TF_B_TRADE_USER_BAK','TF_B_TRADE_GRP_PLATSVC_BAK','TF_B_TRADE_GRP_MERCHP','TF_B_TRADE_GRP_MERCH_DISCNT','TF_B_TRADE_PLATSVC_BAK','TF_B_TRADE_RELATION','TF_B_TRADE_EPAPER_FILE','TF_B_TRADE_RELATION_BB','TF_F_ACCOUNTDEPOSIT_MONTH','TP_FH_USER_CHARGEREMIND','TF_B_TRADE_BLACKWHITE','TF_B_TRADE_CUST_GROUP','TF_BH_TRADE_SECOND','TI_B_EC','TF_B_TRADE_OTHER','TF_B_TRADE_GRP_MEB_PLATSVC_BAK','TF_B_TRADE_GRP_MERCH','TF_B_TRADE_GRP_PLATSVC','TF_B_TRADE_PLATSVC_LOG','TF_B_TRADE_EXT','TF_B_TRADE_RELATION_AA_BAK','TF_B_TRADE_RES','TF_B_CUST_CONTACT_TRACE','TI_BH_CUST_GROUPMEMBER_BAK','TI_B_EC_SUB','TF_BH_ORDERMGR_INSTANCE','TF_B_TRADE_SVCSTATE','TF_B_TRADE_VALIDCHANGE_BAK','TF_B_TRADE_NETNP_BAK','TF_B_TRADE_GRP_MEB_PLATSVC','TF_B_TRADE_GRP_MERCHP_DISCNT','TI_BH_EC_SUB','TF_B_TERMINAL_PSI_DETAIL','TF_B_TRADEFEE_SUB','TF_B_TRADE_PLATSVC_ATTR','TF_B_TRADE_PRODUCT','TF_B_TRADE_ACCOUNT_BAK','TF_B_TRADE_ATTR_BAK','TI_BH_EC','TF_B_TRADE_SVCSTATE_BAK','TF_B_TRADE_VPN_MEB','TF_B_TRADE_WIDENET_ACT','TF_B_TRADE_IMPU_BAK','TF_B_TRADE_OTHER_BAK','TF_B_TRADEFEE_PAYMONEY','TF_B_TRADE_CUST_PERSON','TF_B_TRADE_RELATION_UU_BAK','TF_B_TRADE_SALE_GOODS','TF_B_TRADE_PAYRELATION','TF_B_TRADE_PBOSS_FINISH','TI_BH_MCAS_UDR','TF_B_TERMINAL_PSI_STAT','TF_B_TRADE_RENT_BAK','TF_B_TRADE_SCORE','TF_CHLH_ACCTACTION_LOG','TF_CHL_ACCTACTION_LOG','TF_B_TRADE_ACCOUNT','TF_B_TRADE_CUSTOMER','TF_B_TRADE_CUSTOMER_BAK','TI_BH_ADC_MAS_SUB','TF_BH_CUST_CONTACT','TF_B_TRADE_USER','TF_B_TRADE_USER_ACCTDAY','TF_B_TRADE_USER_FOREGIFT_BAK','TF_B_TRADE_VPN','TF_B_TRADE_WIDENET','TF_B_TRADE_POSTINFO_BAK','TF_B_TRADE_PRODUCT_BAK','TF_B_TRADE_DISCNT','TF_B_TRADE_SVC','TL_B_EPAPER_LOG','TF_B_TRADE_ACCT_CONSIGN','TF_B_TRADE_BRANDCHANGE_BAK','TF_B_TRADE_CUST_FAMILY','TF_BH_TRADEMGR_INSTANCE','TF_BH_ORDER','TF_B_TRADE_INFOCHANGE_BAK','TF_B_TRADE_NETNP','TF_B_TRADE_PAYRELATION_BAK','TF_B_TRADE_PERSON_BAK','TF_B_TRADE_PLATSVC','TF_B_TRADE_GRP_MERCH_MEB','TF_B_TRADEFEE_GIFTFEE','TF_B_TRADE_DEVELOP','TF_B_TRADE_DISCNT_BAK','TF_B_TRADE_RELATION_BB_BAK','TF_B_TRADE_RES_BAK','TF_B_TRADE_SALE_DEPOSIT','TF_B_TRADE_SPECIALEPAY_BAK','TF_SMH_JOB','TF_B_TRADE_ACCOUNT_ACCTDAY_BAK','TF_B_TRADE_CUST_FAMILYMEB','TF_BH_TRADEMGRPBOSS_INSTANCE','TF_B_CUST_CONTACT','TF_B_GRP_BUSAPPLY','CHNL_SKY_REC','TF_BH_CUST_CONTACT_TRACE','TF_B_TRADE_IMEI_BAK','TF_B_TRADE_IMPU','TF_B_TRADE_MPUTE_BAK','TF_B_TRADE_GRP_MOLIST','TI_BH_IBOSS_SVCSTATE','TF_B_TRADE_ELEMENT','TF_B_TRADE_EPAPER','TF_B_TRADE_RELATION_AA','TF_B_TRADE_SALE_ACTIVE','TF_B_TRADE_ACCOUNT_ACCTDAY','TF_B_TRADE_ATTR','TF_B_TRADE_CONSIGN_BAK','TF_B_TRADE_CREDIT','TL_BPM_INSTANCE')


select 'alter table '||a.table_name||' truncate  partition '||a.partition_name||' ;'
from dba_tab_partitions a
where a.table_owner='UCR_CRM11'
and (a.partition_position <>10 and a.partition_position <>11)
and a.table_name in 






