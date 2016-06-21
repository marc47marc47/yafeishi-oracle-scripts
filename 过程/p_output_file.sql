create or replace procedure p_output_file
(
	v_owner         in   varchar2,
	v_outtype       in   char,       --导出类型（1：按照用户导出对象定义 2：按照单表导出数据
	v_outobj        in   varchar2 default '',  --导出对象类别 （procedure,package,package body,type body,trigger,function,type,view ),依赖v_outtype='1'
	v_outmode       in   char default '2',     --导出对象定义方式 （1:导出为一个文件 ，2：分别导出文件,3:在表类别的批量输出的基础上表和索引分开输出）
	v_objectname	  in   varchar2,   --导出数据表名或导出单个对象名
	v_path		      in   varchar2,   --导出文件目录
	v_sep           in   varchar2 default ',', --导出数据的分隔符,依赖导出数据表名
    v_otype         in   varchar2 default '1', --导出表定义的方式（1：表和索引一个文件导出 2：表和索引分别导出）
	outflag         out  varchar2
)
authid current_user
is
	file_handle	               utl_file.file_type;
  file_handle_ind            utl_file.file_type;
	path_notinput_exception    EXCEPTION;
	table_notfind_exception    EXCEPTION;
	write_type_exception       EXCEPTION;

	--type ref_cursor_type       is REF CURSOR;
  --cursor_select              ref_cursor_type;


  type object_name           is TABLE OF dba_objects.object_name%type;
  type object_col            is TABLE OF dba_tab_columns.COLUMN_NAME%type;
  type object_type           is TABLE OF dba_tab_columns.DATA_TYPE%type;
  type table_tablespace      is TABLE OF dba_tables.tablespace_name%type;
  type index_tablespace      is TABLE OF dba_indexes.tablespace_name%type;
  type index_name            is TABLE OF dba_indexes.index_name%type;
  vt_objname                 object_name;
  vt_col                     object_col;
  vt_dtype                   object_type;
  vt_tab_tablespace          table_tablespace;
  vt_ind_tablespace          index_tablespace;
  vt_ind_name                index_name;
	outputline                 varchar2(4000);
	select_cname               varchar2(4000);
  get_cname                  varchar2(2000);
	put_cname                  varchar2(4000);
  put_cname1                 varchar2(4000);
	iv_owner                   varchar2(30);
	iv_objectname              varchar2(30);
	--result                     varchar2(4000);   --对于一行取出来的字符数大于4000的仍然会报错处理－输不出来

   /* 增加动态获取表的字段的变量  */
   c NUMBER;
   d NUMBER;
   col_cnt NUMBER;
   f BOOLEAN;
   rec_tab DBMS_SQL.DESC_TAB2;
   col_num NUMBER;
   col_counter NUMBER := 0;
--   querystr VARCHAR2(2000) ;
   TYPE RefCurTyp IS REF CURSOR;
   TYPE rowQuery IS TABLE of VARCHAR2(200);
   Regca RefCurTyp;
   V_RowQuery rowQuery;
   /* 增加动态获取表的字段的变量  */



	iv_filepath                varchar2(100) ;
	iv_filename                varchar2(100) ;
  iv_filename_ind            varchar2(100) ;
  procedure p_output_file_single
