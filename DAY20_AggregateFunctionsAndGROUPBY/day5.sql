create database day5_practice;
use day5_practice;


CREATE TABLE day5 (
    sale_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    category VARCHAR(50),
    product_name VARCHAR(50),
    quantity INT,
    sales_amount DECIMAL(10,2),
    sale_date DATE
);


INSERT INTO day5
(sale_id, customer_name, city, category, product_name,
 quantity, sales_amount, sale_date)
VALUES
(1, 'Arun', 'Chennai', 'Electronics', 'Laptop', 1, 50000, '2026-01-10'),
(2, 'Priya', 'Chennai', 'Furniture', 'Chair', 2, 12000, '2026-01-15'),
(3, 'Karthik', 'Coimbatore', 'Electronics', 'Mobile', 1, 20000, '2026-02-05'),
(4, 'Divya', 'Madurai', 'Grocery', 'Rice', 5, 5000, '2026-02-18'),
(5, 'Suresh', 'Chennai', 'Electronics', 'Headphones', 2, 8000, '2026-03-12'),
(6, 'Meena', 'Coimbatore', 'Furniture', 'Table', 1, 15000, '2026-03-20'),
(7, 'Ravi', 'Madurai', 'Grocery', 'Oil', 3, 9000, '2026-04-02'),
(8, 'Anu', 'Chennai', 'Grocery', 'Snacks', 4, 4000, '2026-04-15'),
(9, 'Vijay', 'Salem', 'Electronics', 'Monitor', 1, 18000, '2026-05-05'),
(10, 'Nisha', 'Coimbatore', 'Electronics', 'Keyboard', NULL, NULL, '2026-05-15');

-- Display all 10 sales records
SELECT * FROM day5;

-- Aggregate functions - count() , sum() , avg() , min() , max() , round()
select count(*) as total_rocords from day5;
select count(*) - count(sales_amount
) as missing_values from day5;
-- sum()
select sum(sales_amount) as total_revenue from day5;
-- avg() - 
select avg(sales_amount) as average_sales from day5;
-- min() and max()
select min(sales_amount) as min_sales from day5;
select max(sales_amount) as max_sales from day5;
-- round()
select round(avg(sales_amount)) as average_sales from day5;

-- group by - 
select city,sum(sales_amount) as total_sales from day5 group by city;
select city,count(*) as total_sales from day5 group by city;
select city,round(avg(sales_amount)) as average_sales from day5 group by city;

-- gorup by for cateogry
select category,sum(sales_amount) as total_sales from day5 group by category;
-- group by with case
select case
when sales_amount is null then 'Unknown'
when sales_amount <10000 then 'small'
when sales_amount between 10000 and 30000 then 'medium'
else 'large'
end as sales_category,sum(sales_amount) as total_sales,count(*) as total_sales from day5; -- group by 
-- case
-- when sales_amount is null then 'Unknown'
-- when sales_amount <10000 then 'small'
-- when sales_amount between 10000 and 30000 then 'medium'
-- else 'large'
-- END;

-- group by multiple columns
select city,category,sum(sales_amount) as total_sales from day5 group by city,category order by city,category;

-- having - use after group by to filter groups
select city,sum(sales_amount) as total_sales from day5 group by city having sum(sales_amount) > 30000;

select * from day5 where city = 'chennai';
-- from - where - group by - having - select - order by - limit
-- error clinic 
-- error 1 - aggerate function inside where
select city,sum(sales_amount) as total_sales from day5 where sum(sales_amount)>30000 group by city;
select city,sum(sales_amount) as total_sales from day5 group by city having sum(sales_amount) > 30000;

-- error 2 - selected column not included in group by
select city,customer_name,sum(sales_amount) from day5 group by city;
select city,sum(sales_amount) from day5 group by city;
select city,customer_name,sum(sales_amount) from day5 group by city,customer_name;

-- error 3  - normal column with an aggregate and no group by
select sum(sales_amount) as total_revenue from day5;
select city, sum(sales_amount) as total_revenue from day5;
select city, sum(sales_amount) as total_revenue from day5 group by city;

-- eror 4 --confusing count(*) and count(coulum)
select count(*) from day5;
select count(sales_amount) from day5;

-- error 5 - grouping by too few columns
select city,category,sum(sales_amount)m from day5
group  by city;

select city,category,sum(sales_amount) from day5 group by city ,category;
