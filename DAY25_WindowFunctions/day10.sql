CREATE DATABASE day10_window_functions_practice;
USE day10_window_functions_practice;
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(80),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE product_sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    sale_date DATE,
    quantity INT,
    revenue DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE customer_imports (
    import_id INT PRIMARY KEY,
    customer_name VARCHAR(60),
    email VARCHAR(100),
    updated_at DATETIME
);
CREATE TABLE daily_sales (
    sale_date DATE PRIMARY KEY,
    daily_amount DECIMAL(10,2)
);

INSERT INTO categories VALUES
(1,'Electronics'), (2,'Accessories'), (3,'Home Appliances');
INSERT INTO products VALUES
(101,'Laptop',1), (102,'Tablet',1), (103,'Monitor',1), (104,'Camera',1),
(201,'Mouse',2), (202,'Keyboard',2), (203,'Headphones',2), (204,'Webcam',2),
(301,'Mixer',3), (302,'Vacuum Cleaner',3);
INSERT INTO product_sales VALUES
(1,101,'2026-01-01',10,500000.00),
(2,102,'2026-01-02',8,240000.00),
(3,103,'2026-01-03',8,160000.00),
(4,104,'2026-01-04',5,175000.00),
(5,201,'2026-01-01',30,24000.00),
(6,202,'2026-01-02',25,37500.00),
(7,203,'2026-01-03',25,50000.00),
(8,204,'2026-01-04',12,36000.00),
(9,301,'2026-01-02',7,21000.00),
(10,302,'2026-01-03',4,32000.00);
INSERT INTO customer_imports VALUES
(1,'Arun','arun@gmail.com','2026-02-01 09:00:00'),
(2,'Arun Kumar','arun@gmail.com','2026-02-03 10:30:00'),
(3,'Priya','priya@gmail.com','2026-02-02 11:00:00'),
(4,'Karthik','karthik@gmail.com','2026-02-01 08:00:00'),
(5,'Karthik S','karthik@gmail.com','2026-02-04 12:00:00'),
(6,'Divya','divya@gmail.com','2026-02-05 14:00:00');
INSERT INTO daily_sales VALUES
('2026-01-01',1000.00), ('2026-01-02',1500.00),
('2026-01-03',800.00), ('2026-01-04',1200.00),
('2026-01-05',500.00);

with product_sales as (
select p.product_id,p.product_name, c.category_name,sum(ps.revenue) as total_revenue
from products p 
join categories as c on p.category_id = c.category_id
join product_sales as ps on p.product_id = ps.product_id
group by p.product_id,p.product_name,c.category_name
)
-- select product_name,category_name,total_revenue, row_number() over (
-- order by total_revenue desc) as row_num from product_sales;

select product_name,category_name,total_revenue,row_number() over(
partition by category_name 
order by total_revenue desc) as row_num from product_sales
order by category_name,row_num;

select p.product_name,ps.revenue,dense_rank() over(order by revenue desc) as product_rank
from products as p join product_sales as ps on p.product_id = ps.product_id;

-- window aggregate function
-- overall total repeated daily amount
select sale_date,daily_amount, sum(daily_amount) over () as overall_total from daily_sales
order by sale_date;

select sale_date,daily_amount,sum(daily_amount) over( order by sale_date rows between unbounded preceding and current row
) as running_total from daily_sales order by sale_date;

