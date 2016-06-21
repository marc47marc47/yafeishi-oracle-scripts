/*drop table t_showspace_bqq;
  drop table DBA_SEGMENTS_BQQ;
  
  
create table t_showspace_bqq
(
   segment_owner         varchar2(30),
   segment_name          varchar2(30),
   segment_type          varchar2(30),
   partition_name        varchar2(30),
   unformatted_blocks    number, 
   unformatted_bytes     number,    
   fs4_blocks            number, 
   fs4_bytes             number,      
   fs3_blocks            number, 
   fs3_bytes             number,    
   fs2_blocks            number, 
   fs2_bytes             number,    
   fs1_blocks            number, 
   fs1_bytes             number,    
   full_blocks           number,
   full_bytes            number
)
--tablespace TBS_CRM_DEF
;

create table dba_segments_bqq as select * from dba_segments;



drop table percent_table;
 
CREATE TABLE percent_table (segment_owner,segment_name,blank_bytes,total_bytes) AS
SELECT segment_owner,segment_name,SUM(FS4_BYTES +FS3_BYTES+FS2_BYTES+FS1_BYTES) blank_bytes,
       SUM(FS4_BYTES +FS3_BYTES+FS2_BYTES+FS1_BYTES+FULL_BYTES)  total_bytes
FROM t_showspace_bqq
WHERE  segment_type like 'TABLE%'
GROUP BY segment_owner,segment_name
ORDER BY segment_owner,blank_bytes DESC

delete from percent_table where total_bytes = 0;
commit;
 
SELECT a.segment_owner,a.segment_name,a.blank_bytes, trunc(a.blank_bytes/a.total_bytes,2)  bili, a.total_bytes,b.partition_name,b.tablespace_name
FROM percent_table  a,dba_segments_bqq b
WHERE total_bytes!=0 AND blank_bytes !=0 
AND (blank_bytes > 1*1024*1024
or  blank_bytes/total_bytes >= 0.1   
 )
and a.segment_name=b.segment_name
and a.segment_owner = b.owner
and b.tablespace_name not like '%DEF'
and b.tablespace_name not like '%SNAPSHOT'
--and a.segment_owner like 'UCR_CRM1'
--AND b.segment_name  not LIKE '%HB_%'
ORDER  BY segment_owner,blank_bytes DESC






drop table percent_index;

CREATE TABLE percent_index (segment_owner,segment_name,blank_bytes,total_bytes) AS
SELECT segment_owner,segment_name,SUM(FS4_BYTES +FS3_BYTES+FS2_BYTES+FS1_BYTES) blank_bytes,
       SUM(FS4_BYTES +FS3_BYTES+FS2_BYTES+FS1_BYTES+FULL_BYTES)  total_bytes
FROM t_showspace_bqq
WHERE segment_type like 'IND%'
GROUP BY segment_owner,segment_name
ORDER BY segment_owner,blank_bytes DESC

delete from percent_index where total_bytes = 0;
commit;

SELECT a.segment_owner,a.segment_name,a.blank_bytes, trunc(a.blank_bytes/a.total_bytes,2) bili,a.total_bytes,b.partition_name,b.tablespace_name 
FROM percent_index a,dba_segments_bqq b  
WHERE a.total_bytes!=0 AND a.blank_bytes !=0 
AND (a.blank_bytes > 1*1024*1024
or  a.blank_bytes/a.total_bytes >= 0.1 
  )
and a.segment_name=b.segment_name
and a.segment_owner = b.owner
and b.tablespace_name not like '%DEF'
and b.tablespace_name not like '%SNAPSHOT'  
ORDER  BY a.segment_owner,a.blank_bytes DESC

 


grant analyze any to bqq;
grant select on sys.dba_segments to bqq;

set serveroutput on
variable i_owner varchar2(30); 
variable i_segment varchar2(30); 
variable o_err varchar2(500); 
 
 
begin 
	:i_owner := 'ULCU';
	:i_segment := 'TD_S_CPARAM';
  showspace_bqq(:i_owner,:i_segment,:o_err); 
end; 
/ 

begin
showspace_bqq('OSS_SA_TJ','IDX_TS_A_SUBBILL_3',:o_err);
end;
/
  
set serveroutput off
*/

