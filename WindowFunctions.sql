/* =====================================================================
   DAY 10 - SQL PRACTICE NOTES
   Topics: Window functions, OVER(), ROW_NUMBER / RANK / DENSE_RANK,
           PARTITION BY, Top-N per group, De-duplicating with
           ROW_NUMBER, Window aggregates (overall total, running total,
           moving average, % of total), LAG / LEAD, Error clinic
   Needs:  MySQL 8.0+
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP
   NOTE: Drop CHILD tables first (foreign keys), then parents.
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day10_window_functions_practice;
USE day10_window_functions_practice;

DROP TABLE IF EXISTS product_sales;      -- child of products
DROP TABLE IF EXISTS products;           -- child of categories
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customer_imports;
DROP TABLE IF EXISTS daily_sales;

CREATE TABLE categories (
    category_id    INT PRIMARY KEY,
    category_name  VARCHAR(50)
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(80),
    category_id   INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE product_sales (
    sale_id     INT PRIMARY KEY,
    product_id  INT,
    sale_date   DATE,
    quantity    INT,
    revenue     DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE customer_imports (
    import_id      INT PRIMARY KEY,
    customer_name  VARCHAR(60),
    email          VARCHAR(100),
    updated_at     DATETIME
);

CREATE TABLE daily_sales (
    sale_date     DATE PRIMARY KEY,
    daily_amount  DECIMAL(10,2)
);

INSERT INTO categories VALUES
    (1, 'Electronics'), (2, 'Accessories'), (3, 'Home Appliances');

INSERT INTO products VALUES
    (101, 'Laptop', 1),  (102, 'Tablet', 1),   (103, 'Monitor', 1),    (104, 'Camera', 1),
    (201, 'Mouse', 2),   (202, 'Keyboard', 2), (203, 'Headphones', 2), (204, 'Webcam', 2),
    (301, 'Mixer', 3),   (302, 'Vacuum Cleaner', 3);

INSERT INTO product_sales VALUES
    (1,  101, '2026-01-01', 10, 500000.00),
    (2,  102, '2026-01-02',  8, 240000.00),
    (3,  103, '2026-01-03',  8, 160000.00),
    (4,  104, '2026-01-04',  5, 175000.00),
    (5,  201, '2026-01-01', 30,  24000.00),
    (6,  202, '2026-01-02', 25,  37500.00),
    (7,  203, '2026-01-03', 25,  50000.00),
    (8,  204, '2026-01-04', 12,  36000.00),
    (9,  301, '2026-01-02',  7,  21000.00),
    (10, 302, '2026-01-03',  4,  32000.00);

INSERT INTO customer_imports VALUES
    (1, 'Arun',       'arun@gmail.com',    '2026-02-01 09:00:00'),
    (2, 'Arun Kumar', 'arun@gmail.com',    '2026-02-03 10:30:00'),
    (3, 'Priya',      'priya@gmail.com',   '2026-02-02 11:00:00'),
    (4, 'Karthik',    'karthik@gmail.com', '2026-02-01 08:00:00'),
    (5, 'Karthik S',  'karthik@gmail.com', '2026-02-04 12:00:00'),
    (6, 'Divya',      'divya@gmail.com',   '2026-02-05 14:00:00');

INSERT INTO daily_sales VALUES
    ('2026-01-01', 1000.00), ('2026-01-02', 1500.00),
    ('2026-01-03',  800.00), ('2026-01-04', 1200.00),
    ('2026-01-05',  500.00);

/* Revenue per product (one sale each):
     Electronics     : Laptop 500000, Tablet 240000, Camera 175000, Monitor 160000
     Accessories     : Headphones 50000, Keyboard 37500, Webcam 36000, Mouse 24000
     Home Appliances : Vacuum Cleaner 32000, Mixer 21000
   customer_imports  : Arun and Karthik were imported TWICE (same email)  */


/* ---------------------------------------------------------------------
   1. WHAT IS A WINDOW FUNCTION?

   A function that calculates across a set of rows (the "window")
   WITHOUT collapsing them.
     GROUP BY       -> many rows in, one row per group out
     OVER( )        -> every row kept, the result added beside it

   SYNTAX:
     function() OVER (
         PARTITION BY col      -- optional: restart per group
         ORDER BY col          -- order inside the window
         ROWS BETWEEN ...      -- optional: which rows to include
     )

   Two families:
     Ranking    -> ROW_NUMBER, RANK, DENSE_RANK  (ORDER BY required)
     Aggregate  -> SUM, AVG, COUNT, MIN, MAX ... OVER ( )
   Offset       -> LAG, LEAD (look at previous / next row)
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   2. ROW_NUMBER - a unique number per row

   Step 1: a CTE adds up revenue per product (join 3 tables + GROUP BY)
   Step 2: ROW_NUMBER numbers the products by revenue

   NOTE: The CTE is named product_totals, NOT product_sales.
         Naming a CTE the same as a real table is confusing: inside
         the WITH block "product_sales" means the real table, after
         it means the CTE (see Error clinic).
   --------------------------------------------------------------------- */

