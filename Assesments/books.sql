-- ============================================================
-- Exercise: Insert a Single Row
--           (SQL Lab · Easy · DML Intro & INSERT)
--
-- Question:
--   DML (Data Manipulation Language) commands work with the rows
--   inside a table, rather than the table's structure. INSERT is
--   the DML command used to add new rows.
--   Add the first book to an already-existing books table:
--   Insert one row with book_id 1, title 'Atomic Habits',
--   and price 399.00. Return all rows.
--
-- Command types used:
--   DML : INSERT -> change data
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DML] Add one row. Values follow the same order as the
--    column list: book_id -> 1, title -> 'Atomic Habits',
--    price -> 399.00.
INSERT INTO books (book_id, title, price)
VALUES (1, 'Atomic Habits', 399.00);

-- 2. [DQL] Return all rows to confirm the insert.
SELECT * FROM books;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- VALUE vs VALUES
--   Wrote:  VALUE (1, 'Atomic Habits', 399.00)
--   Why:    MySQL accepts VALUE as a synonym, but VALUES is the
--           standard keyword and works in every database.
--   Fix:    VALUES (1, 'Atomic Habits', 399.00)
--
-- Text without quotes
--   Wrote:  VALUES (1, Atomic Habits, 399.00)
--   Why:    MySQL reads Atomic Habits as column names -> error.
--   Fix:    Text always goes in single quotes: 'Atomic Habits'
--
-- Quotes around numbers (works, but unnecessary)
--   '399.00' is converted to a number automatically; plain
--   399.00 is cleaner.
--
-- Duplicate primary key
--   Running the INSERT twice gives Error 1062 (Duplicate entry
--   '1' for key 'PRIMARY') if book_id is the primary key.
--   Each book_id must be unique.
--
-- Column count doesn't match value count
--   3 columns listed -> exactly 3 values needed, same order.
-- ============================================================