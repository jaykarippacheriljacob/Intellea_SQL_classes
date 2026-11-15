-- ============================================================
-- Exercise: Find Names Starting with A
--           (SQL Lab · Easy · Like Wildcards)
--
-- Question:
--   LIKE matches text patterns. % stands for any sequence of
--   characters (including none), so 'A%' matches anything
--   starting with A.
--   Marketing wants a quick list of everyone whose name starts
--   with the letter A. Select name from customers where name
--   LIKE 'A%', ordered by customer_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] 'A%' = starts with A, followed by anything.
--    Then sort by customer_id (ASC is the default, so it's optional).
SELECT name
FROM customers
WHERE name LIKE 'A%'
ORDER BY customer_id ASC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Wildcards
--   %  -> any number of characters (including zero)
--   _  -> exactly ONE character
--
-- Common patterns
--   'A%'    -> starts with A          (Arun, Anu, A)
--   '%a'    -> ends with a            (Priya, Divya)
--   '%an%'  -> contains "an" anywhere (Anand, Karan)
--   'A__'   -> A + exactly 2 more     (Anu, Ann)
--   '_a%'   -> second letter is a     (Ravi, Karthik)
--
-- Using = instead of LIKE
--   WHERE name = 'A%'  -> no error, but looks for a name that is
--                         literally "A%", so it returns nothing.
--
-- Case sensitivity
--   In MySQL, LIKE is usually case-insensitive, so 'A%' also
--   matches 'anu'.
--
-- Leading spaces
--   '  arun' does NOT match 'A%' because it starts with a space.
--   Fix: WHERE TRIM(name) LIKE 'A%'
--
-- NOT LIKE
--   WHERE name NOT LIKE 'A%'  -> everyone NOT starting with A
-- ============================================================