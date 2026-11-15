-- ============================================================
-- Exercise: Employees Earning More Than Their Managers
--           (SQL Lab · Easy · SQL SubQueries)
--
-- Question:
--   In a company's employee database, you have a single table,
--   Employees, that stores information about all employees,
--   including their salary and who their direct manager is.
--
--   Column        Type     Description
--   EmployeeID    INTEGER  A unique ID for each employee.
--   EmployeeName  TEXT     The name of the employee.
--   Salary        INTEGER  The annual salary of the employee.
--   ManagerID     INTEGER  The EmployeeID of this employee's direct
--                          manager. This is NULL for the top-level
--                          employee who has no manager.
--
--   Your goal is to write queries to explore the relationships
--   within this hierarchical structure, specifically focusing on
--   salary comparisons between employees and their managers.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- ############################################################
-- TASK 1 of 3
-- As a warm-up, list the ID, name, and salary of all employees.
-- Order the results by EmployeeID.
-- ############################################################

SELECT EmployeeID, EmployeeName, Salary
FROM Employees
ORDER BY EmployeeID;


-- ############################################################
-- TASK 2 of 3
-- For each employee who has a manager, list their name and their
-- manager's name. Alias the columns as `EmployeeName` and
-- `ManagerName`. Order the results by `EmployeeName`.
-- ############################################################

-- SELF JOIN: the same table used twice with two aliases.
--   e = the employee row
--   m = the manager row
-- ON e.ManagerID = m.EmployeeID finds each employee's manager.
-- INNER JOIN drops the top-level employee (ManagerID is NULL,
-- so there's no match), which is what "who has a manager" asks.
SELECT e.EmployeeName,
       m.EmployeeName AS ManagerName
FROM Employees AS e
INNER JOIN Employees AS m
    ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeName;


-- ############################################################
-- TASK 3 of 3
-- Find all employees who earn more than their direct manager.
-- List the employee's name (as `EmployeeName`), their salary
-- (as `EmployeeSalary`), their manager's name (as `ManagerName`),
-- and their manager's salary (as `ManagerSalary`). Order the
-- results by `EmployeeName`.
-- ############################################################

-- Same self join as Task 2, plus a WHERE comparing the two rows.
SELECT e.EmployeeName,
       e.Salary       AS EmployeeSalary,
       m.EmployeeName AS ManagerName,
       m.Salary       AS ManagerSalary
FROM Employees AS e
INNER JOIN Employees AS m
    ON e.ManagerID = m.EmployeeID
WHERE e.Salary > m.Salary
ORDER BY e.EmployeeName;

-- Alternative: CORRELATED SUBQUERY (same result)
-- The inner query runs once PER employee row, using e.ManagerID
-- from the outer query to find that employee's manager.
SELECT e.EmployeeName,
       e.Salary AS EmployeeSalary,
       (SELECT m.EmployeeName FROM Employees AS m
        WHERE m.EmployeeID = e.ManagerID) AS ManagerName,
       (SELECT m.Salary FROM Employees AS m
        WHERE m.EmployeeID = e.ManagerID) AS ManagerSalary
FROM Employees AS e
WHERE e.Salary > (SELECT m.Salary FROM Employees AS m
                  WHERE m.EmployeeID = e.ManagerID)
ORDER BY e.EmployeeName;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Self join
--   One table, two aliases, treated as two separate tables.
--   Aliases are REQUIRED: without them every column is ambiguous
--   (Error 1052).
--
-- Getting the ON direction right
--   e.ManagerID = m.EmployeeID  -> m is e's manager   (correct)
--   e.EmployeeID = m.ManagerID  -> m is e's employee  (reversed)
--
-- ORDER BY with a self join
--   Both aliases have EmployeeName. ORDER BY EmployeeName worked
--   because MySQL matched the SELECT column, but e.EmployeeName
--   is clearer and safer.
--
-- Top-level employee (ManagerID NULL)
--   INNER JOIN: no match -> dropped.
--   Subquery:   returns NULL -> Salary > NULL is not TRUE -> dropped.
--   To include them, use LEFT JOIN (ManagerName shows NULL).
--
-- Join vs correlated subquery
--   Self join: shorter, reads both rows once -> usually preferred.
--   Correlated subquery: runs per row; useful when you only need
--   one value from the other row (e.g. just the comparison).
--
-- Subquery must return ONE value here
--   WHERE e.Salary > (SELECT ...) needs a single value. Since
--   EmployeeID is unique, each manager lookup returns one row.
-- ============================================================