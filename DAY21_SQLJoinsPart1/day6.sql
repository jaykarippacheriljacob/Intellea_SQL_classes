CREATE DATABASE day6_joins_practice;
USE day6_joins_practice;
CREATE TABLE customers (
 customer_id INT PRIMARY KEY,
 customer_name VARCHAR(100),
 city VARCHAR(50)
);
CREATE TABLE orders (
 order_id INT PRIMARY KEY,
 customer_id INT,
 order_date DATE,
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE products (
 product_id INT PRIMARY KEY,
 product_name VARCHAR(100),
 price DECIMAL(10,2)
);
CREATE TABLE order_items (order_item_id INT PRIMARY KEY,
 order_id INT,
 product_id INT,
 quantity INT,
 FOREIGN KEY (order_id) REFERENCES orders(order_id),
 FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1, 'Arun', 'Chennai'),
(2, 'Priya', 'Coimbatore'),
(3, 'Karthik', 'Madurai'),
(4, 'Divya', 'Chennai'),
(5, 'Suresh', 'Salem');
-- Four orders
INSERT INTO orders VALUES
(101, 1, '2026-01-10'),
(102, 1, '2026-01-12'),
(103, 2, '2026-02-15'),
(104, 4, '2026-03-20');
-- Three products
INSERT INTO products VALUES
(201, 'Laptop', 55000.00),
(202, 'Mouse', 800.00),
(203, 'Keyboard', 1500.00);
-- Six order lines
INSERT INTO order_items VALUES
(1, 101, 201, 1),
(2, 101, 202, 2),
(3, 102, 203, 1),
(4, 103, 202, 1),
(5, 104, 201, 1),
(6, 104, 203, 2);
-- View each table
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM order_items;

-- order id  customer name
-- 1001 Arun
-- 102 Arun
-- 103  Priya 
-- inner join
select o.order_id,c.customer_name from orders as o inner join customers as c on o.customer_id = c.customer_id;

-- left join show every customers id , name and thier order_id
select c.customer_id,c.customer_name,o.order_id from 
customers as c left join orders as o 
on c.customer_id = o.customer_id
order by c.customer_id,o.order_id;

select c.customer_id,c.customer_name,o.order_id from 
customers as c left join orders as o 
on c.customer_id = o.customer_id
where o.order_id is null;

-- right join -mirrors of left join

select  c.customer_name , o.order_id 
from customers as c right join orders as o
on c.customer_id = o.customer_id;

-- customer_name . order-id,product , qunatity 
-- customer , orders, order_items , products

select c.customer_name,o.order_id,p.product_name,oi.quantity
from customers as c inner join orders as o 
on c.customer_id = o.customer_id
inner join order_items as oi 
on o.order_id = oi.order_id
inner join products as p
on oi.product_id = p.product_id 



