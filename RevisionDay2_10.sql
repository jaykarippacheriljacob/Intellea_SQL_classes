/* =====================================================================
   SQL REVISION - EVERYTHING SO FAR (Days 1-10 + Lab exercises)
   Topics: Basics & command types, DDL, DML, Copying tables, SELECT,
           Filtering, NULL, LIKE, CASE, String / Numeric / Date
           functions, Aggregates, GROUP BY, HAVING, JOINs (inner, left,
           right, full, self, cross, multi-table), Foreign keys,
           Subqueries, EXISTS, CTEs, Views, Window functions (OVER),
           Set operations (UNION, INTERSECT, EXCEPT), Data checks,
           Ranking, Top-N per group, De-duplication (Day 10),
           UPDATE with CASE + subquery, Clause order, Error codes
   Note:   Safe to re-run. Tables are dropped and rebuilt each time.
   ===================================================================== */


/* ---------------------------------------------------------------------
   1. BASICS AND SQL COMMAND TYPES

   Data      -> facts stored in an organised way (rows + columns)
   Table     -> rows and columns about one thing
   Row       -> one record          Column -> one type of detail
   Database  -> a collection of related tables
   Relational database -> tables linked by a common column
   SQL       -> Structured Query Language (MySQL, PostgreSQL, Oracle,
                SQL Server, Snowflake all use it)

   DDL -> STRUCTURE : CREATE, ALTER, DROP, TRUNCATE
   DML -> DATA      : INSERT, UPDATE, DELETE
   DQL -> READ      : SELECT
   TCL -> SAVE/UNDO : COMMIT, ROLLBACK
   Utility          : USE, SHOW DATABASES, SHOW TABLES, DESCRIBE

   Syntax rules:
   - End every statement with ;
   - Keywords are not case sensitive (write them in CAPITALS)
   - Type table names exactly (case sensitive on Linux/Mac servers)
   - Spaces and new lines are fine; one clause per line reads best
   - Comments:  -- single line (space after --)   # single line (MySQL)
                multi-line: start with slash-star, end with star-slash
                (plain-text notes without these -> 1064)
   - Workbench: Ctrl+Enter runs one line, Ctrl+Shift+Enter runs all
   - Error 1046 "No database selected" -> run USE db_name;
   - DESCRIBE before SELECT so you know the exact column names
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   2. SETUP - CREATE DATABASE / TABLE (DDL)

   Data types:
     INT            whole numbers
     VARCHAR(n)     text up to n characters
     DECIMAL(10,2)  money: 10 digits total, 2 after the point
     DATE           'YYYY-MM-DD' (always in quotes)

   Constraints:
     PRIMARY KEY    unique + NOT NULL
     AUTO_INCREMENT auto numbering; only ONE per table, and it must be
                    a key (else Error 1075); only on number columns
     NOT NULL       value required
     DEFAULT x      used when no value is given
     CHECK (...)    rejects values breaking the rule (MySQL 8.0.16+)

     AUTO_INCREMENT start vs step:
     AUTO_INCREMENT = 101             -> table option: FIRST id (one table)
     SET SESSION auto_increment_increment = n  -> STEP size (every table
                                                  in this connection)
     SET SESSION auto_increment_offset    = n  -> where the step pattern
                                                  starts (keep <= step)
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS revision_db;
USE revision_db;

-- Drop order: views, then CHILD tables before PARENT tables (foreign keys)
DROP VIEW  IF EXISTS customer_order_summary;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS emp_backup;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS dept_info;
DROP TABLE IF EXISTS Marks;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS source_customers;
DROP TABLE IF EXISTS target_customers;
DROP TABLE IF EXISTS customer_contacts;
DROP TABLE IF EXISTS chennai_departments;
DROP TABLE IF EXISTS coimbatore_departments;
DROP TABLE IF EXISTS daily_sales;

CREATE TABLE employees (
    emp_id        INT AUTO_INCREMENT PRIMARY KEY,
    emp_name      VARCHAR(50) NOT NULL,
    dept          VARCHAR(30) DEFAULT 'Not Set',
    city          VARCHAR(30),
    salary        DECIMAL(10,2) CHECK (salary >= 0),
    bonus         DECIMAL(10,2),
    joining_date  DATE
) AUTO_INCREMENT = 101;                  -- first id = 101


/* ---------------------------------------------------------------------
   3. INSERT (DML) - several rows in one statement

   - One bracket per row, commas between rows, ; only at the end
   - Values follow the order of YOUR column list
   - Leave out the AUTO_INCREMENT column -> MySQL fills it
   - Without a column list you must give EVERY column (else Error 1136)
   - VALUE also works in MySQL, but VALUES is standard
   --------------------------------------------------------------------- */

INSERT INTO employees (emp_name, dept, city, salary, bonus, joining_date)
VALUES
    ('Arun',      'IT',    'Chennai', 25000, 2000, '2024-09-10'),  -- 101
    ('Divya',     'Sales', 'Madurai', 20000, NULL, '2024-09-08'),  -- 102
    ('Priya',     'IT',    'Chennai', 45000, 5000, '2024-08-08'),  -- 103
    ('Ravi',      'HR',    'Salem',   30000, NULL, '2025-01-15'),  -- 104
    ('  meena  ', 'Sales', 'Chennai', 35000, 3000, '2025-03-20');  -- 105

SELECT * FROM employees;
DESCRIBE employees;          -- or: SHOW COLUMNS FROM employees;
SHOW TABLES;


/* ---------------------------------------------------------------------
   4. COPYING TABLES

   CREATE TABLE new AS SELECT ...  -> data + columns, NO keys/AUTO_INCREMENT
   CREATE TABLE new LIKE old       -> exact structure + keys, NO data
   INSERT INTO t (cols) SELECT ... -> copy rows into an existing table
     - no VALUES keyword
     - columns match by POSITION, not name
   --------------------------------------------------------------------- */

CREATE TABLE IF NOT EXISTS emp_backup LIKE employees;
INSERT INTO emp_backup SELECT * FROM employees;
SHOW TABLES;

-- Copy only some columns/rows (pattern from the trial_users lab):
-- INSERT INTO customers (full_name, email)
-- SELECT full_name, email FROM trial_users WHERE usage_count >= 5
-- ORDER BY trial_id;


