partition by range (SYNC_DAY)
(
   partition  PAR_TF_BH_TRADE_STAFF_1   values less than (2) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_2   values less than (3) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_3   values less than (4) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_4   values less than (5) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_5   values less than (6) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_6   values less than (7) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_7   values less than (8) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_8   values less than (9) 	pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_9   values less than (10) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_10  values less than (11) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_11  values less than (12) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_12  values less than (13) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_13  values less than (14) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_14  values less than (15) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_15  values less than (16) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_16  values less than (17) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_17  values less than (18) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_18  values less than (19) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_19  values less than (20) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_20  values less than (21) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_21  values less than (22) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_22  values less than (23) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_23  values less than (24) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_24  values less than (25) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_25  values less than (26) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_26  values less than (27) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_27  values less than (28) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_28  values less than (29) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_29  values less than (30) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_30  values less than (31) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF,
   partition  PAR_TF_BH_TRADE_STAFF_31  values less than (MAXVALUE) pctfree 10 initrans 10 tablespace TBS_CRM_DUIF
);


PAR_TF_BH_TRADE_STAFF_1

pctfree 10 initrans 20 tablespace TBS_CRM_IUIF
local
(
   partition  PAR_TF_BH_TRADE_STAFF_1    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_2    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_3    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_4    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_5    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_6    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_7    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_8    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_9    pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_10   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_11   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_12   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_13   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_14   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_15   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_16   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_17   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_18   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_19   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_20   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_21   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_22   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_23   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_24   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_25   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_26   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_27   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_28   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_29   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_30   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF,
   partition  PAR_TF_BH_TRADE_STAFF_31   pctfree 10 initrans 20 tablespace TBS_CRM_IUIF
);



partition by range (PARTITION_ID)
(
   partition  PAR_TF_B_PAYLOG_STAFF_1   values less than (2) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT01,
   partition  PAR_TF_B_PAYLOG_STAFF_2   values less than (3) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT02,
   partition  PAR_TF_B_PAYLOG_STAFF_3   values less than (4) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT03,
   partition  PAR_TF_B_PAYLOG_STAFF_4   values less than (5) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT04,
   partition  PAR_TF_B_PAYLOG_STAFF_5   values less than (6) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT05,
   partition  PAR_TF_B_PAYLOG_STAFF_6   values less than (7) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT06,
   partition  PAR_TF_B_PAYLOG_STAFF_7   values less than (8) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT07,
   partition  PAR_TF_B_PAYLOG_STAFF_8   values less than (9) 	pctfree 10 initrans 10 tablespace TBS_ACT_HDACT08,
   partition  PAR_TF_B_PAYLOG_STAFF_9   values less than (10) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT09,
   partition  PAR_TF_B_PAYLOG_STAFF_10  values less than (11) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT10,
   partition  PAR_TF_B_PAYLOG_STAFF_11  values less than (12) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT11,
   partition  PAR_TF_B_PAYLOG_STAFF_12  values less than (13) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT12,
   partition  PAR_TF_B_PAYLOG_STAFF_13  values less than (14) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT01,
   partition  PAR_TF_B_PAYLOG_STAFF_14  values less than (15) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT02,
   partition  PAR_TF_B_PAYLOG_STAFF_15  values less than (16) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT03,
   partition  PAR_TF_B_PAYLOG_STAFF_16  values less than (17) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT04,
   partition  PAR_TF_B_PAYLOG_STAFF_17  values less than (18) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT05,
   partition  PAR_TF_B_PAYLOG_STAFF_18  values less than (19) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT06,
   partition  PAR_TF_B_PAYLOG_STAFF_19  values less than (20) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT07,
   partition  PAR_TF_B_PAYLOG_STAFF_20  values less than (21) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT08,
   partition  PAR_TF_B_PAYLOG_STAFF_21  values less than (22) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT09,
   partition  PAR_TF_B_PAYLOG_STAFF_22  values less than (23) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT10,
   partition  PAR_TF_B_PAYLOG_STAFF_23  values less than (24) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT11,
   partition  PAR_TF_B_PAYLOG_STAFF_24  values less than (25) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT12,
   partition  PAR_TF_B_PAYLOG_STAFF_25  values less than (26) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT01,
   partition  PAR_TF_B_PAYLOG_STAFF_26  values less than (27) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT02,
   partition  PAR_TF_B_PAYLOG_STAFF_27  values less than (28) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT03,
   partition  PAR_TF_B_PAYLOG_STAFF_28  values less than (29) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT04,
   partition  PAR_TF_B_PAYLOG_STAFF_29  values less than (30) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT05,
   partition  PAR_TF_B_PAYLOG_STAFF_30  values less than (31) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT06,
   partition  PAR_TF_B_PAYLOG_STAFF_31  values less than (MAXVALUE) pctfree 10 initrans 10 tablespace TBS_ACT_HDACT07
);


PAR_TF_B_PAYLOG_STAFF_7
TI_B_REMINDTHRESHOLD

