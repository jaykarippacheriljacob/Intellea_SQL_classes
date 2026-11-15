-- ============================================================
-- Exercise: Average Order Value by Region
--           (SQL Lab · Easy · DQL, Aggregation, HAVING)
--
-- Question:
--   Regional sales leadership wants to know which regions have an
--   average order value above $100 so they can prioritize account
--   outreach. Using the orders table, return each region and its
--   average order amount, aliased as avg_order_value, for regions
--   where the average order amount is greater than 100.
--   - Return region and avg_order_value
--   - Round avg_order_value to 2 decimal places
--   - Order by avg_order_value descending
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Group orders by region, average each group,
--    keep groups averaging above 100, highest first.
SELECT region,
       ROUND(AVG(amount), 2) AS avg_order_value
FROM orders
GROUP BY region
HAVING AVG(amount) > 100
ORDER BY avg_order_value DESC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Alias in HAVING
--   Wrote:  HAVING avg_order_value > 100
--   Why:    Works in MySQL, but not in every database. It also
--           filters the ROUNDED value: 100.004 -> 100.00 -> excluded.
--   Fix:    HAVING AVG(amount) > 100   (raw value, works everywhere)
--
-- WHERE instead of HAVING
--   WHERE AVG(amount) > 100  -> Error 1111 (Invalid use of group
--   function). WHERE runs before grouping; use HAVING.
--
-- Alias in ORDER BY is fine
--   ORDER BY runs after SELECT, so the alias already exists.
--
-- Forgetting GROUP BY
--   SELECT region, AVG(amount) FROM orders;  -> Error 1140
--   region is a plain column, so it must be in GROUP BY.
--
-- ROUND inside vs outside
--   ROUND(AVG(amount), 2)  -> average first, then round (correct)
--   AVG(ROUND(amount, 2))  -> rounds each order first (different)
-- ============================================================