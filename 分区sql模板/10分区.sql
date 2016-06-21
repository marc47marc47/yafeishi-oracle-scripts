pctfree 20 initrans 10 tablespace TBS_ACT_HDACT03
partition by range (PARTITION_ID)
(
  partition PAR_TF_F_USER_SP_0   values less than (1000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT03,
  partition PAR_TF_F_USER_SP_1   values less than (2000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT04,
  partition PAR_TF_F_USER_SP_2   values less than (3000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT05,
  partition PAR_TF_F_USER_SP_3   values less than (4000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT06,
  partition PAR_TF_F_USER_SP_4   values less than (5000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT07,
  partition PAR_TF_F_USER_SP_5   values less than (6000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT08,
  partition PAR_TF_F_USER_SP_6   values less than (7000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT09,
  partition PAR_TF_F_USER_SP_7   values less than (8000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT10,
  partition PAR_TF_F_USER_SP_8   values less than (9000)            pctfree 20 initrans 10 tablespace TBS_ACT_HDACT11,
  partition PAR_TF_F_USER_SP_9   values less than (MAXVALUE)        pctfree 20 initrans 10 tablespace TBS_ACT_HDACT12
);


PAR_TF_F_USER_SP_0


local
(
  partition PAR_TF_F_USER_SP_0    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR1,
  partition PAR_TF_F_USER_SP_1    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR2,
  partition PAR_TF_F_USER_SP_2    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR3,
  partition PAR_TF_F_USER_SP_3    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR4,
  partition PAR_TF_F_USER_SP_4    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR5,
  partition PAR_TF_F_USER_SP_5    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR1,
  partition PAR_TF_F_USER_SP_6    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR2,
  partition PAR_TF_F_USER_SP_7    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR3,
  partition PAR_TF_F_USER_SP_8    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR4,
  partition PAR_TF_F_USER_SP_9    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR5
);

pctfree 20 initrans 10 tablespace TBS_ACT_DUSR1
partition by range (PARTITION_ID)
(
  partition PAR_TF_F_USER_SP_0   values less than (1000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR1,
  partition PAR_TF_F_USER_SP_1   values less than (2000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR2,
  partition PAR_TF_F_USER_SP_2   values less than (3000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR3,
  partition PAR_TF_F_USER_SP_3   values less than (4000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR4,
  partition PAR_TF_F_USER_SP_4   values less than (5000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR5,
  partition PAR_TF_F_USER_SP_5   values less than (6000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR1,
  partition PAR_TF_F_USER_SP_6   values less than (7000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR2,
  partition PAR_TF_F_USER_SP_7   values less than (8000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR3,
  partition PAR_TF_F_USER_SP_8   values less than (9000)            pctfree 20 initrans 10 tablespace TBS_ACT_DUSR4,
  partition PAR_TF_F_USER_SP_9   values less than (MAXVALUE)        pctfree 20 initrans 10 tablespace TBS_ACT_DUSR5
);


TF_F_USER_SP

pctfree 10 initrans 20 tablespace TBS_ACT_IUSR1
local
(
  partition PAR_TF_F_USER_SP_0    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR1,
  partition PAR_TF_F_USER_SP_1    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR2,
  partition PAR_TF_F_USER_SP_2    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR3,
  partition PAR_TF_F_USER_SP_3    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR4,
  partition PAR_TF_F_USER_SP_4    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR5,
  partition PAR_TF_F_USER_SP_5    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR1,
  partition PAR_TF_F_USER_SP_6    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR2,
  partition PAR_TF_F_USER_SP_7    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR3,
  partition PAR_TF_F_USER_SP_8    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR4,
  partition PAR_TF_F_USER_SP_9    pctfree 10 initrans 20 tablespace TBS_ACT_IUSR5
);




TF_F_USER_ACCESS_ACCT

partition by range (PARTITION_ID)
(
   partition PAR_TF_F_USER_GRP_MOLIST_0   values less than (1000)   tablespace TBS_CRM_DUSR1   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_1   values less than (2000)   tablespace TBS_CRM_DUSR2   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_2   values less than (3000)   tablespace TBS_CRM_DUSR3   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_3   values less than (4000)   tablespace TBS_CRM_DUSR4   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_4   values less than (5000)   tablespace TBS_CRM_DUSR5   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_5   values less than (6000)   tablespace TBS_CRM_DUSR1   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_6   values less than (7000)   tablespace TBS_CRM_DUSR2   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_7   values less than (8000)   tablespace TBS_CRM_DUSR3   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_8   values less than (9000)   tablespace TBS_CRM_DUSR4   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_GRP_MOLIST_9   values less than (MAXVALUE)	 tablespace TBS_CRM_DUSR5   pctfree 20  initrans 10 
);

PAR_TF_F_INTEGRAL_PLAN_8
local
(
   partition PAR_TF_F_USER_GRP_MOLIST_0   tablespace TBS_CRM_IUSR1 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_1   tablespace TBS_CRM_IUSR2 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_2   tablespace TBS_CRM_IUSR3 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_3   tablespace TBS_CRM_IUSR4 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_4   tablespace TBS_CRM_IUSR5 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_5   tablespace TBS_CRM_IUSR1 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_6   tablespace TBS_CRM_IUSR2 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_7   tablespace TBS_CRM_IUSR3 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_8   tablespace TBS_CRM_IUSR4 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_GRP_MOLIST_9   tablespace TBS_CRM_IUSR5 pctfree 10  initrans 20
);


PAR_TF_F_USER_ACCESS_ACCT_0

partition by range (ACCEPT_MONTH)
(
   partition PAR_TF_F_USER_ACCESS_ACCT_0   values less than (1000)   tablespace TBS_CRM_HDTRA1   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_1   values less than (2000)   tablespace TBS_CRM_HDTRA2   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_2   values less than (3000)   tablespace TBS_CRM_HDTRA3   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_3   values less than (4000)   tablespace TBS_CRM_HDTRA4   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_4   values less than (5000)   tablespace TBS_CRM_HDTRA5   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_5   values less than (6000)   tablespace TBS_CRM_HDTRA1   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_6   values less than (7000)   tablespace TBS_CRM_HDTRA2   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_7   values less than (8000)   tablespace TBS_CRM_HDTRA3   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_8   values less than (9000)   tablespace TBS_CRM_HDTRA4   pctfree 20  initrans 10,  
   partition PAR_TF_F_USER_ACCESS_ACCT_9   values less than (MAXVALUE)	 tablespace TBS_CRM_DUSR5   pctfree 20  initrans 10 
);


pctfree 10 initrans 20 tablespace TBS_CRM_IUSR1
local
(
   partition PAR_TF_F_USER_ACCESS_ACCT_0   tablespace TBS_CRM_IUSR1 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_1   tablespace TBS_CRM_IUSR2 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_2   tablespace TBS_CRM_IUSR3 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_3   tablespace TBS_CRM_IUSR4 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_4   tablespace TBS_CRM_IUSR5 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_5   tablespace TBS_CRM_IUSR1 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_6   tablespace TBS_CRM_IUSR2 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_7   tablespace TBS_CRM_IUSR3 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_8   tablespace TBS_CRM_IUSR4 pctfree 10  initrans 20,  
   partition PAR_TF_F_USER_ACCESS_ACCT_9   tablespace TBS_CRM_IUSR5 pctfree 10  initrans 20
);




pctfree 20 initrans 10 tablespace TBS_ACT_DACT1
partition by range (PARTITION_ID)
(
  partition PAR_TF_B_ACCOUNTDEPOSIT_0   values less than (1000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT1,
  partition PAR_TF_B_ACCOUNTDEPOSIT_1   values less than (2000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT2,
  partition PAR_TF_B_ACCOUNTDEPOSIT_2   values less than (3000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT3,
  partition PAR_TF_B_ACCOUNTDEPOSIT_3   values less than (4000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT4,
  partition PAR_TF_B_ACCOUNTDEPOSIT_4   values less than (5000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT5,
  partition PAR_TF_B_ACCOUNTDEPOSIT_5   values less than (6000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT1,
  partition PAR_TF_B_ACCOUNTDEPOSIT_6   values less than (7000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT2,
  partition PAR_TF_B_ACCOUNTDEPOSIT_7   values less than (8000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT3,
  partition PAR_TF_B_ACCOUNTDEPOSIT_8   values less than (9000)            pctfree 20 initrans 10 tablespace TBS_ACT_DACT4,
  partition PAR_TF_B_ACCOUNTDEPOSIT_9   values less than (MAXVALUE)        pctfree 20 initrans 10 tablespace TBS_ACT_DACT5
);

PAR_TF_B_ACCOUNTDEPOSIT_0

pctfree 10 initrans 20 tablespace TBS_ACT_IACT1
local
(
  partition PAR_TF_B_ACCOUNTDEPOSIT_0    pctfree 10 initrans 20 tablespace TBS_ACT_IACT1,
  partition PAR_TF_B_ACCOUNTDEPOSIT_1    pctfree 10 initrans 20 tablespace TBS_ACT_IACT2,
  partition PAR_TF_B_ACCOUNTDEPOSIT_2    pctfree 10 initrans 20 tablespace TBS_ACT_IACT3,
  partition PAR_TF_B_ACCOUNTDEPOSIT_3    pctfree 10 initrans 20 tablespace TBS_ACT_IACT4,
  partition PAR_TF_B_ACCOUNTDEPOSIT_4    pctfree 10 initrans 20 tablespace TBS_ACT_IACT5,
  partition PAR_TF_B_ACCOUNTDEPOSIT_5    pctfree 10 initrans 20 tablespace TBS_ACT_IACT1,
  partition PAR_TF_B_ACCOUNTDEPOSIT_6    pctfree 10 initrans 20 tablespace TBS_ACT_IACT2,
  partition PAR_TF_B_ACCOUNTDEPOSIT_7    pctfree 10 initrans 20 tablespace TBS_ACT_IACT3,
  partition PAR_TF_B_ACCOUNTDEPOSIT_8    pctfree 10 initrans 20 tablespace TBS_ACT_IACT4,
  partition PAR_TF_B_ACCOUNTDEPOSIT_9    pctfree 10 initrans 20 tablespace TBS_ACT_IACT5
);


--insert 模板
set timing on;  
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id < 1000;
commit; 
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 1000 and partition_id < 2000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 2000 and partition_id < 3000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 3000 and partition_id < 4000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 4000 and partition_id < 5000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 5000 and partition_id < 6000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 6000 and partition_id < 7000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 7000 and partition_id < 8000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 8000 and partition_id < 9000;
commit;
insert /*+ append */ into rwdbusi.tf_f_user select * from ucr_crm1.tf_f_user@to_crm where partition_id >= 9000 ;
commit;
