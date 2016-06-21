set linesize 132
column name format a40
column value format a25
select x.ksppinm name,
       y.ksppstvl value,
       y.ksppstdf isdefault,
       decode(bitand(y.ksppstvf, 7),
              1,
              'MODIFIED',
              4,
              'SYSTEM_MOD',
              'FALSE') ismod,
       decode(bitand(y.ksppstvf, 2), 2, 'TRUE', 'FALSE') isadj
  from sys.x$ksppi x, sys.x$ksppcv y
 where x.inst_id = userenv('Instance')
   and y.inst_id = userenv('Instance')
   and x.indx = y.indx
   and x.ksppinm like '%&&1%'
 order by translate(x.ksppinm, ' _', ' ');