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
select 'old-new' as "col_minus" from dual
union all
(select COLUMN_NAME
from imp_col a
where a.TABLE_NAME='&1'
minus
select COLUMN_NAME
from ucr_col b
where b.TABLE_NAME='&1')
union all
select 'new-old' from dual
union all
(select COLUMN_NAME
from ucr_col a
where a.TABLE_NAME='&1'
minus
select COLUMN_NAME
from imp_col b
where b.TABLE_NAME='&1');