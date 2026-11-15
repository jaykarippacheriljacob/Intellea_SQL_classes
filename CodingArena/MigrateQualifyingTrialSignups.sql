-- ============================================================
-- Exercise: Migrate Qualifying Trial Signups
--           (SQL Lab · Easy · DML, INSERT, SELECT)
--
-- Question:
--   A SaaS company wants to move trial users into the paying-
--   customers table when they have used the product enough times.
--   Use a single INSERT INTO ... SELECT statement to copy each
--   qualifying trial user into customers.
--   - Insert only full_name and email into customers
--   - Copy rows from trial_users where usage_count >= 5
--   - The customers table starts empty
--   - After the insert, return all rows from customers,
--     ordered by customer_id
--
-- Tables:
--   trial_users : trial_id INT PRIMARY KEY, full_name, email,
--                 usage_count ...
--   customers   : customer_id INT AUTO_INCREMENT PRIMARY KEY,
--                 full_name, email ...
--
-- Command types used:
--   DML : INSERT -> change data
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DML] Copy qualifying users. customer_id is left out because
--    AUTO_INCREMENT fills it (1, 2, 3...). ORDER BY trial_id makes
--    the lowest trial_id get the lowest customer_id.
INSERT INTO customers (full_name, email)
SELECT full_name, email
FROM trial_users
WHERE usage_count >= 5;

-- 2. [DQL] Show the result, sorted as the task asks.
SELECT * FROM customers
ORDER BY customer_id;


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- Error 1136: Column count doesn't match value count at row 1
--   Wrote:  INSERT INTO customers
--           SELECT full_name, email FROM trial_users ...
--   Why:    No column list, so MySQL expected a value for EVERY
--           column in customers (customer_id, full_name, email...),
--           but SELECT gave only 2.
--   Fix:    INSERT INTO customers (full_name, email) SELECT ...
--
-- Error 1064 near 'descibe customers'
--   Wrote:  descibe customers;
--   Why:    Typo, missing r.
--   Fix:    DESCRIBE customers;  (or SHOW COLUMNS FROM customers;)
--
-- Missing ORDER BY (no error, but doesn't follow the task)
--   Wrote:  SELECT * FROM customers;
--   Fix:    SELECT * FROM customers ORDER BY customer_id;
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- No VALUES keyword with INSERT ... SELECT
--   INSERT INTO t (a, b) VALUES SELECT ...  -> error 1064
--
-- Columns match by POSITION, not by name
--   1st SELECT column -> 1st column in the list, and so on.
--
-- >= vs >
--   usage_count >= 5 includes users with exactly 5 uses.
-- ============================================================