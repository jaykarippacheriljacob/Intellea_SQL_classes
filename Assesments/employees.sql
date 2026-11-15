-- ============================================================
-- Exercise: Update One Employee's Salary
--           (SQL Lab · Easy · Update)
--
-- Question:
--   UPDATE is the DML command used to change values already
--   stored in a table. A WHERE clause picks out exactly which
--   row(s) to change.
--   Give one specific employee a raise: update the salary of the
--   employee with employee_id 2 to 55000.00.
--   Return all rows ordered by employee_id.
--
-- Command types used:
--   DML : UPDATE -> change data
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DML] Change salary only for the row where employee_id = 2.
--    SET says what to change; WHERE says which row.
UPDATE employees
SET salary = 55000.00
WHERE employee_id = 2;

-- 2. [DQL] Return all rows, sorted by employee_id as the task asks.
SELECT * FROM employees
ORDER BY employee_id;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Forgetting WHERE
--   Wrote:  UPDATE employees SET salary = 55000.00;
--   Why:    Without WHERE, EVERY employee gets 55000.00.
--   Note:   In Workbench, safe update mode blocks this with
--           Error 1175 when no key column is used in WHERE.
--
-- Missing ORDER BY
--   Wrote:  SELECT * FROM employees;
--   Why:    Rows often come back in primary-key order, but that's
--           not guaranteed. If the task asks for an order, write it.
--   Fix:    SELECT * FROM employees ORDER BY employee_id;
--
-- Using == instead of =
--   SQL uses a single = both for assigning (SET) and for
--   comparing (WHERE). == is a syntax error (1064).
--
-- Updating several columns at once
--   Separate them with commas in SET:
--   UPDATE employees SET salary = 55000.00, dept = 'IT'
--   WHERE employee_id = 2;
-- ============================================================