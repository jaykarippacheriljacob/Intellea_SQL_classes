create database day3_practice;
use day3_practice;

create table emp_day3(
emp_id INT PRIMARY KEY,
emp_name VARCHAR(20),
age INT,
department VARCHAR(20),
salary decimal(10,2),
joining_date date,
experience int,
location VARCHAR(20));

insert into emp_day3(emp_id,emp_name,age,department,salary,joining_date,experience,location) VALUES
(101,'Arun',21,'IT',25000.00,'2024-9-10',2,'Chennai'),
(102,'Divya',22,'Sales',20000.00,'2024-9-8',3,'Madurai'),
(103,'Priya',22,'IT',45000.00,'2024-8-8',5,'Chennai');

select*from emp_day3;

-- SELECT PROJECTION CONCEPT
select emp_name,salary from emp_day3;
select emp_name,department from emp_day3;

-- AS Column ALIAS 

SELECT emp_id AS emp_code from emp_day3;
select emp_name AS full_name , salary AS monthly_salary from emp_day3;

-- + , - , * , / , % 

select emp_name, salary, salary + 5000 AS Bonus_salary FROM emp_day3;
select emp_name,salary,salary*12 AS Annual_salary FROM emp_day3;

-- SORTIING AND LIMITING ( ORDER BY) - ASC - desc
select emp_name,salary FROM emp_day3 order by salary ASC;
select emp_name,salary FROM emp_day3 order by salary DESC;

select emp_name,salary FROM emp_day3 order by emp_name,salary DESC;

select emp_name,department,salary from emp_day3 order by department ASC , salary DESC;

-- LIMIT
select*from emp_day3 LIMIT 1;

select emp_name,salary from emp_day3 order by salary DESC LIMIT 2;

select*from emp_day3 limit 2 offset 2;

select*from emp_day3;

-- DISTINCT
select distinct department from emp_day3;

select distinct department,location from emp_day3;

-- COUNT WITH DISNTINCT

select count(distinct department) as total_department from emp_day3;

-- COMPARISION OPERATOR , > ,< , = , <> , <= , >= 
select emp_name from emp_day3 where salary > 30000;

select * from emp_day3 where department <> 'IT';

-- AND 
select * from emp_day3 where department = 'IT' AND salary > 30000;

-- OR 
select*from emp_day3 where department = 'IT' OR  experience >2;
-- NOT
select*from emp_day3 where NOT department = 'IT';






