select value,count(*) from v$sesstat
where statistic#=(select statistic# from v$sysstat where name ='session cursor cache count') 
and sid in (select sid from v$session where type='USER')
group by value;

select 'session_cached_cursors' parameter,
       lpad(value, 5) value,
       decode(value, 0, '  n/a', to_char(100 * used / value, '990') || '%') usage
  from (select max(s.value) used
          from v$statname n, v$sesstat s
         where n.name = 'session cursor cache count'
           and s.statistic# = n.statistic#),
       (select value from v$parameter where name = 'session_cached_cursors')
union all
select 'open_cursors',
       lpad(value, 5),
       to_char(100 * used / value, '990') || '%'
  from (select max(sum(s.value)) used
          from v$statname n, v$sesstat s
         where n.name in
               ('opened cursors current', 'session cursor cache count')
           and s.statistic# = n.statistic#
         group by s.sid),
       (select value from v$parameter where name = 'open_cursors') 