(
	v_owner         in   varchar2,
	v_filename      in   varchar2 default null , --导出文件名
	v_objectname	  in   varchar2,               --导出数据表名或导出单个对象名
	v_outobj        in   varchar2,               --导出类型
	file_handle     in   utl_file.file_type,     --打开文件句柄
	v_otype         in   varchar2 default '1'    --导出类型(1:表，2：索引)
)
--authid current_user
is
	iv_filename                varchar2(100) ;
	type text_name             is table of dba_source.text%type;
	type col_name              is table of dba_tab_columns.column_name%type;
	type dt_type               is table of dba_tab_columns.data_type%type;
	type dt_length             is table of dba_tab_columns.data_length%type;
	type dt_null               is table of dba_tab_columns.nullable%type;
	type dt_precision          is table of dba_tab_columns.data_precision%type;
	type dt_scale              is table of dba_tab_columns.data_scale%type;
	type dt_default            is table of dba_tab_columns.data_default%type;
	type dc_conname            is table of dba_constraints.constraint_name%type;
	type dc_scondition         is table of dba_constraints.search_condition%type;
  type dt_tablespace         is table of dba_tab_partitions.tablespace_name%type;
  type dt_inittrans          is table of dba_tab_partitions.ini_trans%type;
  type dt_maxtrans           is table of dba_tab_partitions.max_trans%type;
  type dt_pctfree            is table of dba_tab_partitions.pct_free%type;
  type dt_parvalue           is table of dba_tab_partitions.high_value%type;
  type dt_parname            is table of dba_tab_partitions.partition_name%type;
  type dt_par_key            is table of dba_part_key_columns.column_name%type;
  type dt_ind_name           is table of dba_indexes.index_name%type;
  type dt_tab_name           is table of dba_indexes.table_name%type;
  type dt_ind_type           is table of dba_indexes.index_type%type;
  type dt_ind_unique         is table of dba_indexes.uniqueness%type;
  type dt_ind_pctfree        is table of dba_indexes.pct_free%type;
  type dt_ind_initrans       is table of dba_indexes.ini_trans%type;
  type dt_ind_maxtrans       is table of dba_indexes.max_trans%type;
  type dt_ind_tablespace     is table of dba_indexes.tablespace_name%type;
  type dt_ind_partition      is table of dba_indexes.partitioned%type;
  type dt_ind_temporary      is table of dba_indexes.temporary%type;
  type dt_ind_colname        is table of dba_ind_columns.column_name%type;
  type dt_ind_desc           is table of dba_ind_columns.descend%type;
  type dt_col_comments       is table of dba_col_comments.comments%type;
  vt_text                    text_name;
  vt_colname                 col_name;
  vt_dtype                   dt_type;
  vt_dlength                 dt_length;
  vt_dnull                   dt_null;
  vt_dprecision              dt_precision;
  vt_dscale                  dt_scale;
  vt_default                 dt_default;
  vt_dcscondition            dc_scondition;
  vt_dcconname               dc_conname;
  vt_tablespace              dt_tablespace;
  vt_inittrans               dt_inittrans;
  vt_maxtrans                dt_maxtrans;
  vt_pctfree                 dt_pctfree;
  vt_parvalue                dt_parvalue;
  vt_parname                 dt_parname;
  vt_part_key                dt_par_key;
  vt_ind_name                dt_ind_name;
  vt_tab_name                dt_tab_name;
  vt_ind_type                dt_ind_type;
  vt_ind_unique              dt_ind_unique;
  vt_ind_pctfree             dt_ind_pctfree;
  vt_ind_initrans            dt_ind_initrans;
  vt_ind_maxtrans            dt_ind_maxtrans;
  vt_ind_tablespace          dt_ind_tablespace;
  vt_ind_colname             dt_ind_colname;
  vt_ind_desc                dt_ind_desc;
  vt_ind_partition           dt_ind_partition;
  vt_ind_temporary           dt_ind_temporary;
  vt_col_comment             dt_col_comments;
  outputline                 varchar2(4000);
  oerr                       varchar2(200);
  iv_nullable                varchar2(10);
  iv_dtpre                   varchar2(50);
  iv_default                 varchar2(200);
  iv_scondition              varchar2(4000);
  iv_tablespace              varchar2(30);
  iv_inittrans               varchar2(10);
  iv_maxtrans                varchar2(10);
  iv_pctfree                 varchar2(10);
  iv_rowcount                number;
  iv_rowcount1               number;
  iv_tabletype               varchar2(10);
  iv_iottype                 varchar2(10);
  iv_iotpname                varchar2(30);
  iv_iotstr                  varchar2(2000);
  iv_partition               varchar2(10);
  iv_duration                varchar2(20);
  iv_part_key                varchar2(200);
  iv_part_type               varchar2(30);
  iv_def_tablespace          varchar2(30);
  iv_def_pctfree             varchar2(10);
  iv_def_initrans            varchar2(10);
  iv_def_maxtrans            varchar2(10);
  iv_col_p                   varchar2(10);
  iv_col_p_count             number;
  iv_local                   varchar2(10);
  iv_tabcomment              varchar2(4000);


begin
	 if v_filename is not null then
	   iv_filename := v_filename;
	 else
	   iv_filename := v_objectname;
	 end if;


   if upper(trim(v_outobj)) = 'TABLE' then           --表及其相关索引定义输出
     if v_otype ='1' then                            --表定义输出
       select column_name,data_type,data_length,nullable,data_precision,data_scale,data_default  --获取表字段定义
         bulk collect into vt_colname,vt_dtype,vt_dlength,vt_dnull,vt_dprecision,vt_dscale,vt_default
         from  dba_tab_columns
         where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname))
         order by column_id;
       select constraint_name,search_condition                                          -- 获取除主键，唯一索引之外的check检查
         bulk collect into vt_dcconname,vt_dcscondition
         from dba_constraints
         where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname))
         and constraint_type ='C' ;