/* ---------------------------------------------------------------------
   5. ALTER / UPDATE / DELETE / TRUNCATE  (done on the BACKUP copy)

   ALTER TABLE  ADD / RENAME / MODIFY / DROP COLUMN
   UPDATE t SET col = value [, col2 = v2] WHERE ...
   DELETE FROM t WHERE ...           (removes whole rows)
   TRUNCATE TABLE t                  (all rows, keeps structure,
                                      resets AUTO_INCREMENT, no WHERE,
                                      no ROLLBACK)
   DROP TABLE t                      (table gone completely)

   WARNING: UPDATE / DELETE without WHERE -> EVERY row is affected.
   Safe update mode (Workbench) blocks this -> Error 1175.
     SET SQL_SAFE_UPDATES = 0;  ...  SET SQL_SAFE_UPDATES = 1;
   TIP: run a SELECT with the same WHERE first.
   --------------------------------------------------------------------- */

ALTER TABLE emp_backup ADD COLUMN phone VARCHAR(15) AFTER emp_name;
/* ---------------------------------------------------------------------
   To add a column before the very first column: use FIRST.
      ALTER TABLE employees
      ADD COLUMN row_no INT FIRST;
   -- row_no, emp_id, emp_name, ...
--------------------------------------------------------------------- */
ALTER TABLE emp_backup RENAME COLUMN phone TO mobile;
-- Phone numbers as VARCHAR: no maths on them, keeps leading zeros.

INSERT INTO emp_backup (emp_name, dept, salary)
VALUES ('Sneha', DEFAULT, 28000);            -- id 106, dept 'Not Set'

UPDATE emp_backup SET dept = 'DEV', salary = 26000 WHERE emp_id = 101;
DELETE FROM emp_backup WHERE emp_id = 102;
SELECT * FROM emp_backup ORDER BY emp_id;

-- DELETE keeps the counter (next id 107); TRUNCATE resets it.
TRUNCATE TABLE emp_backup;
SELECT * FROM emp_backup;                    -- 0 rows, table still exists


/* ---------------------------------------------------------------------
   6. SELECT BASICS

   Projection   SELECT col1, col2       (choose columns)
   Alias        col AS new_name         (result only; AS optional;
                                         spaces need quotes "Monthly Pay";
                                         usable in ORDER BY, NOT in WHERE)
   Arithmetic   + - * / %  DIV          (* / before + -)
   DISTINCT     unique rows; with 2+ columns ALL must match
   ORDER BY     ASC default; DESC applies to ONE column only;
                no ORDER BY = no guaranteed order
   LIMIT/OFFSET skip k, take n; ORDER BY first for top-N

   WATCH: missing comma is NOT an error:
          SELECT emp_name salary -> names shown under heading "salary"
   --------------------------------------------------------------------- */

SELECT emp_name, salary * 12 AS annual_salary FROM employees;

-- dept A-Z, then highest salary first inside each dept
SELECT emp_name, dept, salary FROM employees
ORDER BY dept ASC, salary DESC;

-- Top 2 earners: Priya 45000, meena 35000
SELECT emp_name, salary FROM employees
ORDER BY salary DESC
LIMIT 2;

-- Skip 2, take 2 (pagination)
SELECT * FROM employees ORDER BY emp_id LIMIT 2 OFFSET 2;

-- Chennai, Madurai, Salem
SELECT DISTINCT city FROM employees;
SELECT COUNT(DISTINCT city) AS total_cities FROM employees;   -- 3


/* ---------------------------------------------------------------------
   7. WHERE - FILTERING ROWS

   Comparison: =  <> (!=)  >  <  >=  <=
   Logical:    AND (all true)  OR (any true)  NOT (flip)
               AND runs before OR -> ALWAYS use brackets when mixing
   IN / NOT IN       list shortcut (never put NULL inside NOT IN)
   BETWEEN a AND b   both ends included, smaller value first

   Text/dates in quotes, numbers without. Text compare is
   case-insensitive in MySQL ('it' = 'IT').
   --------------------------------------------------------------------- */

-- Priya, meena
SELECT emp_name FROM employees WHERE salary > 30000;

-- Brackets: (IT or Sales) AND above 30000 -> Priya, meena
SELECT emp_name FROM employees
WHERE (dept = 'IT' OR dept = 'Sales') AND salary > 30000;

-- Arun, Priya, Ravi
SELECT emp_name FROM employees WHERE dept IN ('IT', 'HR');

-- Arun, Ravi, meena
SELECT emp_name FROM employees WHERE salary BETWEEN 25000 AND 35000;

-- Joined in 2025: Ravi, meena
SELECT emp_name FROM employees
WHERE joining_date BETWEEN '2025-01-01' AND '2025-12-31';


/* ---------------------------------------------------------------------
   8. NULL HANDLING

   NULL = unknown (not 0, not '').
   = NULL never works -> use IS NULL / IS NOT NULL
   Any maths with NULL -> NULL     (salary + NULL = NULL)
   COALESCE(a, b, c..)  first non-NULL, standard SQL, many args
   IFNULL(a, b)         MySQL only, exactly 2 args
   --------------------------------------------------------------------- */

-- Divya, Ravi
SELECT emp_name FROM employees WHERE bonus IS NULL;

-- Total pay with missing bonus treated as 0
SELECT emp_name,
       salary + IFNULL(bonus, 0)   AS total_pay,
       COALESCE(bonus, 0)          AS bonus_amount
FROM employees;


/* ---------------------------------------------------------------------
   9. LIKE - PATTERN SEARCH

   %  any number of characters     _  exactly ONE character
   'A%' starts with A | '%a' ends with a | '%an%' contains an
   'A__' A + 2 more   | '_a%' 2nd letter a
   = 'A%' does NOT pattern-match (looks for literal "A%")
   Leading spaces break patterns -> use TRIM
   --------------------------------------------------------------------- */

SELECT emp_name FROM employees WHERE emp_name LIKE 'A%';        -- Arun
SELECT emp_name FROM employees WHERE TRIM(emp_name) LIKE 'M%';  -- meena
SELECT emp_name FROM employees WHERE emp_name NOT LIKE 'A%';


/* ---------------------------------------------------------------------
   10. CASE - IF/ELSE INSIDE A QUERY

   CASE WHEN cond THEN value ... ELSE value END AS alias
   - checked top to bottom, first TRUE wins
   - no ELSE + no match -> NULL
   - CASE goes with WHEN (WHERE inside CASE -> Error 1064)
   - check IS NULL first if NULLs are possible
   --------------------------------------------------------------------- */

