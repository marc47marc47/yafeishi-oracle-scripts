select (1-(phy.value/(db.value+cons.value)))*100 "Cache Hit Percentage"
from v$sysstat phy,v$sysstat db,v$sysstat cons
where phy.name='physical reads' and
db.name='db block gets' and
cons.name='consistent gets';

--Library Hit
select round(sum(pinhits)/sum(pins)*100,2) "Library Hit(%)"
from v$librarycache;

--Latch Hit
select round((1-sum(misses)/sum(gets))*100,2) "Latch Hit(%)"
from v$latch;

--Buffer Hit
select round(100*(1-(a.value-b.value-nvl(c.value,0))/d.value),2) "Buffer Hit(%)"
from v$sysstat a,v$sysstat b,v$sysstat c,v$sysstat d
where a.name='physical reads'
and b.name='physical reads direct'
and c.name='physical reads direct (lob)'
and d.name='session logical reads';


