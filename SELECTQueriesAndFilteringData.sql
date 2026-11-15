/* =====================================================================
   DAY 3 - SQL PRACTICE NOTES
   Topics: Projection, Aliases, Arithmetic, ORDER BY, LIMIT/OFFSET,
           DISTINCT, WHERE + Comparison operators, AND / OR / NOT,
           Precedence, IN / BETWEEN
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day3_practice;
USE day3_practice;

DROP TABLE IF EXISTS emp_day3;

CREATE TABLE emp_day3 (
    emp_id        INT PRIMARY KEY,
    emp_name      VARCHAR(20),
    age           INT,
    department    VARCHAR(20),
    salary        DECIMAL(10,2),
    joining_date  DATE,
    experience    INT,
    location      VARCHAR(20)
);

-- NOTE: Dates written as 'YYYY-MM-DD' with zero padding ('2024-09-10').
--       MySQL also accepts '2024-9-10', but padded is safer.
INSERT INTO emp_day3
    (emp_id, emp_name, age, department, salary, joining_date, experience, location)
VALUES
    (101, 'Arun',  21, 'IT',    25000.00, '2024-09-10', 2, 'Chennai'),
    (102, 'Divya', 22, 'Sales', 20000.00, '2024-09-08', 3, 'Madurai'),
    (103, 'Priya', 22, 'IT',    45000.00, '2024-08-08', 5, 'Chennai');

-- Display all 3 employees
SELECT * FROM emp_day3;


/* ---------------------------------------------------------------------
   1. PROJECTION - choosing columns

   SELECT *            -> every column
   SELECT col1, col2   -> only the columns you list (projection)

   NOTE: Projection picks COLUMNS. Filtering (WHERE) picks ROWS.
   NOTE: A missing comma is NOT an error:
         SELECT emp_name salary ... shows names under a column "salary".
   --------------------------------------------------------------------- */

SELECT emp_name, salary FROM emp_day3;
SELECT emp_name, department FROM emp_day3;


/* ---------------------------------------------------------------------
   2. AS - column alias

   Renames a column in the RESULT only. The table is not changed.

   NOTE: AS is optional (salary monthly_salary also works),
         but always write it for clarity.
   NOTE: Aliases with spaces need quotes: AS "Monthly Salary"
   NOTE: Alias can be used in ORDER BY, but NOT in WHERE.
   --------------------------------------------------------------------- */

SELECT emp_id AS emp_code FROM emp_day3;

SELECT emp_name AS full_name,
       salary   AS monthly_salary
FROM emp_day3;


/* ---------------------------------------------------------------------
   3. ARITHMETIC OPERATORS:  +  -  *  /  %

   Calculated for every row while reading. Nothing is saved to the table.

   NOTE: * / % run before + -  (use brackets when needed)
   NOTE: Any maths with NULL gives NULL. Divide by zero gives NULL.
   --------------------------------------------------------------------- */

-- Arun 30000, Divya 25000, Priya 50000
SELECT emp_name, salary, salary + 5000 AS bonus_salary FROM emp_day3;

-- Arun 300000, Divya 240000, Priya 540000
SELECT emp_name, salary, salary * 12 AS annual_salary FROM emp_day3;


/* ---------------------------------------------------------------------
   4. ORDER BY - sorting

   ASC  -> small to big, A to Z (default)
   DESC -> big to small, Z to A

   NOTE: With several columns, the first sorts everything and the next
         only breaks ties.
   NOTE: DESC applies ONLY to the column right before it.
   NOTE: Without ORDER BY, row order is NOT guaranteed.
   --------------------------------------------------------------------- */

-- Divya 20000, Arun 25000, Priya 45000
SELECT emp_name, salary FROM emp_day3 ORDER BY salary ASC;

-- Priya 45000, Arun 25000, Divya 20000
SELECT emp_name, salary FROM emp_day3 ORDER BY salary DESC;

-- CAREFUL: emp_name is ASC (default); only salary is DESC.
-- Names are unique here, so salary never gets used as a tie-breaker.
SELECT emp_name, salary FROM emp_day3 ORDER BY emp_name, salary DESC;

-- Department A to Z, then highest salary first inside each department
-- IT: Priya 45000, Arun 25000  ->  Sales: Divya 20000
SELECT emp_name, department, salary
FROM emp_day3
ORDER BY department ASC, salary DESC;


/* ---------------------------------------------------------------------
   5. LIMIT and OFFSET

   LIMIT n          -> keep only the first n rows
   LIMIT n OFFSET k -> skip k rows, then take n (used for pagination)

   NOTE: Top-N pattern = ORDER BY first, then LIMIT.
   NOTE: LIMIT without ORDER BY gives rows in no guaranteed order.
   --------------------------------------------------------------------- */

SELECT * FROM emp_day3 LIMIT 1;

-- Top 2 earners: Priya, Arun
SELECT emp_name, salary
FROM emp_day3
ORDER BY salary DESC
LIMIT 2;

-- Skip 2, take 2. Only 3 rows exist, so just 1 row comes back.
SELECT * FROM emp_day3 LIMIT 2 OFFSET 2;


