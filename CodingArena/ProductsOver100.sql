-- ============================================================
-- Exercise: Products Over $100
--           (SQL Lab · Easy · DQL, WHERE, Filtering)
--
-- Question:
--   Write a query to find all product_name and category that have
--   a price greater than 100.00 from the Products table.
--
--   Task: Write a SELECT query that returns the product_name and
--   category columns for every product in the Products table whose
--   price is greater than 100.00.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Projection picks the 2 columns; WHERE keeps only rows
--    with price above 100. price itself isn't shown, but it can
--    still be used to filter.
SELECT product_name,
       category
FROM Products
WHERE price > 100.00;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- > vs >=
--   price > 100.00  -> a product priced exactly 100.00 is EXCLUDED
--   price >= 100.00 -> it would be included
--
-- Filtering on a column you don't select
--   WHERE can use any column of the table, even if it's not in
--   the SELECT list.
--
-- 100 vs 100.00
--   Both work the same for comparison; 100.00 just matches the
--   DECIMAL style of the price column.
--
-- Numbers without quotes
--   WHERE price > '100' still works (MySQL converts it), but write
--   numbers without quotes.
--
-- NULL prices
--   A product with price NULL is never returned: NULL > 100 is not
--   TRUE.
--
-- Clause order
--   SELECT -> FROM -> WHERE -> ORDER BY -> LIMIT
--   (No order was asked for here, so no ORDER BY.)
-- ============================================================