-- ============================================================
-- Exercise: Uppercase the First Name
--           (SQL Lab · Easy · String Functions)
--
-- Question:
--   UPPER(text) converts every letter in a string to uppercase;
--   LOWER(text) does the reverse.
--   The name column is stored in lowercase; display it in
--   uppercase for a formal report. Select customer_id and
--   UPPER(first_name) aliased as first_upper, for every customer.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] UPPER changes only the displayed value;
--    first_name stays lowercase in the table.
SELECT customer_id,
       UPPER(first_name) AS first_upper
FROM customers;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Without an alias
--   The heading would be "UPPER(first_name)". The task asks
--   for first_upper, so AS is needed here.
--
-- Table is not changed
--   To store uppercase permanently:
--   UPDATE customers SET first_name = UPPER(first_name);
--
-- Spaces stay as they are
--   UPPER('  arun') -> '  ARUN'. Combine with TRIM if needed:
--   UPPER(TRIM(first_name))
--
-- Only letters change
--   Numbers and symbols are untouched: UPPER('a1-b') -> 'A1-B'
--
-- NULL input
--   UPPER(NULL) -> NULL
-- ============================================================