/* =====================================================================
   DAY 2 - SQL BASICS
   Topics: CREATE DATABASE, CREATE TABLE, ALTER TABLE,
           INSERT, UPDATE, DELETE, TRUNCATE
   Note:   Safe to re-run. The table is dropped and rebuilt each time.
   ===================================================================== */


/* ---------------------------------------------------------------------
   SQL COMMAND TYPES

   DDL (Data Definition Language)    -> changes STRUCTURE
       CREATE, ALTER, DROP, TRUNCATE
   DML (Data Manipulation Language)  -> changes DATA (rows)
       INSERT, UPDATE, DELETE
   DQL (Data Query Language)         -> READS data
       SELECT
   Utility commands                  -> switch / inspect
       USE, SHOW, DESCRIBE
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   1. CREATE AND SELECT A DATABASE

   Database = a container that holds tables.
   IF NOT EXISTS = no error if it already exists.
   --------------------------------------------------------------------- */

-- [DDL] Create the database
CREATE DATABASE IF NOT EXISTS company_db;

-- [Utility] Switch to it, so all commands below run inside company_db
USE company_db;


/* ---------------------------------------------------------------------
   2. CREATE TABLE

   Table = rows and columns, like a spreadsheet.
   Each column has a DATA TYPE and optional CONSTRAINTS (rules).

   Data types used:
     INT            -> whole numbers
     VARCHAR(n)     -> text, up to n characters
     DECIMAL(10,2)  -> 10 digits in total, 2 after the decimal point
                       (max 99,999,999.99) - use for money

   Constraints used:
     PRIMARY KEY    -> unique + NOT NULL, identifies each row
     AUTO_INCREMENT -> MySQL generates the next number automatically
     NOT NULL       -> value is required
     DEFAULT x      -> uses x when no value is given
     CHECK (...)    -> rejects values that break the rule
                       (enforced from MySQL 8.0.16 onwards)
   --------------------------------------------------------------------- */

-- [DDL] Remove any old copy so the script can be re-run
-- WARNING: DROP deletes the table AND all its data permanently
DROP TABLE IF EXISTS employees;

-- [DDL] Create the employees table
CREATE TABLE employees (
    employee_id    INT AUTO_INCREMENT PRIMARY KEY,  -- unique ID, auto-generated
    employee_name  VARCHAR(50) NOT NULL,            -- name is required
    department     VARCHAR(30) DEFAULT 'SQL',       -- 'SQL' if not given
    salary         DECIMAL(10, 2) CHECK (salary >= 0)  -- no negative salary
) AUTO_INCREMENT = 101;                             -- IDs start at 101


/* ---------------------------------------------------------------------
   3. ALTER TABLE - change the structure of an existing table

   ADD COLUMN     -> add a new column (AFTER x places it after column x)
   RENAME COLUMN  -> change a column's name
   Others:  MODIFY COLUMN (change type), DROP COLUMN (remove column)
   --------------------------------------------------------------------- */

-- [DDL] Add a phone column right after the name
ALTER TABLE employees
    ADD COLUMN phone VARCHAR(15) AFTER employee_name;

-- [DDL] Rename it to something clearer
ALTER TABLE employees
    RENAME COLUMN phone TO mobile_number;

-- NOTE: Phone numbers are stored as VARCHAR, not INT.
--       We never do maths on them, and INT would drop leading zeros.


/* ---------------------------------------------------------------------
   4. INSERT - add rows

   Syntax:
     INSERT INTO table (col1, col2, ...) VALUES (val1, val2, ...);

   NOTE: employee_id is left out, so AUTO_INCREMENT fills it in.
   NOTE: DEFAULT keyword -> uses the column's default value.
   NOTE: NULL -> stores "no value".
   --------------------------------------------------------------------- */

