show databases;

create database hr_analytics;
use hr_analytics;

select * from hr;

describe hr;


-- data cleaning and preprocessing

-- changing name of id column

alter table hr
change column ï»¿id  emp_id varchar(20) null;


-- changing the format and datatype of birthdate column

update hr 
set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    else null
    end;

alter table hr
modify birthdate date;


-- changing the format and datatype of hire_date column

update hr 
set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    else null
    end;

alter table hr
modify hire_date date;


-- changing the format and datatype of termdate column

update hr 
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != "";

update hr
set termdate = null 
where termdate = '';


-- creating age column

alter table hr
add column age int;

update hr 
set age = timestampdiff(year, birthdate, curdate());

select min(age), max(age) from hr;


-- Insights

-- 1. What is the gender breakdown of the current employees.
select gender, count(*) as count 
from hr
where termdate is null
group by gender;


-- 2. What is the race breakdown of the current employees.
select race, count(*) as count 
from hr
where termdate is null
group by race;


-- 3. What is the age distribution of employees.
select 
	case
		when age < 18 then '18-'
		when age >= 18 and age <= 24 then '18-24'
        when age >= 25 and age <= 34 then '25-34'
        when age >= 35 and age <= 44 then '35-44'
        when age >= 45 and age <= 54 then '45-54'
        when age >= 55 and age <= 64 then '55-64'
        else '65+'
	end as 'age_group', 
    count(*) as count
    from hr
    where termdate is null
    group by age_group
    order by age_group;	


-- 4. How many employees work at HQ vs remote.

select location, count(*) as count 
from hr
where termdate is null
group by location;


-- 5. What is the average term of employment who have been terminated.

select round(avg(year(termdate)-year(hire_date)),0) as average_years
from hr
where termdate is not null 
and termdate <= curdate();


-- 6. how does the gender distribution vary across dept. & job titles.

select department, jobtitle, gender, count(*) as count
from hr
where termdate is null
group by department, jobtitle, gender
order by department, jobtitle, gender;


-- 7. what is the distribution of job titles.

select jobtitle, count(*) as count
from hr 
where termdate is null
group by jobtitle;


-- 8. Which dept has the highest termination rate.

select department, 
		count(*) as total_count,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as terminated_count,
		round((count(case
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100, 2) as termination_rate
		from hr
        group by department
        order by termination_rate desc;


-- 9. what is the distribution of employees across location_state

select location_state, count(*) as count
from hr
where termdate is null
group by location_state;


-- 10. how has the employee count changed over time based on the hiredate and termination date.

select year, 
	hires,
    terminations,
    hires-terminations as net_change,
    (terminations/hires)*100 as change_percent
from(
		select year(hire_date) as year,
        count(*) as hires,
        sum(case
				when termdate is not null and termdate <= curdate() then 1
                end) as terminations
		from hr
        group by year(hire_date)) as subquery
group by year
order by year;


-- 11. what is the tenure distribution of each dept.

select department, round(avg(datediff(termdate,hire_date)/365), 0) as avg_tenure
from hr
where termdate is not null and termdate <=curdate()
group by department;


-- 12. termination & hire breakdown genderwise

select gender,
		total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100, 2) as termination_rates
from(
		select gender,
        count(*) as total_hires,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as total_terminations
		from hr
        group by gender) as subquery
	group by gender;
    
    
-- 13. termination & hire breakdown agewise

select age,
		total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100, 2) as termination_rates
from(
		select age,
        count(*) as total_hires,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as total_terminations
		from hr
        group by age) as subquery
	group by age
    order by age;
    
    
-- 14. termination & hire breakdown deptwise

select department,
		total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100, 2) as termination_rates
from(
		select department,
        count(*) as total_hires,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as total_terminations
		from hr
        group by department) as subquery
	group by department
    order by department;
    
    
-- 15. termination & hire breakdown racewise

select race,
		total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100, 2) as termination_rates
from(
		select race,
        count(*) as total_hires,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as total_terminations
		from hr
        group by race) as subquery
	group by race
    order by race;
    
    
-- 17. termination & hire breakdown yearwise

select year, 
		total_hires,
		total_terminations,
		round((total_terminations/total_hires)*100, 2) as termination_rates
from(
		select year(hire_date) as year,
        count(*) as total_hires,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as total_terminations
		from hr
        group by year(hire_date)) as subquery
group by year
order by year;
    
