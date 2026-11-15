-- ============================================================
-- Exercise: Round Each Sale Amount
--           (SQL Lab · Easy · Numeric Functions)
--
-- Question:
--   ROUND(number) rounds to the nearest whole number;
--   ROUND(number, n) rounds to n decimal places.
--   The summary report wants whole-number sale amounts, rounded
--   normally. Select sale_id, amount, and ROUND(amount) aliased
--   as rounded_amount, for every sale, ordered by sale_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Show the original amount next to its rounded value,
--    sorted by sale_id (ASC is the default, so it's optional).
SELECT sale_id,
       amount,
       ROUND(amount) AS rounded_amount
FROM sales
ORDER BY sale_id ASC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- How ROUND decides
--   .5 and above -> up      ROUND(149.50) -> 150
--   below .5     -> down    ROUND(149.49) -> 149
--
-- ROUND vs CEIL vs FLOOR vs TRUNCATE on 149.75
--   ROUND(149.75)        -> 150   nearest
--   CEIL(149.75)         -> 150   always up
--   FLOOR(149.75)        -> 149   always down
--   TRUNCATE(149.75, 0)  -> 149   cut decimals
--
-- Decimal places
--   ROUND(amount, 2) -> 2 decimals; ROUND(amount, 0) = ROUND(amount)
--
-- Table is not changed
--   amount keeps its decimals; only the result is rounded.
--
-- NULL amount
--   ROUND(NULL) -> NULL
-- ============================================================