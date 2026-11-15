-- ============================================================
-- Exercise: Rename a Column with AS
--           (SQL Lab · Easy · Column Alias)
--
-- Question:
--   A column alias renames a column (or expression) in the result
--   set only; it doesn't change anything in the actual table.
--   HR wants the monthly_salary column labeled simply "salary"
--   in the report. Select the monthly_salary column, aliased as
--   salary, for every employee.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] AS gives the column a new heading in the result.
--    The column in the table is still called monthly_salary.
SELECT monthly_salary AS salary
FROM employees;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Alias changes only the result heading
--   The table is not changed. To rename the real column you'd need
--   ALTER TABLE employees RENAME COLUMN monthly_salary TO salary;
--
-- AS is optional
--   SELECT monthly_salary salary FROM employees; also works,
--   but writing AS is clearer.
--
-- Aliases with spaces need quotes
--   SELECT monthly_salary AS "Monthly Salary" FROM employees;
--
-- Alias can be used in ORDER BY (but not in WHERE)
--   SELECT monthly_salary AS salary FROM employees
--   ORDER BY salary DESC;          -- works
--   ... WHERE salary > 30000;      -- error: WHERE runs before
--                                     aliases are created
-- ============================================================