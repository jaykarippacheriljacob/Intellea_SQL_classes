CREATE DATABASE day4_practice;

USE day4_practice;

CREATE TABLE day4 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50),
    order_amount DECIMAL(10,2),
    order_date DATE
);

INSERT INTO day4
(customer_id, customer_name, phone, city, order_amount, order_date)
VALUES
(1, '  arun kumar  ', '9876543210', 'Chennai', 5000, '2026-01-10'),
(2, 'PRIYA', NULL, 'Coimbatore', 15000, '2026-02-15'),
(3, 'Karthik', '9876500000', 'Chennai', 25000, '2026-03-20'),
(4, '  divya  ', '9876511111', 'Madurai', 8000, '2026-04-05'),
(5, 'SURESH', NULL, 'Salem', 35000, '2026-05-12'),
(6, 'Meena', '9876522222', 'Chennai', 45000, '2026-06-18'),
(7, '  ravi  ', '9876533333', 'Trichy', 12000, '2026-07-22'),
(8, 'ANU', NULL, 'Coimbatore', 55000, '2026-08-10'),
(9, 'Vijay', '9876544444', 'Madurai', 18000, '2026-09-14'),
(10, '  nisha  ', '9876555555', 'Chennai', 65000, '2026-10-25');


-- null handling
-- is null - for finding only missing records
select* from day4 where phone IS NULL;

-- is not null
select*from day4 where phone is not null;

-- coalesce() - personal number , office number , alternative number 
select customer_name,coalesce(phone,'Not provided') AS phone_number from day4;
-- ifnull 
select customer_name,ifnull(phone,'Not provided') AS phone_number from day4;

/* select coalesce(perosnal , office,alternative)

-- LIKE - used to search for a particular pattern in text value
-- A% - A_

-- name starting with A
select*from day4 where customer_name LIKE 'A%';

-- name ends with A
select*from day4 where customer_name LIKE '%A';
-- name containing vi
select*from day4 where customer_name like '%vi%';

select*from day4 where customer_name like 'A__';

-- CASE  - creates the condional based results in sql 
-- CASE WHEN 
select customer_name,order_amount,
CASE 
WHEN order_amount <10000 THEN 'Small'
WHEN order_amount between 10000 and 30000 THEN 'Medium'
ELSE 'Large'
END AS order_cateogry
from day4;

-- case multiple condition
select customer_name,city,order_amount,
case
when city = 'chennai' AND order_amount >30000 THEN 'Premium customer'
when order_amount >30000 then 'High value customer'
else 'Regular customer'
END AS Customer_type
from day4;

-- String functions
-- concat()
select concat(customer_name, '_', city) AS customer_details from day4;

-- upper()
select customer_name,upper(customer_name) AS uppercase_name from day4;
-- lower()
select customer_name,lower(customer_name) AS lowercase_name from day4;
-- substring
select customer_name,substring(customer_name,2,4) as short_name from day4;
-- TRIM() - 
select customer_name,trim(customer_name) as cleaned_name from day4;
-- replace() - it will replace the particular text to mentioned text
select city,replace(city,'Chennai','Chennai-City') as updated_city from day4;

-- Combining string functions
select customer_id,upper(trim(customer_name)) as cleaned_name from day4;

-- date functions
select curdate() as today_date;
-- for current date and time
select now() as current_date_time;
-- year() extract year from a date
select customer_name,order_date,year(order_date) as order_year from day4;
-- month()  extract the month from a date
select customer_name,order_date,month(order_date) as order_month from day4;
-- date_add() - add a specific time interval to a date
select customer_name,order_date,date_add(order_date,INTERVAL 7 DAY) as due_date from day4;

-- date_sub() - minus a sepcific interval of date
select customer_name,order_date,date_sub(order_date,INTERVAL 7 DAY) as previous_date from day4;
-- filtering date by range(include both starting and endimg)
select*from day4 where order_date between '2026-01-01' AND '2026-06-30';







