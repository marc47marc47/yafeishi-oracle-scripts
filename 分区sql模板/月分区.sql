INFOLOAD_DEALTIME  DATE default sysdate,
  INFOLOAD_DEALTIME2 VARCHAR2(30) default to_char(systimestamp, 'yymmddhh24missxff6')

partition by range (ACCEPT_MONTH)
(
  partition  PAR_TF_B_NOTEPRINTLOG_1     values less than (2)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA1,
  partition  PAR_TF_B_NOTEPRINTLOG_2     values less than (3)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA2,
  partition  PAR_TF_B_NOTEPRINTLOG_3     values less than (4)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA3,
  partition  PAR_TF_B_NOTEPRINTLOG_4     values less than (5)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA4,
  partition  PAR_TF_B_NOTEPRINTLOG_5     values less than (6)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA1,
  partition  PAR_TF_B_NOTEPRINTLOG_6     values less than (7)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA2,
  partition  PAR_TF_B_NOTEPRINTLOG_7     values less than (8)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA3,
  partition  PAR_TF_B_NOTEPRINTLOG_8     values less than (9)        pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA4,
  partition  PAR_TF_B_NOTEPRINTLOG_9     values less than (10)       pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA1,
  partition  PAR_TF_B_NOTEPRINTLOG_10    values less than (11)       pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA2,
  partition  PAR_TF_B_NOTEPRINTLOG_11    values less than (12)       pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA3,
  partition  PAR_TF_B_NOTEPRINTLOG_12    values less than (MAXVALUE) pctfree 20 initrans 10 tablespace   TBS_CRM_HDTRA4
);

PAR_TF_B_TRADE_GRP_CENPAY_12
TBS_ACT_HDACT10

local
(
  partition  PAR_TF_B_NOTEPRINTLOG_1        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA1,
  partition  PAR_TF_B_NOTEPRINTLOG_2        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA2,
  partition  PAR_TF_B_NOTEPRINTLOG_3        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA3,
  partition  PAR_TF_B_NOTEPRINTLOG_4        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA4,
  partition  PAR_TF_B_NOTEPRINTLOG_5        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA1,
  partition  PAR_TF_B_NOTEPRINTLOG_6        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA2,
  partition  PAR_TF_B_NOTEPRINTLOG_7        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA3,
  partition  PAR_TF_B_NOTEPRINTLOG_8        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA4,
  partition  PAR_TF_B_NOTEPRINTLOG_9        pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA1,
  partition  PAR_TF_B_NOTEPRINTLOG_10       pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA2,
  partition  PAR_TF_B_NOTEPRINTLOG_11       pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA3,
  partition  PAR_TF_B_NOTEPRINTLOG_12       pctfree 10 initrans 20 tablespace  TBS_CRM_HITRA4 
);

TI_B_MPAY_RECON

partition by range (MONTH)
(
  partition  PAR_TI_BH_INTEGRAL_ACCT_01     values less than (2),
  partition  PAR_TI_BH_INTEGRAL_ACCT_02     values less than (3),
  partition  PAR_TI_BH_INTEGRAL_ACCT_03     values less than (4),
  partition  PAR_TI_BH_INTEGRAL_ACCT_04     values less than (5),
  partition  PAR_TI_BH_INTEGRAL_ACCT_05     values less than (6),
  partition  PAR_TI_BH_INTEGRAL_ACCT_06     values less than (7),
  partition  PAR_TI_BH_INTEGRAL_ACCT_07     values less than (8),
  partition  PAR_TI_BH_INTEGRAL_ACCT_08     values less than (9),
  partition  PAR_TI_BH_INTEGRAL_ACCT_09     values less than (10),
  partition  PAR_TI_BH_INTEGRAL_ACCT_10    values less than (11),
  partition  PAR_TI_BH_INTEGRAL_ACCT_11    values less than (12),
  partition  PAR_TI_BH_INTEGRAL_ACCT_12    values less than (MAXVALUE) 
)
initrans 10 tablespace TBS_CRM_HDUIF;

PAR_TF_B_TRADEFEE_OTHERFEE_01

initrans 20 tablespace TBS_CEN_IUIF local;
TF_B_TRADEFEE_OTHERFEE_ATTR

TF_B_TRADEFEE_OTHERFEE

partition by range (ACCEPT_MONTH)
(
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_1     values less than (2),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_2     values less than (3),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_3     values less than (4),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_4     values less than (5),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_5     values less than (6),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_6     values less than (7),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_7     values less than (8),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_8     values less than (9),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_9     values less than (10),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_10    values less than (11),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_11    values less than (12),
  partition  PAR_TF_B_TRADEFEE_OTHERFEE_12    values less than (MAXVALUE) 
)
initrans 10 tablespace TBS_CRM_DTRA;