-- Arun Medium, Divya Low, Priya High, Ravi Medium, meena High
SELECT emp_name, salary,
       CASE
           WHEN salary >= 35000 THEN 'High'
           WHEN salary >= 25000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_band
FROM employees
ORDER BY emp_id;


/* ---------------------------------------------------------------------
   11. BUILT-IN FUNCTIONS (only change the result, never the table)

   STRING
     UPPER / LOWER        UPPER('arun') -> 'ARUN'
     LENGTH / CHAR_LENGTH bytes / characters
     CONCAT(a, b)         NULL anywhere -> NULL
     CONCAT_WS('-', a, b) skips NULLs
     SUBSTRING(t, s, n)   SUBSTRING('Karthik', 2, 3) -> 'art' (starts at 1)
     LEFT / RIGHT(t, n)   LEFT('Chennai', 3) -> 'Che'
     TRIM / LTRIM / RTRIM outer spaces only
     REPLACE(t, f, r)     REPLACE('Chennai','nai','NAI') -> 'ChenNAI'
     LPAD / RPAD(t, len, p) LPAD('7', 3, '0') -> '007' (too long -> cut)

   NUMERIC
     ROUND(x[, n])  nearest       ROUND(15.67) -> 16, ROUND(x,-2) hundreds
     CEIL / FLOOR   up / down     CEIL(15.1) -> 16, FLOOR(15.9) -> 15
     TRUNCATE(x, n) cut           TRUNCATE(15.678, 1) -> 15.6
     ABS, MOD(x,y), POWER(x,y), SQRT(x)
     x / 0 -> NULL

   DATE
     CURDATE() date only | NOW() date + time
     YEAR / MONTH / DAY / MONTHNAME / DAYNAME
     DATE_ADD(d, INTERVAL n DAY|WEEK|MONTH|YEAR) / DATE_SUB(...)
     DATEDIFF(d1, d2) -> days (d1 - d2)
     DATE_FORMAT(d, '%d-%m-%Y')
     Unquoted 2026-03-20 = maths (2003)!

   Functions combine from the INSIDE out: UPPER(TRIM(x))
   --------------------------------------------------------------------- */

SELECT emp_name,
       UPPER(TRIM(emp_name))          AS clean_name,     -- 'MEENA'
       CONCAT(TRIM(emp_name), ' - ', city) AS details,   -- 'Arun - Chennai'
       LEFT(city, 3)                  AS city_code,      -- 'Che'
       LPAD(emp_id, 6, '0')           AS emp_code        -- '000101'
FROM employees;

SELECT emp_name,
       ROUND(salary / 30, 2) AS daily_pay,               -- Arun 833.33
       CEIL(salary / 30)     AS daily_up,                -- 834
       FLOOR(salary / 30)    AS daily_down               -- 833
FROM employees;

SELECT emp_name, joining_date,
       YEAR(joining_date)                     AS join_year,
       MONTHNAME(joining_date)                AS join_month,
       DATE_ADD(joining_date, INTERVAL 6 MONTH) AS probation_end,
       DATEDIFF(CURDATE(), joining_date)      AS days_worked
FROM employees;


/* ---------------------------------------------------------------------
   12. AGGREGATES, GROUP BY, HAVING

   COUNT(*) all rows | COUNT(col) non-NULL only
   SUM / AVG / MIN / MAX ignore NULLs (AVG divides by non-NULL count)

   GROUP BY -> one row per group (or per COMBINATION of columns)
   RULE: every PLAIN column in SELECT must be in GROUP BY.
         Columns inside an aggregate don't need to be.
         Order inside GROUP BY doesn't matter.
         A column can be in GROUP BY without being in SELECT.

   WHERE  -> filters ROWS before grouping, no aggregates
   HAVING -> filters GROUPS after grouping, aggregates allowed
   HAVING alias works in MySQL, but HAVING AVG(x) > 100 is portable
   and filters the raw (not rounded) value.
   --------------------------------------------------------------------- */

-- 5 | 3 | 155000 | 31000 | 20000 | 45000
SELECT COUNT(*)       AS total_rows,
       COUNT(bonus)   AS with_bonus,
       SUM(salary)    AS total_salary,
       AVG(salary)    AS avg_salary,
       MIN(salary)    AS lowest,
       MAX(salary)    AS highest
FROM employees;

-- HR 30000 (1) | IT 70000 (2) | Sales 55000 (2)
SELECT dept, SUM(salary) AS total, COUNT(*) AS staff,
       ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept
ORDER BY dept;

-- Groups with total above 50000: IT, Sales
SELECT dept, SUM(salary) AS total
FROM employees
GROUP BY dept
HAVING SUM(salary) > 50000;

-- WHERE + GROUP BY + HAVING: Chennai only, depts with 2+ staff -> IT
SELECT dept, COUNT(*) AS staff
FROM employees
WHERE city = 'Chennai'
GROUP BY dept
HAVING COUNT(*) >= 2;

-- GROUP BY a CASE label (MySQL allows grouping by the alias)
-- High 2 | Medium 2 | Low 1
SELECT CASE
           WHEN salary >= 35000 THEN 'High'
           WHEN salary >= 25000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_band,
       COUNT(*) AS staff
FROM employees
GROUP BY salary_band;

-- Multiple columns: one row per city + dept combination
SELECT city, dept, COUNT(*) AS staff
FROM employees
GROUP BY city, dept
ORDER BY city, dept;


/* ---------------------------------------------------------------------
   13. JOINS - combine two tables on a common column

   FROM left_table JOIN right_table ON left.col = right.col
   INNER JOIN -> only matching rows
   LEFT JOIN  -> all left rows, no match -> NULL on the right side
   RIGHT JOIN -> all right rows (= LEFT JOIN with tables swapped)
   FULL OUTER -> not in MySQL: LEFT JOIN UNION ALL RIGHT JOIN ... IS NULL

   - Same column name in both tables -> prefix with alias (Error 1052)
   - Find missing rows: LEFT JOIN ... WHERE right.id IS NULL
   - Right-table filter in WHERE turns LEFT JOIN into INNER JOIN;
     put it in ON to keep all left rows
   --------------------------------------------------------------------- */

CREATE TABLE Students (id INT PRIMARY KEY, name VARCHAR(50) NOT NULL);
CREATE TABLE Marks    (id INT PRIMARY KEY, marks INT);

INSERT INTO Students VALUES (1,'Arun'), (2,'Rahul'), (3,'Priya'), (4,'Sneha');
INSERT INTO Marks    VALUES (1, 90),    (2, 85),     (5, 70),     (6, 95);

