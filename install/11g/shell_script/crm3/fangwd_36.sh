nohup ./INPUT.sh UCR_ESOP TF_F_WORKFORM_EOMS_SUB -1 36 >>nohup.out &
wait
nohup ./INPUT.sh UCR_CRM3 TI_BH_USER_ACCTDAY -1 36 >>nohup.out &
wait
nohup ./INPUT.sh UCR_CRM3 TF_A_PAYRELATION -1 36 >>nohup.out &
wait
nohup ./INPUT.sh UCR_CRM3 TF_F_ACCOUNT_ACCTDAY -1 36 >>nohup.out &
wait
nohup ./INPUT.sh UCR_CRM3 TF_SM_SMS_INFO -1 36 >>nohup.out &
wait
nohup ./INPUT.sh UIF_CRM3_STA TD_S_YBYK_CHANNEL_DETAIL -1 36 >>nohup.out &
wait