pctfree 10 initrans 20 tablespace TBS_ACT_HIACT01
local
(
   partition  PAR_TF_B_PAYLOG_STAFF_1    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT01,
   partition  PAR_TF_B_PAYLOG_STAFF_2    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT02,
   partition  PAR_TF_B_PAYLOG_STAFF_3    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT03,
   partition  PAR_TF_B_PAYLOG_STAFF_4    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT04,
   partition  PAR_TF_B_PAYLOG_STAFF_5    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT05,
   partition  PAR_TF_B_PAYLOG_STAFF_6    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT06,
   partition  PAR_TF_B_PAYLOG_STAFF_7    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT07,
   partition  PAR_TF_B_PAYLOG_STAFF_8    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT08,
   partition  PAR_TF_B_PAYLOG_STAFF_9    pctfree 10 initrans 20 tablespace TBS_ACT_HIACT09,
   partition  PAR_TF_B_PAYLOG_STAFF_10   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT10,
   partition  PAR_TF_B_PAYLOG_STAFF_11   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT11,
   partition  PAR_TF_B_PAYLOG_STAFF_12   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT12,
   partition  PAR_TF_B_PAYLOG_STAFF_13   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT01,
   partition  PAR_TF_B_PAYLOG_STAFF_14   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT02,
   partition  PAR_TF_B_PAYLOG_STAFF_15   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT03,
   partition  PAR_TF_B_PAYLOG_STAFF_16   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT04,
   partition  PAR_TF_B_PAYLOG_STAFF_17   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT05,
   partition  PAR_TF_B_PAYLOG_STAFF_18   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT06,
   partition  PAR_TF_B_PAYLOG_STAFF_19   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT07,
   partition  PAR_TF_B_PAYLOG_STAFF_20   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT08,
   partition  PAR_TF_B_PAYLOG_STAFF_21   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT09,
   partition  PAR_TF_B_PAYLOG_STAFF_22   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT10,
   partition  PAR_TF_B_PAYLOG_STAFF_23   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT11,
   partition  PAR_TF_B_PAYLOG_STAFF_24   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT12,
   partition  PAR_TF_B_PAYLOG_STAFF_25   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT01,
   partition  PAR_TF_B_PAYLOG_STAFF_26   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT02,
   partition  PAR_TF_B_PAYLOG_STAFF_27   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT03,
   partition  PAR_TF_B_PAYLOG_STAFF_28   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT04,
   partition  PAR_TF_B_PAYLOG_STAFF_29   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT05,
   partition  PAR_TF_B_PAYLOG_STAFF_30   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT06,
   partition  PAR_TF_B_PAYLOG_STAFF_31   pctfree 10 initrans 20 tablespace TBS_ACT_HIACT06
);





PAR_TF_A_DELAYTARGET_0
partition by range (PARTITION_ID)
(
   partition  PAR_TF_A_DELAYTARGET_1   values less than (2) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT1,
   partition  PAR_TF_A_DELAYTARGET_2   values less than (3) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT2,
   partition  PAR_TF_A_DELAYTARGET_3   values less than (4) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT3,
   partition  PAR_TF_A_DELAYTARGET_4   values less than (5) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT4,
   partition  PAR_TF_A_DELAYTARGET_5   values less than (6) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT5,
   partition  PAR_TF_A_DELAYTARGET_6   values less than (7) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT1,
   partition  PAR_TF_A_DELAYTARGET_7   values less than (8) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT2,
   partition  PAR_TF_A_DELAYTARGET_8   values less than (9) 	   pctfree 10 initrans 10 tablespace TBS_ACT_DACT3,
   partition  PAR_TF_A_DELAYTARGET_9   values less than (10)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT4,
   partition  PAR_TF_A_DELAYTARGET_10  values less than (11)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT5,
   partition  PAR_TF_A_DELAYTARGET_11  values less than (12)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT1,
   partition  PAR_TF_A_DELAYTARGET_12  values less than (13)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT2,
   partition  PAR_TF_A_DELAYTARGET_13  values less than (14)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT3,
   partition  PAR_TF_A_DELAYTARGET_14  values less than (15)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT4,
   partition  PAR_TF_A_DELAYTARGET_15  values less than (16)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT5,
   partition  PAR_TF_A_DELAYTARGET_16  values less than (17)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT1,
   partition  PAR_TF_A_DELAYTARGET_17  values less than (18)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT2,
   partition  PAR_TF_A_DELAYTARGET_18  values less than (19)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT3,
   partition  PAR_TF_A_DELAYTARGET_19  values less than (20)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT4,
   partition  PAR_TF_A_DELAYTARGET_20  values less than (21)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT5,
   partition  PAR_TF_A_DELAYTARGET_21  values less than (22)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT1,
   partition  PAR_TF_A_DELAYTARGET_22  values less than (23)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT2,
   partition  PAR_TF_A_DELAYTARGET_23  values less than (24)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT3,
   partition  PAR_TF_A_DELAYTARGET_24  values less than (25)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT4,
   partition  PAR_TF_A_DELAYTARGET_25  values less than (26)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT5,
   partition  PAR_TF_A_DELAYTARGET_26  values less than (27)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT1,
   partition  PAR_TF_A_DELAYTARGET_27  values less than (28)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT2,
   partition  PAR_TF_A_DELAYTARGET_28  values less than (29)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT3,
   partition  PAR_TF_A_DELAYTARGET_29  values less than (30)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT4,
   partition  PAR_TF_A_DELAYTARGET_30  values less than (31)       pctfree 10 initrans 10 tablespace TBS_ACT_DACT5,
   partition  PAR_TF_A_DELAYTARGET_31  values less than (MAXVALUE) pctfree 10 initrans 10 tablespace TBS_ACT_DACT1
);