-- INNER: (1 Arun 90), (2 Rahul 85)
SELECT s.id, s.name, m.marks
FROM Students AS s
INNER JOIN Marks AS m ON s.id = m.id;

-- LEFT: all students, Priya/Sneha marks NULL -> shown as 0
SELECT s.id, s.name, COALESCE(m.marks, 0) AS marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id
ORDER BY s.id;

-- Missing pattern: students without marks -> Priya, Sneha
SELECT s.name
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id
WHERE m.id IS NULL;

-- RIGHT: all marks rows, ids 5/6 have no student -> 'Unknown'
SELECT m.id, COALESCE(s.name, 'Unknown') AS name, m.marks
FROM Students AS s
RIGHT JOIN Marks AS m ON s.id = m.id
ORDER BY m.id;

-- FULL OUTER (6 rows)
SELECT s.id AS student_id, s.name, m.id AS marks_id, m.marks
FROM Students AS s LEFT JOIN Marks AS m ON s.id = m.id
UNION ALL
SELECT s.id, s.name, m.id, m.marks
FROM Students AS s RIGHT JOIN Marks AS m ON s.id = m.id
WHERE s.id IS NULL;

-- JOIN + aggregates: 4 students | 2 with marks | avg 87.5
SELECT COUNT(*) AS total_students,
       COUNT(m.marks) AS with_marks,
       ROUND(AVG(m.marks), 1) AS avg_marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id;


/* ---------------------------------------------------------------------
   14. FOREIGN KEYS + JOINS PART 2 (full, self, cross, multi-table)

   FOREIGN KEY (col) REFERENCES parent(col)
     Parent = table referenced (customers) | Child = holds the FK (orders)
     - child row must point to an existing parent  (else Error 1452)
     - create PARENTS first (else 1824), drop CHILDREN first (else 3730)
     - a FK does NOT join for you: you still write ON ... = ...

   FULL OUTER JOIN -> not in MySQL: LEFT JOIN  UNION  RIGHT JOIN
     UNION removes duplicates, UNION ALL keeps them
     Both SELECTs need the same number of columns (else Error 1222)
   SELF JOIN  -> same table twice, two aliases (else Error 1066)
                 e.manager_id = m.employee_id  -> m is e's manager
   CROSS JOIN -> every pair, no ON; rows = a x b
   ON vs WHERE (LEFT JOIN): condition in ON keeps every left row;
                            in WHERE it can drop them
   Multi-table: one JOIN + one ON per table; once LEFT, stay LEFT
   --------------------------------------------------------------------- */

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(60),
    city          VARCHAR(40)
);
CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    customer_id INT,
    order_date  DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE categories (
    category_id   INT PRIMARY KEY,
    category_name VARCHAR(50)
);
CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(60),
    category_id  INT,
    price        DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE staff (
    employee_id   INT PRIMARY KEY,
    employee_name VARCHAR(60),
    manager_id    INT NULL,
    department    VARCHAR(40)
);

INSERT INTO customers VALUES
    (1,'Arun','Chennai'), (2,'Priya','Coimbatore'), (3,'Karthik','Madurai'),
    (4,'Divya','Chennai'), (5,'Suresh','Salem');
INSERT INTO orders VALUES
    (101,1,'2026-01-10'), (102,1,'2026-01-12'),
    (103,2,'2026-02-15'), (104,4,'2026-03-20');
INSERT INTO categories VALUES (10,'Electronics'), (20,'Accessories'), (30,'Stationery');
INSERT INTO products VALUES
    (201,'Laptop',10,55000), (202,'Mouse',20,800), (203,'Keyboard',20,1500),
    (204,'Notebook',30,100), (205,'Monitor',10,12000);
INSERT INTO order_items VALUES
    (1,101,201,1,55000), (2,101,202,2,800),  (3,102,203,1,1500),
    (4,103,202,1,800),   (5,104,201,1,55000), (6,104,203,2,1500);
INSERT INTO staff VALUES
    (1,'Meena',NULL,'Management'), (2,'Ravi',1,'IT'), (3,'Kavya',1,'HR'),
    (4,'Arun',2,'IT'), (5,'Nila',2,'IT'), (6,'John',3,'HR');

/* Who has what: Arun -> 101, 102 | Priya -> 103 | Divya -> 104
   Karthik, Suresh -> no orders | Notebook, Monitor -> never ordered
   Order totals: 101 = 56600 | 102 = 1500 | 103 = 800 | 104 = 58000 */

-- FULL OUTER (6 rows): Arun 101, Arun 102, Priya 103, Karthik NULL,
--                      Divya 104, Suresh NULL
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers AS c LEFT JOIN orders AS o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers AS c RIGHT JOIN orders AS o ON c.customer_id = o.customer_id;

-- SELF JOIN: Meena NULL | Ravi Meena | Kavya Meena | Arun Ravi |
--            Nila Ravi | John Kavya   (LEFT keeps Meena, the top boss)
SELECT e.employee_name AS employee, m.employee_name AS manager
FROM staff AS e
LEFT JOIN staff AS m ON e.manager_id = m.employee_id;

-- CROSS JOIN: 5 customers x 5 products = 25 rows
SELECT c.customer_name, p.product_name
FROM customers AS c CROSS JOIN products AS p;

-- ON vs WHERE: January orders
-- In ON    -> 6 rows (every customer, only Arun's 101/102 attach)
SELECT c.customer_name, o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_date >= '2026-01-01' AND o.order_date < '2026-02-01';
-- In WHERE -> 2 rows (Arun 101, Arun 102): LEFT became INNER
SELECT c.customer_name, o.order_id
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2026-01-01' AND o.order_date < '2026-02-01';

-- MULTI-TABLE + GROUP BY: total spent per customer (keep everyone)
-- Arun 58100 | Priya 800 | Karthik 0 | Divya 58000 | Suresh 0
SELECT c.customer_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_sales
FROM customers AS c
LEFT JOIN orders      AS o  ON c.customer_id = o.customer_id
LEFT JOIN order_items AS oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- Orders per customer: COUNT(o.order_id), NOT COUNT(*)
-- (COUNT(*) would give Karthik and Suresh 1 for their NULL row)
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Find missing: products never ordered -> Notebook, Monitor
SELECT p.product_name
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;


/* ---------------------------------------------------------------------
   15. SUBQUERIES and EXISTS

   Query inside brackets; the inner query runs first.
     Scalar (one value)  -> use with = > <      (more rows -> Error 1242)
     List (one column)   -> use with IN / NOT IN (more cols -> Error 1241)
     Derived table       -> subquery in FROM; MUST have an alias (1248)
     Correlated          -> uses an outer column; runs once per outer row
   Inside a function a subquery needs TWO bracket pairs: ROUND((SELECT ...))
   Aggregates can't go in WHERE -> compare with (SELECT AVG(...) ...)

   EXISTS (SELECT 1 ...)     -> TRUE if any row is found (SELECT 1 is fine)
   NOT IN breaks if the list has a NULL (returns nothing);
   NOT EXISTS has no such trap.
   --------------------------------------------------------------------- */

-- List: customers with orders -> Arun, Priya, Divya
SELECT customer_name FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);

