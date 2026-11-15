create database day7;
use day7;

create table departments(
	dept_id int primary key,
    dept_name varchar(50),
    location varchar(50)
);

INSERT INTO departments VALUES
(101, 'HR', 'Chennai'),
(102, 'Development', 'Bangalore'),
(103, 'Data Engineering', 'Chennai'),
(104, 'Testing', 'Hyderabad'),
(105, 'Finance', 'Mumbai');

select * from departments;


create table employees(
	emp_id int primary key ,
    emp_name varchar(50),
    salary decimal(10,2),
    dept_id int,
    manager_id int
    );
INSERT INTO employees VALUES
(1, 'Manoj', 35000, 103, 5),
(2, 'Arun', 30000, 102, 5),
(3, 'Priya', 40000, 103, 5),
(4, 'Divya', 28000, 101, 6),
(5, 'Kumar', 60000, 102, NULL),
(6, 'Ravi', 55000, 101, NULL),
(7, 'Sanjay', 32000, NULL, 5),
(8, 'Meena', 25000, 104, 6);

select * from employees;

full outer join

select 
	e.emp_id, e.emp_name , d.dept_id , d.dept_name
from employees e left join departments d on e.dept_id = d.dept_id 

UNION ALL

select 
	e.emp_id, e.emp_name , d.dept_id , d.dept_name
from employees e RIGHT join departments d on e.dept_id = d.dept_id ;
SELECT E.* FROM EMPLOYEES E LEFT JOIN DEPARTMENTS D ON E.DEPT_ID = D.DEPT_ID WHERE D.DEPT_ID IS NULL;

SELECT D.* FROM EMPLOYEES E LEFT JOIN DEPARTMENTS D ON E.DEPT_ID = D.DEPT_ID WHERE E.EMP_ID IS NULL;


SELECT E.EMP_NAME AS EMPLOYEE,
	   M.EMP_NAME AS MANAGER
	FROM EMPLOYEES E INNER JOIN EMPLOYEES M
    ON E.MANAGER_ID = M.EMP_ID ;
    
SELECT * FROM EMPLOYEES ;
SELECT * FROM DEPARTMENTS;



CROSS JOIN 

CREATE TABLE colors (
    color_id INT PRIMARY KEY,
    color_name VARCHAR(30)
);

INSERT INTO colors VALUES
(1, 'Red'),
(2, 'Blue'),
(3, 'Green');

CREATE TABLE sizes (
    size_id INT PRIMARY KEY,
    size_name VARCHAR(20)
);

INSERT INTO sizes VALUES
(1, 'Small'),
(2, 'Medium'),
(3, 'Large');

SELECT C.COLOR_NAME , S.SIZE_NAME FROM COLORS C CROSS JOIN SIZES S;

CREATE DATABASE SECTION2;
USE SECTION2;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);


INSERT INTO customers VALUES
(1, 'Manoj', 'Chennai'),
(2, 'Arun', 'Bangalore'),
(3, 'Priya', 'Chennai'),
(4, 'Divya', 'Madurai'),
(5, 'Karthik', 'Coimbatore');


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
(101, 1, '2026-10-01'),
(102, 2, '2026-10-02'),
(103, 1, '2026-10-05'),
(104, 3, '2026-10-06'),
(105, 4, '2026-10-07');


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2)
);


INSERT INTO products VALUES
(201, 'Laptop', 'Electronics', 50000),
(202, 'Mouse', 'Accessories', 500),
(203, 'Keyboard', 'Accessories', 1000),
(204, 'Mobile', 'Electronics', 20000),
(205, 'Headphones', 'Accessories', 1500);



CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);


INSERT INTO order_items VALUES
(1, 101, 201, 1),
(2, 101, 202, 2),
(3, 102, 203, 1),
(4, 103, 204, 1),
(5, 104, 202, 3),
(6, 104, 205, 2),
(7, 105, 201, 1);

SELECT C.CUSTOMER_NAME , O.ORDER_ID , O.ORDER_DATE FROM CUSTOMERS C INNER JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID ;

SELECT C.CUSTOMER_NAME , O.ORDER_ID , P.PRODUCT_NAME , OI.QUANTITY FROM CUSTOMERS C 
INNER JOIN ORDERS O 
ON C.CUSTOMER_ID = O.CUSTOMER_ID

INNER JOIN ORDER_ITEMS OI
ON O.ORDER_ID = OI.ORDER_ID

INNER JOIN PRODUCTS P
ON OI.PRODUCT_ID = P.PRODUCT_ID ;


