/* =====================================================================
   DAY 7 - SQL PRACTICE NOTES
   Topics: FOREIGN KEY, FULL OUTER JOIN (UNION), SELF JOIN, CROSS JOIN,
           Multiple conditions in ON vs WHERE, Multi-table JOINs,
           JOIN + GROUP BY, Error clinic
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP

   NOTE: Tables with FOREIGN KEYs must be dropped CHILD first,
         then parent (see Error clinic). Created in the reverse order.
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day7_joins_practice;
USE day7_joins_practice;

DROP TABLE IF EXISTS order_items;     -- child of orders and products
DROP TABLE IF EXISTS orders;          -- child of customers
DROP TABLE IF EXISTS products;        -- child of categories
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;

CREATE TABLE customers (
    customer_id    INT PRIMARY KEY,
    customer_name  VARCHAR(60),
    city           VARCHAR(40)
);

CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_date   DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE categories (
    category_id    INT PRIMARY KEY,
    category_name  VARCHAR(50)
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(60),
    category_id   INT,
    price         DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY,
    order_id       INT,
    product_id     INT,
    quantity       INT,
    unit_price     DECIMAL(10,2),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE employees (
    employee_id    INT PRIMARY KEY,
    employee_name  VARCHAR(60),
    manager_id     INT NULL,           -- NULL = top-level, no manager
    department     VARCHAR(40)
);

INSERT INTO customers VALUES
    (1, 'Arun',    'Chennai'),
    (2, 'Priya',   'Coimbatore'),
    (3, 'Karthik', 'Madurai'),
    (4, 'Divya',   'Chennai'),
    (5, 'Suresh',  'Salem');

INSERT INTO orders VALUES
    (101, 1, '2026-01-10'),
    (102, 1, '2026-01-12'),
    (103, 2, '2026-02-15'),
    (104, 4, '2026-03-20');

INSERT INTO categories VALUES
    (10, 'Electronics'),
    (20, 'Accessories'),
    (30, 'Stationery');

INSERT INTO products VALUES
    (201, 'Laptop',   10, 55000),
    (202, 'Mouse',    20, 800),
    (203, 'Keyboard', 20, 1500),
    (204, 'Notebook', 30, 100),
    (205, 'Monitor',  10, 12000);

INSERT INTO order_items VALUES
    (1, 101, 201, 1, 55000),
    (2, 101, 202, 2, 800),
    (3, 102, 203, 1, 1500),
    (4, 103, 202, 1, 800),
    (5, 104, 201, 1, 55000),
    (6, 104, 203, 2, 1500);

INSERT INTO employees VALUES
    (1, 'Meena', NULL, 'Management'),
    (2, 'Ravi',  1,    'IT'),
    (3, 'Kavya', 1,    'HR'),
    (4, 'Arun',  2,    'IT'),
    (5, 'Nila',  2,    'IT'),
    (6, 'John',  3,    'HR');

/* How the tables link:
     customers   --< orders      (customer_id)
     orders      --< order_items (order_id)
     products    --< order_items (product_id)
     categories  --< products    (category_id)
     employees   --< employees   (manager_id -> employee_id)  self link

   Who has what:
     Arun    -> orders 101, 102
     Priya   -> order 103
     Divya   -> order 104
     Karthik, Suresh -> no orders
     Notebook, Monitor -> never ordered
     Stationery -> no sales                                             */


/* ---------------------------------------------------------------------
   1. FOREIGN KEY

   A FOREIGN KEY links a column to the PRIMARY KEY of another table.
     FOREIGN KEY (customer_id) REFERENCES customers(customer_id)

   Parent table = the one being referenced  (customers)
   Child table  = the one holding the FK    (orders)

   RULES it enforces:
   - A child row can't point to a parent that doesn't exist
       INSERT INTO orders VALUES (105, 99, '2026-04-01');  -> Error 1452
   - A parent row can't be deleted while children point to it
   - A parent table can't be dropped while a child references it

   NOTE: A FK does NOT create the join. You still write ON ... = ...
         It only keeps the data consistent.
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   2. FULL OUTER JOIN - everything from both tables

   MySQL has no FULL OUTER JOIN. Build it with:
     LEFT JOIN  +  UNION  +  RIGHT JOIN

   UNION     -> combines both results, removes duplicate rows
   UNION ALL -> keeps duplicates (faster); then add
                WHERE left.id IS NULL to the 2nd part (see Day 6)

   NOTE: Both SELECTs need the SAME number of columns, in the same order.
   NOTE: Here every order has a customer (the FK guarantees it), so the
         RIGHT JOIN adds nothing new: the result equals the LEFT JOIN.
   --------------------------------------------------------------------- */

-- Result (6 rows):
--   1 Arun 101 | 1 Arun 102 | 2 Priya 103 | 3 Karthik NULL
--   4 Divya 104 | 5 Suresh NULL
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers AS c
RIGHT JOIN orders AS o ON c.customer_id = o.customer_id;


