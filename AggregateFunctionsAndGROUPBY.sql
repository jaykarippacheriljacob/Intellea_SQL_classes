/* =====================================================================
   DAY 5 - SQL PRACTICE NOTES
   Topics: Aggregate functions, GROUP BY, CASE with GROUP BY, HAVING,
           Clause order, Error clinic
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day5;
USE day5;

DROP TABLE IF EXISTS day5;

CREATE TABLE day5 (
    sale_id        INT PRIMARY KEY,
    customer_name  VARCHAR(50),
    city           VARCHAR(50),
    category       VARCHAR(50),
    product        VARCHAR(50),
    quantity       INT,
    sales_amount   INT,
    order_date     DATE
);

INSERT INTO day5 VALUES
    (1,  'Arun',    'Chennai',    'Electronics', 'Laptop',     1,    50000, '2026-01-10'),
    (2,  'Priya',   'Chennai',    'Furniture',   'Chair',      2,    12000, '2026-01-15'),
    (3,  'Karthik', 'Coimbatore', 'Electronics', 'Mobile',     1,    20000, '2026-02-05'),
    (4,  'Divya',   'Madurai',    'Grocery',     'Rice',       5,    5000,  '2026-02-18'),
    (5,  'Suresh',  'Chennai',    'Electronics', 'Headphones', 2,    8000,  '2026-03-12'),
    (6,  'Meena',   'Coimbatore', 'Furniture',   'Table',      1,    15000, '2026-03-20'),
    (7,  'Ravi',    'Madurai',    'Grocery',     'Oil',        3,    9000,  '2026-04-02'),
    (8,  'Anu',     'Chennai',    'Grocery',     'Snacks',     4,    4000,  '2026-04-15'),
    (9,  'Vijay',   'Salem',      'Electronics', 'Monitor',    1,    18000, '2026-05-05'),
    (10, 'Nisha',   'Coimbatore', 'Electronics', 'Keyboard',   NULL, NULL,  '2026-05-15');

-- Display all 10 sales records
SELECT * FROM day5;


/* ---------------------------------------------------------------------
   1. AGGREGATE FUNCTIONS

   Aggregate functions take MANY rows and return ONE value.
     COUNT() -> how many
     SUM()   -> total
     AVG()   -> average
     MIN()   -> smallest
     MAX()   -> largest

   NOTE: All of them IGNORE NULL values, except COUNT(*).
         Row 10 (Nisha) has sales_amount = NULL, so it is skipped
         by SUM, AVG, MIN, MAX and COUNT(sales_amount).
   --------------------------------------------------------------------- */

/* COUNT(*) vs COUNT(column)
   COUNT(*)      -> counts ALL rows, including NULLs      -> 10
   COUNT(column) -> counts only rows where column is NOT NULL -> 9  */
SELECT COUNT(*) AS total_records FROM day5;                 -- 10
SELECT COUNT(sales_amount) AS non_null_sales FROM day5;     -- 9

-- Trick: number of missing values = all rows - non-NULL rows
SELECT COUNT(*) - COUNT(sales_amount) AS missing_values FROM day5;  -- 1

-- SUM() : total of all non-NULL values
SELECT SUM(sales_amount) AS total_revenue FROM day5;        -- 141000

-- AVG() : SUM / COUNT(column)  ->  141000 / 9 (not / 10!)
SELECT AVG(sales_amount) AS average_sales FROM day5;        -- 15666.6667

-- MIN() / MAX() : smallest / largest value
SELECT MIN(sales_amount) AS min_sales FROM day5;            -- 4000
SELECT MAX(sales_amount) AS max_sales FROM day5;            -- 50000

/* ROUND(value, decimals) : rounds a number
   ROUND(x)    -> no decimals
   ROUND(x, 1) -> 1 decimal place
   Combining functions runs from the INSIDE out: AVG first, then ROUND */
SELECT ROUND(AVG(sales_amount), 1) AS average_sales FROM day5;  -- 15666.7

-- Several aggregates in one query
SELECT COUNT(*)          AS total_orders,
       SUM(sales_amount) AS total_revenue,
       MIN(sales_amount) AS min_sales,
       MAX(sales_amount) AS max_sales
FROM day5;