create or replace PROCEDURE showspace_bqq (
	o_owner 		in 	  varchar2 default null,
	o_segment 	in 	  varchar2 default null,
  o_err			  OUT 	VARCHAR2
)
as
	 v_owner				         varchar2(30);
   v_segment_owner	       VARCHAR2(30);
   v_segment_name 	       varchar2(30);
   v_segment_type 	       varchar2(30);
   v_partition_name 	     varchar2(30);
   v_unformatted_blocks    number; 
   v_unformatted_bytes     number;    
   v_fs4_blocks            number; 
   v_fs4_bytes             number;      
   v_fs3_blocks            number; 
   v_fs3_bytes             number;    
   v_fs2_blocks            number; 
   v_fs2_bytes             number;    
   v_fs1_blocks            number; 
   v_fs1_bytes             number;    
   v_full_blocks           number;
   v_full_bytes            number;
	 v_error				         VARCHAR2(200);

	 type t_cursor is ref cursor;
	 cursor_segments t_cursor;

begin

   if o_owner is null or length(o_owner)=0 then
   	select user into v_owner from dual;
   else
   	v_owner := upper(o_owner);
   end if;

   if o_segment is null or length(o_segment)=0 then
		delete t_showspace_bqq where segment_owner=v_owner;
   else
   	delete t_showspace_bqq where segment_owner=v_owner and segment_name=upper(o_segment);
   end if;
   commit;

   --open cursor_segments;
   if o_segment is null or length(o_segment)=0 then
   	open cursor_segments for
   	select owner,segment_name,segment_type,partition_name
	   from dba_segments_bqq
	   where owner LIKE v_owner
	   	and segment_type in ('INDEX','INDEX PARTITION','TABLE','TABLE PARTITION')
--	   	and rownum<2
	   	;
	else
   	open cursor_segments for
   	select owner,segment_name,segment_type,partition_name
	   from dba_segments_bqq
	   where owner LIKE v_owner and segment_name=upper(o_segment)
	   	and segment_type in ('INDEX','INDEX PARTITION','TABLE','TABLE PARTITION');
	end if;
	
   loop
      fetch cursor_segments into v_segment_owner,v_segment_name,v_segment_type,v_partition_name;
      exit when cursor_segments%notfound;

      sys.dbms_space.space_usage(
        segment_owner       =>v_segment_owner     ,
	      segment_name        =>v_segment_name      ,
	      segment_type        =>v_segment_type      ,
	      partition_name      =>v_partition_name    , 
	      unformatted_blocks  =>v_unformatted_blocks, 
	      unformatted_bytes   =>v_unformatted_bytes , 
	      fs4_blocks          =>v_fs4_blocks        , 
	      fs4_bytes           =>v_fs4_bytes         , 
	      fs3_blocks          =>v_fs3_blocks        , 
	      fs3_bytes           =>v_fs3_bytes         , 
	      fs2_blocks          =>v_fs2_blocks        , 
	      fs2_bytes           =>v_fs2_bytes         , 
	      fs1_blocks          =>v_fs1_blocks        , 
	      fs1_bytes           =>v_fs1_bytes         , 
	      full_blocks         =>v_full_blocks       , 
	      full_bytes          =>v_full_bytes        );


      insert into t_showspace_bqq
      (  
      	segment_owner       ,
      	segment_name        ,
      	segment_type        ,
      	partition_name      ,
      	unformatted_blocks  ,
      	unformatted_bytes   ,
      	fs4_blocks          ,
      	fs4_bytes           ,
      	fs3_blocks          ,
      	fs3_bytes           ,
      	fs2_blocks          ,
      	fs2_bytes           ,
      	fs1_blocks          ,
      	fs1_bytes           ,
      	full_blocks         ,
      	full_bytes          
      )
      values
      (
      	v_segment_owner     ,
        v_segment_name      ,       
        v_segment_type      ,       
        v_partition_name    ,       
        v_unformatted_blocks,       
        v_unformatted_bytes ,       
        v_fs4_blocks        ,       
        v_fs4_bytes         ,       
        v_fs3_blocks        ,       
        v_fs3_bytes         ,       
        v_fs2_blocks        ,       
        v_fs2_bytes         ,       
        v_fs1_blocks        ,       
        v_fs1_bytes         ,       
        v_full_blocks       ,       
        v_full_bytes               
      );
      commit;
   end loop;
   close cursor_segments;
		o_err := 'success!';

  
exception
when others THEN
	v_error := v_segment_name||'-ERR:'||SQLERRM;
  dbms_output.put_line(v_error);
	o_err := v_error;
  return;
end;
/
 