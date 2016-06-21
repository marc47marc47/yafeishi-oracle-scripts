select a.initial_extent,'alter table '||a.owner||'.'||a.table_name||' move  storage (initial 64k);',a.*
from dba_tables a 
where a.owner in ('IMP_ACT1','IMP_ACT2','IMP_ACT3','IMP_ACT4','UCR_ACT1','UCR_ACT11','UCR_ACT2','UCR_ACT3','UCR_ACT4','UCR_ACTNEW','UCR_ACTOLD','UCR_CREDITNEW','UCR_CREDITOLD')
and a.initial_extent > 65536
and a.num_rows=0
order by a.initial_extent desc,a.owner,a.table_name;

select a.initial_extent,'alter index '||a.owner||'.'||a.index_name||' rebuild  storage (initial 64k);',a.*
from dba_indexes a 
where a.owner in ('IMP_ACT1','IMP_ACT2','IMP_ACT3','IMP_ACT4','UCR_ACT1','UCR_ACT11','UCR_ACT2','UCR_ACT3','UCR_ACT4','UCR_ACTNEW','UCR_ACTOLD','UCR_CREDITNEW','UCR_CREDITOLD')
and a.initial_extent > 65536
and a.num_rows=0
order by a.initial_extent desc,a.owner,a.index_name;

------------------------------------------------------------------

alter table ucr_act1.TS_BH_BILL_201508 move partition PAR_TS_BH_BILL_1  storage (initial 64k);

select a.initial_extent,'alter table '||a.table_owner||'.'||a.table_name||' move partition '||a.partition_name||' storage (initial 64k);',a.*
from dba_tab_partitions a 
where a.table_owner like 'UCR_ACT%'
and a.initial_extent > 65536
and a.num_rows=0
order by a.initial_extent desc, a.table_owner,a.table_name;

select a.initial_extent,'alter index '||a.index_owner||'.'||a.index_name||' rebuild partition '||a.partition_name||' storage (initial 64k);',a.*
from dba_ind_partitions a 
where a.index_owner like 'IMP_ACT%'
and a.initial_extent > 65536
and a.num_rows=0
order by a.initial_extent desc, a.index_owner,a.index_name;

