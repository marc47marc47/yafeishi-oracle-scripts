create or replace procedure P_SYS_GEN_CODE_TEMPLATE1
(i_vc_owner in varchar2,
 i_vc_tablename in varchar2,
 o_vc_return_flag out varchar2) is
/*
���ܣ� �����Զ�����������ʹ��ģ��һ(��������δ֪����µ�һ��һ���������Ĵ���ܹ�
       �����ڱ��������ĳ���ȫ��Ϊ6�ı�����������ĳ��Ȳ��ǹ̶�Ϊ6�����ӡCursor��ӦSELECT���ʱ�ܿ��ܻ���ִ�λ����Ҫ�ֹ�����
���ߣ� cuihua
�������ڣ�2009-04-13

���������
i_vc_owner:����������ṹ�ı������ڵ�schema��
i_vc_tablename������������ṹ�ı���

���������
o_vc_returnflag�������жϸô洢�����Ƿ�ɹ�ִ�У����ڳ�����洢��Ӧ�Ĵ���ԭ��
�������ֵ�ĵ�һλΪS��������ô洢���̳ɹ�ִ�У�û�д���
�������ֵ�ĵ�һλΪE��������ô洢����ִ��ʧ�ܣ��������ԭ��Ϊ����ֵ�ĵڶ�λ�����һλ��

�������������
��

���õ��Ĵ洢���̣�
��

ʹ�����ͣ�
��
*/

type typ_columnname is table of dba_tab_columns.COLUMN_NAME%type index by binary_integer;
columnnames typ_columnname;

vc_temp varchar2(4000);
n_temp number(13);
n_itemp number(13);

begin

  o_vc_return_flag := 'S';
  
  select column_name bulk collect into columnnames from dba_tab_columns where owner=i_vc_owner and table_name=i_vc_tablename;
  
  ----------------------����Bulk collect into���������---------Begin--------------------------------------------------------------------------------------
  dbms_output.put_line('  --��������fetch������������ֵ��1000;');
  dbms_output.put_line('  CN_BATCH_SIZE constant pls_integer := 1000;');
  
  dbms_output.put_line(chr(13));
   
  dbms_output.put_line('  --������fetch�����Ľ���������飬����ֵ��1000'); 
  dbms_output.put_line('  type typ_result is record');  
  
  vc_temp := '  (';
  dbms_output.put(vc_temp);
  
  for i in columnnames.first .. columnnames.last loop    
    vc_temp := lower(columnnames(i)) || ' ' || lower(i_vc_tablename) || '.' || lower(columnnames(i)) || '%type,';
    if( i = 1 ) then
      dbms_output.put_line(vc_temp);
    else
      dbms_output.put_line('  ' || vc_temp);
    end if;     
  end loop;
  
  dbms_output.put_line('  rid urowid);');
  dbms_output.put_line('  type typ_results is varray(1000) of typ_result;');
  dbms_output.put_line('  results typ_results;');  
  ----------------------����Bulk collect into���������---------End--------------------------------------------------------------------------------------

  
  ----------------------����cursor����-------------------------Begin--------------------------------------------------------------------------------------
  dbms_output.put_line(chr(13));
  dbms_output.put_line('  cur_' || lower(i_vc_tablename) || ' sys_refcursor;');
   
  vc_temp := null;
  for i in columnnames.first .. columnnames.last loop 
    if( i = columnnames.count ) then
      vc_temp := vc_temp || lower(columnnames(i));
    else
      vc_temp := vc_temp || lower(columnnames(i)) || ',';      
    end if;                     
  end loop;
  
  n_temp := trunc(length(vc_temp)/49) + 1;
  n_itemp := 0;
  for i in 0 .. n_temp loop
    n_itemp := i*49 + 1;
    if( n_itemp <= length(vc_temp) ) then
      if( n_itemp = 1 ) then
        --�������n_temp=1,�������������ֶ���С��7
        if ( n_temp = 1 ) then
          dbms_output.put_line('  vc_sql varchar2(4000) :=  ''select ' || substr(vc_temp,n_itemp,49) || ',rowid from ' || lower(i_vc_tablename) || ' where �Զ���Ĵ��󶨱�����where����'';');
        else
          dbms_output.put_line('  vc_sql varchar2(4000) :=  ''select ' || substr(vc_temp,n_itemp,49));
        end if;        
      else
        if( n_itemp + 49 >= length(vc_temp) ) then
          dbms_output.put_line('       ' || substr(vc_temp,n_itemp,49) || ',rowid from ' || lower(i_vc_tablename) || ' where �Զ���Ĵ��󶨱�����where����'';');
        else
          dbms_output.put_line('       ' || substr(vc_temp,n_itemp,49));
        end if;        
      end if;       
    end if;                
  end loop;  
  ----------------------����cursor����--------------------------End--------------------------------------------------------------------------------------

  
  ----------------------����cursor��ѭ�����ֵĴ���--------------begin--------------------------------------------------------------------------------------
  dbms_output.put_line(chr(13));  
  dbms_output.put_line('begin');  
  dbms_output.put_line(chr(13));
  
  dbms_output.put_line('  --���󶨱�����ref cursor�Ĵ򿪷�ʽ');
  dbms_output.put_line('  open cur_' || lower(i_vc_tablename) || ' for vc_sql using variable;');
  dbms_output.put_line(chr(13));  
  
  dbms_output.put_line('  --��һ�ִ�����ʽ��һ��һ������');
  dbms_output.put_line('  loop');
  dbms_output.put_line('    fetch cur_' || lower(i_vc_tablename) || ' bulk collect into results limit CN_BATCH_SIZE;');
  dbms_output.put_line(chr(13));
  dbms_output.put_line('    for i in 1 .. results.count loop');
  dbms_output.put_line('      execute immediate ''�Զ����SQL�ı�'' using results(i).����;');
  dbms_output.put_line('    end loop;');
  dbms_output.put_line(chr(13));
  dbms_output.put_line('    exit when results.count < CN_BATCH_SIZE;');
  dbms_output.put_line('  end loop;');
  dbms_output.put_line('  close cur_' || lower(i_vc_tablename) || ';');
  ----------------------����cursor��ѭ�����ֵĴ���---------------End-------------------------------------------------------------------------------------- 
  
exception
  when others then
    o_vc_return_flag := 'E' || '_' || sqlcode || '_' || sqlerrm;    
    return;
  
end P_SYS_GEN_CODE_TEMPLATE1;
/