/* ---------------------------------------------------------------------
   3. SELF JOIN - a table joined to ITSELF

   Used when rows in one table relate to other rows in the SAME table
   (employee -> manager, product -> similar product ...).

   Use TWO aliases and treat them as two separate tables:
     e = the employee row
     m = the manager row
   ON e.manager_id = m.employee_id  -> "m is e's manager"

   NOTE: Aliases are REQUIRED (Error 1066 without them).
   NOTE: Direction matters:
         e.manager_id = m.employee_id  -> m is the manager   (correct)
         e.employee_id = m.manager_id  -> m is the employee  (reversed)
   --------------------------------------------------------------------- */

-- LEFT JOIN keeps Meena (no manager -> NULL)
-- Result: Meena NULL | Ravi Meena | Kavya Meena | Arun Ravi |
--         Nila Ravi  | John Kavya
SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m ON e.manager_id = m.employee_id;

-- INNER JOIN drops Meena (only employees WITH a manager) -> 5 rows
SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM employees AS e
INNER JOIN employees AS m ON e.manager_id = m.employee_id;

-- Self join + GROUP BY: how many direct reports each manager has
-- Result: Kavya 1 | Meena 2 | Ravi 2
SELECT m.employee_name AS manager,
       COUNT(*)        AS direct_reports
FROM employees AS e
INNER JOIN employees AS m ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.employee_name
ORDER BY m.employee_name;

-- Self join with an extra condition: employees in the SAME
-- department as their manager
-- Result: Arun-Ravi (IT) | Nila-Ravi (IT) | John-Kavya (HR)
SELECT e.employee_name AS employee,
       m.employee_name AS manager,
       e.department
FROM employees AS e
INNER JOIN employees AS m
    ON e.manager_id = m.employee_id
   AND e.department = m.department;


/* ---------------------------------------------------------------------
   4. CROSS JOIN - every row paired with every row

   No ON condition. Rows = rows in table 1 x rows in table 2.

   NOTE: Old style FROM a, b (comma) is also a cross join.
   NOTE: An INNER JOIN with a forgotten ON behaves like this too.
         If a join returns far too many rows, check the ON.
   --------------------------------------------------------------------- */

-- 5 customers x 5 products = 25 rows
SELECT c.customer_name, p.product_name
FROM customers AS c
CROSS JOIN products AS p
ORDER BY c.customer_name, p.product_name;


/* ---------------------------------------------------------------------
   5. MULTIPLE CONDITIONS - ON vs WHERE (with LEFT JOIN)

   ON    -> decides which right rows MATCH. Left rows always stay.
   WHERE -> filters the FINISHED result. Can remove left rows.

   Question: show January 2026 orders for each customer.
   --------------------------------------------------------------------- */

