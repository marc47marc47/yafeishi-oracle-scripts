create or replace procedure p_unused_space(p_object_name in varchar2,
p_object_type in varchar2 default 'TABLE',
p_owner in varchar2 default user,
p_partition_name in varchar2 default '') is
v_total_blocks number;
v_total_bytes number;
v_unused_blocks number;
v_unused_bytes number;
v_last_used_extent_file_id number;
v_last_used_extent_block_id number;
v_last_used_block number;
begin
dbms_space.unused_space(upper(p_owner), upper(p_object_name), upper(p_object_type), v_total_blocks,
v_total_bytes, v_unused_blocks, v_unused_bytes, v_last_used_extent_file_id,
v_last_used_extent_block_id, v_last_used_block, upper(p_partition_name));
dbms_output.put_line('total_blocks is ' || v_total_blocks);
dbms_output.put_line('total_bytes is ' || v_total_bytes);
dbms_output.put_line('unused_blocks is ' || v_unused_blocks);
dbms_output.put_line('unused_bytes is ' || v_unused_bytes);
dbms_output.put_line('last_used_extent_file_id is ' || v_last_used_extent_file_id);
dbms_output.put_line('last_used_extent_block_id is ' || v_last_used_extent_block_id);
dbms_output.put_line('last_used_block is ' || v_last_used_block);
end
/

过程已创建。

SQL> EXEC P_UNUSED_SPACE('UCR_CRM1', 'TABLE', 'TEST_TABLE_NAME')
total_blocks is 1397504
total_bytes is 22896705536
unused_blocks is 0
unused_bytes is 0
last_used_extent_file_id is 31
last_used_extent_block_id is 110981
last_used_block is 128

PL/SQL 过程已成功完成。

SQL> create or replace procedure p_space_usage (p_segment_name in varchar2,
2 p_segment_type in varchar2 default 'TABLE',
3 p_segment_owner in varchar2 default user,
4 p_partition_name in varchar2 default '') as
5 v_unformatted_blocks number;
6 v_unformatted_bytes number;
7 v_fs1_blocks number;
8 v_fs1_bytes number;
9 v_fs2_blocks number;
10 v_fs2_bytes number;
11 v_fs3_blocks number;
12 v_fs3_bytes number;
13 v_fs4_blocks number;
14 v_fs4_bytes number;
15 v_full_blocks number;
16 v_full_bytes number;
17 begin
18 dbms_space.space_usage(upper(p_segment_owner), upper(p_segment_name), upper(p_segment_type), v_unformatted_blocks,
19 v_unformatted_bytes, v_fs1_blocks, v_fs1_bytes, v_fs2_blocks, v_fs2_bytes, v_fs3_blocks, v_fs3_bytes,
20 v_fs4_blocks, v_fs4_bytes, v_full_blocks, v_full_bytes, upper(p_partition_name));
21
22 dbms_output.put_line('unformatted_blocks is ' || v_unformatted_blocks);
23 dbms_output.put_line('unformatted_bytes is ' || v_unformatted_bytes);
24 dbms_output.put_line('fs1_blocks is ' || v_fs1_blocks);
25 dbms_output.put_line('fs1_bytes is ' || v_fs1_bytes);
26 dbms_output.put_line('fs2_blocks is ' || v_fs2_blocks);
27 dbms_output.put_line('fs2_bytes is ' || v_fs2_bytes);
28 dbms_output.put_line('fs3_blocks is ' || v_fs3_blocks);
29 dbms_output.put_line('fs3_bytes is ' || v_fs3_bytes);
30 dbms_output.put_line('fs4_blocks is ' || v_fs4_blocks);
31 dbms_output.put_line('fs4_bytes is ' || v_fs4_bytes);
32 dbms_output.put_line('full_blocks is ' || v_full_blocks);
33 dbms_output.put_line('full_bytes is ' || v_full_bytes);
34 end;
35 /

过程已创建。

SQL> EXEC P_SPACE_USAGE('UCR_CRM1', 'TABLE', 'TEST_TABLE_NAME');
unformatted_blocks is 1300462
unformatted_bytes is 21306769408
fs1_blocks is 37
fs1_bytes is 606208
fs2_blocks is 52
fs2_bytes is 851968
fs3_blocks is 22
fs3_bytes is 360448
fs4_blocks is 903
fs4_bytes is 14794752
full_blocks is 94412
full_bytes is 1546846208

PL/SQL 过程已成功完成。