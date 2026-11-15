-- subquery -- IN - Customer who have placed orders
select customer_name from customers where customer_id IN (select customer_id from orders);

select customer_name from customers where customer_id NOT IN (select customer_id from orders);

-- products above average price - 1.average price 2.check condition price > avg_price

select product_name,price from products where price > ( select avg(price) from products);

-- 4 , arun 2 , divya 1 , priya 1 = 4/3 = 1.33 - averge order count 
-- customers with an above average number of orders
select customer_id from orders group by customer_id having count(*) > ( select avg(order_count) from (
select count(*) as order_count from orders group by customer_id) as counts_per_customer);

-- EXISTS -- CUSTOMER WHO HAVE ORDERS
select c.customer_id , c.customer_name
from customers as c where exists ( 
select 1 from orders as o where o.customer_id = c.customer_id);

select c.customer_id , c.customer_name
from customers as c where NOT exists ( 
select 1 from orders as o where o.customer_id = c.customer_id);

-- CTE COMMON TABLE EXPRESSION
-- calculate total qunatity sold per product
-- mouse - 3 , key - 3 , laptop - 2 not --

with product_quantity as (
select p.product_id,p.product_name,sum(oi.quantity) as total_quantity from products p
 inner join order_items as oi 
on p.product_id = oi.product_id group by p.product_id,p.product_name)

select * from product_quantity order by total_quantity DESC ;

-- view 
create view customer_order_summary as 
select c.customer_id,c.customer_name,count(o.order_id) as order_count from customers as c
left join orders as o 
on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name;

select*from customer_order_summary;
select*from customer_order_summary where order_count>1;

drop view customer_order_summary;

