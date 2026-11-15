-- ============================================================
-- Exercise: Delete a Cancelled Order
--           (SQL Lab · Easy · Delete Practical)
--
-- Question:
--   Practice the DELETE syntax hands-on with a small orders table.
--   Remove a single cancelled order: delete the order with
--   order_id 2. Return all remaining rows ordered by order_id.
--
-- Command types used:
--   DML : DELETE -> change data (remove rows)
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DML] Remove only the row where order_id = 2.
DELETE FROM orders
WHERE order_id = 2;

-- 2. [DQL] Return the remaining rows, sorted by order_id.
SELECT * FROM orders
ORDER BY order_id;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Forgetting WHERE
--   Wrote:  DELETE FROM orders;
--   Why:    Without WHERE, EVERY row is deleted.
--   Note:   Workbench's safe update mode blocks this (Error 1175).
--
-- Writing column names after DELETE
--   Wrote:  DELETE order_id FROM orders WHERE order_id = 2;
--   Why:    DELETE removes whole rows, not single columns -> error.
--   Fix:    DELETE FROM orders WHERE order_id = 2;
--           (To clear one value instead, use UPDATE ... SET col = NULL)
--
-- DELETE vs TRUNCATE vs DROP
--   DELETE FROM orders WHERE ...;  -> removes chosen rows
--   TRUNCATE TABLE orders;         -> removes all rows, keeps table
--   DROP TABLE orders;             -> removes the whole table
--
-- Undoing a DELETE
--   Inside a transaction, ROLLBACK brings the row back:
--   START TRANSACTION;
--   DELETE FROM orders WHERE order_id = 2;
--   ROLLBACK;  -- order 2 is restored
-- ============================================================