-- Scalar: products above average price (69400 / 5 = 13880) -> Laptop
SELECT product_name, price FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Derived table: customers above the average order count
-- counts 2, 1, 1 -> average 1.33 -> customer_id 1 (Arun)
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > (SELECT AVG(order_count)
                   FROM (SELECT COUNT(*) AS order_count
                         FROM orders GROUP BY customer_id) AS counts_per_customer);

-- EXISTS / NOT EXISTS: customers without orders -> Karthik, Suresh
SELECT c.customer_name FROM customers AS c
WHERE NOT EXISTS (SELECT 1 FROM orders AS o WHERE o.customer_id = c.customer_id);

-- Correlated: each customer's latest order -> 102, 103, 104
SELECT o.customer_id, o.order_id, o.order_date
FROM orders AS o
WHERE o.order_date = (SELECT MAX(o2.order_date) FROM orders AS o2
                      WHERE o2.customer_id = o.customer_id);

/* Three ways to find "no orders": NOT IN (subquery) | NOT EXISTS |
   LEFT JOIN ... WHERE o.order_id IS NULL                              */


/* ---------------------------------------------------------------------
   16. CTE - COMMON TABLE EXPRESSION (WITH)

   WITH name AS ( SELECT ... )  SELECT ... FROM name;
   - name FIRST, then AS            (WITH (...) AS name -> 1064)
   - no ; between the CTE and its SELECT
   - must be followed by a complete query starting with SELECT
   - several CTEs: WITH a AS (...), b AS (...) ; b can use a
   - can hold one value, one column, or a full table
   - lasts for ONE query only; needs MySQL 8.0+
   --------------------------------------------------------------------- */

-- Quantity sold per product: Keyboard 3 | Mouse 3 | Laptop 2
WITH product_quantity AS (
    SELECT p.product_id, p.product_name, SUM(oi.quantity) AS total_quantity
    FROM products AS p
    INNER JOIN order_items AS oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT * FROM product_quantity
ORDER BY total_quantity DESC, product_name;

-- Multiple CTEs: orders above the average order total (29225) -> 101, 104
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
),
avg_total AS (
    SELECT AVG(order_total) AS avg_order FROM order_totals
)
SELECT ot.order_id, ot.order_total
FROM order_totals AS ot
CROSS JOIN avg_total AS a
WHERE ot.order_total > a.avg_order
ORDER BY ot.order_id;


/* ---------------------------------------------------------------------
   17. VIEW - a saved query

   Stores the QUERY, not the data; always shows current data.
   CREATE VIEW v AS SELECT ...;   use it like a table
   CREATE OR REPLACE VIEW v AS ...;   (CREATE twice -> Error 1050)
   DROP VIEW v;                       (real tables untouched)

                Subquery          CTE                View
   Has a name   no                yes                yes
   Lasts        one query         one query          until dropped
   Use it for   short one-off     long, step by step reused often
   --------------------------------------------------------------------- */

CREATE VIEW customer_order_summary AS
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS order_count
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Arun 2 | Priya 1 | Karthik 0 | Divya 1 | Suresh 0
SELECT * FROM customer_order_summary;
SELECT * FROM customer_order_summary WHERE order_count > 1;   -- Arun

DROP VIEW customer_order_summary;


/* ---------------------------------------------------------------------
   18. WINDOW FUNCTIONS - OVER()  (from the lab)

   Aggregate without OVER -> rows collapse into ONE value
   Aggregate with OVER    -> every row kept, value added beside it

   Inside OVER( ):
     (empty)                                   -> all rows
     PARTITION BY col                          -> restart per group
     ORDER BY col                              -> running calculation
     ROWS BETWEEN 2 PRECEDING AND CURRENT ROW  -> exactly 3 rows (moving)
   - ORDER BY inside OVER decides the window; the ORDER BY at the end
     decides the display order. You usually need both.
   - ORDER BY without ROWS BETWEEN -> RUNNING total/average
   - Correlated subquery with dates = 3 DAYS, not 3 ROWS
   Ranking (ORDER BY inside OVER is required), prices 900,700,700,500:
     ROW_NUMBER() -> 1,2,3,4 | RANK() -> 1,2,2,4 | DENSE_RANK() -> 1,2,2,3
     e.g. ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC)
   PARTITION BY only (no ORDER BY) -> same group total on every row
   --------------------------------------------------------------------- */

-- Order totals by date: 101 56600 | 102 1500 | 103 800 | 104 58000
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, o.order_date,
           SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id, o.order_date
)
SELECT order_id,
       order_total,
       AVG(order_total) OVER ()                         AS overall_avg,     -- 29225 on every row
       SUM(order_total) OVER (PARTITION BY customer_id) AS customer_total,  -- Arun 58100 on both rows
       SUM(order_total) OVER (ORDER BY order_date)      AS running_total,   -- 56600, 58100, 58900, 116900
       ROUND(AVG(order_total) OVER (
           ORDER BY order_date
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW))   AS moving_avg3      -- 56600, 29050, 19633, 20100
FROM order_totals
ORDER BY order_date;


/* ---------------------------------------------------------------------
   19. SET OPERATIONS + DATA CHECKS (Day 9)

   JOIN -> tables SIDE BY SIDE | set operation -> results STACKED /
   compared as whole rows
     UNION      -> both results, duplicates removed
     UNION ALL  -> both results, duplicates kept (faster)
     INTERSECT  -> rows in BOTH results
     EXCEPT     -> rows in the FIRST, not the second (order matters;
                   Oracle: MINUS)
   Rules: same number of columns (else 1222), same order and types
          (matched by POSITION), names from the FIRST SELECT,
          one ORDER BY at the very END
   INTERSECT / EXCEPT need MySQL 8.0.31+ (SELECT VERSION();)
     older: INTERSECT -> IN,  EXCEPT -> NOT EXISTS
   Duplicates: GROUP BY the "should be unique" columns HAVING COUNT(*) > 1

   5 ETL CHECKS (source vs target, compare by the KEY):
     1 row counts  2 missing  3 extra  4 duplicates  5 mismatched values
   Equal counts NEVER prove a correct load.
   <> ignores NULL; NULL-safe compare: NOT (a <=> b)
   --------------------------------------------------------------------- */

