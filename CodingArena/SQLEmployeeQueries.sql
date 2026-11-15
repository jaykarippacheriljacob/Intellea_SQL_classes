-- ============================================================
-- Exercise: SQL Employee Queries
--           (SQL Lab · Easy · DQL)
--
-- Problem Statement
--
--   You have been provided with an EMPLOYEES table containing
--   information about company staff. Your task is to write several
--   SQL queries to extract specific information from this table.
--
--   Table Schema: EMPLOYEES
--
--   The table has the following columns:
--   Column      Type     Description
--   EMP_ID      INTEGER  A unique ID for each employee.
--   EMP_NAME    TEXT     The employee's name.
--   SALARY      INTEGER  The employee's annual salary.
--   DEPARTMENT  TEXT     The department the employee works in.
--   CITY        TEXT     The city where the employee is based.
--
--   Complete the following tasks by writing a single SQL query
--   for each.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- ############################################################
-- TASK 1 of 4
-- Find all employees who work in either 'Chennai' or 'Mumbai'.
-- List their name, department, and city. Order the results by
-- employee name alphabetically.
-- ############################################################

-- IN is a shortcut for: CITY = 'Chennai' OR CITY = 'Mumbai'
SELECT EMP_NAME, DEPARTMENT, CITY
FROM EMPLOYEES
WHERE CITY IN ('Chennai', 'Mumbai')
ORDER BY EMP_NAME ASC;


-- ############################################################
-- TASK 2 of 4
-- Find all employees whose name starts with the letter 'A' and
-- ends with the letter 'r'. Display their full name and salary,
-- ordered by salary from highest to lowest.
-- ############################################################

-- 'A%r' = A, then anything (or nothing), then r
-- Same as: EMP_NAME LIKE 'A%' AND EMP_NAME LIKE '%r'
SELECT EMP_NAME, SALARY
FROM EMPLOYEES
WHERE EMP_NAME LIKE 'A%r'
ORDER BY SALARY DESC;


-- ############################################################
-- TASK 3 of 4
-- Find the names of the 3 employees with the lowest salaries. The
-- output column for the employee name must be aliased as
-- `Low_Earner`. Order the results by salary from lowest to highest.
-- ############################################################

-- Top-N pattern: sort first, then LIMIT.
-- SALARY isn't selected, but ORDER BY can still use it.
SELECT EMP_NAME AS Low_Earner
FROM EMPLOYEES
ORDER BY SALARY ASC
LIMIT 3;

-- Tie-safe version (if the 3rd and 4th salaries are equal):
-- ORDER BY SALARY ASC, EMP_NAME ASC LIMIT 3;


-- ############################################################
-- TASK 4 of 4
-- Find the second highest salary from the `EMPLOYEES` table. The
-- result should be a single value in a column named
-- `SecondHighestSalary`. If there is no second highest salary,
-- the query should return an empty result.
-- ############################################################

-- DISTINCT    -> removes repeated salaries, so a shared top salary
--                isn't counted twice
-- DESC        -> highest first
-- OFFSET 1    -> skip the highest
-- LIMIT 1     -> take the next one
-- No 2nd salary -> OFFSET skips everything -> empty result (as asked)
SELECT DISTINCT SALARY AS SecondHighestSalary
FROM EMPLOYEES
ORDER BY SALARY DESC
LIMIT 1 OFFSET 1;

-- Example: salaries 90000, 90000, 75000, 60000
--   DISTINCT -> 90000, 75000, 60000 -> skip 1 -> 75000
--   Without DISTINCT -> 90000, 90000, 75000 ... -> skip 1 -> 90000 (wrong)

-- Alternative (subquery): highest salary below the top one
--   SELECT MAX(SALARY) AS SecondHighestSalary
--   FROM EMPLOYEES
--   WHERE SALARY < (SELECT MAX(SALARY) FROM EMPLOYEES);
-- With no 2nd salary this returns ONE row containing NULL, not an
-- empty result, because an aggregate always returns a row. So the
-- LIMIT/OFFSET version fits this task better.


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- ---------- TASK 2 ----------
--
-- Missing ORDER BY (no error, but doesn't follow the task)
--   Wrote:  ... WHERE EMP_NAME LIKE 'A%' AND EMP_NAME LIKE '%r';
--   Why:    The task asks for salary from highest to lowest.
--   Fix:    ORDER BY SALARY DESC
--
-- ---------- TASK 3 ----------
--
-- Error 1140: aggregated query without GROUP BY
--   Wrote:  SELECT EMP_NAME AS Low_Earner FROM EMPLOYEES
--           HAVING MIN(SALARY) ORDER BY salary ASC;
--   Why:    MIN() makes it an aggregate query (all rows -> one row),
--           so the plain column EMP_NAME has no single value.
--           HAVING filters GROUPS, and there was no GROUP BY.
--           MIN also finds only ONE value, not three employees.
--   Fix:    ORDER BY SALARY ASC LIMIT 3   (no MIN, no HAVING)
--
-- ---------- TASK 4 ----------
--
-- Error 1064 near ', 2) as SecondHighestSalary'
--   Wrote:  SELECT MIN(SALARY, 2) AS SecondHighestSalary ...
--   Why:    MIN takes exactly ONE argument (the column). There is
--           no "Nth value" argument.
--   Fix:    ORDER BY SALARY DESC LIMIT 1 OFFSET 1
--
-- Missing DISTINCT (passes only if the top salary isn't shared)
--   Wrote:  SELECT SALARY AS SecondHighestSalary ... LIMIT 1 OFFSET 1
--   Why:    If two employees share the highest salary, the 2nd row
--           is the same top salary again.
--   Fix:    SELECT DISTINCT SALARY ...
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- IN vs many ORs
--   CITY IN ('Chennai', 'Mumbai') = CITY = 'Chennai' OR CITY = 'Mumbai'
--
-- LIKE patterns
--   'A%'  starts with A   |  '%r' ends with r  |  'A%r' both
--   MySQL LIKE is usually case-insensitive.
--
-- Value vs rows
--   "WHAT is the lowest salary?"  -> SELECT MIN(SALARY) ...   (one value)
--   "WHO are the 3 lowest?"       -> ORDER BY SALARY LIMIT 3 (rows)
--
-- LIMIT and OFFSET
--   LIMIT n          -> first n rows
--   LIMIT n OFFSET k -> skip k, then take n
--   Nth highest      -> DISTINCT ... ORDER BY col DESC LIMIT 1 OFFSET N-1
--
-- Empty result vs NULL
--   LIMIT/OFFSET with nothing left -> no rows at all
--   MAX()/MIN() with nothing found -> one row containing NULL
--
-- Aliases
--   Allowed in ORDER BY, not in WHERE.
--   Column names (SALARY vs salary) are not case-sensitive in MySQL.
-- ============================================================