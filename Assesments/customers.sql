-- ============================================================
-- Exercise: List Each City Once
--           (SQL Lab · Easy · Distinct)
--
-- Question:
--   DISTINCT removes duplicate rows from the result; if several
--   rows share the same value, it's shown only once.
--   The marketing team wants a list of cities customers are in,
--   without a city repeating for every customer who lives there.
--   Select the distinct list of cities customers live in.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] DISTINCT shows each city only once,
--    no matter how many customers live there.
SELECT DISTINCT city
FROM customers;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Without DISTINCT
--   SELECT city FROM customers;
--   -> one row per customer, so cities repeat.
--
-- Adding extra columns breaks the de-duplication
--   SELECT DISTINCT city, customer_name FROM customers;
--   -> every row is unique again (names differ), so cities repeat.
--
-- DISTINCT position
--   Must come right after SELECT:
--