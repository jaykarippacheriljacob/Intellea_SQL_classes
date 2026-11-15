-- ============================================================
-- Exercise: Purge Stale and Orphaned Cart Items
--           (SQL Lab · Medium · DELETE)
--
-- Question:
--   As a database administrator for an e-commerce platform, you've
--   been tasked with a critical cleanup operation. The CartItems
--   table has accumulated a large number of records over time, many
--   of which are no longer relevant. Your goal is to purge these
--   records to improve database performance and reclaim space.
--
--   You need to delete cart items that are either "stale" (belonging
--   to long-inactive users) or "orphaned" (belonging to users who no
--   longer exist in the system).
--
--   Database Schema
--
--   You'll be working with two tables:
--
--   Users
--   Column      Type     Description
--   user_id     INTEGER  Primary key for the user.
--   username    TEXT     The user's username.
--   last_login  DATE     The date of the user's last login, in
--                        'YYYY-MM-DD' format.
--
--   CartItems
--   Column      Type     Description
--   cart_id     INTEGER  Primary key for the cart item.
--   user_id     INTEGER  Foreign key referencing the user who owns
--                        the cart.
--   product_id  INTEGER  The ID of the product in the cart.
--
--   Task
--
--   Write a single SQL DELETE statement that removes records from the
--   CartItems table if they meet at least one of the following
--   criteria:
--
--   Stale Item: The associated user's last_login date in the Users
--   table was more than 90 days ago.
--   Orphaned Item: The user_id in the CartItems table does not
--   correspond to any existing user_id in the Users table.
--   For date calculations, you can use SQLite's julianday() function.
--   For this problem, assume the current date is '2024-08-01'. The
--   condition for an inactive user would be
--   julianday('2024-08-01') - julianday(last_login) > 90.
--
-- Sample data:
--
--   Users (3 rows)
--   user_id | username | last_login
--   101     | alice    | 2024-07-15   (17 days before 2024-08-01)
--   102     | bob      | 2024-01-10   (204 days -> STALE)
--   103     | carol    | 2024-05-15   (78 days  -> active)
--
--   CartItems (original, 7 rows)
--   cart_id | user_id | product_id
--   1       | 101     | 1001
--   2       | 101     | 1002
--   3       | 102     | (bob's item)
--   4       | 999     | 3001         (no user 999 -> ORPHANED)
--   5       | 102     | (bob's item)
--   6       | 888     | 3002         (no user 888 -> ORPHANED)
--   7       | 103     | 4001
--
-- Command types used:
--   DML : DELETE -> change data (remove rows)
--   DQL : SELECT -> read data
-- ============================================================


-- ############################################################
-- TASK 1 of 2
-- Write a SQL query to delete all cart items from the `CartItems`
-- table that are either stale (user inactive for >90 days) or
-- orphaned (user does not exist).
-- ############################################################

-- ------------------------------------------------------------
-- NOTE: julianday() is SQLite. This lab runs MySQL, so use DATEDIFF.
--   SQLite: julianday('2024-08-01') - julianday(last_login) > 90
--   MySQL : DATEDIFF('2024-08-01', last_login) > 90
--   DATEDIFF(later, earlier) -> number of days between them
-- ------------------------------------------------------------

-- Step 1. [DQL] Preview what will be deleted (same WHERE as the DELETE)
--         Expected: cart 3, 5 (bob, stale) and 4, 6 (999/888, orphaned)
SELECT *
FROM CartItems
WHERE user_id IN (SELECT user_id FROM Users
                  WHERE DATEDIFF('2024-08-01', last_login) > 90)
   OR user_id NOT IN (SELECT user_id FROM Users);

-- ------------------------------------------------------------
-- FINAL ANSWER - TASK 1
-- ------------------------------------------------------------

-- 1. [DML] Delete rows matching EITHER condition (OR).
--    Stale    -> user exists, but last login > 90 days before 2024-08-01
--    Orphaned -> user_id not found in Users at all
DELETE FROM CartItems
WHERE user_id IN (SELECT user_id FROM Users
                  WHERE DATEDIFF('2024-08-01', last_login) > 90)   -- stale
   OR user_id NOT IN (SELECT user_id FROM Users);                   -- orphaned

-- 2. [DQL] Check what is left -> 3 rows
--    1 | 101 | 1001
--    2 | 101 | 1002
--    7 | 103 | 4001   (carol stays: 78 days is not > 90)
SELECT * FROM CartItems ORDER BY cart_id;


-- ############################################################
-- TASK 2 of 2
-- The marketing team wants an engagement report of recently active
-- users, evaluated against the original (pre-cleanup) cart data.
-- Write a SQL query that returns, for every user in the `Users`
-- table whose `last_login` is on or after '2024-05-01', their
-- `user_id`, `username`, and total number of cart items
-- (`item_count`) — including users who have zero items. Order the
-- results by `item_count` descending, then by `user_id` ascending.
-- ############################################################

-- ------------------------------------------------------------
-- HOW IT WORKS
-- ------------------------------------------------------------
-- Needs data from BOTH tables (username from Users, items from
-- CartItems) -> JOIN on the common column user_id.
-- "including users who have zero items" -> LEFT JOIN, Users first.
-- One row per user -> GROUP BY; count that user's items -> COUNT.

-- ------------------------------------------------------------
-- FINAL ANSWER - TASK 2
-- ------------------------------------------------------------
SELECT u.user_id,
       u.username,
       COUNT(c.cart_id) AS item_count
FROM Users AS u
LEFT JOIN CartItems AS c
    ON u.user_id = c.user_id
WHERE u.last_login >= '2024-05-01'
GROUP BY u.user_id, u.username
ORDER BY item_count DESC, u.user_id ASC;

-- Expected (original cart data):
--   101 | alice | 2
--   103 | carol | 1
--   (bob is excluded: last login 2024-01-10 is before 2024-05-01)

-- The version that passed (also correct):
--   COUNT(c.user_id)                       works like COUNT(c.cart_id)
--   WHERE DATEDIFF(u.last_login, '2024-05-01') >= 0
--                                          same as last_login >= '2024-05-01'
--   GROUP BY u.user_id                     allowed: user_id is the PK


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- ---------- TASK 1 ----------
--
-- Error 1305: FUNCTION ... julianday does not exist
--   Wrote:  WHERE julianday(last_login) > 90
--   Why:    julianday() is a SQLite function; the lab runs MySQL.
--   Fix:    DATEDIFF('2024-08-01', last_login) > 90
--
-- Wrong date logic
--   Wrote:  julianday(last_login) > 90
--   Why:    julianday alone returns a huge day number (~2.4 million),
--           always > 90. "Days ago" needs a SUBTRACTION from the
--           current date, which DATEDIFF does.
--
-- Row count doesn't match: 5 rows, expected 3  (no error)
--   Wrote:  DELETE ... WHERE user_id IN (stale users) only
--   Why:    Orphaned items (users 999, 888) were not deleted. The
--           subquery only returns ids that EXIST in Users, so it can
--           never match a missing user.
--   Fix:    OR user_id NOT IN (SELECT user_id FROM Users)
--
-- ---------- TASK 2 ----------
--
-- Error 1140: aggregated query without GROUP BY
--   Wrote:  SELECT u.user_id, u.username, COUNT(...) ... (no GROUP BY)
--   Fix:    GROUP BY u.user_id, u.username
--
-- Cross join (no error, wrong counts)
--   Wrote:  FROM Users AS u, CartItems AS c   (no join condition)
--   Why:    A comma with no ON pairs EVERY user with EVERY cart item,
--           so alice and carol both got 7 (all items in the table).
--   Fix:    LEFT JOIN CartItems AS c ON u.user_id = c.user_id
--
-- INNER JOIN instead of LEFT JOIN (passes here, wrong in general)
--   Why:    INNER JOIN drops users with no cart items. The task says
--           "including users who have zero items". Here alice and carol
--           both have items, so the result happens to be the same.
--   Fix:    LEFT JOIN with Users first.
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- SQLite vs MySQL dates
--   julianday(a) - julianday(b)  ->  DATEDIFF(a, b)
--
-- Delete on two conditions -> OR, with a preview SELECT first
--   Same WHERE in the SELECT and the DELETE = same rows removed.
--
-- Orphaned rows (child with no parent)
--   user_id NOT IN (SELECT user_id FROM Users)
--   Safe here: Users.user_id is a PK, so it has no NULLs.
--   NULL-safe alternative:
--   NOT EXISTS (SELECT 1 FROM Users u WHERE u.user_id = CartItems.user_id)
--
-- When to JOIN vs subquery
--   Only FILTER by another table      -> subquery (IN / EXISTS)  [Task 1]
--   SHOW / COUNT data from both tables -> JOIN                    [Task 2]
--
-- Counting with LEFT JOIN
--   COUNT(c.cart_id) -> 0 for users with no items
--   COUNT(*)         -> 1 for them (counts the NULL row) - wrong
--
-- Filter the LEFT table in WHERE, never the right one
--   WHERE u.last_login ...   keeps the LEFT JOIN working
--   WHERE c.something ...    would turn it into an INNER JOIN
--
-- Safe update mode (Workbench only)
--   DELETE with a WHERE that isn't on a key -> Error 1175
--   SET SQL_SAFE_UPDATES = 0;  ...  SET SQL_SAFE_UPDATES = 1;
-- ============================================================