--         and instr(vt_dcscondition(idx_ind),'NOT NULL') = 0;  --对于long型字段操作必须先赋值给varchar2型，然后操作


       begin

         IF vt_colname.first IS not null THEN

       select temporary,iot_type,partitioned,duration                        --获取表类型
         into iv_tabletype,iv_iottype,iv_partition,iv_duration
         from dba_tables
         where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname)) ;

        if iv_iottype = 'IOT' then         --取出iot表的主键定义
          select constraint_name into iv_iotpname
            from dba_constraints
            where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname))
            and constraint_type ='P' ;
          select column_name bulk collect into vt_ind_colname
            from dba_ind_columns where index_owner = upper(trim(v_owner)) and table_owner = upper(trim(v_owner))
            and table_name = upper(trim(v_objectname))
            and index_name = iv_iotpname order by column_position ;
          iv_iotstr :='constraint '||rpad(iv_iotpname,31,' ')||'primary key ( ';
          for iot_i in vt_ind_colname.first..vt_ind_colname.last loop
            if iot_i = vt_ind_colname.last then
              iv_iotstr := iv_iotstr||vt_ind_colname(iot_i)||' )' ;
            else
              iv_iotstr := iv_iotstr||vt_ind_colname(iot_i)||' , ' ;
            end if;
          end loop;

       select tablespace_name,ini_trans,max_trans,pct_free  -- 获取iot普通表空间的索引表空间定义参数
         into iv_tablespace,iv_inittrans,iv_maxtrans,iv_pctfree from dba_indexes
         where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname))
         and index_name = iv_iotpname;

       select tablespace_name,ini_trans,max_trans,pct_free,high_value,partition_name  -- 获取iot分区表空间的索引表空间定义参数
         bulk collect into vt_tablespace,vt_inittrans,vt_maxtrans,vt_pctfree,vt_parvalue,vt_parname
         from dba_ind_partitions
         where index_owner = upper(trim(v_owner)) --and table_name = upper(trim(v_objectname))
         and index_name = iv_iotpname
         order by partition_position;



       else

       select tablespace_name,ini_trans,max_trans,pct_free  -- 获取普通表空间定义参数
         into iv_tablespace,iv_inittrans,iv_maxtrans,iv_pctfree from dba_tables
         where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname));

       select tablespace_name,ini_trans,max_trans,pct_free,high_value,partition_name  -- 获取分区表空间定义参数
         bulk collect into vt_tablespace,vt_inittrans,vt_maxtrans,vt_pctfree,vt_parvalue,vt_parname
         from dba_tab_partitions
         where table_owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname))
         order by partition_position;



       end if;

       if  trim(iv_tabletype) = 'Y' then
         outputline := 'create GLOBAL TEMPORARY TABLE '||v_objectname||'	(' ;
       else
         outputline := 'create  TABLE '||v_objectname||'	(' ;
       end if;
       utl_file.put_line(file_handle,outputline);


         for idx_ind IN vt_colname.first..vt_colname.last loop
           if vt_dnull(idx_ind) = 'Y' then
              iv_nullable := ' ' ;
           else
              iv_nullable := 'not null';
           end if;
           if vt_dtype(idx_ind)='NUMBER' and vt_dprecision(idx_ind) is null then
             iv_dtpre := 'NUMBER' ;
           elsif vt_dscale(idx_ind) = '0' then
             iv_dtpre := 'NUMBER('||vt_dprecision(idx_ind)||')';
           elsif vt_dscale(idx_ind) > '0' then
             iv_dtpre := 'NUMBER('||vt_dprecision(idx_ind)||','||vt_dscale(idx_ind)||')';
           elsif vt_dtype(idx_ind)='DATE' then
             iv_dtpre := 'DATE' ;
           elsif (vt_dtype(idx_ind)='CLOB' OR vt_dtype(idx_ind)='BLOB') then    --增加大字段类型不能带默认的4000字节的长度
             iv_dtpre := vt_dtype(idx_ind) ;
           else
             iv_dtpre := vt_dtype(idx_ind)||'('||vt_dlength(idx_ind)||')';
           end if;
           if vt_default(idx_ind) is null then
             iv_default := rpad(' ',50,' ');
           else
             iv_default := 'default '||vt_default(idx_ind) ;
           end if;
           if idx_ind = vt_colname.last then
             outputline := lpad(' ',3,' ')||rpad(vt_colname(idx_ind),30,' ')
                           ||rpad(iv_dtpre,20,' ')||rpad(iv_default,50,' ')||rpad(iv_nullable,10,' ');
             iv_rowcount :=1;
             IF vt_dcconname.first IS not null THEN                            --加入是否有其他check条件
             iv_rowcount1 :=1 ;
              for  j in vt_dcconname.first..vt_dcconname.last loop
               iv_scondition := vt_dcscondition(j);
               if instr(iv_scondition,'NOT NULL') = 0 then                    --判断其他check的总数
                iv_rowcount1 := iv_rowcount1 +1 ;
               end if;
             end loop;
             for idx_ind1 IN vt_dcconname.first..vt_dcconname.last loop        --检查表是否有除primary key ,uqiue之类的check约束
                iv_scondition := vt_dcscondition(idx_ind1);
                if instr(iv_scondition,'NOT NULL') = 0 then
                  iv_rowcount := iv_rowcount + 1;
                  if iv_rowcount =2 then
                    outputline :=outputline||' , ';
                    utl_file.put_line(file_handle,outputline);
                  end if;
                  if iv_rowcount = iv_rowcount1 then
                    outputline := lpad(' ',3,' ')||rpad('constraint',30,' ')||rpad(vt_dcconname(idx_ind1),46,' ')
                                 ||' check   '||'( '||rpad(iv_scondition,20,' ');
                    if iv_iottype = 'IOT' then     --增加iot表的主键写
                      outputline :=outputline||' , '||chr(10)||'   '||iv_iotstr ;
                    else
                      outputline :=outputline||' ) ';
                    end if;
                    utl_file.put_line(file_handle,outputline);
                    utl_file.put_line(file_handle,')');

                  else
                    outputline := lpad(' ',3,' ')||rpad('constraint',30,' ')||rpad(vt_dcconname(idx_ind1),46,' ')
                                 ||' check   '||'( '||rpad(iv_scondition,20,' ')||' ) '||' , ';
                  utl_file.put_line(file_handle,outputline);

                  end if;
               end if;

             end loop;
             if iv_rowcount = 1 then                                       --判断表没有constraint的写
               if iv_iottype = 'IOT' then   --增加iot表的主键写
                 outputline :=outputline||' , '||chr(10)||'   '||iv_iotstr ;
               end if;
               utl_file.put_line(file_handle,outputline);
               utl_file.put_line(file_handle,')');
             end if;
             else

               if iv_iottype = 'IOT' then   --增加iot表的主键写
                 outputline :=outputline||' , '||chr(10)||'   '||iv_iotstr ;
               end if;
               utl_file.put_line(file_handle,outputline);
               utl_file.put_line(file_handle,')');

             end if;                                                         --加入是否有其他check条件 结束

           else
             outputline := lpad(' ',3,' ')||rpad(vt_colname(idx_ind),30,' ')
                           ||rpad(iv_dtpre,20,' ')||rpad(iv_default,50,' ')||rpad(iv_nullable,10,' ')||'	,';
             utl_file.put_line(file_handle,outputline);
           end if;

         end loop;




         --   加入表空间存储参数

         if iv_iottype = 'IOT' then   --增加iot表的主键写
           utl_file.put_line(file_handle,'organization   index');
         end if;




         if trim(iv_tabletype) = 'Y' then           --对于全局临时表存储
           if trim(iv_duration) = 'SYS$SESSION' then
             outputline := '   on commit '||chr(10)||'   preserve rows '||chr(10)||'/'||chr(10)||chr(10) ;
           else
             outputline := '   on commit '||chr(10)||'   delete rows '||chr(10)||'/'||chr(10)||chr(10) ;
           end if;
           utl_file.put_line(file_handle,outputline);

         elsif  trim(iv_partition) = 'YES' then     --对于分区表
           if iv_iottype = 'IOT' then   --增加iot表获取的分区默认存储参数也不同
             select partitioning_type,def_tablespace_name,def_pct_free,def_ini_trans,def_max_trans -- 获取iot分区表空间的索引表空间默认表空间定义
               into iv_part_type,iv_def_tablespace,iv_def_pctfree,iv_def_initrans,iv_def_maxtrans  --和下面的去分区索引的略有不同（iv_part_type－iv_local)
               from dba_part_indexes   --取分区索引类型
               where  owner = upper(trim(v_owner)) and index_name = iv_iotpname ;
           else
             select partitioning_type,def_tablespace_name,def_pct_free,def_ini_trans,def_max_trans --获取分区表的默认表空间定义
               into iv_part_type,iv_def_tablespace,iv_def_pctfree,iv_def_initrans,iv_def_maxtrans
               from dba_part_tables   --取分区类型
               where  owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname)) ;
           end if;

           select column_name bulk collect into vt_part_key    --取分区字段
              from dba_part_key_columns
              where  owner = upper(trim(v_owner)) and name = upper(trim(v_objectname))
              order by column_position;
           iv_part_key := '';
           for idx_i in vt_part_key.first..vt_part_key.last loop
              iv_part_key := iv_part_key||vt_part_key(idx_i)||' ,' ;
              if idx_i = vt_part_key.last then
                iv_part_key := substr(iv_part_key,1,length(iv_part_key)-2) ;
              end if;
           end loop ;

           if iv_def_tablespace is null then          --分区表的defualt tablespace为空的话,不指定表空间名||'  tablespace &'||'part_tablespace_null '||chr(10)
             outputline := '  pctfree '||iv_def_pctfree||chr(10)||'  initrans '||iv_def_initrans||chr(10)
                         ||'  maxtrans '||iv_def_maxtrans||chr(10)
                         ||'partition by '||iv_part_type||' ( '||iv_part_key||' ) '||chr(10)||'(' ;
           else
             outputline := '  pctfree '||iv_def_pctfree||chr(10)||'  initrans '||iv_def_initrans||chr(10)
                         ||'  maxtrans '||iv_def_maxtrans||chr(10)||'  tablespace '||iv_def_tablespace||chr(10)
                         ||'partition by '||iv_part_type||' ( '||iv_part_key||' ) '||chr(10)||'(' ;
           end if;
           utl_file.put_line(file_handle,outputline);

