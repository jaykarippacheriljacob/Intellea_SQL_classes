-- ============================================================
-- Exercise: Sort Movies by Rating, Highest First
--           (SQL Lab · Easy · Order By)
--
-- Question:
--   ORDER BY sorts the result set. DESC sorts highest to lowest;
--   ASC (the default) sorts lowest to highest.
--   The homepage wants movies listed with the best-rated one
--   first. Select title and rating for every movie, ordered by
--   rating descending.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Pick title and rating, then sort highest rating first.
SELECT title, rating
FROM movies
ORDER BY rating DESC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Clause order
--   Wrote:  ... ORDER BY rating DESC WHERE rating IS NOT NULL;
--   Why:    Error 1064. WHERE must come before ORDER BY.
--   Fix:    SELECT ... FROM ... WHERE ... ORDER BY ...;
--
-- Filtering when the task says "every movie"
--   Adding WHERE rating IS NOT NULL removes unrated movies,
--   so the result would be missing rows.
--
-- NULL ratings
--   In MySQL, NULLs come last with DESC (first with ASC).
--
-- Forgetting DESC
--   ORDER BY rating; sorts lowest first (ASC is the default).
-- ============================================================