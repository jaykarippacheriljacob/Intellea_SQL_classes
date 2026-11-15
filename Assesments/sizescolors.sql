-- ============================================================
-- Exercise: Generate Every Size-Color Combination with CROSS JOIN
--           (SQL Lab · Easy · Cross Join & Self Join)
--
-- Question:
--   CROSS JOIN pairs every row of one table with every row of
--   another — there's no ON condition, and the result has rows
--   equal to the product of both row counts.
--   The catalog needs every possible size and color combination
--   for a new t-shirt line, before deciding which combinations to
--   actually stock.
--   Select sizes.size_label and colors.color_name, CROSS JOINing
--   sizes and colors, ordered by sizes.size_label,
--   colors.color_name.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Every size paired with every color. No ON needed.
--    e.g. 4 sizes x 3 colors = 12 rows.
SELECT s.size_label,
       c.color_name
FROM sizes AS s
CROSS JOIN colors AS c
ORDER BY s.size_label, c.color_name;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Row count = rows in table 1 x rows in table 2
--   Large tables explode fast: 1,000 x 1,000 = 1,000,000 rows.
--
-- No ON clause
--   CROSS JOIN colors c ON ...  -> not how CROSS JOIN is meant
--   to be used; the point is "every pair".
--
-- Same result, older comma style
--   FROM sizes s, colors c        (comma = cross join)
--
-- Text sorting is alphabetical, not by size
--   size_label sorts as L, M, S, XL (letter order), not S, M, L, XL.
--   For real size order you'd need a sort column, or CASE:
--   ORDER BY CASE s.size_label
--                WHEN 'S' THEN 1 WHEN 'M' THEN 2
--                WHEN 'L' THEN 3 WHEN 'XL' THEN 4 END,
--            c.color_name;
--
-- Accidental cross join
--   An INNER JOIN with its ON missing also pairs every row with
--   every row. If a JOIN returns far too many rows, check the ON.
-- ============================================================