-- Condition in ON: EVERY customer stays; only January orders attach
-- Result (6 rows): Arun 101 | Arun 102 | Priya NULL | Karthik NULL |
--                  Divya NULL | Suresh NULL
-- (Priya's Feb order and Divya's Mar order don't match -> NULL)
SELECT c.customer_name, o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_date >= '2026-01-01'
   AND o.order_date <  '2026-02-01';

-- Condition in WHERE: customers without a January order DISAPPEAR
-- Result (2 rows): Arun 101 | Arun 102
-- Why: their order_date is NULL or not in January -> WHERE removes them.
--      The LEFT JOIN has effectively become an INNER JOIN.
SELECT c.customer_name, o.order_id
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2026-01-01'
  AND o.order_date <  '2026-02-01';

/* Which to use?
     "All customers, show January orders if any"   -> condition in ON
     "Only customers who ordered in January"        -> condition in WHERE

   NOTE: >= '2026-01-01' AND < '2026-02-01' is safer than BETWEEN
         '2026-01-01' AND '2026-01-31' if the column ever stores times. */


/* ---------------------------------------------------------------------
   6. MULTI-TABLE JOINS (3+ tables)

   Chain the joins one after another. Each JOIN needs its own ON.
     FROM a
     JOIN b ON a.x = b.x
     JOIN c ON b.y = c.y

   NOTE: Once you start with LEFT JOIN to keep all rows, keep the
         following joins LEFT too. An INNER JOIN later in the chain
         drops the rows that had NULLs.
   --------------------------------------------------------------------- */

-- Every item sold with customer, product and category (4 tables + orders)
SELECT c.customer_name,
       o.order_id,
       p.product_name,
       cat.category_name,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM customers AS c
INNER JOIN orders      AS o   ON c.customer_id  = o.customer_id
INNER JOIN order_items AS oi  ON o.order_id     = oi.order_id
INNER JOIN products    AS p   ON oi.product_id  = p.product_id
INNER JOIN categories  AS cat ON p.category_id  = cat.category_id
ORDER BY o.order_id;


/* ---------------------------------------------------------------------
   7. JOIN + GROUP BY (links to Day 5)

   Join first, then group the joined rows.
   SUM over no rows gives NULL -> wrap with COALESCE to show 0.
   --------------------------------------------------------------------- */

-- Total sales per customer (every customer, even with no orders)
-- Order totals: 101 = 55000 + 2*800 = 56600 | 102 = 1500
--               103 = 800 | 104 = 55000 + 2*1500 = 58000
-- Result: Arun 58100 | Priya 800 | Karthik 0 | Divya 58000 | Suresh 0
SELECT c.customer_id,
       c.customer_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_sales
FROM customers AS c
LEFT JOIN orders      AS o  ON c.customer_id = o.customer_id
LEFT JOIN order_items AS oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- Sales per category (every category, even with no sales)
-- Electronics 110000 | Accessories 6900 | Stationery 0
SELECT cat.category_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS category_sales
FROM categories AS cat
LEFT JOIN products    AS p  ON cat.category_id = p.category_id
LEFT JOIN order_items AS oi ON p.product_id    = oi.product_id
GROUP BY cat.category_id, cat.category_name
ORDER BY category_sales DESC;

-- "Find missing" pattern on other tables:
-- Customers who never ordered -> Karthik, Suresh
SELECT c.customer_name
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Products never ordered -> Notebook, Monitor
SELECT p.product_name
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;


/* ---------------------------------------------------------------------
   8. ERROR CLINIC
   Wrong queries are commented out so this file runs without errors.
   --------------------------------------------------------------------- */

/* ERROR 1 - Inserting a child row with no parent
   Wrote:
     INSERT INTO orders VALUES (105, 99, '2026-04-01');
   Error:  1452 - Cannot add or update a child row:
           a foreign key constraint fails
   Why:    No customer has customer_id 99.
   Fix:    Insert the customer first, or use an existing id.          */


/* ERROR 2 - Dropping a parent table before its child
   Wrote:
     DROP TABLE customers;
   Error:  3730 - Cannot drop table 'customers' referenced by a
           foreign key constraint
   Why:    orders still points to customers.
   Fix:    Drop children first: order_items -> orders -> customers
           (see Setup).                                               */


/* ERROR 3 - Self join without aliases
   Wrote:
     SELECT employee_name FROM employees
     JOIN employees ON manager_id = employee_id;
   Error:  1066 - Not unique table/alias: 'employees'
   Why:    The same table twice needs two different names.
   Fix:    employees AS e JOIN employees AS m ON e.manager_id = m.employee_id */


/* ERROR 4 - UNION with different column counts
   Wrote:
     SELECT c.customer_id, c.customer_name, o.order_id ...
     UNION
     SELECT c.customer_id, o.order_id ...
   Error:  1222 - The used SELECT statements have a different
           number of columns
   Fix:    Same number of columns, same order, in both SELECTs.       */


/* ERROR 5 - Filter in WHERE drops LEFT JOIN rows  (no error, wrong result)
   Wrote:  LEFT JOIN orders ... WHERE o.order_date >= '2026-01-01' ...
   Result: Only Arun. Customers without a January order vanish.
   Fix:    Move the condition into ON when every left row must stay
           (see Section 5).                                           */


/* ERROR 6 - INNER JOIN after a LEFT JOIN  (no error, wrong result)
   Wrote:
     FROM customers c
     LEFT JOIN orders o ON ...
     INNER JOIN order_items oi ON o.order_id = oi.order_id
   Result: Karthik and Suresh disappear.
   Why:    Their o.order_id is NULL, so the INNER JOIN finds no match.
   Fix:    Keep the chain LEFT: LEFT JOIN order_items ...              */


/* ERROR 7 - SUM shows NULL for customers with no orders  (no error)
   Wrote:  SUM(oi.quantity * oi.unit_price)
   Result: Karthik NULL, Suresh NULL
   Fix:    COALESCE(SUM(...), 0)                                       */


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   FOREIGN KEY       -> child column must match a parent PRIMARY KEY;
                        drop child tables first; doesn't replace ON
   FULL OUTER JOIN   -> not in MySQL: LEFT JOIN UNION RIGHT JOIN
   UNION / UNION ALL -> remove duplicates / keep duplicates;
                        same column count in both SELECTs
   SELF JOIN         -> same table, two aliases (e, m);
                        e.manager_id = m.employee_id
   CROSS JOIN        -> every pair, no ON; rows = a x b
   ON vs WHERE       -> ON keeps all LEFT rows; WHERE can drop them
   Multi-table JOIN  -> one ON per JOIN; stay LEFT once you start LEFT
   JOIN + GROUP BY   -> group by the id and name; COALESCE(SUM, 0)
   Find missing      -> LEFT JOIN ... WHERE right.id IS NULL
   Errors            -> 1452 FK fails | 3730 drop parent first |
                        1066 self join alias | 1222 UNION columns
   ===================================================================== */