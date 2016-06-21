--导出用户对象：
nohup expdp system/Hnyd123# directory=bak_dir dumpfile=param.dmp logfile=param.log content=metadata_only exclude=statistics schemas=ucr_param,uop_param > param.out &
                            
--dblink-remap_schema:
nohup impdp system/linkage DIRECTORY=DANG_DIR network_link=TO_BILDB1 remap_schema=uif_bil1_bi:uif_bil1i1_bi schemas=uif_bil1_bi  > bil1i1_bi.out &
nohup impdp system/linkage DIRECTORY=DANG_DIR network_link=TO_BILDB1 remap_schema=uif_bil1_bi:uif_bil1i2_bi schemas=uif_bil1_bi  > bil1i2_bi.out &

--dblink拖表
nohup impdp system/Hnyd123# directory=bak_dir network_link=TO_CRMTST parfile=term.par exclude=statistics > term.out &

impdp system/linkage DIRECTORY=IMPDP_DIR network_link=DBLNK_CRMTST remap_schema=UCR_CRM41:UCR_CRM42 tables=ucr_crm41.tf_bh_trade

nohup exp system/Hnyd123# file=uif.dmp log=exp-uif.log compress=n rows=n statistics=none owner=ucr_uif1,uop_uif1 > uif1.out &

nohup expdp system/Hnyd123# directory=bak_dir dumpfile=expdp-uif.dmp logfile=uif.log content=metadata_only exclude=statistics schemas=ucr_uif1,uop_uif1 > uif.out &

nohup expdp system/Hnyd123# directory=bak_dir dumpfile=expdp-uif.dmp logfile=uif.log content=metadata_only exclude=statistics schemas=ucr_uif1,uop_uif1 > uif.out &

nohup expdp system/Hnyd123# directory=bak_dir dumpfile=test-uif.dmp logfile=uif.log content=metadata_only exclude=statistics schemas=ucr_uif1,uop_uif1 > uif.out &

nohup impdp \'/ as sysdba\' directory=dang_dir dumpfile=expdp-uif.dmp logfile=uif.log content=metadata_only  TABLE_EXISTS_ACTION=replace schemas=ucr_uif1,uop_uif1 > uif.out &

-- 导出分区
expdp danghb/Dang1# directory=dang_dir dumpfile=user_p1.dmp logfile=testp.log content=all exclude=statistics tables=ucr_crm1.tf_f_user:PAR_TF_F_USER_0 > user0.out &

--单导某类对象：
nohup impdp system/linkage directory=DANG_DIR network_link=TO_J2EECRMT parallel=10  TABLE_EXISTS_ACTION=skip include=CONSTRAINT schemas=ucr_sys > sys.out &
impdp system/"eYzx^akCgd3" directory=DATA_PUMP_DIR dumpfile=uif_pro.dmp  include=PROCEDURE TABLE_EXISTS_ACTION=replace schemas=test_uif remap_schema=test_uif:uif_cen1_sta

--dmp文件抽取ddl语句
impdp danghb/dang directory=hunan_dir dumpfile=crmcen-full-1101.dmp logfile=imp_res.log schemas=UCR_RES exclude=statistics sqlfile=create_ucr_res.sql 

---
exp ubak/ubakabc@bil file=TS_B_DETAILBILL_STA_05.dmp compress=n statistics=none rows=n tables=ucr_dtb1.TS_B_DETAILBILL_STA_05  
imp danghb/dang  file=TS_B_DETAILBILL_STA_05.dmp fromuser=ucr_dtb1 touser=ucr_dtb1 
--
