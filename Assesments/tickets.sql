-- ============================================================
-- Exercise: Find Unresolved Tickets
--           (SQL Lab · Easy · Is Null & Is Not Null)
--
-- Question:
--   A NULL means the value is missing or not yet set; it can't
--   be tested with =, only with IS NULL or IS NOT NULL.
--   An unresolved ticket is one where resolved_date has never
--   been filled in. Select ticket_id and subject for tickets
--   where resolved_date IS NULL, ordered by ticket_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] Keep only tickets with no resolved_date,
--    then sort by ticket_id (ASC is the default, so it's optional).
SELECT ticket_id, subject
FROM tickets
WHERE resolved_date IS NULL
ORDER BY ticket_id ASC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Using = with NULL
--   Wrote:  WHERE resolved_date = NULL
--   Why:    No error, but returns NO rows. NULL means "unknown",
--           so any comparison with it is never TRUE.
--   Fix:    WHERE resolved_date IS NULL
--
-- Resolved tickets (the opposite)
--   WHERE resolved_date IS NOT NULL
--
-- NULL is not the same as empty text or zero
--   ''  -> an empty string (a real value)
--   0   -> a real number
--   NULL -> no value at all
--
-- Quotes around NULL
--   WHERE resolved_date IS 'NULL'  -> error
--   NULL is a keyword, never in quotes.
-- ============================================================