/* =====================================================================
   DAY 4 - SQL PRACTICE NOTES
   Topics: NULL handling, LIKE, CASE, String functions, Date functions
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS day4_practice;
USE day4_practice;

DROP TABLE IF EXISTS day4;

CREATE TABLE day4 (
    customer_id    INT PRIMARY KEY,
    customer_name  VARCHAR(100),
    phone          VARCHAR(15),
    city           VARCHAR(50),
    order_amount   DECIMAL(10,2),
    order_date     DATE
);

INSERT INTO day4
    (customer_id, customer_name, phone, city, order_amount, order_date)
VALUES
    (1,  '  arun kumar  ', '9876543210', 'Chennai',    5000,  '2026-01-10'),
    (2,  'PRIYA',          NULL,         'Coimbatore', 15000, '2026-02-15'),
    (3,  'Karthik',        '9876500000', 'Chennai',    25000, '2026-03-20'),
    (4,  '  divya  ',      '9876511111', 'Madurai',    8000,  '2026-04-05'),
    (5,  'SURESH',         NULL,         'Salem',      35000, '2026-05-12'),
    (6,  'Meena',          '9876522222', 'Chennai',    45000, '2026-06-18'),
    (7,  '  ravi  ',       '9876533333', 'Trichy',     12000, '2026-07-22'),
    (8,  'ANU',            NULL,         'Coimbatore', 55000, '2026-08-10'),
    (9,  'Vijay',          '9876544444', 'Madurai',    18000, '2026-09-14'),
    (10, '  nisha  ',      '9876555555', 'Chennai',    65000, '2026-10-25');

SELECT * FROM day4;


/* ---------------------------------------------------------------------
   1. NULL HANDLING

   NULL = a missing / unknown value.
   It is NOT zero and NOT an empty string ''.

   IMPORTANT: NULL cannot be checked with = or !=
       WHERE phone = NULL     -- wrong, always returns nothing
       WHERE phone IS NULL    -- correct
   --------------------------------------------------------------------- */

-- IS NULL : rows where the value is missing
SELECT * FROM day4 WHERE phone IS NULL;

-- IS NOT NULL : rows where the value is present
SELECT * FROM day4 WHERE phone IS NOT NULL;


/* COALESCE(a, b, c, ...)
   Returns the FIRST non-NULL value from the list.
   - Takes 2 or more arguments
   - ANSI standard, works in every database
   Use case: personal number -> office number -> alternative number */
SELECT customer_name,
       COALESCE(phone, 'Not provided') AS phone_number
FROM day4;

/* IFNULL(a, b)
   If a is NULL, returns b. Otherwise returns a.
   - Takes EXACTLY 2 arguments
   - MySQL only (SQL Server: ISNULL, Oracle: NVL)

   NOTE: With 2 arguments, COALESCE and IFNULL give the same result.
         Prefer COALESCE: portable and supports many fallbacks. */
SELECT customer_name,
       IFNULL(phone, 'Not provided') AS phone_number
FROM day4;


/* ---------------------------------------------------------------------
   2. LIKE - pattern search in text

   Wildcards:
     %  = any number of characters (including zero)
     _  = exactly ONE character

   NOTE: In MySQL, LIKE is case-insensitive by default ('A%' matches 'anu').
   NOTE: Leading spaces matter! '  arun kumar  ' does NOT match 'A%'
         because it starts with a space. Use TRIM() to fix this.
   --------------------------------------------------------------------- */

-- Names starting with A (any length)
SELECT * FROM day4 WHERE customer_name LIKE 'A%';

-- Same, but ignoring leading/trailing spaces (now finds arun kumar too)
SELECT * FROM day4 WHERE TRIM(customer_name) LIKE 'A%';

-- Names ending with A
SELECT * FROM day4 WHERE customer_name LIKE '%A';

-- Names starting with A and EXACTLY 3 characters long (e.g. ANU)
SELECT * FROM day4 WHERE customer_name LIKE 'A__';


/* ---------------------------------------------------------------------
   3. CASE - conditional results (like IF-ELSE in programming)

   Syntax:
     CASE
         WHEN condition1 THEN result1
         WHEN condition2 THEN result2
         ELSE default_result
     END AS column_name

   NOTE: Conditions are checked TOP to BOTTOM. The first true one wins.
   NOTE: If no condition matches and there is no ELSE, result is NULL.
   NOTE: BETWEEN includes both ends (10000 and 30000 are both 'Medium').
   --------------------------------------------------------------------- */

-- Single condition per WHEN
SELECT customer_name, order_amount,
    CASE
        WHEN order_amount < 10000                 THEN 'Small'
        WHEN order_amount BETWEEN 10000 AND 30000 THEN 'Medium'
        ELSE 'Large'
    END AS order_category
