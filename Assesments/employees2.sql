-- ============================================================
-- Exercise: Replace a Missing Bonus with Zero
--           (SQL Lab · Easy · IFNULL & COALESCE)
--
-- Question:
--   IFNULL(expr, replacement) returns the replacement value only
--   when expr is NULL, and returns expr unchanged otherwise.
--   Two employees haven't been assigned a bonus yet (NULL); the
--   payroll report should treat that as 0, not blank.
--   Select name and IFNULL(bonus, 0) aliased as bonus_amount,
--   for every employee.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] If bonus is NULL show 0, otherwise show the real bonus.
SELECT name,
       IFNULL(bonus, 0) AS bonus_amount
FROM employees;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Same result with COALESCE (works in every database)
--   SELECT name, COALESCE(bonus, 0) AS bonus_amount FROM employees;
--
-- IFNULL vs COALESCE
--   IFNULL(a, b)        -> MySQL only, exactly 2 arguments
--   COALESCE(a, b, c..) -> standard SQL, first non-NULL of many
--
-- Table is not changed
--   IFNULL only changes the displayed value. bonus is still NULL
--   in the table. To store 0 permanently:
--   UPDATE employees SET bonus = 0 WHERE bonus IS NULL;
--
-- Why it matters in maths
--   salary + bonus            ->