local
(
   partition  PAR_TF_A_DELAYTARGET_1   pctfree 10 initrans 10 tablespace TBS_ACT_IACT1,
   partition  PAR_TF_A_DELAYTARGET_2   pctfree 10 initrans 10 tablespace TBS_ACT_IACT2,
   partition  PAR_TF_A_DELAYTARGET_3   pctfree 10 initrans 10 tablespace TBS_ACT_IACT3,
   partition  PAR_TF_A_DELAYTARGET_4   pctfree 10 initrans 10 tablespace TBS_ACT_IACT4,
   partition  PAR_TF_A_DELAYTARGET_5   pctfree 10 initrans 10 tablespace TBS_ACT_IACT5,
   partition  PAR_TF_A_DELAYTARGET_6   pctfree 10 initrans 10 tablespace TBS_ACT_IACT1,
   partition  PAR_TF_A_DELAYTARGET_7   pctfree 10 initrans 10 tablespace TBS_ACT_IACT2,
   partition  PAR_TF_A_DELAYTARGET_8   pctfree 10 initrans 10 tablespace TBS_ACT_IACT3,
   partition  PAR_TF_A_DELAYTARGET_9   pctfree 10 initrans 10 tablespace TBS_ACT_IACT4,
   partition  PAR_TF_A_DELAYTARGET_10  pctfree 10 initrans 10 tablespace TBS_ACT_IACT5,
   partition  PAR_TF_A_DELAYTARGET_11  pctfree 10 initrans 10 tablespace TBS_ACT_IACT1,
   partition  PAR_TF_A_DELAYTARGET_12  pctfree 10 initrans 10 tablespace TBS_ACT_IACT2,
   partition  PAR_TF_A_DELAYTARGET_13  pctfree 10 initrans 10 tablespace TBS_ACT_IACT3,
   partition  PAR_TF_A_DELAYTARGET_14  pctfree 10 initrans 10 tablespace TBS_ACT_IACT4,
   partition  PAR_TF_A_DELAYTARGET_15  pctfree 10 initrans 10 tablespace TBS_ACT_IACT5,
   partition  PAR_TF_A_DELAYTARGET_16  pctfree 10 initrans 10 tablespace TBS_ACT_IACT1,
   partition  PAR_TF_A_DELAYTARGET_17  pctfree 10 initrans 10 tablespace TBS_ACT_IACT2,
   partition  PAR_TF_A_DELAYTARGET_18  pctfree 10 initrans 10 tablespace TBS_ACT_IACT3,
   partition  PAR_TF_A_DELAYTARGET_19  pctfree 10 initrans 10 tablespace TBS_ACT_IACT4,
   partition  PAR_TF_A_DELAYTARGET_20  pctfree 10 initrans 10 tablespace TBS_ACT_IACT5,
   partition  PAR_TF_A_DELAYTARGET_21  pctfree 10 initrans 10 tablespace TBS_ACT_IACT1,
   partition  PAR_TF_A_DELAYTARGET_22  pctfree 10 initrans 10 tablespace TBS_ACT_IACT2,
   partition  PAR_TF_A_DELAYTARGET_23  pctfree 10 initrans 10 tablespace TBS_ACT_IACT3,
   partition  PAR_TF_A_DELAYTARGET_24  pctfree 10 initrans 10 tablespace TBS_ACT_IACT4,
   partition  PAR_TF_A_DELAYTARGET_25  pctfree 10 initrans 10 tablespace TBS_ACT_IACT5,
   partition  PAR_TF_A_DELAYTARGET_26  pctfree 10 initrans 10 tablespace TBS_ACT_IACT1,
   partition  PAR_TF_A_DELAYTARGET_27  pctfree 10 initrans 10 tablespace TBS_ACT_IACT2,
   partition  PAR_TF_A_DELAYTARGET_28  pctfree 10 initrans 10 tablespace TBS_ACT_IACT3,
   partition  PAR_TF_A_DELAYTARGET_29  pctfree 10 initrans 10 tablespace TBS_ACT_IACT4,
   partition  PAR_TF_A_DELAYTARGET_30  pctfree 10 initrans 10 tablespace TBS_ACT_IACT5,
   partition  PAR_TF_A_DELAYTARGET_31  pctfree 10 initrans 10 tablespace TBS_ACT_IACT1
);