/* ---------------------------------------------------------------------
   2. GROUP BY

   GROUP BY puts rows with the SAME value into one group, then the
   aggregate function runs once PER GROUP.

   Without GROUP BY -> one result for the whole table
   With GROUP BY    -> one result row per group

   RULE: every column in SELECT must be either
         - in the GROUP BY, or
         - inside an aggregate function
   --------------------------------------------------------------------- */

-- Total sales per city
-- Chennai 74000, Coimbatore 35000, Madurai 14000, Salem 18000
SELECT city, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY city;

-- Number of orders per city
-- Chennai 4, Coimbatore 3, Madurai 2, Salem 1
SELECT city, COUNT(*) AS total_orders
FROM day5
GROUP BY city;

-- Average sales per city, rounded
-- NOTE: Coimbatore = (20000 + 15000) / 2 = 17500 (the NULL is skipped)
SELECT city, ROUND(AVG(sales_amount)) AS average_sales
FROM day5
GROUP BY city;

-- Total sales per category
-- Electronics 96000, Furniture 27000, Grocery 18000
SELECT category, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY category;


/* ---------------------------------------------------------------------
   3. GROUP BY WITH CASE

   CASE creates a new label for each row, then GROUP BY groups rows
   by that label.

   NOTE: Check IS NULL FIRST. Otherwise NULL falls through every WHEN
         and lands in ELSE ('Large'), which is wrong.
   NOTE: MySQL lets you GROUP BY the alias (sales_category).
         This is much easier to read than repeating the whole CASE.
   --------------------------------------------------------------------- */

-- Result:
--   Unknown -> total NULL,  1 order
--   Small   -> 26000,       4 orders
--   Medium  -> 65000,       4 orders
--   Large   -> 50000,       1 order
SELECT
    CASE
        WHEN sales_amount IS NULL                 THEN 'Unknown'
        WHEN sales_amount < 10000                 THEN 'Small'
        WHEN sales_amount BETWEEN 10000 AND 30000 THEN 'Medium'
        ELSE 'Large'
    END AS sales_category,
    SUM(sales_amount) AS total_sales,
    COUNT(*)          AS total_orders
FROM day5
GROUP BY sales_category;

/* Same result, but repeating the full CASE inside GROUP BY.
   Works in every database, but long and hard to read.
   In MySQL, prefer grouping by the alias (query above).

   GROUP BY
       CASE
           WHEN sales_amount IS NULL                 THEN 'Unknown'
           WHEN sales_amount < 10000                 THEN 'Small'
           WHEN sales_amount BETWEEN 10000 AND 30000 THEN 'Medium'
           ELSE 'Large'
       END;
*/


/* ---------------------------------------------------------------------
   4. GROUP BY MULTIPLE COLUMNS

   One group per unique COMBINATION of the columns.
   e.g. Chennai-Electronics, Chennai-Furniture, Chennai-Grocery ...
   --------------------------------------------------------------------- */

SELECT city, category, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY city, category
ORDER BY city, category;


/* ---------------------------------------------------------------------
   5. HAVING - filter GROUPS

   WHERE  -> filters ROWS   (before grouping)
   HAVING -> filters GROUPS (after grouping)

   Aggregate functions can be used in HAVING, but NOT in WHERE.
   --------------------------------------------------------------------- */

-- Cities with total sales above 30000
-- Result: Chennai 74000, Coimbatore 35000
SELECT city, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY city
HAVING SUM(sales_amount) > 30000;

-- WHERE and HAVING together:
-- Step 1 WHERE keeps only Electronics rows
-- Step 2 GROUP BY city
-- Step 3 HAVING keeps cities with Electronics sales above 15000
SELECT city, SUM(sales_amount) AS electronics_sales
FROM day5
WHERE category = 'Electronics'
GROUP BY city
HAVING SUM(sales_amount) > 15000;

-- NOTE: Text comparison is case-insensitive in MySQL,
--       so 'chennai' still matches 'Chennai' (4 rows)
SELECT * FROM day5 WHERE city = 'chennai';


