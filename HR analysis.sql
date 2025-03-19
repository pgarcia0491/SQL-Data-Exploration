-- Import csv file and analyze whole table
-- correct termdate (termination) so that there are no dates in the future
select * from hr;
-- clean the date, then create a new row to apply the datatype of date
use hr1;
update hr set termdate  = format(convert(datetime, left(termdate, 19), 120), 'yyyy-mm-dd');

-- alter table hr add  term_date DATE; 
update hr set term_date = case when termdate is not null and isdate(termdate)= 1
then cast(termdate as date) else null end;

-- add age column

alter table hr add age int;

update hr set age = datediff(year, birthdate, getdate());

select * from hr;

--  age distribution
Select max(age) as oldest, min(age) as youngest from hr1;

-- age group by gender

select age_group,gender, count(*) as count from
 (select gender,
 case when age between 21 and 30 then '21 to 30'
 when age between 31 and  40 then '31 to 40'
  when age between 41 and 50 then '41 to 50' else '50+' end as age_group
 from hr where termdate is null ) as SQ1
 group by age_group, gender order by age_group, gender ;


-- gender breakdown - how many per category

select gender, count(gender) as count from hr 
where termdate is null group by gender order by gender;



-- gender across departments and job titles

select gender,department, jobtitle, count(gender) as count from hr 
where termdate is null group by department, jobtitle, gender order by department, jobtitle,gender;

-- race dist

select race, count(*) as count from hr where termdate is null group by race order by count desc;

-- avg length of employment

select avg(datediff(year,hire_date, term_date))as avgtenure from hr 
where term_date is not null and term_date <= getdate();

--  deparment with highest turnover
select department, total, terminated_count, (cast(terminated_count as float)/ total) as Turnover_Rate from
(select department, count(*) as total, 
sum(case when term_date is not null and term_date <= getdate () then 1 else 0 end ) as terminated_count 
from hr group by department ) as subq order by turnover_Rate desc;


--  tenure dist for each deparment

select department, avg(datediff(year,hire_date, term_date))as avgtenure from hr 
where term_date is not null and term_date <= getdate() group by department;

-- how many employees work remotely

select count(*)as remote_employees from hr ;

select hr.location, count(*)as remote_employees from hr where termdate is null group by hr.location;

--  dist of employees across states

select location_state, count(*)as employees from hr where termdate is null group by location_state order by employees desc;

--  job titles dist across company
select jobtitle, count(*)as employees from hr where termdate is null group by jobtitle order by employees desc;

--  how have employee hire counts varied over time
--  calculate hires 
--  calculate terminations

select hireY, hires, terminations, round((cast(hires as float)-terminations)/hires, 3)*100 as PercentChange from
(select year(hire_date) as hireY, count(*) as hires,
sum(case when term_date is not null and term_date <= getdate() then 1 else 0 end) as terminations from hr
group by year(hire_date)) as subq 
order by PercentChange desc ;