initrans 20 tablespace TBS_CRM_ITRA local;



partition by range (VISIT_MONTH)
(
  partition  COMMUNIONS_P1    values less than (2)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC1,
  partition  COMMUNIONS_P2    values less than (3)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC2,
  partition  COMMUNIONS_P3    values less than (4)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC3,
  partition  COMMUNIONS_P4    values less than (5)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC4,
  partition  COMMUNIONS_P5    values less than (6)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC1,
  partition  COMMUNIONS_P6    values less than (7)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC2,
  partition  COMMUNIONS_P7    values less than (8)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC3,
  partition  COMMUNIONS_P8    values less than (9)        pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC4,
  partition  COMMUNIONS_P9    values less than (10)       pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC1,
  partition  COMMUNIONS_P10   values less than (11)       pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC2,
  partition  COMMUNIONS_P11   values less than (12)       pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC3,
  partition  COMMUNIONS_P12   values less than (13)       pctfree 20 initrans 10 tablespace   TBS_CEN_HDUEC4
);


local
(
  partition  COMMUNIONS_P1     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC1,
  partition  COMMUNIONS_P2     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC2,
  partition  COMMUNIONS_P3     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC3,
  partition  COMMUNIONS_P4     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC4,
  partition  COMMUNIONS_P5     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC1,
  partition  COMMUNIONS_P6     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC2,
  partition  COMMUNIONS_P7     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC3,
  partition  COMMUNIONS_P8     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC4,
  partition  COMMUNIONS_P9     pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC1,
  partition  COMMUNIONS_P10    pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC2,
  partition  COMMUNIONS_P11    pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC3,
  partition  COMMUNIONS_P12    pctfree 20 initrans 10 tablespace   TBS_CEN_HIUEC4
)


partition by range (PARTITION_ID)
(
  partition  PAR_TF_F_CRMBOSSNOTE_1     values less than (2)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR1,
  partition  PAR_TF_F_CRMBOSSNOTE_2     values less than (3)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR2,
  partition  PAR_TF_F_CRMBOSSNOTE_3     values less than (4)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR3,
  partition  PAR_TF_F_CRMBOSSNOTE_4     values less than (5)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR4,
  partition  PAR_TF_F_CRMBOSSNOTE_5     values less than (6)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR5,
  partition  PAR_TF_F_CRMBOSSNOTE_6     values less than (7)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR1,
  partition  PAR_TF_F_CRMBOSSNOTE_7     values less than (8)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR2,
  partition  PAR_TF_F_CRMBOSSNOTE_8     values less than (9)        pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR3,
  partition  PAR_TF_F_CRMBOSSNOTE_9     values less than (10)       pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR4,
  partition  PAR_TF_F_CRMBOSSNOTE_10    values less than (11)       pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR5,
  partition  PAR_TF_F_CRMBOSSNOTE_11    values less than (12)       pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR3,
  partition  PAR_TF_F_CRMBOSSNOTE_12    values less than (MAXVALUE) pctfree 20 initrans 10 tablespace   TBS_ACT_DUSR4
);



local
(
  partition  PAR_TF_F_CRMBOSSNOTE_1     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR1,
  partition  PAR_TF_F_CRMBOSSNOTE_2     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR2,
  partition  PAR_TF_F_CRMBOSSNOTE_3     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR3,
  partition  PAR_TF_F_CRMBOSSNOTE_4     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR4,
  partition  PAR_TF_F_CRMBOSSNOTE_5     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR5,
  partition  PAR_TF_F_CRMBOSSNOTE_6     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR1,
  partition  PAR_TF_F_CRMBOSSNOTE_7     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR2,
  partition  PAR_TF_F_CRMBOSSNOTE_8     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR3,
  partition  PAR_TF_F_CRMBOSSNOTE_9     pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR4,
  partition  PAR_TF_F_CRMBOSSNOTE_10    pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR5,
  partition  PAR_TF_F_CRMBOSSNOTE_11    pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR3,
  partition  PAR_TF_F_CRMBOSSNOTE_12    pctfree 20 initrans 20 tablespace   TBS_ACT_IUSR4
); 


