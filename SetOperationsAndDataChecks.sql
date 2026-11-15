/* =====================================================================
   DAY 9 - SQL PRACTICE NOTES
   Topics: UNION, UNION ALL, INTERSECT, EXCEPT, Set operation rules,
           Alternatives for older MySQL, Finding duplicates,
           Source to target validation (5 checks), Error clinic
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP

   NOTE: source_customers / target_customers have NO primary key on
         purpose, so duplicates can be loaded (like a real bad load).
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day9_set_operations_practice;
USE day9_set_operations_practice;

DROP TABLE IF EXISTS source_customers;
DROP TABLE IF EXISTS target_customers;
DROP TABLE IF EXISTS customer_contacts;
DROP TABLE IF EXISTS chennai_departments;
DROP TABLE IF EXISTS coimbatore_departments;

CREATE TABLE source_customers (
    customer_id    INT,
    customer_name  VARCHAR(50),
    city           VARCHAR(50)
);

CREATE TABLE target_customers (
    customer_id    INT,
    customer_name  VARCHAR(50),
    city           VARCHAR(50)
);

CREATE TABLE customer_contacts (
    contact_id     INT PRIMARY KEY,
    customer_name  VARCHAR(50),
    email          VARCHAR(100)
);

CREATE TABLE chennai_departments (
    employee_id    INT,
    employee_name  VARCHAR(50)
);

CREATE TABLE coimbatore_departments (
    employee_id    INT,
    employee_name  VARCHAR(50)
);

INSERT INTO source_customers VALUES
    (1, 'Arun',    'Chennai'),
    (2, 'Priya',   'Coimbatore'),
    (3, 'Karthik', 'Madurai'),
    (4, 'Divya',   'Chennai'),
    (5, 'Suresh',  'Salem');

INSERT INTO target_customers VALUES
    (1, 'Arun',    'Chennai'),
    (2, 'Priya',   'Coimbatore'),
    (3, 'Karthik', 'Trichy'),        -- city changed during the load
    (4, 'Divya',   'Chennai'),
    (6, 'Nila',    'Erode');         -- not in source; Suresh (5) missing

INSERT INTO customer_contacts VALUES
    (1, 'Arun',    'arun@gmail.com'),
    (2, 'Priya',   'priya@gmail.com'),
    (3, 'Karthik', 'arun@gmail.com'),   -- Arun's email reused
    (4, 'Divya',   'divya@gmail.com'),
    (5, 'Suresh',  'suresh@gmail.com'),
    (6, 'Arun',    'arun@gmail.com');   -- Arun entered twice

INSERT INTO chennai_departments VALUES
    (101, 'Arun'), (102, 'Priya'), (103, 'Divya');

INSERT INTO coimbatore_departments VALUES
    (102, 'Priya'), (104, 'Karthik'), (105, 'Nila');

/* Overlaps to remember:
     Offices   -> Priya (102) works in BOTH offices
     Customers -> Arun, Priya, Divya identical in both tables
                  Karthik's city differs | Suresh only in source
                  Nila only in target
     Contacts  -> arun@gmail.com used 3 times                         */


/* ---------------------------------------------------------------------
   1. WHAT ARE SET OPERATIONS?

   JOIN           -> puts tables SIDE BY SIDE (adds columns)
   SET OPERATION  -> STACKS results ON TOP of each other, or compares
                     them (works on whole rows)

     UNION      -> everything from both, duplicates removed
     UNION ALL  -> everything from both, duplicates kept
     INTERSECT  -> only rows found in BOTH results
     EXCEPT     -> rows in the FIRST result that are NOT in the second

   Venn view (offices):
     Chennai only: Arun, Divya | Both: Priya | Coimbatore only: Karthik, Nila
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   2. UNION vs UNION ALL - stack two results

   UNION     -> removes duplicate rows (extra work: sorts / compares)
   UNION ALL -> keeps every row (faster)

   Use UNION     for a unique list (e.g. a mailing list)
   Use UNION ALL when every row counts (e.g. adding up sales from
                 two branches), or when you know there are no duplicates
   --------------------------------------------------------------------- */

