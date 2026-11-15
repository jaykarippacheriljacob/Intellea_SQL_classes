-- ============================================================
-- Exercise: Filter Bookings Above a Fare
--           (SQL Lab · Easy · Where & Comparison Operators)
--
-- Question:
--   WHERE filters rows using a condition. > is the greater-than
--   comparison operator.
--   Finance wants to see only the higher-value bookings.
--   Select every column for bookings where fare is greater
--   than 5000.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] * returns all columns; WHERE keeps only rows
--    with fare above 5000.
SELECT *
FROM bookings
WHERE fare > 5000;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- > vs >=
--   fare > 5000   -> excludes a fare of exactly 5000
--   fare >= 5000  -> includes it
--
-- Quotes around numbers
--   WHERE fare > '5000' still works (MySQL converts it),
--   but numbers should be written without quotes.
--
-- Stray # at the end
--   Wrote:  ... WHERE fare > 5000;#
--   Why:    # starts a comment in MySQL, so it's ignored.
--           Harmless, but best removed.
--
-- NULL fares
--   Rows where fare is NULL are never returned by fare > 5000,
--   because any comparison with NULL is not TRUE.
-- ============================================================