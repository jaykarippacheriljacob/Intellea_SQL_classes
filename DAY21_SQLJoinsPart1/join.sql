create database day6b2;
use day6b2;

create table customers (
	customer_id int primary key , 
    customer_name varchar(50),
    city varchar(50)
    );

create table orders(
	order_id int primary key,
    customer_id int,
    product_name varchar(50),
    quantity int,
    amount decimal(10,2),
    FOREIGN KEY (customer_id ) references customers(customer_id)
    );
INSERT INTO customers VALUES
(1, 'Arun', 'Chennai'),
(2, 'Bala', 'Madurai'),
(3, 'Charan', 'Coimbatore'),
(4, 'Deepa', 'Chennai'),
(5, 'Priya', 'Salem'),
(6, 'Karthik', 'Trichy'),
(7, 'Divya', 'Chennai'),
(8, 'Rahul', 'Madurai');


INSERT INTO orders VALUES
(101, 1, 'Laptop', 1, 55000),
(102, 1, 'Mouse', 2, 1000),
(103, 2, 'Keyboard', 1, 1500),
(104, 3, 'Monitor', 1, 12000),
(105, 2, 'Headphones', 2, 5000),
(106, 7, 'Printer', 1, 15000),
(107, 7, 'Mouse', 3, 1500),
(108, 6, 'Laptop', 1, 55000);

JOIN - INNER JOIN , LEFT JOIN , RIGHT JOIN 

SYNTAX :

SELECT COLUMNS 
FROM TABLE1
JOIN TABLE2
ON TABLE1.COMMON_COLUMN = TABLE2 .COMMON_COLUMN ;


DISPLAY CUSTOMER NAMES ALONG WITH ORDER ID

SELECT C.CUSTOMER_NAME , O.ORDER_ID  FROM CUSTOMERS C  right JOIN ORDERS  O ON C.CUSTOMER_ID = O.CUSTOMER_ID ;

select c.customer_id , c.customer_name from customers c left join orders o on c.customer_id = o.customer_id where o.order_id is null;

CREATE TABLE PRODUCTS (
	PRODUCT_ID INT PRIMARY KEY ,
    PRODUCT_NAME VARCHAR(50),
    PRICE DECIMAL(10,2),
    CATEGORY VARCHAR(30),
    STOCK int
);

INSERT INTO products VALUES
(201, 'Laptop', 55000, 'Electronics', 10),
(202, 'Mouse', 500, 'Accessories', 50),
(203, 'Keyboard', 1500, 'Accessories', 30),
(204, 'Monitor', 12000, 'Electronics', 15),
(205, 'Headphones', 2500, 'Electronics', 20),
(206, 'Printer', 15000, 'Electronics', 8),
(207, 'Webcam', 3000, 'Accessories', 25),
(208, 'Speaker', 4000, 'Electronics', 12);


 drop table customers;
 drop table orders;
 
create table customers (
	customer_id int primary key , 
    customer_name varchar(50),
    city varchar(50)
    );
create table orders (
	order_id int primary key,
    customer_id int , 
    product_id int ,
    quantity int,
    foreign key(customer_id) references customers(customer_id),
    foreign key (product_id) references products(product_id)
);

create table products (
		product_id int primary key , 
        product_name varchar(50),
        price decimal(10,2)
        );
        

select c.customer_name , o.order_id , p.product_name from customers c inner join orders o on c.customer_id = o.customer_id inner join products p on o.product_id = p.product_id;