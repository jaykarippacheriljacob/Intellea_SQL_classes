-- ============================================================
-- Exercise: Create the Students Table with Basic Data Types
--           (SQL Lab · Easy · Data Types & CREATE/DROP)
--
-- Question:
--   Before creating a table, each column's data type must be chosen
--   based on what kind of value it will store:
--     INTEGER -> whole numbers
--     VARCHAR -> text of varying length
--     DATE    -> calendar dates
--   Create a table named students with columns:
--     student_id (INTEGER), name (VARCHAR(50)), department (VARCHAR(50)),
--     age (INTEGER), date_of_birth (DATE).
--   Insert one row with student_id 1, name 'Rahul',
--   department 'Computer Science', age 20, date_of_birth '2005-06-15'.
--
-- Command types used:
--   DDL : CREATE  -> change structure
--   DML : INSERT  -> change data
--   DQL : SELECT  -> read data
-- ============================================================


-- 1. [DDL] Create the students table only if it doesn't already exist.
CREATE TABLE IF NOT EXISTS students (
    student_id    INT AUTO_INCREMENT PRIMARY KEY,  -- whole number, auto-generated (1, 2, 3...)
    name          VARCHAR(50),                     -- text, up to 50 characters
    department    VARCHAR(50),                     -- text, up to 50 characters
    age           INT,                             -- whole number
    date_of_birth DATE                             -- calendar date, format 'YYYY-MM-DD'
);

-- 2. [DML] Insert Rahul. student_id is left out because AUTO_INCREMENT
--    fills it in automatically -> the first row gets student_id = 1.
INSERT INTO students (name, department, age, date_of_birth)
VALUES ('Rahul', 'Computer Science', 20, '2005-06-15');

-- 3. [DQL] Show the table to confirm the row was inserted.
SELECT * FROM students;


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- Error 1064 (syntax error) near 'exits students'
--   Wrote:  CREATE TABLE IF NOT EXITS students
--   Why:    Typo. The keyword is EXISTS (with an S). MySQL stops at the
--           first word it doesn't recognise and quotes from there.
--   Fix:    CREATE TABLE IF NOT EXISTS students
--
-- AUTO_INCREMENT on a text column
--   Wrote:  name VARCHAR(50) AUTO_INCREMENT
--   Why:    AUTO_INCREMENT generates numbers, so it only works on a
--           numeric column (INT), never on VARCHAR.
--   Fix:    Remove it from name; put it on student_id instead.
--
-- Error 1075: there can be only one auto column and it must be
--             defined as a key
--   Wrote:  student_id INT AUTO_INCREMENT
--   Why:    An AUTO_INCREMENT column must be a key (usually PRIMARY KEY)
--           so MySQL can track which numbers are already used.
--   Fix:    student_id INT AUTO_INCREMENT PRIMARY KEY
--
-- Date without quotes (no error, but wrong value)
--   Wrote:  2005-06-15
--   Why:    Without quotes MySQL treats it as maths: 2005 - 6 - 15 = 1984.
--   Fix:    '2005-06-15'  (dates always go in single quotes)
--
-- Column count doesn't match value count
--   Wrote:  5 columns in the list but only 4 values
--   Why:    Every column listed in INSERT needs exactly one value.
--   Fix:    Match them, or leave out student_id when it's AUTO_INCREMENT.
--
-- SELECT placed before INSERT (no error, but empty result)
--   Why:    Statements run top to bottom, so the table was still empty.
--   Fix:    Put SELECT after INSERT.
-- ============================================================