/* =====================================================================
   DAY 8 - SQL PRACTICE NOTES
   Topics: Subqueries (IN / NOT IN, scalar, derived table),
           Correlated subqueries, EXISTS / NOT EXISTS,
           Common Table Expressions (WITH), Views, Error clinic
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP  (same tables and data as Day 6)

   NOTE: Drop child tables first, then parents (foreign keys).
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day8_practice;
USE day8_practice;

DROP VIEW  IF EXISTS customer_order_summary;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id    INT PRIMARY KEY,
    customer_name  VARCHAR(100),
    city           VARCHAR(50)
);

CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_date   DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100),
    price         DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY,
    order_id       INT,
    product_id     INT,
    quantity       INT,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
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

INSERT INTO products VALUES
    (201, 'Laptop',   55000.00),
    (202, 'Mouse',      800.00),
    (203, 'Keyboard',  1500.00);

INSERT INTO order_items VALUES
    (1, 101, 201, 1),
    (2, 101, 202, 2),
    (3, 102, 203, 1),
    (4, 103, 202, 1),
    (5, 104, 201, 1),
    (6, 104, 203, 2);

/* Who has what:
     Arun    -> orders 101, 102      Priya -> 103      Divya -> 104
     Karthik, Suresh -> no orders
   Quantity sold: Mouse 3, Keyboard 3, Laptop 2                         */


/* ---------------------------------------------------------------------
   1. WHAT IS A SUBQUERY?

   A query written INSIDE another query, in brackets.
   The inner query runs first; the outer query uses its result.

   Three shapes, depending on what the inner query returns:
     Scalar      -> ONE value         WHERE price > (SELECT AVG(price) ...)
     List        -> ONE column        WHERE id IN (SELECT customer_id ...)
     Table       -> rows + columns    FROM (SELECT ...) AS t   (derived table)

   NOTE: Every subquery needs its own brackets.
   NOTE: Inside a function it needs TWO pairs: ROUND((SELECT ...))
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   2. IN / NOT IN WITH A SUBQUERY  (list subquery)

   The subquery returns a list of ids; IN checks against that list.
   --------------------------------------------------------------------- */

-- Inner query returns: 1, 1, 2, 4  (duplicates don't matter for IN)
-- Customers who have placed orders -> Arun, Priya, Divya
SELECT customer_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);

-- Customers who have NOT placed orders -> Karthik, Suresh
SELECT customer_name
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders);

/* NOTE: NOT IN trap. If the subquery returns even ONE NULL,
         NOT IN returns NO rows at all. Here orders.customer_id has no
         NULLs, so it works. NOT EXISTS (Section 5) is the safer choice. */


/* ---------------------------------------------------------------------
   3. SCALAR SUBQUERY - compare against one calculated value

   Aggregates can't go straight into WHERE (Error 1111),
   so calculate the value in a subquery first.

   Step 1: average price = (55000 + 800 + 1500) / 3 = 19100
   Step 2: keep products with price > 19100
   --------------------------------------------------------------------- */

-- Result: Laptop 55000.00
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);


/* ---------------------------------------------------------------------
   4. DERIVED TABLE - a subquery used in FROM

   The inner query builds a temporary table; the outer query reads it.
   NOTE: A derived table MUST have an alias (Error 1248 without it).

   Question: customers with an above-average number of orders
     Orders per customer: Arun 2, Priya 1, Divya 1
     Average = 4 / 3 = 1.33
     Above average: Arun
   --------------------------------------------------------------------- */

-- Step 1 on its own: order count per customer -> 2, 1, 1
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id;

-- Step 2: average of those counts -> 1.3333
SELECT AVG(order_count) AS avg_orders
FROM (SELECT COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS counts_per_customer;

-- Step 3: customers above that average -> customer_id 1
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > (SELECT AVG(order_count)
                   FROM (SELECT COUNT(*) AS order_count
                         FROM orders
                         GROUP BY customer_id) AS counts_per_customer);

-- Same, showing the name with a JOIN -> Arun 2
SELECT c.customer_name, COUNT(*) AS order_count
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) > (SELECT AVG(order_count)
                   FROM (SELECT COUNT(*) AS order_count
                         FROM orders
                         GROUP BY customer_id) AS counts_per_customer);