-- Across ALL products: Laptop 1, Tablet 2, Camera 3, Monitor 4,
-- Headphones 5, Keyboard 6, Webcam 7, Vacuum Cleaner 8, Mouse 9, Mixer 10
WITH product_totals AS (
    SELECT p.product_id,
           p.product_name,
           c.category_name,
           SUM(ps.revenue) AS total_revenue
    FROM products AS p
    JOIN categories    AS c  ON p.category_id = c.category_id
    JOIN product_sales AS ps ON p.product_id  = ps.product_id
    GROUP BY p.product_id, p.product_name, c.category_name
)
SELECT product_name, category_name, total_revenue,
       ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS row_num
FROM product_totals
ORDER BY row_num;


/* ---------------------------------------------------------------------
   3. PARTITION BY - restart the numbering per group

   PARTITION BY category_name -> 1, 2, 3 ... starts again in each category
   --------------------------------------------------------------------- */

-- Accessories     : Headphones 1, Keyboard 2, Webcam 3, Mouse 4
-- Electronics     : Laptop 1, Tablet 2, Camera 3, Monitor 4
-- Home Appliances : Vacuum Cleaner 1, Mixer 2
WITH product_totals AS (
    SELECT p.product_id, p.product_name, c.category_name,
           SUM(ps.revenue) AS total_revenue
    FROM products AS p
    JOIN categories    AS c  ON p.category_id = c.category_id
    JOIN product_sales AS ps ON p.product_id  = ps.product_id
    GROUP BY p.product_id, p.product_name, c.category_name
)
SELECT product_name, category_name, total_revenue,
       ROW_NUMBER() OVER (PARTITION BY category_name
                          ORDER BY total_revenue DESC) AS row_num
FROM product_totals
ORDER BY category_name, row_num;


/* ---------------------------------------------------------------------
   4. ROW_NUMBER vs RANK vs DENSE_RANK

   They differ ONLY when values tie. On prices 900, 700, 700, 500:
     ROW_NUMBER -> 1, 2, 3, 4   always unique (tie order not fixed)
     RANK       -> 1, 2, 2, 4   ties share, then a GAP
     DENSE_RANK -> 1, 2, 2, 3   ties share, NO gap

   This data has no tied revenues, so all three agree here.
   The quantity column DOES tie (8, 8 and 25, 25) - see the 2nd query.
   --------------------------------------------------------------------- */

-- No ties in revenue -> all three columns are 1 to 10
SELECT p.product_name, ps.revenue,
       ROW_NUMBER() OVER (ORDER BY ps.revenue DESC) AS row_num,
       RANK()       OVER (ORDER BY ps.revenue DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY ps.revenue DESC) AS product_rank
FROM products AS p
JOIN product_sales AS ps ON p.product_id = ps.product_id
ORDER BY ps.revenue DESC;

-- Ties in quantity: 30, 25, 25, 12, 10, 8, 8, 7, 5, 4
--   RANK       -> 1, 2, 2, 4, 5, 6, 6, 8, 9, 10
--   DENSE_RANK -> 1, 2, 2, 3, 4, 5, 5, 6, 7, 8
SELECT p.product_name, ps.quantity,
       ROW_NUMBER() OVER (ORDER BY ps.quantity DESC, p.product_name) AS row_num,
       RANK()       OVER (ORDER BY ps.quantity DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY ps.quantity DESC) AS dense_rnk
FROM products AS p
JOIN product_sales AS ps ON p.product_id = ps.product_id
ORDER BY ps.quantity DESC, p.product_name;


/* ---------------------------------------------------------------------
   5. TOP-N PER GROUP

   A window result can't be used in WHERE (Error 3593), because WHERE
   runs BEFORE the window is calculated. Wrap it in a CTE, then filter.
   --------------------------------------------------------------------- */

