-- ============================================================
-- Exercise: Moving Average and Department Salary Comparison
--           (SQL Lab · Easy · window-function, moving averages,
--            CTE/join)
--
-- Question:
--   You are working with two tables, Sales and Employees, and need
--   to complete two SQL analysis tasks.
--   Task 1: Using the Sales table, write a query that returns the
--   SaleDate, Amount, and a 3-day moving average of Amount (the
--   current row plus the 2 preceding rows, ordered by SaleDate) for
--   the employee with EmployeeID = 5. Round the moving average to
--   the nearest whole number and label it MovingAvg3.
--   Task 2: Using the Employees table, first create a CTE that
--   computes the average salary per department. Then write a query
--   joining the CTE with the Employees table to return each
--   employee's EmployeeName, Department, Salary, and their
--   department's average salary (rounded to the nearest whole
--   number, labeled DeptAvgSalary), restricted to employees whose
--   salary exceeds their department's average.
--
-- Sample data:
--   Sales (6 rows)
--   SaleID | SaleDate   | Amount | EmployeeID
--   1      | 2024-01-01 | 100    | 5
--   2      | 2024-01-02 | 200    | 5
--   3      | 2024-01-03 | 300    | 5
--   4      | 2024-01-04 | 400    | 5
--   5      | 2024-01-05 | 500    | 5
--   6      | 2024-01-01 | 150    | 3
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- ############################################################
-- TASK 1 of 2
-- Write a query on the Sales table to display the SaleDate,
-- Amount, and a 3-day moving average of Amount for the employee
-- with EmployeeID = 5. Calculate the moving average over the
-- current row and the 2 preceding rows, ordered by SaleDate,
-- round it to the nearest whole number, and label it MovingAvg3.
-- ############################################################

-- ------------------------------------------------------------
-- WHAT A MOVING AVERAGE IS
-- ------------------------------------------------------------
-- For each row: average of THIS row + up to 2 rows before it.
-- The 3-row window slides down one row at a time.
--
--   SaleDate | Amount | Rows in window  | MovingAvg3
--   01-01    | 100    | 100             | 100   (only 1 row exists)
--   01-02    | 200    | 100, 200        | 150   (only 2 rows exist)
--   01-03    | 300    | 100, 200, 300   | 200
--   01-04    | 400    | 200, 300, 400   | 300   (100 drops out)
--   01-05    | 500    | 300, 400, 500   | 400
--
-- SaleID 6 belongs to EmployeeID 3, so it's filtered out first.


-- ------------------------------------------------------------
-- ANSWER A - Correlated subquery (the version that passed)
-- ------------------------------------------------------------
-- For each sale (s), the subquery averages employee 5's sales
-- from 2 days before up to that sale's date.
--
-- Brackets in ROUND((SELECT ...)):
--   round ( ( select avg(...) ... ) ) as MovingAvg3
--         1  2                    2 1
--   1 = ROUND's own input brackets
--   2 = the subquery's brackets (turn the SELECT into one value)
SELECT s.SaleDate,
       s.Amount,
       ROUND((
           SELECT AVG(s1.Amount)
           FROM Sales AS s1
           WHERE s1.EmployeeID = 5
             AND s1.SaleDate BETWEEN DATE_SUB(s.SaleDate, INTERVAL 2 DAY)
                                 AND s.SaleDate
       )) AS MovingAvg3
FROM Sales AS s
WHERE s.EmployeeID = 5
ORDER BY s.SaleDate;

-- CATCH: this counts 3 CALENDAR DAYS, not 3 ROWS. It matches here
-- only because there is exactly one sale per day with no gaps.


-- ------------------------------------------------------------
-- ANSWER B - Window function (what the task is designed for)
-- ------------------------------------------------------------
-- OVER turns AVG into a window function:
--   normal AVG  -> squeezes all rows into ONE value
--   AVG ... OVER -> keeps every row, adds a value next to each
-- Inside OVER( ):
--   ORDER BY SaleDate                       -> which rows come before
--   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -> exactly 3 ROWS
SELECT SaleDate,
       Amount,
       ROUND(
           AVG(Amount) OVER (
               ORDER BY SaleDate
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           )
       ) AS MovingAvg3
FROM Sales
WHERE EmployeeID = 5
ORDER BY SaleDate;

-- Result (both answers):
--   2024-01-01 | 100 | 100
--   2024-01-02 | 200 | 150
--   2024-01-03 | 300 | 200
--   2024-01-04 | 400 | 300
--   2024-01-05 | 500 | 400


-- ############################################################
-- TASK 2 of 2
-- Using the Employees table, first create a CTE that computes the
-- average salary per department. Then write a query joining the
-- CTE with the Employees table to return each employee's
-- EmployeeName, Department, Salary, and their department's
-- average salary (rounded to the nearest whole number, labeled
-- DeptAvgSalary), restricted to employees whose salary exceeds
-- their department's average.
-- ############################################################

