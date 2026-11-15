-- ============================================================
-- Exercise: Manager vs. Company Average
--           (SQL Lab · Medium · JOINS)
--
-- The Scenario
--
--   You are an analyst at a company and have been tasked with a
--   peculiar request from HR. They want to identify employees who are
--   high-earners relative to the company average, but whose direct
--   managers are paid less than the company average. This might
--   indicate a salary structure anomaly or identify high-performing
--   individual contributors managed by more junior leads.
--
-- Database Schema
--
--   You have access to two tables: employees and departments.
--
--   departments table
--   Column  Type     Description
--   id      INTEGER  The unique ID for the department.
--   name    TEXT     The name of the department (e.g., 'Engineering').
--
--   employees table
--   Column         Type     Description
--   id             INTEGER  The unique ID for the employee.
--   name           TEXT     The employee's name.
--   salary         INTEGER  The employee's annual salary.
--   department_id  INTEGER  Foreign key to the departments table.
--   manager_id     INTEGER  The id of this employee's direct manager.
--                           This is a self-referencing key. It is NULL
--                           for the top-level employee.
--
-- How the tables link:
--   employees.department_id -> departments.id   (normal join)
--   employees.manager_id    -> employees.id     (SELF join)
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- ############################################################
-- TASK 1 of 3
-- First, as a warm-up, find all employees who earn more than
-- $100,000. List their name, salary, and department name. Order
-- the results by salary in descending order.
-- ############################################################

-- Join on the FOREIGN KEY: e.department_id = d.id
-- d.name is aliased because both tables have a "name" column.
SELECT e.name,
       e.salary,
       d.name AS department_name
FROM employees AS e
LEFT JOIN departments AS d
    ON e.department_id = d.id
WHERE e.salary > 100000
ORDER BY e.salary DESC;

-- Expected Output
--   name   | salary | department_name
--   Alice  | 250000 | Engineering
--   Bob    | 140000 | Engineering
--   Frank  | 120000 | Sales
--   Heidi  | 115000 | Human Resources
--   Eve    | 110000 | Engineering


-- ############################################################
-- TASK 2 of 3
-- Next, list all employees and their direct manager's name. Return
-- the employee's name as `employee_name` and their manager's name
-- as `manager_name`. Order the results by `employee_name`
-- alphabetically. Employees without a manager should not be listed.
-- ############################################################

-- SELF JOIN: the same table twice, with two aliases.
--   e = the employee row
--   m = the manager row
-- Read the ON aloud: "the employee's manager_id is the manager's id"
-- INNER JOIN drops Alice (manager_id NULL -> no match), which is
-- what "employees without a manager should not be listed" asks.
SELECT e.name AS employee_name,
       m.name AS manager_name
FROM employees AS e
INNER JOIN employees AS m
    ON e.manager_id = m.id
ORDER BY e.name;

-- Expected Output
--   employee_name | manager_name
--   Bob           | Alice
--   Carol         | Alice
--   David         | Alice
--   Eve           | Bob
--   Frank         | Carol
--   Grace         | Carol
--   Heidi         | David
--   Ivan          | David
--   Judy          | Bob


-- ############################################################
-- TASK 3 of 3
-- Finally, find all employees who earn more than the company-wide
-- average salary, but whose direct manager earns less than that
-- same average. Return the employee's name as `employee_name`, the
-- employee's salary as `employee_salary`, their manager's name as
-- `manager_name`, and their department's name as
-- `department_name`. Order the results by `employee_name`
-- alphabetically.
-- ############################################################

-- ------------------------------------------------------------
-- ANSWER A - No CTE (simplest)
-- ------------------------------------------------------------
-- Self join (Task 2) + department join (Task 1) + a scalar subquery
-- for the company-wide average (ALL employees, one number).
SELECT e.name   AS employee_name,
       e.salary AS employee_salary,
       m.name   AS manager_name,
       d.name   AS department_name
FROM employees AS e
INNER JOIN employees AS m                -- each employee's manager
    ON e.manager_id = m.id
LEFT JOIN departments AS d               -- the employee's department
    ON e.department_id = d.id
WHERE e.salary > (SELECT AVG(salary) FROM employees)   -- employee above
  AND m.salary < (SELECT AVG(salary) FROM employees)   -- manager below
ORDER BY employee_name;

-- ------------------------------------------------------------
-- ANSWER B - CTE version (the one built while solving)
-- ------------------------------------------------------------
-- The CTE adds the department name to each employee. Columns are
-- LISTED (not SELECT *) so no two columns share a name.
WITH dept_name AS (
    SELECT e.id,
           e.name,
           e.salary,
           e.manager_id,
           d.name AS department_name
    FROM employees AS e
    LEFT JOIN departments AS d
        ON e.department_id = d.id
)
SELECT e.name            AS employee_name,
       e.salary          AS employee_salary,
       m.name            AS manager_name,
       e.department_name AS department_name
FROM dept_name AS e
INNER JOIN employees AS m
    ON e.manager_id = m.id