--           case trim(iv_part_type)                        -- 对于3种不同分区方式的写窜
--             when 'RANGE' then iv_part_string := 'values less than ';
--            when 'LIST'  then iv_part_string := 'values  ';
--             when 'HASH'  then iv_part_string := '        ';
--           end case ;

           for i IN vt_parname.first..vt_parname.last loop

             if i = vt_parname.last  then
               case trim(iv_part_type)                        -- 对于3种不同分区方式的写窜
                 when 'RANGE' then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'values less than ( '
                                 ||vt_parvalue(i)||' )'||' initrans '||vt_inittrans(i)||' maxtrans '
                                 ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                                 ||chr(10)||')'||chr(10)||'/'||chr(10)||chr(10);
                 when 'LIST'  then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'values  ( '
                                 ||vt_parvalue(i)||' )'||' initrans '||vt_inittrans(i)||' maxtrans '
                                 ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                                 ||chr(10)||')'||chr(10)||'/'||chr(10)||chr(10);
                 when 'HASH'  then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'         '
                                 ||' initrans '||vt_inittrans(i)||' maxtrans '
                                 ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                                 ||chr(10)||')'||chr(10)||'/'||chr(10)||chr(10);
               end case ;
             else
               case trim(iv_part_type)                        -- 对于3种不同分区方式的写窜
                 when 'RANGE' then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'values less than ( '
                                 ||vt_parvalue(i)||' )'||' initrans '||vt_inittrans(i)||' maxtrans '
                                 ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                                 ||',';
                 when 'LIST'  then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'values  ( '
                                 ||vt_parvalue(i)||' )'||' initrans '||vt_inittrans(i)||' maxtrans '
                                 ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                                 ||',';
                 when 'HASH'  then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'         '
                                 ||' initrans '||vt_inittrans(i)||' maxtrans '
                                 ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                                 ||',';
               end case ;
             end if;
             utl_file.put_line(file_handle,outputline);

           end loop ;

         else                                       -- 对于普通表

           outputline := 'tablespace  '||iv_tablespace||chr(10)||
                         '   pctfree  '||iv_pctfree||chr(10)||
                         '   initrans  '||iv_inittrans||chr(10)||
                         '   maxtrans  '||iv_maxtrans||chr(10)||
                         '/ '||chr(10)||chr(10) ;

            utl_file.put_line(file_handle,outputline);

         end if;


     --增加commet语句,added by zhongsl at 20090109
     select comments  --获取表的comment
        into iv_tabcomment
        from  dba_tab_comments
       where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname));
     if iv_tabcomment is not null then
        outputline :='comment on table '||v_objectname||chr(10)||' is '''||iv_tabcomment||''';';
        utl_file.put_line(file_handle,outputline);
     end if;

     select  column_name,comments  --获取表字段的comment
        bulk collect into vt_colname,vt_col_comment
        from  dba_col_comments
       where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname));

     if vt_colname.first is not null then

       for ind_i in vt_colname.first..vt_colname.last loop
         if ind_i != vt_colname.last then
            outputline :='comment on column '||v_objectname||'.'||vt_colname(ind_i)||chr(10)||' is '''||vt_col_comment(ind_i)||''';';
         else
            outputline :='comment on column '||v_objectname||'.'||vt_colname(ind_i)||chr(10)||' is '''||vt_col_comment(ind_i)||''';'||chr(10);
         end if;
         utl_file.put_line(file_handle,outputline);
       end loop;
     end if;

     else
       outputline := 'the object is not exist ,please chech it ! ';
       utl_file.put_line(file_handle,outputline);
     end if ;



       exception
       when others then
         oerr := sqlerrm;
       end ;

     else                                            --索引定义输出

      begin
 --      select index_name,index_type,uniqueness,tablespace_name,ini_trans,max_trans,pct_free --取出所有索引定义
 --        bulk collect into vt_ind_name,vt_ind_type,vt_ind_unique,vt_ind_tablespace,vt_ind_initrans,vt_maxtrans,vt_pctfree
 --        from dba_indexes where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname));
         select index_name,table_name,index_type,uniqueness,tablespace_name,ini_trans,max_trans,pct_free,partitioned,temporary --取出索引定义-因为索引名称已经有了
           bulk collect into vt_ind_name,vt_tab_name,vt_ind_type,vt_ind_unique,vt_ind_tablespace,vt_ind_initrans,vt_ind_maxtrans,vt_ind_pctfree,
           vt_ind_partition,vt_ind_temporary
           from dba_indexes
           where owner = upper(trim(v_owner)) and index_name = upper(trim(v_objectname))
           and index_type not in ('IOT - TOP');             --增加对iot表的主键剥离

       if vt_ind_name.first is not null then


         for ind_i in vt_ind_name.first..vt_ind_name.last loop  --所有索引循环

           select column_name,descend bulk collect into vt_ind_colname,vt_ind_desc  --取出索引字段
             from dba_ind_columns where index_owner = upper(trim(v_owner)) and table_owner = upper(trim(v_owner))
             and index_name = trim(vt_ind_name(ind_i)) order by column_position ;
           if vt_ind_unique(ind_i) = 'NONUNIQUE' then
             outputline := 'create index '||vt_ind_name(ind_i)||' on '||vt_tab_name(ind_i)||' (' ;
           else
             iv_col_p :=' ';
               iv_col_p_count :=0 ;
         --    select constraint_type into iv_col_p from dba_constraints where owner = upper(trim(v_owner))
        --       and table_name = upper(trim(v_objectname))
        --       and constraint_name = vt_ind_name(ind_i) ;
             select count(*) into iv_col_p_count from dba_constraints where owner = upper(trim(v_owner))
         --      and table_name = upper(trim(v_objectname))
             and constraint_name = vt_ind_name(ind_i) and constraint_type ='P';
 --            if trim(iv_col_p) = 'P' then
             if iv_col_p_count > 0 then
               outputline := 'alter table '||vt_tab_name(ind_i)||chr(10)||'  add constraint '||vt_ind_name(ind_i)||
                             ' primary key '||' (' ;
               iv_col_p := 'P' ;
             else
               outputline := 'create unique index '||vt_ind_name(ind_i)||' on '||vt_tab_name(ind_i)||' (' ;
             end if ;
           end if ;

           utl_file.put_line(file_handle,outputline);
           for i in vt_ind_colname.first..vt_ind_colname.last loop
             if  i = vt_ind_colname.last then
               if trim(iv_col_p) = 'P' then                            --对于主键的不允许有asc,desc的标识，否则报错
                 outputline := '   '||rpad(vt_ind_colname(i),35,' ')||'      '||chr(10)||')' ;
               else
                 outputline := '   '||rpad(vt_ind_colname(i),35,' ')||' '||rpad(vt_ind_desc(i),5,' ')||chr(10)||')' ;
               end if;
             else
               if trim(iv_col_p) = 'P' then
                 outputline := '   '||rpad(vt_ind_colname(i),35,' ')||'      '||' ,' ;
               else
                 outputline := '   '||rpad(vt_ind_colname(i),35,' ')||' '||rpad(vt_ind_desc(i),5,' ')||' ,' ;
               end if;
             end if;
             utl_file.put_line(file_handle,outputline);
           end loop;
           if trim(iv_col_p) = 'P' then                          --对于主键多写一行
               utl_file.put_line(file_handle,'using index');
           end if;
           if vt_ind_partition(ind_i) = 'YES' then
             select locality,def_tablespace_name,def_pct_free,def_ini_trans,def_max_trans
               into iv_local,iv_def_tablespace,iv_def_pctfree,iv_def_initrans,iv_def_maxtrans
               from dba_part_indexes   --取分区索引类型
               where  owner = upper(trim(v_owner)) and index_name = trim(vt_ind_name(ind_i)) ;
             if iv_def_tablespace is null and iv_local ='LOCAL' then  --如果default tablespace 为空的话，则不指定表空间名||'  tablespace &'||'part_tablespace_null '||chr(10)
               outputline := '  pctfree '||iv_def_pctfree||chr(10)||'  initrans '||iv_def_initrans||chr(10)
                       ||'  maxtrans '||iv_def_maxtrans||chr(10)||'local '||'(' ;
             else
               outputline := '  pctfree '||iv_def_pctfree||chr(10)||'  initrans '||iv_def_initrans||chr(10)
                       ||'  maxtrans '||iv_def_maxtrans||chr(10)||'  tablespace '||iv_def_tablespace||chr(10)
                       ||'local '||'(' ;
             end if;
             utl_file.put_line(file_handle,outputline);
             select tablespace_name,ini_trans,max_trans,pct_free,high_value,partition_name  -- 获取分区表空间定义参数
               bulk collect into vt_tablespace,vt_inittrans,vt_maxtrans,vt_pctfree,vt_parvalue,vt_parname
               from dba_ind_partitions
               where index_owner = upper(trim(v_owner)) and index_name = trim(vt_ind_name(ind_i))
               order by partition_position;
             for i in vt_parname.first..vt_parname.last loop
               if i = vt_parname.last  then
                 if trim(iv_col_p) = 'P' then
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'         '
                               ||' initrans '||vt_inittrans(i)||' maxtrans '
                               ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                               ||chr(10)||')'||chr(10)||'nologging'||chr(10)||'/'||chr(10)||chr(10);
                 else
                   outputline := '   partition '||rpad(vt_parname(i),35,' ')||'         '
                               ||' initrans '||vt_inittrans(i)||' maxtrans '
                               ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                               ||chr(10)||')'||chr(10)||'parallel'||chr(10)||'nologging'||chr(10)||'/'||chr(10)||chr(10);
                   outputline := outputline||'alter index '||vt_ind_name(ind_i)||' noparallel  '||chr(10)||'/'||chr(10)||chr(10);
                 end if;
               else
                  outputline := '   partition '||rpad(vt_parname(i),35,' ')||'         '
                               ||' initrans '||vt_inittrans(i)||' maxtrans '
                               ||vt_maxtrans(i)||' pctfree '||vt_pctfree(i)||' tablespace '||vt_tablespace(i)
                               ||',';
                  utl_file.put_line(file_handle,outputline);
               end if;

             end loop;
           elsif vt_ind_temporary(ind_i) = 'Y'   then
             outputline := '/' ;

           else
             if trim(iv_col_p) = 'P' then
               outputline :='tablespace '||vt_ind_tablespace(ind_i)||chr(10)||'  pctfree '||vt_ind_pctfree(ind_i)
                               ||chr(10)||'  initrans '||vt_ind_initrans(ind_i)||chr(10)||'  maxtrans '
                               ||vt_ind_maxtrans(ind_i)||chr(10)||'nologging'||chr(10)||'/'||chr(10)||chr(10) ;
             else
               outputline :='tablespace '||vt_ind_tablespace(ind_i)||chr(10)||'  pctfree '||vt_ind_pctfree(ind_i)
                               ||chr(10)||'  initrans '||vt_ind_initrans(ind_i)||chr(10)||'  maxtrans '
                               ||vt_ind_maxtrans(ind_i)||chr(10)||'parallel'||chr(10)
                               ||'nologging'||chr(10)||'/'||chr(10)||chr(10) ;
               outputline := outputline||'alter index '||vt_ind_name(ind_i)||' noparallel  '||chr(10)||'/'||chr(10)||chr(10);
             end if;

           end if ;


           utl_file.put_line(file_handle,outputline);

           iv_col_p :=' ';---复原此主建标志位(由于p_output_file过程是每个索引调用退出的,因此此变量会自动复位


         end loop;

       else             --没有索引

         null;

       end if;

      exception
      when others then
         oerr := sqlerrm;
      end ;

     end if;



   elsif upper(trim(v_outobj)) = 'VIEW'    then     --view视图输出

     select text into outputline from dba_views
       where owner =upper(trim(v_owner)) and view_name =upper(trim(v_objectname)) ;
     utl_file.put_line(file_handle,'create or replace view '||upper(trim(v_objectname))||' as ');
     utl_file.put_line(file_handle,outputline);
     utl_file.put_line(file_handle,'/'||chr(10)||chr(10));

   else                                              --其他输出对象脚本开始

	 select substr(text,1,length(text)-1)  BULK COLLECT into vt_text from dba_source  where
   owner =upper(trim(v_owner))  and name =upper(trim(v_objectname))
   and type =upper(trim(v_outobj))   order by line ;  --去掉表里面的数据每行都有一个换行符
	 begin                                              --输出对象脚本开始
	   IF vt_text.last IS NOT NULL THEN
       for idx_ind IN vt_text.first..vt_text.last loop
         if idx_ind = 1 then
 --        vt_text(idx_ind) := 'create or replace '||vt_text(idx_ind) ; --修改为下面的语句，防止超过VARCHR2(4000)而输出报错
           utl_file.put_line(file_handle,'create or replace ');
         elsif idx_ind=vt_text.last then
           if trim(vt_text(idx_ind)) != ' ' then
             vt_text(idx_ind) := vt_text(idx_ind)||';' ;
           end if;
         end if;
     	   utl_file.put_line(file_handle,vt_text(idx_ind));
       end loop;
       utl_file.put_line(file_handle,'/'||chr(10)||chr(10));
     else
       outputline := 'the object is not exist ,please chech it ! ';
       utl_file.put_line(file_handle,outputline);
     end if ;
     exception
     when others then
       oerr := sqlerrm;
   end ;                                             --输出对象脚本结束


   end if ;                                          --表及其所有对象脚本输出结束


exception
		when others then
	  oerr := sqlerrm;
end p_output_file_single;


begin

	if v_outtype not in ('1','2') then
	  outflag :='the outtype param is wrong ,pls input the correct value !';
	  return;
	end if;

	outflag :='ok';

	IF (v_path is null) THEN
	   select value into iv_filepath from v$parameter where name = 'utl_file_dir';
	ELSE
		iv_filepath := trim(v_path);
	END IF;

	if v_outtype ='2' then                                                                  --按表导出数据部分
	  	  put_cname := '';

	  iv_objectname := nls_upper(v_objectname);
	  iv_owner:= nls_upper(v_owner);
    iv_filename := v_objectname;
	  file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w',32767);

    select column_name,data_type bulk collect into vt_col,vt_dtype from dba_tab_columns where table_name =iv_objectname
           and owner =iv_owner ;
    if vt_col.last is not null then                ---如果表存在

      for v_index in vt_col.first..vt_col.last loop ---循环取出字段开始
	      if vt_dtype(v_index) = 'DATE' then
	         get_cname := 'to_char('||trim(vt_col(v_index))||',''yyyy-mm-dd hh24:mi:ss'')';
	      else
	         get_cname := trim(vt_col(v_index));
	      end if;
        if v_index =1 then
           put_cname :=get_cname;
        else
           --put_cname :=put_cname ||'||'||''''||v_sep||''''||'||'||get_cname;
           put_cname :=put_cname||','||get_cname;
        end if;
	    END LOOP;

      select_cname := 'select '||put_cname||' from '||iv_owner||'.'||iv_objectname;
/*      result := '';                       ---对于select_cname拼串出来的结果超出4000字符的就会报错，需采用下面的方法
      OPEN cursor_select for select_cname;   ---循环写出表数据
	    	FETCH cursor_select into result;
	    	WHILE cursor_select%FOUND LOOP
	  	  	outputline := result;
	  	    utl_file.put_line(file_handle,outputline);
	  	 	FETCH cursor_select into result;
	  	END LOOP;
   	  CLOSE cursor_select;                 ---循环写出表数据结束*/

      V_RowQuery := rowQuery();
      c := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(c, select_cname, DBMS_SQL.NATIVE);
      DBMS_SQL.DESCRIBE_COLUMNS2(c, col_cnt, rec_tab);
      col_num := rec_tab.first;
      IF (col_num IS NOT NULL) THEN
        LOOP
          col_counter := col_counter + 1;
          col_num := rec_tab.next(col_num);
        EXIT WHEN (col_num IS NULL);
        END LOOP;
      END IF;
      V_RowQuery.EXTEND(col_counter);
      FOR v_Counter IN 1..col_counter LOOP
      --DBMS_OUTPUT.PUT_LINE('Defining Column: ' || v_Counter);
        DBMS_SQL.DEFINE_COLUMN(c, v_Counter, v_RowQuery(v_Counter), 200);
      END LOOP;
      d := DBMS_SQL.EXECUTE(c);
      LOOP
        if DBMS_SQL.FETCH_ROWS(c) = 0 THEN
          DBMS_OUTPUT.PUT_LINE('Exiting....');
          exit;
        END IF;
        outputline :='';
        FOR v_Counter2 IN 1..col_counter LOOP
          DBMS_SQL.column_value(c, v_counter2, v_RowQuery(v_counter2));
          if v_Counter2 = 1 then
           outputline :=v_RowQuery(v_counter2);
          else
           outputline :=outputline||v_sep||v_RowQuery(v_counter2);
          end if;
        END LOOP;
        utl_file.put_line(file_handle,outputline);
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(c);


    else
     	outputline := 'the table is not exist ,pls check it !';
	  	utl_file.put_line(file_handle,outputline);
    end if;


	  utl_file.fclose(file_handle);

	 else                                                                                    -- 按表导出数据部分结束

	   if  v_objectname is null then       ---按对象类型批量导出

       if v_outmode ='1' then            ---输出为单个文件

         if upper(trim(v_outobj)) ='TABLE' then
           select distinct (decode(temporary,'Y','global temporary tables',tablespace_name))  --取出表的表空间名称－即文件名
             bulk collect into  vt_objname from dba_tables  --因为下面公用vt_objname为空判断,和vt_tab_tablespace对换
             where owner =upper(trim(v_owner))   ;

           select distinct (decode(temporary,'Y','global temporary indexes',tablespace_name))  --取出索引的表空间名称－即文件名
             bulk collect into  vt_ind_tablespace from dba_indexes  --因为下面公用vt_objname为空判断
             where owner =upper(trim(v_owner))   ;

         else
	        select object_name  BULK COLLECT INTO vt_objname from dba_objects
            where owner =upper(trim(v_owner))  and object_type =upper(trim(v_outobj))
            order by object_name desc;
         end if;

         IF vt_objname.last IS NOT NULL THEN

           if upper(trim(v_outobj)) ='TABLE' then

             for j in vt_objname.first..vt_objname.last loop           --表对象输出
               if vt_objname(j) is null then
                 iv_filename := 'PARTITION_TABLE'||'.sql';                --分区表
                 select table_name bulk collect into vt_tab_tablespace from dba_tables
                   where owner =upper(trim(v_owner)) and tablespace_name is null and temporary ='N'
                   order by table_name desc;
               else
                 iv_filename := vt_objname(j)||'.sql';
                 if vt_objname(j) = 'global temporary tables' then       --全局临时表
                   select table_name bulk collect into vt_tab_tablespace from dba_tables
                     where owner =upper(trim(v_owner)) and temporary ='Y'
                     order by table_name desc;
                 else                                             --普通表按表空间名字输出
                   select table_name bulk collect into vt_tab_tablespace from dba_tables
                     where owner =upper(trim(v_owner)) and tablespace_name = vt_objname(j)
                     order by table_name desc;
                 end if;
               end if ;
               file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w');
               for i in vt_tab_tablespace.first..vt_tab_tablespace.last loop --按表的表空间表对象输出
                 p_output_file_single(v_owner,iv_filename,trim(vt_tab_tablespace(i)),v_outobj,file_handle);
               end loop ;
               utl_file.fclose(file_handle);

             end loop ;

             for k in vt_ind_tablespace.first..vt_ind_tablespace.last loop           --索引对象输出

               if vt_ind_tablespace(k) is null then          --分区索引输出
                 iv_filename := 'PARTITION_INDEX'||'.sql';
                 select index_name bulk collect into vt_objname from dba_indexes
                   where owner =upper(trim(v_owner)) and tablespace_name is null and temporary ='N'
                   order by table_name,index_name desc;
               else
                 iv_filename := 'IDX_'||vt_ind_tablespace(k)||'.sql';
                 if vt_ind_tablespace(k) = 'global temporary indexes' then    --全局临时表索引输出
                   select index_name bulk collect into vt_objname from dba_indexes
                     where owner =upper(trim(v_owner)) and temporary ='Y'
                     order by table_name,index_name desc;
                 else
                   select index_name bulk collect into vt_objname from dba_indexes   --普通索引输出
                     where owner =upper(trim(v_owner)) and tablespace_name = vt_ind_tablespace(k)
                     order by table_name,index_name desc;
                 end if;
               end if ;
               file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w');
               for i in vt_objname.first..vt_objname.last loop --按索引的表空间表对象输出
                 p_output_file_single(v_owner,iv_filename,trim(vt_objname(i)),v_outobj,file_handle,'2');
               end loop ;
               utl_file.fclose(file_handle);

             end loop ;


           else                                                    --非表对象输出

             iv_filename := 'outputfile'||'.sql';
	           file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w',32767);
             for v_index in vt_objname.first..vt_objname.last loop
               p_output_file_single(v_owner,iv_filename,trim(vt_objname(v_index)),v_outobj,file_handle);
             end loop;
             utl_file.fclose(file_handle);

           end if;

         else
           iv_filename := upper(trim(v_owner))||'.sql';
	         file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w',32767);
           outputline := 'the owner object is not exist ,please chech it ! ';
           utl_file.put_line(file_handle,outputline);
           utl_file.fclose(file_handle);
         end if ;


       else                              ---按对象名分别输出文件

	       select object_name  BULK COLLECT INTO vt_objname from dba_objects  where
         owner =upper(trim(v_owner))  and object_type =upper(trim(v_outobj)) ;
         IF vt_objname.last IS NOT NULL THEN
           for v_index in vt_objname.first..vt_objname.last loop
             iv_filename := trim(vt_objname(v_index))||'.sql';
	           file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w');
             if upper(trim(v_outobj)) = 'TABLE' then
               p_output_file_single(v_owner,iv_filename,trim(vt_objname(v_index)),v_outobj,file_handle);
               select index_name            --取出所有索引定义
                 bulk collect into vt_ind_name
                 from dba_indexes where owner = upper(trim(v_owner)) and table_name = trim(vt_objname(v_index));
               if vt_ind_name.first is not null then
                 if v_outmode = 3 then -- 按对象名分别输出时,索引和表也分开输出
                   utl_file.fclose(file_handle);
                   iv_filename := trim(vt_objname(v_index))||'-IND'||'.sql';
	                 file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w');
                 end if;
                 for ind_j in vt_ind_name.first..vt_ind_name.last loop
                   p_output_file_single(v_owner,iv_filename,vt_ind_name(ind_j),v_outobj,file_handle,'2') ;
                 end loop;

               end if;

             else
               p_output_file_single(v_owner,iv_filename,trim(vt_objname(v_index)),v_outobj,file_handle);
             end if;
             utl_file.fclose(file_handle);
           end loop;


         else
           iv_filename := upper(trim(v_owner))||upper(trim(v_outobj))||'.sql';
	         file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w',32767);
           outputline := 'the object is not exist ,please chech it ! ';
           utl_file.put_line(file_handle,outputline);
           utl_file.fclose(file_handle);
         end if ;


       end if;

	   else                                ---按单个对象名称导出

	      iv_filename := v_objectname||'.sql';
        file_handle :=utl_file.fopen(iv_filepath,iv_filename,'w');
        if upper(trim(v_outobj)) ='TABLE' then
          p_output_file_single(v_owner,iv_filename,v_objectname,v_outobj,file_handle) ;
          utl_file.fclose(file_handle);
          select index_name            --取出所有索引定义
            bulk collect into vt_ind_name
            from dba_indexes where owner = upper(trim(v_owner)) and table_name = upper(trim(v_objectname));
          if vt_ind_name.first is not null then
            iv_filename_ind := v_objectname||'-IND'||'.sql';
            file_handle_ind :=utl_file.fopen(iv_filepath,iv_filename_ind,'w');
            for ind_j in vt_ind_name.first..vt_ind_name.last loop
              p_output_file_single(v_owner,iv_filename_ind,vt_ind_name(ind_j),v_outobj,file_handle_ind,'2') ;
            end loop;
           -- outputline := 'exit ; ';
            utl_file.put_line(file_handle_ind,outputline);
            utl_file.fclose(file_handle_ind);
          end if;
        else
	        p_output_file_single(v_owner,iv_filename,v_objectname,v_outobj,file_handle) ;
        end if;
	      utl_file.fclose(file_handle);

	   end if ;                            ---按对象导出定义结束
   end if;

exception
		when others then
	  outflag := sqlerrm;
end p_output_file;
/

