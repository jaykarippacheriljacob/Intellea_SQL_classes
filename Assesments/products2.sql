-- ============================================================
-- Exercise: Product Ranking by Category
--           (SQL Lab · Easy · ROW_NUMBER() with PARTITION BY)
--
-- Question:
--   You are given a table named `products` which contains
--   information about various products, including their name,
--   category, and price.
--   Your task is to write a SQL query to rank products within the
--   'Electronics' and 'Furniture' categories based on their price.
--   The most expensive product in each category should get a rank
--   of 1, the second most expensive a rank of 2, and so on.
--
--   Table Schema
--   The `products` table has the following columns:
--   * `product_id` (INTEGER): A unique identifier for each product.
--   * `product_name` (TEXT): The name of the product.
--   * `category` (TEXT): The category the product belongs to.
--   * `price` (REAL): The price of the product.
--
--   Task: Select the product name, category, price, and a
--   calculated rank for all products in the 'Electronics' and
--   'Furniture' categories. The rank should be calculated using
--   ROW_NUMBER(), partitioned by category and ordered by price in
--   descending order. Alias the rank column as price_rank. Order
--   the final result set by category alphabetically and then by
--   the calculated rank in ascending order.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] WHERE keeps only the two categories (runs BEFORE the
--    window function, so only these rows get numbered).
--    PARTITION BY category -> numbering restarts at 1 per category.
--    ORDER BY price DESC (inside OVER) -> most expensive gets 1.
--    Final ORDER BY only sets the display order.
SELECT product_name,
       category,
       price,
       ROW_NUMBER() OVER (PARTITION BY category
                          ORDER BY price DESC) AS price_rank
FROM products
WHERE category IN ('Electronics', 'Furniture')
ORDER BY category, price DESC;

-- Version matching the task wording exactly (safer if prices tie):
-- ORDER BY category, price_rank;


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- Error 1064 near '--Your SQL Code goes here'  (twice)
--   Wrote:  --Your SQL Code goes here
--   Why:    In MySQL, -- only starts a comment when a SPACE follows.
--           Without it, MySQL tried to run the line as SQL and
--           stopped at line 1, before reaching the query.
--   Fix:    -- Your SQL Code goes here   (or delete the line)
--
-- Wrong ranking function (first attempt)
--   Wrote:  RANK() OVER (...)
--   Why:    The task asks for ROW_NUMBER(). They differ on ties.
--   Fix:    ROW_NUMBER() OVER (...)
--
-- Note on the final ORDER BY
--   ORDER BY category, price DESC passed because no two products
--   in a category share a price. With a tie, ROW_NUMBER still gives
--   2 and 3, but price DESC could show 3 before 2.
--   ORDER BY category, price_rank always shows 1, 2, 3 in order.
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- Ranking functions on prices 900, 700, 700, 500
--   ROW_NUMBER() -> 1, 2, 3, 4   always unique (tie order not fixed)
--   RANK()       -> 1, 2, 2, 4   ties share, then a gap
--   DENSE_RANK() -> 1, 2, 2, 3   ties share, no gap
--
-- ORDER BY inside OVER is REQUIRED for ranking functions
--   It decides who is 1st. PARTITION BY restarts the count per group.
--
-- Two ORDER BYs, two jobs
--   Inside OVER( ) -> decides the numbering
--   At the end     -> decides the display order only
--
-- WHERE runs before the window function
--   Only Electronics and Furniture rows are numbered.
--
-- Alias in the final ORDER BY is fine; in WHERE it is not
--   To keep only the top product per category, wrap it in a CTE:
--   WITH r AS ( ...query above... )
--   SELECT * FROM r WHERE price_rank = 1;
--
-- Comment syntax in MySQL
--   -- comment   (space required)   # comment   /* comment */
-- ============================================================