CREATE TABLE chennai_departments    (employee_id INT, employee_name VARCHAR(50));
CREATE TABLE coimbatore_departments (employee_id INT, employee_name VARCHAR(50));
CREATE TABLE source_customers (customer_id INT, customer_name VARCHAR(50), city VARCHAR(50));
CREATE TABLE target_customers (customer_id INT, customer_name VARCHAR(50), city VARCHAR(50));
CREATE TABLE customer_contacts (contact_id INT PRIMARY KEY, customer_name VARCHAR(50), email VARCHAR(100));

INSERT INTO chennai_departments    VALUES (101,'Arun'), (102,'Priya'), (103,'Divya');
INSERT INTO coimbatore_departments VALUES (102,'Priya'), (104,'Karthik'), (105,'Nila');
INSERT INTO source_customers VALUES
    (1,'Arun','Chennai'), (2,'Priya','Coimbatore'), (3,'Karthik','Madurai'),
    (4,'Divya','Chennai'), (5,'Suresh','Salem');
INSERT INTO target_customers VALUES
    (1,'Arun','Chennai'), (2,'Priya','Coimbatore'), (3,'Karthik','Trichy'),
    (4,'Divya','Chennai'), (6,'Nila','Erode');
INSERT INTO customer_contacts VALUES
    (1,'Arun','arun@gmail.com'), (2,'Priya','priya@gmail.com'),
    (3,'Karthik','arun@gmail.com'), (4,'Divya','divya@gmail.com'),
    (5,'Suresh','suresh@gmail.com'), (6,'Arun','arun@gmail.com');

-- UNION: 5 rows (Priya once) | UNION ALL: 6 rows (Priya twice)
SELECT employee_id, employee_name FROM chennai_departments
UNION
SELECT employee_id, employee_name FROM coimbatore_departments
ORDER BY employee_id;

-- Label column trick: where did each row come from?
SELECT employee_name, 'Chennai' AS office FROM chennai_departments
UNION ALL
SELECT employee_name, 'Coimbatore' FROM coimbatore_departments
ORDER BY employee_name, office;

-- INTERSECT: in both offices -> 102 Priya
SELECT employee_id, employee_name FROM chennai_departments
INTERSECT
SELECT employee_id, employee_name FROM coimbatore_departments;

-- EXCEPT: only in Chennai -> 101 Arun, 103 Divya
SELECT employee_id, employee_name FROM chennai_departments
EXCEPT
SELECT employee_id, employee_name FROM coimbatore_departments;

-- Same without EXCEPT (older MySQL) -> 101 Arun, 103 Divya
SELECT c.employee_id, c.employee_name
FROM chennai_departments AS c
WHERE NOT EXISTS (SELECT 1 FROM coimbatore_departments AS k
                  WHERE k.employee_id = c.employee_id);

-- Duplicates: emails used more than once -> arun@gmail.com 3
SELECT email, COUNT(*) AS occurrence_count
FROM customer_contacts
GROUP BY email
HAVING COUNT(*) > 1;

-- CHECK 1 Row counts -> SOURCE 5 | TARGET 5 (equal, but keep going!)
SELECT 'SOURCE' AS system_name, COUNT(*) AS row_count FROM source_customers
UNION ALL
SELECT 'TARGET', COUNT(*) FROM target_customers;

-- CHECK 2 Missing in target -> 5 Suresh
SELECT s.customer_id, s.customer_name
FROM source_customers AS s
LEFT JOIN target_customers AS t ON s.customer_id = t.customer_id
WHERE t.customer_id IS NULL;

-- CHECK 3 Extra in target -> 6 Nila
SELECT t.customer_id, t.customer_name
FROM target_customers AS t
LEFT JOIN source_customers AS s ON t.customer_id = s.customer_id
WHERE s.customer_id IS NULL;

-- CHECK 4 Duplicate keys in target -> 0 rows
SELECT customer_id, COUNT(*) AS copies
FROM target_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- CHECK 5 Mismatched values (NULL-safe) -> 3 Karthik, Madurai vs Trichy
SELECT s.customer_id, s.customer_name,
       s.city AS source_city, t.city AS target_city
FROM source_customers AS s
INNER JOIN target_customers AS t ON s.customer_id = t.customer_id
WHERE NOT (s.customer_name <=> t.customer_name)
   OR NOT (s.city <=> t.city);

-- Whole-row check: source rows that didn't arrive exactly
-- -> 3 Karthik Madurai, 5 Suresh Salem
SELECT * FROM source_customers
EXCEPT
SELECT * FROM target_customers;

/* LAB REPORT: counts 5 vs 5 | missing 1 (Suresh) | extra 1 (Nila) |
               duplicates 0 | mismatched 1 (Karthik's city)
   5 source - 1 missing + 1 extra + 0 duplicates = 5 target
   Equal counts hid three problems -> always run all five checks.     */


/* ---------------------------------------------------------------------
   20. WINDOW FUNCTIONS PART 2 - RANKING, TOP-N, DE-DUPLICATION (Day 10)

   Ranking functions need ORDER BY inside OVER:
     ROW_NUMBER  1,2,3,4  unique (tie order not fixed -> add a tie-breaker)
     RANK        1,2,2,4  ties share, then a gap
     DENSE_RANK  1,2,2,3  ties share, no gap
   PARTITION BY -> numbering restarts in each group

   A window result can't go in WHERE (Error 3593 / 1054): WHERE runs
   BEFORE SELECT. Wrap it in a CTE, then filter outside:
     Top-N per group -> WHERE row_num <= N
     De-duplicate    -> ROW_NUMBER() OVER (PARTITION BY key
                        ORDER BY updated DESC), keep rn = 1

   Don't name a CTE the same as a real table (confusing; inside the
   WITH it means the table, after it the CTE).
   --------------------------------------------------------------------- */