-- Best-selling product in each category
-- Accessories Headphones 50000 | Electronics Laptop 500000 |
-- Home Appliances Vacuum Cleaner 32000
WITH product_totals AS (
    SELECT p.product_id, p.product_name, c.category_name,
           SUM(ps.revenue) AS total_revenue
    FROM products AS p
    JOIN categories    AS c  ON p.category_id = c.category_id
    JOIN product_sales AS ps ON p.product_id  = ps.product_id
    GROUP BY p.product_id, p.product_name, c.category_name
),
ranked AS (
    SELECT product_name, category_name, total_revenue,
           ROW_NUMBER() OVER (PARTITION BY category_name
                              ORDER BY total_revenue DESC) AS row_num
    FROM product_totals
)
SELECT category_name, product_name, total_revenue
FROM ranked
WHERE row_num = 1
ORDER BY category_name;

-- Change to WHERE row_num <= 2 for the top 2 per category.


/* ---------------------------------------------------------------------
   6. DE-DUPLICATING WITH ROW_NUMBER  (data-cleaning pattern)

   customer_imports has the same email twice for Arun and Karthik.
   Keep only the LATEST row per email:
     PARTITION BY email          -> one group per customer
     ORDER BY updated_at DESC    -> newest row gets 1
     WHERE rn = 1                -> keep the newest only

   GROUP BY email can't do this: it can't tell you WHICH name and
   import_id belong to the latest row.
   --------------------------------------------------------------------- */

-- See the numbering first: duplicates get rn = 2
SELECT import_id, customer_name, email, updated_at,
       ROW_NUMBER() OVER (PARTITION BY email
                          ORDER BY updated_at DESC) AS rn
FROM customer_imports
ORDER BY email, rn;

-- Latest row per email -> 2 Arun Kumar | 6 Divya | 5 Karthik S | 3 Priya
WITH numbered AS (
    SELECT import_id, customer_name, email, updated_at,
           ROW_NUMBER() OVER (PARTITION BY email
                              ORDER BY updated_at DESC) AS rn
    FROM customer_imports
)
SELECT import_id, customer_name, email, updated_at
FROM numbered
WHERE rn = 1
ORDER BY email;

-- The OLD copies (rn > 1) are the ones a cleanup would delete -> 1, 4
WITH numbered AS (
    SELECT import_id,
           ROW_NUMBER() OVER (PARTITION BY email
                              ORDER BY updated_at DESC) AS rn
    FROM customer_imports
)
SELECT import_id FROM numbered WHERE rn > 1 ORDER BY import_id;


/* ---------------------------------------------------------------------
   7. WINDOW AGGREGATE FUNCTIONS  (daily_sales)

   SUM / AVG / COUNT / MIN / MAX + OVER ( )
     OVER ()                         -> whole table, same value on every row
     OVER (ORDER BY ...)             -> running (builds up row by row)
     OVER (ORDER BY ... ROWS BETWEEN n PRECEDING AND CURRENT ROW)
                                     -> moving (sliding window)
   --------------------------------------------------------------------- */

-- Overall total repeated on every row -> 5000 on all 5 rows
SELECT sale_date, daily_amount,
       SUM(daily_amount) OVER () AS overall_total
FROM daily_sales
ORDER BY sale_date;

