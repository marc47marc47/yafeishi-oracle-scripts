create table datafile_all (name varchar2(50));
alter table datafile_all  add s number;
truncate table datafile_all; 

drop table file_useable;
create table  file_useable (name varchar2(50),s number);
create table  file_useable (name varchar2(50));
truncate table file_useable;
insert into  file_useable 
(select name 
from datafile_all
minus
select file_name
from dba_data_files@to_newcrm);
commit;


begin
   for i in 1..6 loop
      for j  in 1..60 loop
         insert into datafile_all values('/dev/rrcrmvg'||i||'_4_'||trim(to_char(j,'099')),4); 
         insert into datafile_all values('/dev/rrcrmvg'||i||'_8_'||trim(to_char(j,'099')),8); 
      end loop;
      for j  in 1..20 loop
         insert into datafile_all values('/dev/rrcrmvg'||i||'_2_'||trim(to_char(j,'099')),2);  
      end loop;
   end loop;
   commit;       
end ;         


begin
   for i in 7..14 loop
      for j  in 1..98 loop
         insert into datafile_all values('/dev/rrcrmvg'||i||'_4_'||trim(to_char(j,'099')),4);  
      end loop;
      for j  in 1..60 loop
         insert into datafile_all values('/dev/rrcrmvg'||i||'_8_'||trim(to_char(j,'099')),8);  
      end loop;
   end loop;
   commit;       
end ;  


select t.*,substr(t.name,-3),substr(t.name,13,2),substr(t.name,1,14) 
from datafile_all t 
where t.s=8  and length(t.name)=20 and substr(t.name,13,2) not in ('14','15')
order by substr(t.name,-3),substr(t.name,13,2);

 