-- RANK vs DENSE_RANK on tied prices
-- prices 55000, 12000, 1500, 800, 100 -> no ties, all three agree
SELECT product_name, price,
       ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num,
       RANK()       OVER (ORDER BY price DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rnk
FROM products
ORDER BY price DESC;

-- Ties in order_items.quantity: 2, 2, 1, 1, 1, 1
--   RANK -> 1, 1, 3, 3, 3, 3 | DENSE_RANK -> 1, 1, 2, 2, 2, 2
SELECT order_item_id, quantity,
       RANK()       OVER (ORDER BY quantity DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY quantity DESC) AS dense_rnk
FROM order_items
ORDER BY quantity DESC, order_item_id;

-- PARTITION BY: price rank inside each category
-- Accessories: Keyboard 1, Mouse 2 | Electronics: Laptop 1, Monitor 2 |
-- Stationery: Notebook 1
SELECT c.category_name, p.product_name, p.price,
       ROW_NUMBER() OVER (PARTITION BY c.category_name
                          ORDER BY p.price DESC) AS price_rank
FROM products AS p
JOIN categories AS c ON p.category_id = c.category_id
ORDER BY c.category_name, price_rank;

-- TOP-N PER GROUP: most expensive product per category
-- Accessories Keyboard | Electronics Laptop | Stationery Notebook
WITH ranked AS (
    SELECT c.category_name, p.product_name, p.price,
           ROW_NUMBER() OVER (PARTITION BY c.category_name
                              ORDER BY p.price DESC) AS row_num
    FROM products AS p
    JOIN categories AS c ON p.category_id = c.category_id
)
SELECT category_name, product_name, price
FROM ranked
WHERE row_num = 1
ORDER BY category_name;

-- DE-DUPLICATION: keep the LATEST contact per email
-- (customer_contacts from section 19: arun@gmail.com appears 3 times)
-- Kept -> 6 Arun arun@ | 4 Divya | 2 Priya | 5 Suresh
WITH numbered AS (
    SELECT contact_id, customer_name, email,
           ROW_NUMBER() OVER (PARTITION BY email
                              ORDER BY contact_id DESC) AS rn
    FROM customer_contacts
)
SELECT contact_id, customer_name, email
FROM numbered
WHERE rn = 1
ORDER BY email;
-- WHERE rn > 1 instead -> the old copies a cleanup would delete (1, 3)

-- WINDOW AGGREGATES on daily data (Day 10 lab table)
CREATE TABLE daily_sales (
    sale_date    DATE PRIMARY KEY,
    daily_amount DECIMAL(10,2)
);
INSERT INTO daily_sales VALUES
    ('2026-01-01', 1000.00), ('2026-01-02', 1500.00),
    ('2026-01-03',  800.00), ('2026-01-04', 1200.00),
    ('2026-01-05',  500.00);

-- overall_total -> 5000 on every row
-- running_total -> 1000, 2500, 3300, 4500, 5000
-- pct_of_total  -> 20, 30, 16, 24, 10
-- moving_avg_3  -> 1000.00, 1250.00, 1100.00, 1166.67, 833.33
-- change        -> NULL, 500, -700, 400, -700   (LAG = previous row)
SELECT sale_date, daily_amount,
       SUM(daily_amount) OVER ()                                    AS overall_total,
       SUM(daily_amount) OVER (ORDER BY sale_date
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)      AS running_total,
       ROUND(daily_amount * 100 / SUM(daily_amount) OVER (), 2)     AS pct_of_total,
       ROUND(AVG(daily_amount) OVER (ORDER BY sale_date
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)          AS moving_avg_3,
       daily_amount - LAG(daily_amount) OVER (ORDER BY sale_date)   AS change_vs_prev
FROM daily_sales
ORDER BY sale_date;


/* ---------------------------------------------------------------------
   21. SUBQUERY + UPDATE WITH CASE  (Supplier discount lab pattern)

   Subquery = query inside brackets; runs first, result used outside.
     WHERE col IN (SELECT one_column FROM other_table WHERE ...)
     Subquery in IN must return ONE column (else Error 1241)

   Workflow: preview with SELECT -> same WHERE -> convert to UPDATE
     SELECT ..., <expr> AS new_val  |  UPDATE t
     FROM t                         |  SET col = <expr>   (no AS, no FROM)
     WHERE ...                      |  WHERE ...          (same)
   Keep the ELSE in an UPDATE CASE (else non-matching rows -> NULL).
   Run the UPDATE ONCE (each run applies again).
   --------------------------------------------------------------------- */

CREATE TABLE dept_info (dept_name VARCHAR(30) PRIMARY KEY, status VARCHAR(10));
INSERT INTO dept_info VALUES ('IT','Active'), ('Sales','Active'), ('HR','Inactive');

-- Step 1: preview. Active depts: above 30000 -> +5%, else +10%
-- Arun 27500 | Divya 22000 | Priya 47250 | meena 36750 (Ravi/HR excluded)
SELECT emp_name, salary,
       CASE
           WHEN salary > 30000 THEN salary * 1.05
           ELSE salary * 1.10
       END AS new_salary
FROM employees
WHERE dept IN (SELECT dept_name FROM dept_info WHERE status = 'Active');

-- Step 2: update (WHERE isn't on a key -> safe mode would block it)
SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET salary = CASE
                 WHEN salary > 30000 THEN salary * 1.05
                 ELSE salary * 1.10
             END
WHERE dept IN (SELECT dept_name FROM dept_info WHERE status = 'Active');

SET SQL_SAFE_UPDATES = 1;

-- Step 3: final state, ordered as labs usually ask
SELECT * FROM employees ORDER BY emp_id;



/* ---------------------------------------------------------------------
   22. CLAUSE ORDER

   WRITING:   WITH  SELECT  FROM  JOIN..ON  WHERE  GROUP BY  HAVING
              ORDER BY  LIMIT
   EXECUTION: FROM  JOIN..ON  WHERE  GROUP BY  HAVING  SELECT (+ OVER)
              ORDER BY  LIMIT

   Why it matters:
   - WHERE before GROUP BY -> no aggregates in WHERE (Error 1111)
   - WHERE before SELECT   -> no aliases in WHERE
   - ORDER BY after SELECT -> aliases OK in ORDER BY
   - ON before WHERE       -> filter in ON keeps LEFT JOIN rows
   - Round for display in SELECT; compare raw values in WHERE / HAVING
   - Each statement is separate: ORDER BY on an INSERT doesn't sort
     a later SELECT. If a task says "ordered by", add ORDER BY there.
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   23. ERROR CODES MET SO FAR
   ---------------------------------------------------------------------
   1064  Syntax error. Read "near '...' at line N" - the problem is
         at or just before that text. Seen: IF NOT EXITS, descibe,
         alias with a space (AS discounted price), WHERE instead of
         WHEN in CASE, FROM inside UPDATE, endWHERE (missing space),
         WHERE after ORDER BY, comma before FROM, FULL OUTER JOIN,
         missing SELECT after a CTE, ROUND(SELECT ...) with one
         bracket pair, plain-text notes not commented out,
         --comment without a space, EXCEPT/INTERSECT on MySQL < 8.0.31
   1046  No database selected (run USE db_name;)
   1054  Unknown column (typo: suppiler_id, saels_amount, SalesDate;
         or column from the wrong alias, e1.DeptAvgSalary)
   1146  Table doesn't exist (typo, or employee vs employees)
   1050  Table / view already exists (use IF NOT EXISTS, OR REPLACE)
   1136  Column count doesn't match value count (INSERT without
         column list, or too few/many values)
   1062  Duplicate entry for PRIMARY key
   1075  Only one AUTO_INCREMENT column, and it must be a key
   1052  Column is ambiguous (prefix with table alias in JOINs)
   1066  Not unique table/alias (self join needs two aliases)
   1222  UNION / EXCEPT / INTERSECT SELECTs have different column counts
   1221  ORDER BY placed before UNION (put one ORDER BY at the end)
   1055  Column in SELECT not in GROUP BY
   1140  Plain column + aggregate without GROUP BY
   1111  Aggregate used in WHERE (use HAVING or a subquery)
   1175  Safe update mode: UPDATE/DELETE without key in WHERE
   1241  Subquery returns more than one column
   1242  Subquery returns more than one row (use IN, not =)
   1248  Derived table without an alias
   3593  Window function used in WHERE (wrap in a CTE, filter outside)
   1452  Foreign key fails: child row points to a missing parent
   1824  Foreign key to a table that doesn't exist yet
   3730  Can't drop a parent table still referenced by a child

   Silent mistakes (no error, wrong result):
   - = NULL instead of IS NULL               -> 0 rows
   - missing comma in SELECT                 -> column becomes an alias
   - AND/OR without brackets                 -> wrong rows
   - LIKE written as = 'A%'                  -> 0 rows
   - unquoted date 2026-03-20                -> number 2003
   - CASE without ELSE in UPDATE             -> values set to NULL
   - right-table filter in WHERE on LEFT JOIN -> rows disappear
   - INNER JOIN after a LEFT JOIN            -> unmatched rows disappear
   - INNER JOIN with ON forgotten            -> every row x every row
   - COUNT(*) after a LEFT JOIN              -> 1 instead of 0
   - SUM over no rows                        -> NULL (use COALESCE)
   - NOT IN with a NULL in the list          -> 0 rows
   - no ORDER BY when order matters          -> order not guaranteed
   - columns in a different order in UNION   -> values under wrong headings
   - EXCEPT the wrong way round              -> opposite question answered
   - UNION when counting / checking          -> duplicates hidden (use ALL)
   - trusting equal row counts               -> missing + extra cancel out
   - <> on columns with NULL                 -> mismatch missed (use <=>)
   - ranking without ORDER BY inside OVER    -> meaningless numbers
   - ORDER BY inside OVER on a total         -> running total, not overall
   - ROW_NUMBER with tied ORDER BY values    -> order not fixed (tie-break)
   ===================================================================== */


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   DDL structure | DML data | DQL read | TCL save/undo
   DELETE (rows, WHERE, keeps counter) | TRUNCATE (all rows, resets
     counter, keeps table) | DROP (whole table)
   INSERT ... SELECT       -> no VALUES, match columns by position
   AS                      -> result only; ORDER BY yes, WHERE no
   ORDER BY a, b DESC      -> DESC on b only
   LIMIT n OFFSET k        -> skip k, take n
   DISTINCT a, b           -> combination must repeat
   IS NULL                 -> never = NULL
   COALESCE / IFNULL       -> replace NULL in the result
   LIKE % / _              -> many / exactly one character
   CASE WHEN ... END       -> first match wins; keep ELSE
   COUNT(*) vs COUNT(col)  -> all rows vs non-NULL
   GROUP BY rule           -> plain SELECT columns must be grouped
   WHERE vs HAVING         -> rows before vs groups after grouping
   INNER / LEFT / RIGHT    -> overlap / all left / all right
   FULL OUTER              -> LEFT JOIN UNION RIGHT JOIN
   SELF / CROSS JOIN       -> same table, 2 aliases / every pair, no ON
   ON vs WHERE             -> ON keeps LEFT rows, WHERE can drop them
   Foreign key             -> parents created first, children dropped first
   Find missing            -> LEFT JOIN ... WHERE right.id IS NULL
                              (or NOT EXISTS)
   Subquery                -> scalar with = >, list with IN,
                              derived table needs an alias
   EXISTS                  -> TRUE if any row; NOT EXISTS is NULL-safe
   CTE                     -> WITH name AS (...) SELECT ...
   View                    -> saved query, no stored data
   OVER()                  -> keep rows; PARTITION BY = per group;
                              ORDER BY = running; ROWS BETWEEN = moving
   UNION / UNION ALL       -> stack: unique rows / every row (faster)
   INTERSECT / EXCEPT      -> in both / in first only (order matters);
                              older MySQL: IN / NOT EXISTS
   Set operation rules     -> same column count & order, names from
                              first SELECT, ORDER BY once at the end
   Duplicates              -> GROUP BY key HAVING COUNT(*) > 1
   5 data checks           -> counts, missing, extra, duplicates,
                              mismatches; equal counts prove nothing
   Ranking (OVER)          -> ROW_NUMBER 1,2,3 | RANK 1,2,2,4 |
                              DENSE_RANK 1,2,2,3
   Top-N per group         -> CTE + ROW_NUMBER() OVER (PARTITION BY g
                              ORDER BY x DESC), WHERE row_num <= N
   De-duplicate            -> ROW_NUMBER() OVER (PARTITION BY key
                              ORDER BY newest DESC), keep rn = 1
   Window aggregates       -> OVER () total | ORDER BY running |
                              ROWS n PRECEDING moving | LAG previous
   Preview then UPDATE     -> same WHERE; SET col = expr
   ===================================================================== */