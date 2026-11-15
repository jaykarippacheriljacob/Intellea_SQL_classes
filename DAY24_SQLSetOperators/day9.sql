CREATE DATABASE day9_set_operations_practice; 
USE day9_set_operations_practice;
CREATE TABLE source_customers 
(    customer_id INT,    customer_name VARCHAR(50),    city VARCHAR(50) );
CREATE TABLE target_customers 
(    customer_id INT,    customer_name VARCHAR(50),    city VARCHAR(50) );
CREATE TABLE customer_contacts 
(    contact_id INT PRIMARY KEY,    customer_name VARCHAR(50),    email VARCHAR(100) );
CREATE TABLE chennai_departments 
(    employee_id INT,    employee_name VARCHAR(50) );
CREATE TABLE coimbatore_departments 
(    employee_id INT,    employee_name VARCHAR(50) );

INSERT INTO source_customers VALUES 
(1, 'Arun', 'Chennai'), (2, 'Priya', 'Coimbatore'),
(3, 'Karthik', 'Madurai'), (4, 'Divya', 'Chennai'),
(5, 'Suresh', 'Salem');

INSERT INTO target_customers VALUES
 (1, 'Arun', 'Chennai'),
 (2, 'Priya', 'Coimbatore'),
 (3, 'Karthik', 'Trichy'),
 (4, 'Divya', 'Chennai'), 
 (6, 'Nila', 'Erode');
 
 INSERT INTO customer_contacts VALUES
 (1, 'Arun', 'arun@gmail.com'), (2, 'Priya', 'priya@gmail.com'), 
 (3, 'Karthik', 'arun@gmail.com'), (4, 'Divya', 'divya@gmail.com'),
 (5, 'Suresh', 'suresh@gmail.com'), (6, 'Arun', 'arun@gmail.com');
 
 INSERT INTO chennai_departments VALUES (101, 'Arun'), (102, 'Priya'), (103, 'Divya');
 INSERT INTO coimbatore_departments VALUES (102, 'Priya'), (104, 'Karthik'), (105, 'Nila');
 
 -- UNION removes duplicate result
 select employee_id,employee_name from chennai_departments
 UNION
 select employee_id,employee_name from coimbatore_departments;
 
 -- UNION ALL - it keeps the duplicates
  select employee_id,employee_name from chennai_departments
 UNION ALL
 select employee_id,employee_name from coimbatore_departments;
 
-- EXCEPT 
select customer_id,customer_name,city from source_customers 
EXCEPT
select customer_id,customer_name,city from target_customers;

select customer_id,customer_name,city from target_customers 
EXCEPT
select customer_id,customer_name,city from source_customers;

-- intersect - exact rows common to both
select customer_id,customer_name,city from source_customers 
INTERSECT
select customer_id,customer_name,city from target_customers;

-- Finding duplicates
-- find email addressess used more than once
select email,count(*) as occurance_count from customer_contacts group by email having count(*) > 1;

select customer_name,email,count(*) as occurance_count from customer_contacts 
group by customer_name,email
having count(*)>1;

-- source to validation
-- Comapre row counts
select 'SOURCE' as system_name,count(*) as row_count from source_customers
UNION ALL
select 'TARGET',count(*) from target_customers;

-- find missing rows in target matching by id
select s.customer_id,s.customer_name,s.city from source_customers as s
left join target_customers as t
on s.customer_id = t.customer_id
where t.customer_id is null;

-- Find extra rows in target match by id
select t.customer_id,t.customer_name,t.city
from target_customers as t
left join source_customers as s 
on t.customer_id = s.customer_id
where s.customer_id is  null;




