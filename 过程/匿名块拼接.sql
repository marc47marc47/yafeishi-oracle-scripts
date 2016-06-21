declare
 v_year  number;
 v_month number;
begin
  v_year := 2010;
  v_month := 1;
  for i in 0..6 loop
    for j in 0..11 loop 
         dbms_output.put_line('alter table TS_BH_BILL_'||trim(to_char(v_year+i,'0000'))||trim(to_char(v_month+j,'00'))||' add NO_TAX_FEE NUMBER(11);      ');
         dbms_output.put_line('alter table TS_BH_BILL_'||trim(to_char(v_year+i,'0000'))||trim(to_char(v_month+j,'00'))||' add TAX_FEE NUMBER(11);         ');
         dbms_output.put_line('alter table TS_BH_BILL_'||trim(to_char(v_year+i,'0000'))||trim(to_char(v_month+j,'00'))||' add TAX_RATE NUMBER(5);         ');
         dbms_output.put_line('alter table TS_BH_BILL_'||trim(to_char(v_year+i,'0000'))||trim(to_char(v_month+j,'00'))||' add MIX_ITEM_ID NUMBER(6);      ');
         dbms_output.put_line('alter table TS_BH_BILL_'||trim(to_char(v_year+i,'0000'))||trim(to_char(v_month+j,'00'))||' add NO_TAX_BALANCE NUMBER(11);  ');
         dbms_output.put_line('alter table TS_BH_BILL_'||trim(to_char(v_year+i,'0000'))||trim(to_char(v_month+j,'00'))||' add TAX_BALANCE NUMBER(11);     ');
          dbms_output.put_line('');
    end loop;
 end loop;  
end;      