FROM day4;

-- Multiple conditions using AND
-- Order matters: the Chennai rule must come BEFORE the general rule,
-- otherwise Chennai customers would be caught by the second WHEN first.
SELECT customer_name, city, order_amount,
    CASE
        WHEN city = 'Chennai' AND order_amount > 30000 THEN 'Premium customer'
        WHEN order_amount > 30000                      THEN 'High value customer'
        ELSE 'Regular customer'
    END AS customer_type
FROM day4;


/* ---------------------------------------------------------------------
   4. STRING FUNCTIONS
   --------------------------------------------------------------------- */

-- CONCAT(a, b, ...) : joins text together
-- NOTE: if ANY value is NULL, the whole result becomes NULL
SELECT CONCAT(customer_name, '_', city) AS customer_details FROM day4;

-- UPPER() / LOWER() : change letter case
SELECT customer_name, UPPER(customer_name) AS uppercase_name FROM day4;
SELECT customer_name, LOWER(customer_name) AS lowercase_name FROM day4;

-- SUBSTRING(text, start, length) : extract part of a text
-- NOTE: Position starts at 1 (not 0 like Python)
-- Example: SUBSTRING('Karthik', 2, 3) -> 'art'
SELECT customer_name, SUBSTRING(customer_name, 2, 3) AS short_name FROM day4;

-- TRIM() : removes spaces at the start and end (NOT in the middle)
-- '  arun kumar  ' -> 'arun kumar'
SELECT customer_name, TRIM(customer_name) AS cleaned_name FROM day4;

-- REPLACE(text, find, replace_with) : replaces matching text
SELECT city, REPLACE(city, 'Chennai', 'Chennai-City') AS updated_city FROM day4;

-- Combining functions : runs from the INSIDE out
-- Step 1: TRIM removes spaces -> Step 2: UPPER converts to capitals
SELECT customer_name, UPPER(TRIM(customer_name)) AS cleaned_name FROM day4;


/* ---------------------------------------------------------------------
   5. DATE FUNCTIONS

   MySQL date format: 'YYYY-MM-DD'          e.g. '2026-11-05'
   Datetime format:   'YYYY-MM-DD HH:MM:SS' e.g. '2026-11-05 14:32:02'
   --------------------------------------------------------------------- */

-- CURDATE() : today's date only
SELECT CURDATE() AS today_date;

-- NOW() : today's date AND current time
SELECT NOW() AS current_date_time;

/* WORKBENCH DISPLAY BUG NOTE
   In the new MySQL Workbench (Mac), the result grid shows NOW()
   as date only. The time IS stored correctly; only the display hides it.
   The MySQL terminal shows the full value. No setting exists to change it.
   Related bug: https://bugs.mysql.com/bug.php?id=115709

   Proof (one row, side by side):                                       */
SELECT
    CURDATE()            AS curdate_value,  -- date only (expected)
    NOW()                AS now_grid,       -- grid hides the time
    CAST(NOW() AS CHAR)  AS now_real;       -- real value with time

-- Workaround: format the value as text so the grid can't change it
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS current_date_time;


-- MONTH() : extract the month number (1-12) from a date
SELECT customer_name, order_date, MONTH(order_date) AS order_month FROM day4;

-- YEAR() : extract the year from a date
SELECT customer_name, order_date, YEAR(order_date) AS order_year FROM day4;

-- DATE_ADD(date, INTERVAL n unit) : add time to a date
-- Units: DAY, WEEK, MONTH, YEAR, HOUR, MINUTE ...
SELECT customer_name, order_date,
       DATE_ADD(order_date, INTERVAL 7 DAY) AS due_date
FROM day4;

-- DATE_SUB(date, INTERVAL n unit) : subtract time from a date
SELECT customer_name, order_date,
       DATE_SUB(order_date, INTERVAL 7 DAY) AS previous_date
FROM day4;

-- BETWEEN with dates : includes BOTH the start and end date
-- Here: all orders from Jan 1 to Jun 30, 2026
SELECT * FROM day4
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30';


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   IS NULL / IS NOT NULL  -> check missing values (never use = NULL)
   COALESCE(a,b,c...)     -> first non-NULL value, any number of args
   IFNULL(a,b)            -> MySQL only, exactly 2 args
   LIKE '%' / '_'         -> any characters / exactly one character
   CASE WHEN ... END      -> IF-ELSE logic, first match wins
   CONCAT                 -> join text (NULL makes whole result NULL)
   SUBSTRING(t, start, n) -> starts counting at 1
   TRIM                   -> removes outer spaces only
   CURDATE() vs NOW()     -> date only vs date + time
   DATE_ADD / DATE_SUB    -> add / subtract intervals
   BETWEEN                -> inclusive on both ends
   ===================================================================== */