partition by range (PARTITION_ID)
(
  partition  PAR_TF_B_VATPRINTLOG_1     values less than (2)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT1,
  partition  PAR_TF_B_VATPRINTLOG_2     values less than (3)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT2,
  partition  PAR_TF_B_VATPRINTLOG_3     values less than (4)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT3,
  partition  PAR_TF_B_VATPRINTLOG_4     values less than (5)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT4,
  partition  PAR_TF_B_VATPRINTLOG_5     values less than (6)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT5,
  partition  PAR_TF_B_VATPRINTLOG_6     values less than (7)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT1,
  partition  PAR_TF_B_VATPRINTLOG_7     values less than (8)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT2,
  partition  PAR_TF_B_VATPRINTLOG_8     values less than (9)        pctfree 20 initrans 10 tablespace   TBS_ACT_DACT3,
  partition  PAR_TF_B_VATPRINTLOG_9     values less than (10)       pctfree 20 initrans 10 tablespace   TBS_ACT_DACT4,
  partition  PAR_TF_B_VATPRINTLOG_10    values less than (11)       pctfree 20 initrans 10 tablespace   TBS_ACT_DACT5,
  partition  PAR_TF_B_VATPRINTLOG_11    values less than (12)       pctfree 20 initrans 10 tablespace   TBS_ACT_DACT3,
  partition  PAR_TF_B_VATPRINTLOG_12    values less than (MAXVALUE) pctfree 20 initrans 10 tablespace   TBS_ACT_DACT4
);



local
(
  partition  PAR_TF_B_VATPRINTLOG_1     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT1,
  partition  PAR_TF_B_VATPRINTLOG_2     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT2,
  partition  PAR_TF_B_VATPRINTLOG_3     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT3,
  partition  PAR_TF_B_VATPRINTLOG_4     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT4,
  partition  PAR_TF_B_VATPRINTLOG_5     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT5,
  partition  PAR_TF_B_VATPRINTLOG_6     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT1,
  partition  PAR_TF_B_VATPRINTLOG_7     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT2,
  partition  PAR_TF_B_VATPRINTLOG_8     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT3,
  partition  PAR_TF_B_VATPRINTLOG_9     pctfree 20 initrans 10 tablespace   TBS_ACT_IACT4,
  partition  PAR_TF_B_VATPRINTLOG_10    pctfree 20 initrans 10 tablespace   TBS_ACT_IACT5,
  partition  PAR_TF_B_VATPRINTLOG_11    pctfree 20 initrans 10 tablespace   TBS_ACT_IACT3,
  partition  PAR_TF_B_VATPRINTLOG_12    pctfree 20 initrans 10 tablespace   TBS_ACT_IACT4
);


partition by range (PARTITION_ID)
(
  partition  PAR_TF_BH_VATPRINTLOG_1     values less than (2)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT01,
  partition  PAR_TF_BH_VATPRINTLOG_2     values less than (3)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT02,
  partition  PAR_TF_BH_VATPRINTLOG_3     values less than (4)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT03,
  partition  PAR_TF_BH_VATPRINTLOG_4     values less than (5)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT04,
  partition  PAR_TF_BH_VATPRINTLOG_5     values less than (6)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT05,
  partition  PAR_TF_BH_VATPRINTLOG_6     values less than (7)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT06,
  partition  PAR_TF_BH_VATPRINTLOG_7     values less than (8)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT07,
  partition  PAR_TF_BH_VATPRINTLOG_8     values less than (9)        pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT08,
  partition  PAR_TF_BH_VATPRINTLOG_9     values less than (10)       pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT09,
  partition  PAR_TF_BH_VATPRINTLOG_10    values less than (11)       pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT10,
  partition  PAR_TF_BH_VATPRINTLOG_11    values less than (12)       pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT11,
  partition  PAR_TF_BH_VATPRINTLOG_12    values less than (MAXVALUE) pctfree 20 initrans 10 tablespace   TBS_ACT_HDACT12
);



local
(
  partition  PAR_TF_BH_VATPRINTLOG_1     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT01,
  partition  PAR_TF_BH_VATPRINTLOG_2     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT02,
  partition  PAR_TF_BH_VATPRINTLOG_3     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT03,
  partition  PAR_TF_BH_VATPRINTLOG_4     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT04,
  partition  PAR_TF_BH_VATPRINTLOG_5     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT05,
  partition  PAR_TF_BH_VATPRINTLOG_6     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT06,
  partition  PAR_TF_BH_VATPRINTLOG_7     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT07,
  partition  PAR_TF_BH_VATPRINTLOG_8     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT08,
  partition  PAR_TF_BH_VATPRINTLOG_9     pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT09,
  partition  PAR_TF_BH_VATPRINTLOG_10    pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT10,
  partition  PAR_TF_BH_VATPRINTLOG_11    pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT11,
  partition  PAR_TF_BH_VATPRINTLOG_12    pctfree 20 initrans 10 tablespace   TBS_ACT_HIACT12
);