/* ---------------------------------------------------------------------
   5. CORRELATED SUBQUERY and EXISTS / NOT EXISTS

   Normal subquery     -> runs ONCE, result reused
   Correlated subquery -> runs once PER OUTER ROW, because it uses a
                          column from the outer query (c.customer_id)

   EXISTS (subquery)     -> TRUE if the subquery returns at least 1 row
   NOT EXISTS (subquery) -> TRUE if it returns no rows

   NOTE: SELECT 1 is a convention. EXISTS only checks IF a row exists,
         not what is in it, so the selected value doesn't matter.
   NOTE: NOT EXISTS has no NULL trap, unlike NOT IN.
   --------------------------------------------------------------------- */

-- Customers WITH orders -> 1 Arun, 2 Priya, 4 Divya
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE EXISTS (SELECT 1
              FROM orders AS o
              WHERE o.customer_id = c.customer_id);

-- Customers WITHOUT orders -> 3 Karthik, 5 Suresh
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE NOT EXISTS (SELECT 1
                  FROM orders AS o
                  WHERE o.customer_id = c.customer_id);

-- Correlated subquery in WHERE: each customer's LATEST order
-- Result: 102 (Arun, 2026-01-12) | 103 (Priya) | 104 (Divya)
SELECT o.customer_id, o.order_id, o.order_date
FROM orders AS o
WHERE o.order_date = (SELECT MAX(o2.order_date)
                      FROM orders AS o2
                      WHERE o2.customer_id = o.customer_id);

-- Correlated subquery in SELECT: order count next to each customer
-- Result: Arun 2 | Priya 1 | Karthik 0 | Divya 1 | Suresh 0
SELECT c.customer_name,
       (SELECT COUNT(*)
        FROM orders AS o
        WHERE o.customer_id = c.customer_id) AS order_count
FROM customers AS c;

/* Three ways to find customers with no orders - all give Karthik, Suresh:
     WHERE customer_id NOT IN (SELECT customer_id FROM orders)
     WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
     LEFT JOIN orders o ... WHERE o.order_id IS NULL                     */


/* ---------------------------------------------------------------------
   6. CTE - COMMON TABLE EXPRESSION (WITH)

   A temporary named result, defined at the START of a query and used
   only by the query right after it. Needs MySQL 8.0+.

   SYNTAX:
     WITH cte_name AS (
         SELECT ...
     )
     SELECT ... FROM cte_name;

   NOTE: Name FIRST, then AS:  WITH name AS (...)   not  WITH (...) AS name
   NOTE: No semicolon between the CTE and the SELECT after it.
   NOTE: A CTE can hold one value, one column, or a full table.
   --------------------------------------------------------------------- */

-- Total quantity sold per product
-- Result: Keyboard 3 | Mouse 3 | Laptop 2
-- (Keyboard and Mouse tie at 3, so product_name breaks the tie)
WITH product_quantity AS (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity) AS total_quantity
    FROM products AS p
    INNER JOIN order_items AS oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT *
FROM product_quantity
ORDER BY total_quantity DESC, product_name;

-- The Section 4 question, rewritten with a CTE (much easier to read)
-- Result: customer_id 1, order_count 2
WITH counts_per_customer AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id, order_count
FROM counts_per_customer
WHERE order_count > (SELECT AVG(order_count) FROM counts_per_customer);

-- MULTIPLE CTEs: separate with commas; a later CTE can use an earlier one
-- Order totals: 101 = 56600 | 102 = 1500 | 103 = 800 | 104 = 58000
-- Average     : 116900 / 4 = 29225
-- Result      : orders above average -> 101, 104
WITH order_totals AS (
    SELECT oi.order_id,
           SUM(p.price * oi.quantity) AS order_total
    FROM order_items AS oi
    INNER JOIN products AS p ON oi.product_id = p.product_id
    GROUP BY oi.order_id
),
avg_total AS (
    SELECT AVG(order_total) AS avg_order
    FROM order_totals
)
SELECT ot.order_id, ot.order_total
FROM order_totals AS ot, avg_total AS a
WHERE ot.order_total > a.avg_order
ORDER BY ot.order_id;


/* ---------------------------------------------------------------------
   7. VIEW - a saved query

   A view stores the QUERY, not the data. Each time you use it, MySQL
   runs the query on the real tables, so it's always up to date.
   Use it like a table: SELECT, WHERE, JOIN ...

   CREATE VIEW name AS SELECT ...;
   CREATE OR REPLACE VIEW name AS SELECT ...;   -- change an existing one
   DROP VIEW name;                              -- tables are untouched
   --------------------------------------------------------------------- */

CREATE VIEW customer_order_summary AS
SELECT c.customer_id,
       c.customer_name,
       COUNT(o.order_id) AS order_count
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Result: Arun 2 | Priya 1 | Karthik 0 | Divya 1 | Suresh 0
SELECT * FROM customer_order_summary;