-- Running total -> 1000, 2500, 3300, 4500, 5000
SELECT sale_date, daily_amount,
       SUM(daily_amount) OVER (ORDER BY sale_date
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
           AS running_total
FROM daily_sales
ORDER BY sale_date;

-- Share of the total -> 20.00, 30.00, 16.00, 24.00, 10.00 (%)
SELECT sale_date, daily_amount,
       ROUND(daily_amount * 100 / SUM(daily_amount) OVER (), 2) AS pct_of_total
FROM daily_sales
ORDER BY sale_date;

-- Several window aggregates side by side
-- running_avg     -> 1000.00, 1250.00, 1100.00, 1125.00, 1000.00
-- moving_avg_3    -> 1000.00, 1250.00, 1100.00, 1166.67,  833.33
-- best_so_far     -> 1000, 1500, 1500, 1500, 1500
SELECT sale_date, daily_amount,
       ROUND(AVG(daily_amount) OVER (ORDER BY sale_date
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_avg,
       ROUND(AVG(daily_amount) OVER (ORDER BY sale_date
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)         AS moving_avg_3,
       MAX(daily_amount) OVER (ORDER BY sale_date
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)     AS best_so_far
FROM daily_sales
ORDER BY sale_date;

-- Window aggregates on the product data: each product's share of
-- its category's revenue
-- Electronics: Laptop 46.51, Tablet 22.33, Camera 16.28, Monitor 14.88
SELECT p.product_name, c.category_name, ps.revenue,
       SUM(ps.revenue) OVER (PARTITION BY c.category_name) AS category_total,
       ROUND(ps.revenue * 100
             / SUM(ps.revenue) OVER (PARTITION BY c.category_name), 2) AS pct_of_category
FROM products AS p
JOIN categories    AS c  ON p.category_id = c.category_id
JOIN product_sales AS ps ON p.product_id  = ps.product_id
ORDER BY c.category_name, ps.revenue DESC;


/* ---------------------------------------------------------------------
   8. LAG / LEAD - compare with the previous / next row

   LAG(col)  -> value from the row BEFORE   (first row -> NULL)
   LEAD(col) -> value from the row AFTER    (last row  -> NULL)
   --------------------------------------------------------------------- */

-- change_vs_prev -> NULL, 500, -700, 400, -700
SELECT sale_date, daily_amount,
       LAG(daily_amount)  OVER (ORDER BY sale_date)                AS prev_day,
       daily_amount - LAG(daily_amount) OVER (ORDER BY sale_date)  AS change_vs_prev,
       LEAD(daily_amount) OVER (ORDER BY sale_date)                AS next_day
FROM daily_sales
ORDER BY sale_date;


/* ---------------------------------------------------------------------
   9. CLAUSE ORDER (with window functions)

   EXECUTION: FROM -> JOIN/ON -> WHERE -> GROUP BY -> HAVING
              -> SELECT (window functions run HERE) -> ORDER BY -> LIMIT

   This explains:
   - WHERE / HAVING can't use a window result -> wrap in a CTE
   - ORDER BY at the end CAN use the window alias (row_num)
   - Window functions run AFTER GROUP BY, so they can wrap an
     aggregate: SUM(SUM(revenue)) OVER (...)
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   10. ERROR CLINIC
   Wrong queries are commented out so this file runs without errors.
   --------------------------------------------------------------------- */

/* ERROR 1 - Window result in WHERE
   Wrote:
     SELECT product_name, ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
     FROM ... WHERE rn = 1;
   Error:  1054 (unknown column rn), or 3593 if you repeat the
           ROW_NUMBER() inside WHERE
   Why:    WHERE runs before SELECT, so the window doesn't exist yet.
   Fix:    WITH r AS (...) SELECT ... FROM r WHERE rn = 1;            */


/* ERROR 2 - Ranking without ORDER BY inside OVER  (no error, meaningless)
   Wrote:  ROW_NUMBER() OVER (PARTITION BY category_name)
   Why:    No order -> the numbers are given in any order.
   Fix:    ROW_NUMBER() OVER (PARTITION BY category_name
                              ORDER BY total_revenue DESC)            */


/* ERROR 3 - ORDER BY inside OVER on a total  (no error, wrong meaning)
   Wrote:  SUM(daily_amount) OVER (ORDER BY sale_date) AS overall_total
   Result: 1000, 2500, 3300 ... a RUNNING total, not the overall total
   Fix:    SUM(daily_amount) OVER () for the same total on every row  */


/* ERROR 4 - CTE named the same as a real table  (confusing)
   Wrote:  WITH product_sales AS ( ... JOIN product_sales AS ps ... )
           SELECT ... FROM product_sales;
   Why:    Inside the WITH, product_sales is the REAL table; after it,
           product_sales is the CTE. It runs, but is easy to misread,
           and fails in databases that resolve the name differently.
   Fix:    Give the CTE its own name: WITH product_totals AS (...)    */


/* ERROR 5 - Forgetting the outer ORDER BY  (no error, order not fixed)
   ORDER BY inside OVER only decides the numbering. Add ORDER BY at
   the end for the display order, e.g. ORDER BY category_name, row_num */


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   Window function    -> calculates across rows, keeps every row
   OVER ()            -> whole table
   PARTITION BY       -> restart per group (like GROUP BY, rows kept)
   ORDER BY in OVER   -> required for ranking; makes SUM/AVG running
   ROW_NUMBER         -> 1,2,3,4  unique
   RANK               -> 1,2,2,4  ties share, gap
   DENSE_RANK         -> 1,2,2,3  ties share, no gap
   Top-N per group    -> CTE with ROW_NUMBER ... WHERE row_num <= N
   De-duplicate       -> ROW_NUMBER() OVER (PARTITION BY key
                         ORDER BY updated_at DESC), keep rn = 1
   Running total      -> SUM() OVER (ORDER BY ... ROWS BETWEEN
                         UNBOUNDED PRECEDING AND CURRENT ROW)
   Moving average     -> AVG() OVER (ORDER BY ... ROWS BETWEEN
                         2 PRECEDING AND CURRENT ROW)
   % of total         -> col * 100 / SUM(col) OVER ()
   LAG / LEAD         -> previous / next row's value
   Window in WHERE    -> not allowed; filter in an outer query
   ===================================================================== */