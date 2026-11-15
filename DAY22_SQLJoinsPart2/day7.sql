
CREATE DATABASE day7_joins_practice;
USE day7_joins_practice;
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(60),
city VARCHAR(40)
);
CREATE TABLE orders (
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE categories (
category_id INT PRIMARY KEY,
category_name VARCHAR(50)
);
CREATE TABLE products (
product_id INT PRIMARY KEY,
product_name VARCHAR(60),
category_id INT,
price DECIMAL(10,2),
FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE order_items (
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
unit_price DECIMAL(10,2),
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE employees (
employee_id INT PRIMARY KEY,
employee_name VARCHAR(60),
manager_id INT NULL,
department VARCHAR(40)
);
INSERT INTO customers VALUES
(1,'Arun','Chennai'),(2,'Priya','Coimbatore'),
(3,'Karthik','Madurai'),(4,'Divya','Chennai'),
(5,'Suresh','Salem');
INSERT INTO orders VALUES
(101,1,'2026-01-10'),(102,1,'2026-01-12'),
(103,2,'2026-02-15'),(104,4,'2026-03-20');
INSERT INTO categories VALUES
(10,'Electronics'),(20,'Accessories'),(30,'Stationery');
INSERT INTO products VALUES
(201,'Laptop',10,55000),(202,'Mouse',20,800),
(203,'Keyboard',20,1500),(204,'Notebook',30,100),
(205,'Monitor',10,12000);
INSERT INTO order_items VALUES
(1,101,201,1,55000),(2,101,202,2,800),
(3,102,203,1,1500),(4,103,202,1,800),
(5,104,201,1,55000),(6,104,203,2,1500);
INSERT INTO employees VALUES
(1,'Meena',NULL,'Management'),(2,'Ravi',1,'IT'),
(3,'Kavya',1,'HR'),(4,'Arun',2,'IT'),
(5,'Nila',2,'IT'),(6,'John',3,'HR');

-- full join
select c.customer_id,c.customer_name,o.order_id
from customers as c left join orders as o
on c.customer_id = o.customer_id
UNION
select c.customer_id,c.customer_name,o.order_id
from customers as c right join orders as o
on c.customer_id = o.customer_id;

-- self join
select e.employee_name as employee,m.employee_name as manager
from employees as e left join employees as m 
on e.manager_id = m.employee_id;

-- cross join
select c.customer_name , p.product_name
from customers as c cross join products as p;

-- multiple conditions in on 
select c.customer_name,o.order_id
from customers as c left join orders as o 
on c.customer_id = o.customer_id AND
o.order_date >= '2026-01-01'
AND o.order_date < '2026-02-01';

select c.customer_name,o.order_id
from customers as c left join orders as o 
on c.customer_id = o.customer_id 
where o.order_date >= '2026-01-01'
AND o.order_date < '2026-02-01';

select c.customer_id,customer_name, sum(oi.quantity * oi.unit_price) as total_sales
from customers as c left join orders as o
on c.customer_id = o.customer_id
left join order_items as oi
on o.order_id = oi.order_id
group by c.customer_id, c.customer_name;