WHERE e.salary > (SELECT AVG(salary) FROM employees)
  AND m.salary < (SELECT AVG(salary) FROM employees)
ORDER BY employee_name;

-- ------------------------------------------------------------
-- ANSWER C - CTE holding the average (calculated once)
-- ------------------------------------------------------------
WITH company AS (
    SELECT AVG(salary) AS avg_salary FROM employees
)
SELECT e.name   AS employee_name,
       e.salary AS employee_salary,
       m.name   AS manager_name,
       d.name   AS department_name
FROM employees AS e
INNER JOIN employees  AS m ON e.manager_id    = m.id
LEFT JOIN departments AS d ON e.department_id = d.id
CROSS JOIN company    AS c
WHERE e.salary > c.avg_salary
  AND m.salary < c.avg_salary
ORDER BY employee_name;

-- Expected Output (all three answers)
--   employee_name | employee_salary | manager_name | department_name
--   Frank         | 120000          | Carol        | Sales
--   Heidi         | 115000          | David        | Human Resources


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- ---------- TASK 1 ----------
--
-- Wrong department (no error): your value "Sales", expected "Engineering"
--   Wrote:  ON e.id = d.id
--   Why:    e.id is the EMPLOYEE's number, not a department. Employee 2
--           got department 2. UNION couldn't fix it: UNION stacks
--           results, it doesn't match rows.
--   Fix:    ON e.department_id = d.id   (foreign key = primary key)
--
-- ---------- TASK 2 ----------
--
-- Error 1064 near 'self join employees as m' (twice)
--   Wrote:  FROM employees AS e SELF JOIN employees AS m
--   Why:    "Self join" is the NAME of the technique, not a keyword.
--   Fix:    INNER JOIN employees AS m
--
-- ON condition reversed
--   Wrote:  ON m.manager_id = e.id    (m becomes e's EMPLOYEE)
--   Fix:    ON e.manager_id = m.id    (m is e's MANAGER)
--
-- Unneeded filter
--   Wrote:  WHERE m.manager_id IS NOT NULL
--   Why:    The INNER JOIN already drops Alice (no manager).
--
-- ---------- TASK 3 ----------
--
-- Error 1060: Duplicate column name 'id'
--   Wrote:  WITH dept_name AS (SELECT *, d.name ... employees e
--                              LEFT JOIN departments d ...)
--   Why:    Both tables have "id" and "name". A plain SELECT may show
--           duplicate names, but a CTE becomes a TABLE, and a table
--           can't have two columns with the same name.
--   Fix:    List the columns: SELECT e.id, e.name, e.salary,
--           e.manager_id, d.name AS department_name
--
-- Wrong average
--   Wrote:  HAVING e.salary > AVG(m.salary) AND m.salary < AVG(m.salary)
--   Why:    AVG(m.salary) averages only the managers in the join, not
--           the whole company. HAVING without GROUP BY collapses rows.
--   Fix:    WHERE ... > (SELECT AVG(salary) FROM employees)
--
-- Error 1064 near 'SELECT AVG(salary) FROM employees and ...'
--   Wrote:  e.salary > SELECT AVG(salary) FROM employees
--   Why:    A subquery needs its own brackets.
--   Fix:    e.salary > (SELECT AVG(salary) FROM employees)
--
-- Error 1054: Unknown column 'd.name' in 'field list'
--   Wrote:  d.name AS department_name   (in the main query)
--   Why:    Alias d exists only INSIDE the CTE. The main query can see
--           only the CTE's output columns: id, name, salary,
--           manager_id, department_name.
--   Fix:    e.department_name
--
-- Wrong output column
--   Wrote:  m.salary AS manager_salary
--   Fix:    m.name AS manager_name
--
-- ORDER BY inside the CTE (no error, no effect)
--   Why:    A CTE's row order is not kept in the final result.
--   Fix:    ORDER BY employee_name at the very end.
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- Join on the foreign key
--   child.fk_column = parent.id    e.g. e.department_id = d.id
--   Never id = id between two different tables.
--
-- Self join
--   Same table, two aliases, a normal JOIN keyword.
--   Valid keywords: JOIN / INNER / LEFT / RIGHT / CROSS
--   Not valid: SELF JOIN, FULL OUTER JOIN (MySQL)
--
-- INNER vs LEFT on the manager
--   INNER -> top-level employee (no manager) dropped
--   LEFT  -> top-level employee kept, manager_name NULL
--
-- Company-wide value -> scalar subquery
--   (SELECT AVG(salary) FROM employees) = one number for every row
--
-- WHERE vs HAVING
--   Filtering individual rows -> WHERE
--   Filtering groups after GROUP BY -> HAVING
--
-- CTE rules
--   - No duplicate column names (no SELECT * over a join) -> 1060
--   - Inner aliases are invisible outside -> use the CTE's column names
--   - ORDER BY belongs in the final query, not the CTE
--
-- A plain SELECT can show duplicate column names, but a SELECT used
-- AS A TABLE (CTE, derived table, view, CREATE TABLE AS) cannot.
-- ============================================================