-- ------------------------------------------------------------
-- HOW IT WORKS
-- ------------------------------------------------------------
-- Step 1 (CTE):  build a temporary table DepartmentSal
--                -> one row per department with its average salary
-- Step 2 (JOIN): attach the matching department row to every
--                employee, so each row carries its dept average
-- Step 3 (WHERE): keep employees earning above that average
--
-- CTE syntax:  WITH name AS ( SELECT ... )  SELECT ... FROM name
--              The WITH part only DEFINES the table; a complete
--              query starting with SELECT must follow it.

-- ------------------------------------------------------------
-- FINAL ANSWER - TASK 2
-- ------------------------------------------------------------
WITH DepartmentSal AS (
    SELECT e.Department,
           AVG(e.Salary) AS DeptAvgSalary
    FROM Employees AS e
    GROUP BY e.Department
)
SELECT e1.EmployeeName,
       e1.Department,
       e1.Salary,
       ROUND(d.DeptAvgSalary) AS DeptAvgSalary
FROM Employees AS e1
INNER JOIN DepartmentSal AS d
    ON e1.Department = d.Department
WHERE e1.Salary > d.DeptAvgSalary;

-- NOTE: The version that passed showed d.DeptAvgSalary without
--       ROUND, probably because the averages were already whole
--       numbers. The task asks for rounding, so ROUND is added.
--       ROUND only in SELECT; WHERE compares the raw average.


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- ---------- TASK 1 ----------
--
-- Error 1064 near 'select s1.Amount from Sales ...'
--   Wrote:  round(avg(select s1.Amount from Sales ...))
--   Why:    A subquery can't go straight inside AVG. AVG belongs
--           INSIDE the subquery.
--   Fix:    ROUND((SELECT AVG(s1.Amount) FROM Sales ...))
--
-- Typo: amd
--   Fix:    AND
--
-- Typo: s.SalesDate  (extra s) -> would give Error 1054
--   Fix:    s.SaleDate
--
-- Error 1064 near 'select avg(s1.Amount) from Sales ...'
--   Wrote:  round (select avg(...) ...)
--   Why:    Only ROUND's brackets. Right after "round (" MySQL
--           expected a value but found the word SELECT.
--   Fix:    round((select avg(...) ...))  <- two opening brackets
--
-- Unprefixed column inside the subquery (no error, but risky)
--   Wrote:  ... and SaleDate between ...
--   Why:    MySQL looks in the subquery's own table first, so it
--           was read as s1.SaleDate by luck.
--   Fix:    s1.SaleDate
--
-- ORDER BY commented out (no error, order not guaranteed)
--   Fix:    ORDER BY s.SaleDate
--
-- ---------- TASK 2 ----------
--
-- Wrong CTE syntax
--   Wrote:  WITH ( SELECT ... ) AS DepartmentCount
--   Why:    That's alias style. In a CTE the name comes FIRST.
--   Fix:    WITH DepartmentSal AS ( SELECT ... )
--
-- COUNT instead of AVG
--   Wrote:  SELECT COUNT(e.Department) ...
--   Why:    The task needs the average salary per department.
--   Fix:    SELECT e.Department, AVG(e.Salary) ... GROUP BY e.Department
--
-- Not a real table
--   Wrote:  FROM Employees e1, Department.count d
--   Fix:    Use the CTE by its name:
--           INNER JOIN DepartmentSal AS d ON ...
--
-- Error 1064 near 'EmployeeName, Department, Salary ...' (twice)
--   Wrote:  )
--           e1.EmployeeName, ...
--   Why:    The main query after the CTE was missing SELECT.
--   Fix:    )
--           SELECT e1.EmployeeName, ...
--
-- Typo: DepartmentSal ad d
--   Fix:    DepartmentSal AS d
--
-- Different columns in SELECT and GROUP BY -> Error 1055
--   Wrote:  SELECT e.DepartmentID ... GROUP BY e.Department
--   Fix:    Same column in both. The table uses Department
--           (check with: SELECT * FROM Employees LIMIT 0;)
--
-- Column from the wrong table -> Error 1054
--   Wrote:  WHERE e1.salary > e1.DeptAvgSalary
--   Why:    DeptAvgSalary lives in the CTE (d), not Employees (e1).
--   Fix:    WHERE e1.Salary > d.DeptAvgSalary
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- Window function vs GROUP BY
--   GROUP BY          -> one row per group (rows collapse)
--   AVG(...) OVER (...) -> every row kept, value added beside it
--
-- Two ORDER BYs in a window query
--   Inside OVER( ) -> decides which rows are in the window
--   At the end     -> decides the display order
--
-- Without ROWS BETWEEN ...
--   The default window is first row -> current row, giving a
--   RUNNING average (100, 150, 200, 250, 300), not a 3-row one.
--
-- 3 rows vs 3 days
--   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -> exactly 3 rows
--   BETWEEN DATE_SUB(d, INTERVAL 2 DAY) AND d -> 3 calendar days
--   (differs when days are missing or repeated)
--
-- Subquery inside a function needs its own brackets
--   ROUND((SELECT ...))
--
-- CTE can hold any result
--   a single value, one column, or a full table (as here)
--
-- Prefix columns when tables share names
--   Both Employees and the CTE have Department -> e1. / d.
--
-- Round only for display
--   ROUND in SELECT, raw value in WHERE, so rounding never
--   changes which rows qualify.
-- ============================================================