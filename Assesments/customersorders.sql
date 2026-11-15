-- ============================================================
-- Exercise: Match Customers to Their Orders with INNER JOIN
--           (SQL Lab · Easy · Joins (Inner, Left, Right))
--
-- Question:
--   INNER JOIN returns only rows that have a match in both
--   tables — a customer with no orders, or an order with no
--   matching customer, is left out entirely.
--   Farhan hasn't placed any orders yet. List only customers
--   alongside their actual orders.
--   Select customers.name, orders.order_id, and orders.amount,
--   joining customers to orders on customer_id, ordered by
--   orders.order_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] c and o are table aliases (short names).
--    ON links each order to its customer through customer_id.
--    INNER JOIN keeps only customers who have orders,
--    so Farhan does not appear.
SELECT c.name,
       o.order_id,
       o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Table aliases
--   customers AS c -> write c.name instead of customers.name.
--   AS is optional here too: FROM customers c
--
-- Ambiguous column (Error 1052)
--   ON customer_id = customer_id  -> both tables have it.
--   Always prefix: c.customer_id = o.customer_id
--
-- Customers with several orders
--   They appear once per order (one row per match).
--
-- Showing Farhan too
--   Use LEFT JOIN: every customer, NULL order columns for Farhan.
--   FROM customers AS c LEFT JOIN orders AS o ON ...
--
-- Finding customers with no orders (Farhan only)
--   LEFT JOIN ... WHERE o.order_id IS NULL
--
-- JOIN is the same as INNER JOIN
--   FROM customers c JOIN orders o ON ...  (INNER is the default)
--
-- Missing ON
--   INNER JOIN without ON in MySQL gives every customer paired
--   with every order (cross join) -> far too many rows.
-- ============================================================