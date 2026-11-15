create database day10;
use day10;
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

INSERT INTO departments
VALUES
(1, 'IT', 'Chennai'),
(2, 'HR', 'Bangalore'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Chennai'),
(5, 'Sales', 'Hyderabad');

select * from departments;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    age INT,
    salary DECIMAL(10,2),
    dept_id INT,
    city VARCHAR(50),
    experience INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    );

INSERT INTO employees
VALUES
(113, 'Aru', 25, 35000, 1, 'Chennai', 2),
(114, 'Bala', 28, 50000, 1, 'Chennai', 5),
(103, 'Charan', 30, 60000, 2, 'Bangalore', 7),
(104, 'Divya', 26, 40000, 2, 'Bangalore', 3),
(105, 'Ezhil', 32, 75000, 3, 'Mumbai', 9),
(106, 'Farhan', 27, 45000, 3, 'Mumbai', 4),
(107, 'Gokul', 29, 55000, 4, 'Chennai', 6),
(108, 'Harini', 24, 30000, 4, 'Chennai', 1),
(109, 'Kavin', 35, 90000, 1, 'Chennai', 12),
(110, 'Lavanya', 31, 65000, 5, 'Hyderabad', 8),
(111, 'Mani', 23, 28000, 5, 'Hyderabad', 1),
(112, 'Nithya', 29, 52000, 2, 'Bangalore', 5);



select emp_name , count(*) as total_employees from employees group by emp_name;

select emp_name , salary , count(*) over() as total_employees from employees; 

select 
	colmn_name ,
    wind_fun over(
		partition by col_name
        order by col_name
        )
        from tab_name;
        
select emp_id , emp_name , salary , row_number() over (
	order by salary desc) as row_num
from employees;

select emp_id , emp_name , salary , row_number() over (
	partition by city
	order by salary desc) as row_num
from employees;


RANK AND DENSE_RANK

SELECT 	EMP_NAME , SALARY , DENSE_RANK() OVER ( 
	ORDER BY SALARY DESC ) AS SALARY_RANK 
FROM EMPLOYEES;
WITH RANKED_EMPLOYEES AS (
	SELECT 
		EMP_ID , 
        EMP_NAME,
        CITY , 
        SALARY ,
        ROW_NUMBER() OVER(
			PARTITION BY CITY 
            ORDER BY SALARY DESC , emp_id 
            ) as rn 
            from employees )
		select * from ranked_employees where rn <= 2;

select emp_name , city , salary , sum(salary) over() as total_salary from employees;