-- UNION: 5 rows -> 101 Arun, 102 Priya, 103 Divya, 104 Karthik, 105 Nila
-- (Priya 102 appears in both tables but is shown once)
SELECT employee_id, employee_name FROM chennai_departments
UNION
SELECT employee_id, employee_name FROM coimbatore_departments
ORDER BY employee_id;

-- UNION ALL: 6 rows -> Priya 102 appears twice
SELECT employee_id, employee_name FROM chennai_departments
UNION ALL
SELECT employee_id, employee_name FROM coimbatore_departments
ORDER BY employee_id;


/* ---------------------------------------------------------------------
   3. RULES FOR SET OPERATIONS

   1. Same NUMBER of columns in every SELECT      (else Error 1222)
   2. Matching types in the same ORDER            (text under text,
                                                   numbers under numbers)
   3. Column NAMES come from the FIRST SELECT     (aliases in the second
                                                   are ignored)
   4. ORDER BY goes ONCE, at the very END         (sorts the combined result)

   Trick: add a fixed text "label" column to show where each row came from.
   --------------------------------------------------------------------- */

-- Label column: 6 rows, sorted by name
-- Arun Chennai | Divya Chennai | Karthik Coimbatore | Nila Coimbatore |
-- Priya Chennai | Priya Coimbatore
SELECT employee_name, 'Chennai' AS office FROM chennai_departments
UNION ALL
SELECT employee_name, 'Coimbatore' FROM coimbatore_departments
ORDER BY employee_name, office;

-- Row counts side by side (also used in the lab, Section 7)
-- SOURCE 5 | TARGET 5
SELECT 'SOURCE' AS system_name, COUNT(*) AS row_count FROM source_customers
UNION ALL
SELECT 'TARGET', COUNT(*) FROM target_customers;


/* ---------------------------------------------------------------------
   4. INTERSECT - rows found in BOTH results

   Compares WHOLE rows: every selected column must match.
   NOTE: Needs MySQL 8.0.31 or later (check with SELECT VERSION();)
   --------------------------------------------------------------------- */

-- Employees in both offices -> 102 Priya
SELECT employee_id, employee_name FROM chennai_departments
INTERSECT
SELECT employee_id, employee_name FROM coimbatore_departments;

-- Customers loaded EXACTLY the same -> 1 Arun, 2 Priya, 4 Divya
-- (Karthik is missing: his city differs, so the whole row differs)
SELECT customer_id, customer_name, city FROM source_customers
INTERSECT
SELECT customer_id, customer_name, city FROM target_customers;


/* ---------------------------------------------------------------------
   5. EXCEPT - rows in the FIRST result, not in the second

   ORDER MATTERS:  A EXCEPT B  is NOT  B EXCEPT A
   Oracle calls it MINUS. Needs MySQL 8.0.31 or later.
   --------------------------------------------------------------------- */

-- Source rows that did not arrive exactly -> 3 Karthik Madurai,
--                                            5 Suresh Salem
SELECT customer_id, customer_name, city FROM source_customers
EXCEPT
SELECT customer_id, customer_name, city FROM target_customers;

-- Target rows that are not in source -> 3 Karthik Trichy, 6 Nila Erode
SELECT customer_id, customer_name, city FROM target_customers
EXCEPT
SELECT customer_id, customer_name, city FROM source_customers;

-- Only in Chennai office -> 101 Arun, 103 Divya
SELECT employee_id, employee_name FROM chennai_departments
EXCEPT
SELECT employee_id, employee_name FROM coimbatore_departments;


/* ---------------------------------------------------------------------
   6. BEFORE MySQL 8.0.31 - same results without EXCEPT / INTERSECT

   Instead of INTERSECT -> IN  (or EXISTS)
   Instead of EXCEPT    -> NOT EXISTS (or NOT IN)

   Small difference: EXCEPT / INTERSECT also remove duplicate rows.
   IN / NOT EXISTS keep them.
   --------------------------------------------------------------------- */

SELECT VERSION();

