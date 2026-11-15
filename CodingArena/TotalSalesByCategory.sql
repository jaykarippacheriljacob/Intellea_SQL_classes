-- ============================================================
-- Exercise: Total Sales by Category
--           (SQL Lab · Easy · DQL, Aggregation, Aliasing)
--
-- Question:
--   You are given a table named sales that records individual
--   product sales transactions.
--
--   Table: sales
--   Column            Type     Description
--   sale_id           INTEGER  Unique ID for each sale.
--   product_name      TEXT     The name of the product sold.
--   product_category  TEXT     The category the product belongs to.
--   quantity_sold     INTEGER  The number of units sold in the
--                              transaction.
--   sale_date         DATE     The date of the sale.
--
--   Your task is to write a SQL query to calculate the total
--   quantity of items sold for each product category.
--
--   Task: Write a query that returns the total quantity sold for
--   each product category. The output should have two columns:
--   product_category and total_quantity_sold. Please order the
--   results alphabetically by product_category
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] GROUP BY puts each category's sales into one group;
--    SUM adds up quantity_sold inside each group.
--    AS gives the total the column name the task asks for.
SELECT product_category,
       SUM(quantity_sold) AS total_quantity_sold
FROM sales
GROUP BY product_category
ORDER BY product_category ASC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- GROUP BY rule
--   product_category is a plain column in SELECT, so it must be
--   in GROUP BY. SUM(quantity_sold) is inside an aggregate, so it
--   doesn't need to be.
--   Missing GROUP BY -> Error 1140
--
-- SUM vs COUNT
--   SUM(quantity_sold) -> total UNITS sold   (what's asked)
--   COUNT(*)           -> number of SALES (transactions)
--   e.g. two sales of 3 and 5 units -> SUM 8, COUNT 2
--
-- ORDER BY with GROUP BY
--   GROUP BY doesn't sort. Always add ORDER BY when the task
--   asks for an order. ASC is the default (optional).
--
-- Sorting by the total instead
--   ORDER BY total_quantity_sold DESC  -> best-selling category
--   first (aliases are allowed in ORDER BY).
--
-- Filtering the groups
--   Only categories with more than 10 units:
--   ... GROUP BY product_category
--       HAVING SUM(quantity_sold) > 10
--   (Aggregates go in HAVING, never in WHERE -> Error 1111)
--
-- NULL quantities
--   SUM skips NULLs. A category whose quantities are all NULL
--   shows NULL; use COALESCE(SUM(quantity_sold), 0) to show 0.
-- ============================================================