-- Filter it like a normal table -> Arun 2
SELECT * FROM customer_order_summary WHERE order_count > 1;

-- NOTE: COUNT(o.order_id), not COUNT(*). With COUNT(*), Karthik and
--       Suresh would show 1, because their LEFT JOIN row still exists.

DROP VIEW customer_order_summary;


/* ---------------------------------------------------------------------
   8. SUBQUERY vs CTE vs VIEW

                 Subquery           CTE                 View
   Written       inside brackets    WITH ... AS ( )     CREATE VIEW
   Has a name    no (only alias)    yes                 yes
   Lasts         one query          one query           until dropped
   Reusable      no                 within that query   by any query
   Stores data   no                 no                  no

   When to use:
   - Short, one-off check          -> subquery
   - Long query, several steps     -> CTE (reads top to bottom)
   - Same query used again & again -> view
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   9. ERROR CLINIC
   Wrong queries are commented out so this file runs without errors.
   --------------------------------------------------------------------- */

/* ERROR 1 - Aggregate directly in WHERE
   Wrote:
     SELECT product_name FROM products WHERE price > AVG(price);
   Error:  1111 - Invalid use of group function
   Fix:    WHERE price > (SELECT AVG(price) FROM products)             */


/* ERROR 2 - = with a subquery that returns many rows
   Wrote:
     SELECT customer_name FROM customers
     WHERE customer_id = (SELECT customer_id FROM orders);
   Error:  1242 - Subquery returns more than 1 row
   Why:    = expects ONE value; the subquery returns 1, 1, 2, 4.
   Fix:    Use IN:  WHERE customer_id IN (SELECT customer_id FROM orders) */


/* ERROR 3 - Derived table without an alias
   Wrote:
     SELECT AVG(order_count)
     FROM (SELECT COUNT(*) AS order_count FROM orders GROUP BY customer_id);
   Error:  1248 - Every derived table must have its own alias
   Fix:    ... GROUP BY customer_id) AS counts_per_customer;           */


/* ERROR 4 - Subquery in IN returning more than one column
   Wrote:
     WHERE customer_id IN (SELECT * FROM orders)
   Error:  1241 - Operand should contain 1 column(s)
   Fix:    Select exactly one column: (SELECT customer_id FROM orders) */


/* ERROR 5 - NOT IN with a NULL in the list  (no error, wrong result)
   If orders had a row with customer_id NULL:
     WHERE customer_id NOT IN (SELECT customer_id FROM orders)
   Result: 0 rows, even for Karthik and Suresh
   Fix:    Use NOT EXISTS, or add WHERE customer_id IS NOT NULL
           inside the subquery.                                         */


/* ERROR 6 - CTE syntax mistakes
   Wrote:  WITH (SELECT ...) AS product_quantity  -> Error 1064
   Fix:    WITH product_quantity AS (SELECT ...)

   Wrote:  WITH product_quantity AS (SELECT ...);
           SELECT * FROM product_quantity;         -> Error 1064 / 1146
   Why:    The semicolon ends the statement, so the CTE is gone.
   Fix:    No semicolon between the CTE and its SELECT.

   Wrote:  WITH product_quantity AS (SELECT ...)   (and nothing after)
   Error:  1064
   Fix:    A CTE must be followed by a complete query starting with SELECT. */


/* ERROR 7 - Creating a view that already exists
   Wrote:  CREATE VIEW customer_order_summary AS ...   (second time)
   Error:  1050 - Table 'customer_order_summary' already exists
   Fix:    CREATE OR REPLACE VIEW ...   or   DROP VIEW IF EXISTS first */


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   Subquery          -> query inside brackets; inner runs first
   Scalar subquery   -> one value; use with = > <  (more rows -> 1242)
   List subquery     -> one column; use with IN / NOT IN (more cols -> 1241)
   Derived table     -> subquery in FROM; MUST have an alias (1248)
   Aggregate filter  -> WHERE price > (SELECT AVG(price) ...), not AVG in WHERE
   Correlated        -> uses an outer column; runs once per outer row
   EXISTS            -> TRUE if the subquery finds any row; SELECT 1 is fine
   NOT IN vs NOT EXISTS -> NOT IN breaks on NULL; NOT EXISTS is safe
   CTE               -> WITH name AS (...) SELECT ...; no ; in between;
                        several CTEs separated by commas
   View              -> saved query, no stored data; CREATE OR REPLACE VIEW,
                        DROP VIEW
   Count with LEFT JOIN -> COUNT(right.id), not COUNT(*)
   ===================================================================== */