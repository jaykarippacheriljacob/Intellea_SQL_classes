-- ============================================================
-- Exercise: Filter with IN Against a Short List
--           (SQL Lab · Easy · IN & NOT IN)
--
-- Question:
--   IN checks a column against a list of values in one clean
--   condition, instead of chaining several ORs.
--   The warehouse report should cover Electronics and Furniture
--   only. Select name and category for products where category
--   is IN ('Electronics', 'Furniture'), ordered by product_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Keep only Electronics and Furniture rows,
--    then sort by product_id (ASC is the default, so it's optional).
SELECT name, category
FROM products
WHERE category IN ('Electronics', 'Furniture')
ORDER BY product_id ASC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Same query with OR (longer)
--   WHERE category = 'Electronics' OR category = 'Furniture'
--
-- ASC is optional
--   ORDER BY product_id ASC  =  ORDER BY product_id
--
-- Sorting by a column not in the SELECT list
--   product_id isn't selected, but ORDER BY product_id still
--   works because the column exists in the table.
--
-- Missing quotes or brackets
--   WHERE category IN (Electronics, Furniture)   -> error
--   WHERE category IN 'Electronics', 'Furniture' -> error 1064
--   Fix: IN ('Electronics', 'Furniture')
--
-- Clause order
--   WHERE must come before ORDER BY.
-- ============================================================