/* ---------------------------------------------------------------------
   6. CLAUSE ORDER

   WRITING order:
     SELECT -> FROM -> WHERE -> GROUP BY -> HAVING -> ORDER BY -> LIMIT

   EXECUTION order (how MySQL actually runs it):
     FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT

   This explains the rules:
   - WHERE runs before GROUP BY -> it can't use SUM(), AVG() etc.
   - WHERE runs before SELECT   -> it can't use column aliases
   - ORDER BY runs after SELECT -> it CAN use aliases
   --------------------------------------------------------------------- */

-- Everything together: top 2 cities by sales, excluding Grocery
SELECT city, SUM(sales_amount) AS total_sales
FROM day5
WHERE category <> 'Grocery'
GROUP BY city
HAVING SUM(sales_amount) > 10000
ORDER BY total_sales DESC
LIMIT 2;


/* ---------------------------------------------------------------------
   7. ERROR CLINIC
   Wrong queries are commented out so this file runs without errors.
   --------------------------------------------------------------------- */

/* ERROR 1 - Aggregate function inside WHERE
   Wrote:
     SELECT city, SUM(sales_amount) AS total_sales FROM day5
     WHERE SUM(sales_amount) > 30000 GROUP BY city;
   Error:  1111 - Invalid use of group function
   Why:    WHERE runs BEFORE grouping, so SUM() doesn't exist yet.
   Fix:    Move the condition to HAVING.                               */
SELECT city, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY city
HAVING SUM(sales_amount) > 30000;


/* ERROR 2 - Selected column not included in GROUP BY
   Wrote:
     SELECT city, customer_name, SUM(sales_amount) FROM day5
     GROUP BY city;
   Error:  1055 - Expression #2 of SELECT list is not in GROUP BY
   Why:    One city has many customers. MySQL can't show one
           customer_name for the whole Chennai group.
   Fix:    Add the column to GROUP BY (or remove it from SELECT).      */
SELECT city, customer_name, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY city, customer_name;


/* ERROR 3 - Normal column with an aggregate and no GROUP BY
   Wrote:
     SELECT city, SUM(sales_amount) AS total_revenue FROM day5;
   Error:  1140 - In aggregated query without GROUP BY ...
   Why:    SUM() returns ONE row for the whole table, but city has
           many values. Which city should be shown?
   Fix:    Either drop the normal column, or add GROUP BY.             */
SELECT SUM(sales_amount) AS total_revenue FROM day5;      -- one total
SELECT city, SUM(sales_amount) AS total_revenue
FROM day5
GROUP BY city;                                            -- per city


/* ERROR 4 - Confusing COUNT(*) and COUNT(column)  (no error, wrong number)
   COUNT(*)            -> 10  (all rows)
   COUNT(sales_amount) -> 9   (NULL in row 10 is skipped)
   Use COUNT(*) to count rows; COUNT(column) to count filled values.   */
SELECT COUNT(*)            AS all_rows,
       COUNT(sales_amount) AS filled_sales
FROM day5;


/* ERROR 5 - Grouping by too few columns
   Wrote:
     SELECT city, category, SUM(sales_amount) FROM day5
     GROUP BY city;
   Error:  1055 (same as Error 2)
   Why:    category is in SELECT but not in GROUP BY.
   Fix:    Group by every non-aggregated column in SELECT.

   ALSO WATCH typos in column names:
     SUM(saels_amount) -> Error 1054 - Unknown column 'saels_amount'
   And in keywords:
     FROM day5 group5 HAVING ... -> Error 1064 (meant GROUP BY city)   */
SELECT city, category, SUM(sales_amount) AS total_sales
FROM day5
GROUP BY city, category;


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   COUNT(*)            -> all rows, NULLs included
   COUNT(column)       -> non-NULL values only
   SUM / AVG / MIN/MAX -> ignore NULLs (AVG divides by non-NULL count)
   ROUND(x, n)         -> round to n decimals
   GROUP BY            -> one result row per group
   SELECT rule         -> every column is in GROUP BY or an aggregate
   CASE + GROUP BY     -> label rows, then group by the label
                          (check IS NULL first)
   WHERE vs HAVING     -> rows before grouping vs groups after grouping
   Aggregates          -> allowed in HAVING, NOT in WHERE
   Writing order       -> SELECT FROM WHERE GROUP BY HAVING ORDER BY LIMIT
   Execution order     -> FROM WHERE GROUP BY HAVING SELECT ORDER BY LIMIT
   ===================================================================== */