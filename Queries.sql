--1 which team has won the maximum gold medals over the years.
select top 1 
 a.team , 
 count(distinct ae.event) as cnt 
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
where medal='gold'
group by a.team
order by cnt desc;

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
with cte as (
select 
 a.team,
 ae.year,
 count(case when ae.medal='silver' then ae.medal end) as cnt 
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
group by a.team, ae.year
),
bte as (
select *,
 sum(cnt) over (partition by team) as total_silver,
 max(cnt) over (partition by team) as max_silver, 
 ROW_NUMBER() OVER (PARTITION BY team ORDER BY year DESC) AS rn
from cte
where cnt>0)
select team , year as year_of_max_silver,total_silver from bte 
where rn=1;

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with cte as(
select 
 a.name,
 ae.medal
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
)
select top 1
 name ,
 count(1) as no_of_gold_medals
from cte 
where name not in (select distinct name from cte where medal in ('Silver','Bronze'))
and medal='Gold'
group by name
order by no_of_gold_medals desc;

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with cte as (
select 
 a.name,
 ae.year,
 count(case when medal='gold' then medal end) as total_gold_yearly
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='gold'
group by a.name,ae.year
),
bte as (
select *,
 rank() over (partition by year order by total_gold_yearly desc) as rk 
from cte)
select 
 year,
 total_gold_yearly,
 STRING_AGG(name,',') as names 
from bte 
where rk=1
group by year,total_gold_yearly
order by year;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
with cte as (
select 
 ae.event,
 ae.medal,
 ae.year,rank() over(partition by ae.medal order by ae.year asc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where a.team='India' and ae.medal!='NA'
)
select distinct 
 event,
 medal,
 year 
from cte
where rn=1;

--6 find players who won gold medal in summer and winter olympics both.
select distinct
 a.name 
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where ae.medal='gold'
group by a.name
having count(distinct ae.season)=2;

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select 
 a.name,
 ae.year 
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where ae.medal !='NA'
group by a.name,ae.year
having count(distinct ae.medal)=3;

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as (
select * 
from athlete_events ae  
inner join athletes a on a.id=ae.athlete_id
where ae.year>=2000 and ae.medal='gold' and ae.season='summer'
),
bte as (
select *,
 lead(year) over (partition by name,event order by year) as nxt_olympic,
 lead(year,2) over (partition by name,event order by year) as second_nxt_olympic 
from cte)
select 
 name,
 event,
 year,
 nxt_olympic,
 second_nxt_olympic 
from bte
where second_nxt_olympic = nxt_olympic+4 and nxt_olympic=year+4;
