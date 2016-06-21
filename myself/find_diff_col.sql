with imp_col as
(
select a.OWNER,a.TABLE_NAME,a.COLUMN_NAME,a.COLUMN_ID,a.DATA_TYPE,a.DATA_LENGTH,a.DATA_PRECISION
from dba_tab_columns a
where a.OWNER='IMP_CRM1'
--and a.TABLE_NAME='TF_F_ACCOUNT'
)
,
ucr_col as
(
select a.OWNER,a.TABLE_NAME,a.COLUMN_NAME,a.COLUMN_ID,a.DATA_TYPE,a.DATA_LENGTH,a.DATA_PRECISION
from dba_tab_columns a
where a.OWNER='UCR_CRM1'
--and a.TABLE_NAME='TF_F_ACCOUNT'
)
select a.table_name,a.COLUMN_NAME,a.data_type,b.data_type,a.data_length,b.data_length,a.DATA_PRECISION,b.DATA_PRECISION,a.COLUMN_ID,b.COLUMN_ID
from imp_col a,ucr_col b
where a.table_name=b.table_name
and a.column_name=b.column_name
and (a.DATA_TYPE<>b.data_type or a.data_length<>b.data_length
or a.DATA_PRECISION<> b.DATA_PRECISION or a.COLUMN_ID<>b.COLUMN_ID)
and a.TABLE_NAME='&1'
order by 1;