/* ---------------------------------------------------------------------
   6. DISTINCT - unique values

   Removes repeated rows from the result.

   NOTE: With several columns, a row is removed only if ALL listed
         columns match.
   NOTE: DISTINCT goes right after SELECT, written once.
   --------------------------------------------------------------------- */

-- IT, Sales
SELECT DISTINCT department FROM emp_day3;

-- IT-Chennai, Sales-Madurai  (Arun and Priya are both IT-Chennai)
SELECT DISTINCT department, location FROM emp_day3;

-- COUNT with DISTINCT: number of unique departments -> 2
SELECT COUNT(DISTINCT department) AS total_department FROM emp_day3;


/* ---------------------------------------------------------------------
   7. WHERE + COMPARISON OPERATORS

   =   equal              <>  not equal  (!= also works)
   >   greater than       <   less than
   >=  greater or equal   <=  less or equal

   NOTE: Text and dates in single quotes, numbers without.
   NOTE: NULL can't be checked with =. Use IS NULL / IS NOT NULL.
   NOTE: Text comparison is case-insensitive in MySQL ('it' = 'IT').
   --------------------------------------------------------------------- */

-- Priya
SELECT emp_name FROM emp_day3 WHERE salary > 30000;

-- Divya
SELECT * FROM emp_day3 WHERE department <> 'IT';


/* ---------------------------------------------------------------------
   8. LOGICAL OPERATORS: AND / OR / NOT

   AND -> ALL conditions true       (narrows the result)
   OR  -> AT LEAST ONE true         (widens the result)
   NOT -> flips a condition

   NOTE: Repeat the column in each condition:
         WHERE department = 'IT' OR 'Sales'               -- wrong
         WHERE department = 'IT' OR department = 'Sales'  -- correct
   --------------------------------------------------------------------- */

-- AND: IT and earning above 30000 -> Priya
SELECT * FROM emp_day3 WHERE department = 'IT' AND salary > 30000;

-- OR: IT, or more than 2 years' experience -> all 3
SELECT * FROM emp_day3 WHERE department = 'IT' OR experience > 2;

-- NOT: everyone outside IT -> Divya
SELECT * FROM emp_day3 WHERE NOT department = 'IT';


/* ---------------------------------------------------------------------
   9. PRECEDENCE: AND runs before OR

   Question: IT or Sales employees earning above 22000

   NOTE: When mixing AND and OR, ALWAYS use brackets.
   --------------------------------------------------------------------- */

-- WRONG: read as  IT (any salary)  OR  (Sales AND > 22000)
-- Returns Arun, Priya here, but only by luck.
SELECT * FROM emp_day3
WHERE department = 'IT' OR department = 'Sales' AND salary > 22000;

-- RIGHT: brackets make OR run first
SELECT * FROM emp_day3
WHERE (department = 'IT' OR department = 'Sales') AND salary > 22000;


/* ---------------------------------------------------------------------
   10. IN / NOT IN

   IN     -> matches ANY value in the list (shortcut for many ORs)
   NOT IN -> matches NONE of the values

   NOTE: Never put NULL inside a NOT IN list (returns no rows).
   --------------------------------------------------------------------- */

-- All 3 (same as location = 'Chennai' OR location = 'Madurai')
SELECT * FROM emp_day3 WHERE location IN ('Chennai', 'Madurai');

-- Divya
SELECT * FROM emp_day3 WHERE department NOT IN ('IT');


/* ---------------------------------------------------------------------
   11. BETWEEN / NOT BETWEEN

   BETWEEN a AND b -> inside the range, BOTH ends included
   NOT BETWEEN     -> outside the range

   NOTE: Smaller value first. BETWEEN 25000 AND 20000 -> no rows.
   --------------------------------------------------------------------- */

-- Divya 20000, Arun 25000 (same as salary >= 20000 AND salary <= 25000)
SELECT emp_name, salary FROM emp_day3
WHERE salary BETWEEN 20000 AND 25000;

-- Priya (joined in August, outside September)
SELECT emp_name, joining_date FROM emp_day3
WHERE joining_date NOT BETWEEN '2024-09-01' AND '2024-09-30';


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   SELECT col1, col2      -> projection (choose columns)
   AS                     -> rename in result only; usable in ORDER BY,
                             not in WHERE
   + - * / %              -> row-by-row maths; NULL in -> NULL out
   ORDER BY ASC / DESC    -> ASC default; DESC applies to one column
   LIMIT n OFFSET k       -> skip k, take n; ORDER BY first for top-N
   DISTINCT               -> unique rows (all listed columns must match)
   COUNT(DISTINCT col)    -> number of unique values
   WHERE                  -> filter rows; = <> > < >= <=
   IS NULL                -> never use = NULL
   AND / OR / NOT         -> AND runs before OR -> use brackets
   IN / NOT IN            -> list shortcut for many OR / AND
   BETWEEN                -> inclusive on both ends, smaller first
   Clause order           -> SELECT FROM WHERE ORDER BY LIMIT
   ===================================================================== */