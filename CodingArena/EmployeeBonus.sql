-- ============================================================
-- Exercise: Employee Bonus
--           (SQL Lab · Easy · LEFT JOIN)
--
-- Question:
--   You are given two tables, Employee and Bonus.
--
--   Schema
--   The Employee table contains information about employees,
--   including their salary.
--   Column      Type     Description
--   empId       INTEGER  Unique ID for the employee.
--   name        TEXT     Name of the employee.
--   supervisor  INTEGER  ID of the employee's supervisor.
--   salary      INTEGER  The employee's salary.
--
--   The Bonus table contains information about employee bonuses.
--   Column  Type     Description
--   empId   INTEGER  ID of the employee receiving the bonus.
--   bonus   INTEGER  The bonus amount.
--
--   Not all employees receive a bonus. The empId in the Bonus table
--   is a foreign key to the empId in the Employee table.
--
--   Task: Write a solution to report the name and bonus amount of
--   each employee who either has a bonus of less than 1000 or did
--   not receive a bonus. Order the results by employee name
--   alphabetically.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] LEFT JOIN keeps EVERY employee. No bonus row -> b.bonus
--    is NULL. WHERE keeps bonus < 1000 OR no bonus at all.
SELECT e.name,
       b.bonus
FROM Employee AS e
LEFT JOIN Bonus AS b
    ON e.empId = b.empId
WHERE b.bonus < 1000
   OR b.bonus IS NULL
ORDER BY e.name ASC;


-- Version that passed (also correct):
--   WHERE b.bonus < 1000
--      OR e.empID NOT IN (SELECT empID FROM Bonus)
--   The subquery re-checks the Bonus table, but the LEFT JOIN has
--   already marked those employees with NULL, so IS NULL is enough.


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Why LEFT JOIN, not INNER JOIN
--   INNER JOIN drops employees with no Bonus row, but the task
--   wants them ("did not receive a bonus").
--
-- Forgetting the IS NULL part
--   WHERE b.bonus < 1000 alone -> employees with no bonus vanish,
--   because NULL < 1000 is not TRUE. This is the "filter on the
--   right table in WHERE turns LEFT into INNER" trap, fixed here by
--   adding OR b.bonus IS NULL.
--
-- = NULL never works
--   WHERE b.bonus = NULL -> 0 rows. Always IS NULL.
--
-- Showing 0 instead of NULL
--   COALESCE(b.bonus, 0) AS bonus   (only if the task asks for it;
--   here the expected output shows NULL)
--
-- NOT IN with NULLs
--   NOT IN (SELECT empId FROM Bonus) would return NO rows if Bonus
--   had a NULL empId. NOT EXISTS or IS NULL after LEFT JOIN avoid it.
--
-- Column names are not case-sensitive in MySQL
--   empId, empID, EMPID all refer to the same column.
-- ============================================================