-- INTERSECT replacement -> 102 Priya
SELECT c.employee_id, c.employee_name
FROM chennai_departments AS c
WHERE c.employee_id IN (SELECT employee_id FROM coimbatore_departments);

-- EXCEPT replacement -> 101 Arun, 103 Divya
SELECT c.employee_id, c.employee_name
FROM chennai_departments AS c
WHERE NOT EXISTS (SELECT 1
                  FROM coimbatore_departments AS k
                  WHERE k.employee_id = c.employee_id);


/* ---------------------------------------------------------------------
   7. FINDING DUPLICATES

   GROUP BY the column(s) that SHOULD be unique,
   then HAVING COUNT(*) > 1 keeps the groups that repeat.
   (Same GROUP BY + HAVING from Day 5.)

   Run this after every data load: duplicate customers, duplicate
   payments, the same order loaded twice ...
   --------------------------------------------------------------------- */

-- Emails used more than once -> arun@gmail.com 3
SELECT email, COUNT(*) AS occurrence_count
FROM customer_contacts
GROUP BY email
HAVING COUNT(*) > 1;

-- Same name AND email more than once -> Arun, arun@gmail.com, 2
-- (Karthik shares the email but has a different name, so he's not here)
SELECT customer_name, email, COUNT(*) AS occurrence_count
FROM customer_contacts
GROUP BY customer_name, email
HAVING COUNT(*) > 1;

-- See the actual duplicate rows (join back to the groups)
-- contact_id 1, 3, 6
SELECT cc.*
FROM customer_contacts AS cc
WHERE cc.email IN (SELECT email
                   FROM customer_contacts
                   GROUP BY email
                   HAVING COUNT(*) > 1)
ORDER BY cc.contact_id;


/* ---------------------------------------------------------------------
   8. SOURCE TO TARGET VALIDATION (ETL testing lab)

   Data is copied from a SOURCE system into a TARGET. An ETL tester
   proves both match with 5 checks. Compare by the KEY (customer_id).

     1. Row counts         -> UNION ALL of two COUNT(*)
     2. Missing in target  -> source EXCEPT target   (or LEFT JOIN IS NULL)
     3. Extra in target    -> target EXCEPT source   (or LEFT JOIN IS NULL)
     4. Duplicate rows     -> GROUP BY key HAVING COUNT(*) > 1
     5. Mismatched values  -> JOIN on key, compare other columns with <>

   Never check by eye. Real tables have millions of rows.
   --------------------------------------------------------------------- */

-- CHECK 1: Row counts -> SOURCE 5 | TARGET 5   (equal... but keep going!)
SELECT 'SOURCE' AS system_name, COUNT(*) AS row_count FROM source_customers
UNION ALL
SELECT 'TARGET', COUNT(*) FROM target_customers;

-- CHECK 2: Missing in target (by id) -> 5 Suresh Salem
SELECT s.customer_id, s.customer_name, s.city
FROM source_customers AS s
LEFT JOIN target_customers AS t ON s.customer_id = t.customer_id
WHERE t.customer_id IS NULL;

-- same check with EXCEPT on the key only -> 5
SELECT customer_id FROM source_customers
EXCEPT
SELECT customer_id FROM target_customers;

-- CHECK 3: Extra in target (by id) -> 6 Nila Erode
SELECT t.customer_id, t.customer_name, t.city
FROM target_customers AS t
LEFT JOIN source_customers AS s ON t.customer_id = s.customer_id
WHERE s.customer_id IS NULL;

-- CHECK 4: Duplicate keys in target -> 0 rows (no duplicates this time)
SELECT customer_id, COUNT(*) AS copies
FROM target_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- CHECK 5: Same id, different values -> 3 Karthik, Madurai vs Trichy
SELECT s.customer_id,
       s.customer_name,
       s.city AS source_city,
       t.city AS target_city
FROM source_customers AS s
INNER JOIN target_customers AS t ON s.customer_id = t.customer_id
WHERE s.customer_name <> t.customer_name
   OR s.city <> t.city;

/* NOTE: <> ignores NULLs (NULL <> 'Chennai' is not TRUE), so a value
         that became NULL during the load would be missed.
         NULL-safe version (MySQL):
           WHERE NOT (s.customer_name <=> t.customer_name)
              OR NOT (s.city <=> t.city)
         <=> is TRUE when both sides are equal OR both are NULL.      */

-- QUICK WHOLE-ROW CHECK: every source row that didn't arrive exactly
-- -> 3 Karthik Madurai, 5 Suresh Salem
SELECT * FROM source_customers
EXCEPT
SELECT * FROM target_customers;

/* LAB REPORT
   Check              Result     Finding
   Row counts         5 vs 5     Counts match (but that proves nothing!)
   Missing rows       1          customer 5, Suresh, not loaded
   Extra rows         1          customer 6, Nila, not in source
   Duplicate rows     0          none
   Mismatched values  1          customer 3, Karthik, Madurai -> Trichy

   Do the numbers add up?  5 source - 1 missing + 1 extra + 0 dup = 5 target
   Equal counts hid THREE problems. Always run all five checks.        */


/* ---------------------------------------------------------------------
   9. ERROR CLINIC
   Wrong queries are commented out so this file runs without errors.
   --------------------------------------------------------------------- */

/* ERROR 1 - Different number of columns
   Wrote:
     SELECT employee_id, employee_name FROM chennai_departments
     UNION
     SELECT employee_name FROM coimbatore_departments;
   Error:  1222 - The used SELECT statements have a different number
           of columns
   Fix:    Same columns, same order, in every SELECT.                  */


/* ERROR 2 - ORDER BY in the middle
   Wrote:
     SELECT employee_name FROM chennai_departments ORDER BY employee_name
     UNION
     SELECT employee_name FROM coimbatore_departments;
   Error:  1221 / 1064 - Incorrect usage of UNION and ORDER BY
   Fix:    One ORDER BY, after the LAST SELECT.                        */


/* ERROR 3 - Columns in a different order  (no error, wrong result)
   Wrote:
     SELECT employee_id, employee_name FROM chennai_departments
     UNION
     SELECT employee_name, employee_id FROM coimbatore_departments;
   Result: names end up under employee_id and ids under employee_name.
   Why:    Set operations match columns by POSITION, not by name.      */


/* ERROR 4 - EXCEPT / INTERSECT on old MySQL
   Wrote:  ... EXCEPT ...   on MySQL 8.0.30 or older
   Error:  1064 - syntax error near 'EXCEPT'
   Fix:    Check SELECT VERSION(); use NOT EXISTS / IN (Section 6).    */


/* ERROR 5 - EXCEPT in the wrong direction  (no error, wrong answer)
   source EXCEPT target -> missing from target
   target EXCEPT source -> extra in target
   Swapping them answers the opposite question.                       */


/* ERROR 6 - Trusting row counts alone  (no error, wrong conclusion)
   Counts here are 5 vs 5, yet one row is missing, one is extra and
   one has a wrong city. Equal counts never prove a correct load.     */


/* ERROR 7 - UNION hiding duplicates  (no error, wrong count)
   Counting rows after UNION removes repeats you may need to see.
   For totals or duplicate checks, use UNION ALL.                      */


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   JOIN vs set operation -> side by side vs stacked / compared
   UNION              -> both results, duplicates removed
   UNION ALL          -> both results, duplicates kept (faster)
   INTERSECT          -> rows in both
   EXCEPT (MINUS)     -> rows in first, not second; order matters
   Rules              -> same column count (1222), same order and types,
                         names from first SELECT, one ORDER BY at the end
   Label column       -> 'web' AS source ... shows where rows came from
   Old MySQL (<8.0.31)-> INTERSECT = IN, EXCEPT = NOT EXISTS
   Duplicates         -> GROUP BY key HAVING COUNT(*) > 1
   5 ETL checks       -> counts, missing, extra, duplicates, mismatches
   Missing / extra    -> LEFT JOIN ... WHERE other.id IS NULL, or EXCEPT
   Mismatched values  -> JOIN on key, WHERE a.col <> b.col
                         (NULL-safe: NOT (a.col <=> b.col))
   Equal counts       -> do NOT prove a correct load
   ===================================================================== */
