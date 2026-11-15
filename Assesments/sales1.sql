-- ============================================================
-- Exercise: Show Each Region's Total Alongside Every Row
--           (SQL Lab · Easy · Window Aggregate Functions)
--
-- Question:
--   A window function computes an aggregate without collapsing
--   rows the way GROUP BY does — SUM(amount) OVER (PARTITION BY
--   region) shows the region's total on every one of that region's
--   rows, side by side with the row's own data.
--   Show each sale next to its region's overall total, without
--   losing any individual sale rows.
--   Select sale_id, region, amount, and SUM(amount) OVER
--   (PARTITION BY region) aliased as region_total, for every sale,
--   ordered by region, sale_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] PARTITION BY region splits the rows into one window per
--    region. SUM runs over the WHOLE window, so every row in a
--    region gets the same total. No row is collapsed.
SELECT sale_id,
       region,
       amount,
       SUM(amount) OVER (PARTITION BY region) AS region_total
FROM sales
ORDER BY region, sale_id;


-- ============================================================
-- MISTAKE MADE WHILE SOLVING (passed, but wrong result)
-- ============================================================
--
-- ORDER BY inside OVER turns the total into a RUNNING total
--   Wrote:  SUM(amount) OVER (PARTITION BY region ORDER BY sale_id)
--   Why:    With ORDER BY, the default window becomes "first row of
--           the partition up to the current row", so each row adds
--           up only the sales so far: 100, 300, 600 ...
--   Fix:    SUM(amount) OVER (PARTITION BY region)
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- GROUP BY vs PARTITION BY
--   GROUP BY region           -> one row per region (sales collapse)
--   OVER (PARTITION BY region)-> every sale kept, total added beside it
--
-- What goes inside OVER( )
--   (empty)                    -> grand total on every row
--   PARTITION BY region        -> region total on every row
--   PARTITION BY region
--     ORDER BY sale_id         -> running total within each region
--   ... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -> moving 3-row sum
--
-- Two ORDER BYs, two jobs
--   Inside OVER( ) -> changes the CALCULATION
--   At the end     -> changes only the DISPLAY order
--
-- Useful follow-up: each sale's share of its region
--   ROUND(amount * 100 / SUM(amount) OVER (PARTITION BY region), 2)
--     AS pct_of_region
-- ============================================================