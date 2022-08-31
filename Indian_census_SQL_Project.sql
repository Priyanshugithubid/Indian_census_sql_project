-- dataset taken from sites
-- 1. https://www.census2011.co.in/district.php
-- 2. https://www.census2011.co.in/literacy.php

select * from indian_census.dataset1;
select * from indian_census.dataset2;
/* number of rows in our dataset*/
select count(*) from indian_census.dataset1;
select count(*) from indian_census.dataset2;

/* dataset for jharkhand and bihar*/
select * from indian_census.dataset1 where state in ('Jharkhand','Bihar'); 
/* population in india*/
 select sum(population) as p from indian_census.dataset2;
 /*avg growth*/
 select avg(growth) from indian_census.dataset1;
/*avg growth state wise*/
 select state,avg(growth) from indian_census.dataset1 group by state order by avg(growth);
/*avg sex ratio*/
select state,round(avg(sex_ratio),0) as avg_sex_ratio from indian_census.dataset1 group by state order by avg_sex_ratio desc; 
/*select states having avg literacy rate>90*/
select state,round(avg(literacy),0) as literacy from indian_census.dataset1 group by state having literacy>90 order by literacy desc;
/*select top 3 states having highest growth rate*/
select state,avg(growth) from indian_census.dataset1 group by state order by avg(growth) desc limit 3;
/*select bottom 3 states having lowest growth rate*/
select state,avg(growth) from indian_census.dataset1 group by state order by avg(growth) limit 3;
/*select bottom 3 states having lowest sex ratio*/
select state,round(avg(sex_ratio)) as avg_sex_ratio from indian_census.dataset1 group by state order by avg_sex_ratio limit 3;

/*select top 3 and bottom three states on basis of literacy(temproray table method)*/

DROP TABLE if exists topstates;
create temporary table topstates
(
state text,
topstate int
);
insert into topstates(state,topstate)
select state,round(avg(literacy),0) as literacy from indian_census.dataset1 group by state order by literacy desc;
 
 select * from topstates limit 3;
 DROP TABLE if exists bottomstates;
create temporary table bottomstates
(
state text,
bottomstate int
);
insert into bottomstates(state,bottomstate)
select state,round(avg(literacy),0) as literacy from indian_census.dataset1 group by state order by literacy;
 
 select * from bottomstates limit 3;
 /*union operator*/
 select * from 
 (select * from topstates limit 3)a 
 union
 select * from
(select * from bottomstates limit 3)b;
/*states starting from a OR  b*/
select DISTINCT STATE from indian_census.dataset1 where LEFT(State,1)='a' or LEFT(STATE,1)='b';
/*states starting with A and ending with h*/
select distinct state from indian_census.dataset1 where lower(state) like 'a%h';


/*number of male and females in every city*/
select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males,round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from indian_census.dataset1 a inner join indian_census.dataset2 b on a.district=b.district)c;
/*total literacy rate*/
select d.state,sum(d.literate) as state_literate,sum(illiterate) as state_illiterate from
(select c.district,c.state,round(literacy*c.population,0) as literate,round((1-c.Literacy)*c.Population,0) as illiterate from
(select a.district,a.state,a.literacy/1000 as literacy,b.population from indian_census.dataset1 a inner join indian_census.dataset2 b on a.district=b.district)c order by literate desc)d group by state order by state_literate;

/*population in previous census*/
select sum(f.previous_census),sum(f.present_census) from
(select e.state,sum(e.previous_census) as previous_census,sum(e.present_population) as present_census from
(select d.district,d.state,round(d.population/(1+growth),0) as previous_census,d.population as present_population from
(select a.district,a.state,a.growth Growth,b.population from indian_census.dataset1 a inner join indian_census.dataset2 b on a.district=b.district)d)e group by e.state)f;

/*area/population*/
select c.x/c.t as previous_area_ratio_population,c.x/c.v as present_area_population_ratio from
(
select q.previous_census as t,q.present_census as v,r.total_area as x from 
(
select '1' as keyy,g.* from
(select sum(f.previous_census) as previous_census,sum(f.present_census) as present_census from
(select e.state,sum(e.previous_census) as previous_census,sum(e.present_population) as present_census from
(select d.district,d.state,round(d.population/(1+growth),0) as previous_census,d.population as present_population from
(select a.district,a.state,a.growth Growth,b.population from indian_census.dataset1 a inner join indian_census.dataset2 b on a.district=b.district)d)e group by e.state)f)g)q
inner join
(select '1' as keyy,z.* from 
(select sum(area_km2) total_area from indian_census.dataset2)z)r on q.keyy=r.keyy)c;

/*window function*/
/*top 3 districts from each state on basis of literacy rate*/
select a.* from
(select district,state,literacy,rank() over (partition by state order by literacy desc) rnk from indian_census.dataset1)a
where a.rnk in (1,2,3) order by state;