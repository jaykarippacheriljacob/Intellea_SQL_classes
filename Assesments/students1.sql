-- ============================================================
-- Exercise: Remove All Rows with TRUNCATE
--           (SQL Lab · Easy · Truncate)
--
-- Question:
--   TRUNCATE TABLE removes every row from a table in a single
--   operation while keeping the table's structure exactly as it was.
--   The students table currently has 3 rows.
--   Remove all rows from the table using TRUNCATE, while keeping
--   the table structure intact.
--
-- Command types used:
--   DDL : TRUNCATE -> resets the table (counts as structure-level)
--   DQL : SELECT   -> read data
-- ============================================================

-- 1. [DDL] Remove every row in one go. Columns, data types and
--    keys stay exactly as they were; only the data is wiped.
TRUNCATE TABLE students;



-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- TRUNCATE vs DELETE vs DROP
--   TRUNCATE TABLE students;  -> removes all rows, keeps the table
--   DELETE FROM students;     -> also removes all rows, but row by row
--                                (slower; can use WHERE to remove some)
--   DROP TABLE students;      -> deletes the whole table, structure too
--
-- No WHERE with TRUNCATE
--   Wrote:  TRUNCATE TABLE students WHERE age > 20;
--   Why:    TRUNCATE is all-or-nothing; it can't filter rows.
--   Fix:    Use DELETE FROM students WHERE age > 20;
--
-- AUTO_INCREMENT resets
--   TRUNCATE restarts the counter, so the next insert gets
--   student_id = 1 again. DELETE keeps counting from where it was.
--
-- Can't undo with ROLLBACK
--   TRUNCATE is DDL and commits automatically in MySQL, so
--   ROLLBACK won't bring the rows back. DELETE inside a
--   transaction can be rolled back.
-- ============================================================