-- [DML]
INSERT INTO employees (employee_name, mobile_number, department, salary)
VALUES
    ('Anil Kumar',  '9876543210', 'Data',  55000.00),  -- ID 101
    ('Meera Nair',  '9123456780', DEFAULT, 48000.00),  -- ID 102, department = 'SQL'
    ('Rahul Menon', NULL,         'HR',    42000.00);  -- ID 103, no phone

-- Constraints in action (uncomment one at a time to see the error):
-- INSERT INTO employees (employee_name, salary) VALUES (NULL, 30000);    -- fails: NOT NULL
-- INSERT INTO employees (employee_name, salary) VALUES ('Test', -500);   -- fails: CHECK


/* ---------------------------------------------------------------------
   5. INSPECT THE DATABASE
   --------------------------------------------------------------------- */

SHOW TABLES;              -- [Utility] list all tables in company_db
DESCRIBE employees;       -- [Utility] column names, types, keys, defaults
SELECT * FROM employees;  -- [DQL] show all rows (* = all columns)


/* ---------------------------------------------------------------------
   6. UPDATE - change existing rows

   Syntax:
     UPDATE table SET column = value WHERE condition;

   WARNING: Always use WHERE. Without it, EVERY row is updated.
   NOTE: Workbench "Safe Update Mode" blocks UPDATE/DELETE without
         a WHERE on a key column, to protect you from this mistake.
   --------------------------------------------------------------------- */

-- [DML] Move employee 101 (Anil Kumar) to DEV
UPDATE employees SET department = 'DEV' WHERE employee_id = 101;

-- [DQL] Confirm the change
SELECT * FROM employees;


/* ---------------------------------------------------------------------
   7. DELETE - remove specific rows

   Syntax:
     DELETE FROM table WHERE condition;

   WARNING: Without WHERE, ALL rows are deleted.
   TIP: Run a SELECT with the same WHERE first, to see what will go.
   --------------------------------------------------------------------- */

-- [DQL] Check what will be deleted
SELECT * FROM employees WHERE employee_id = 101;

-- [DML] Delete only employee 101
DELETE FROM employees WHERE employee_id = 101;

-- [DQL] Confirm: 101 is gone, 102 and 103 remain
SELECT * FROM employees;

-- NOTE: DELETE does NOT reset AUTO_INCREMENT.
--       The next new row gets ID 104, not 101.
INSERT INTO employees (employee_name, salary) VALUES ('Sneha Pillai', 40000.00);
SELECT * FROM employees;   -- Sneha gets ID 104


/* ---------------------------------------------------------------------
   8. TRUNCATE - empty the whole table

   - Removes ALL rows in one step (no WHERE allowed)
   - Faster than DELETE on large tables
   - Cannot be rolled back
   - Resets the AUTO_INCREMENT counter
   - Table STRUCTURE stays (columns remain, only data is removed)
   --------------------------------------------------------------------- */

-- [DDL]
TRUNCATE TABLE employees;

-- [DQL] Confirm the table is empty
SELECT * FROM employees;

-- See the counter reset: insert a row and check which ID it gets
INSERT INTO employees (employee_name, salary) VALUES ('Test Reset', 30000.00);
SELECT * FROM employees;


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   DDL -> structure   DML -> data   DQL -> read

   CREATE DATABASE / TABLE   -> make new
   ALTER TABLE               -> change columns (ADD, RENAME, MODIFY, DROP)
   INSERT                    -> add rows
   UPDATE ... WHERE          -> change rows   (no WHERE = all rows!)
   DELETE ... WHERE          -> remove rows   (no WHERE = all rows!)

   DELETE vs TRUNCATE vs DROP:
     DELETE   -> removes chosen rows, keeps counter,  can use WHERE
     TRUNCATE -> removes ALL rows,    resets counter, keeps table
     DROP     -> removes the WHOLE table (structure + data)

   PRIMARY KEY    = unique + not null
   AUTO_INCREMENT = automatic numbering
   NOT NULL       = required
   DEFAULT        = fallback value
   CHECK          = custom rule
   ===================================================================== */