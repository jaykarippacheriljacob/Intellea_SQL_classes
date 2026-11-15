-- ============================================================
-- Exercise: Label Pass or Fail with CASE
--           (SQL Lab · Easy · Case Statement)
--
-- Question:
--   CASE WHEN condition THEN value ... END works like an if/else
--   chain inside a SELECT list; it evaluates conditions top to
--   bottom and returns the value of the first one that matches.
--   Label each student as Pass or Fail based on a 50-mark cutoff.
--   Select name, marks, and a CASE expression aliased as result
--   that returns 'Pass' when marks >= 50, and 'Fail' otherwise,
--   ordered by student_id.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] CASE checks each row: 50 or more -> 'Pass',
--    anything else -> 'Fail'. Then sort by student_id.
SELECT name,
       marks,
       CASE
           WHEN marks >= 50 THEN 'Pass'
           ELSE 'Fail'
       END AS result
FROM students
ORDER BY student_id;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Missing ORDER BY
--   Wrote:  ... FROM students;
--   Why:    Row order is not guaranteed without ORDER BY.
--   Fix:    ... FROM students ORDER BY student_id;
--
-- >= vs >
--   marks > 50  -> a student with exactly 50 would Fail
--   marks >= 50 -> 50 counts as Pass (what the task wants)
--
-- Forgetting END
--   CASE WHEN ... THEN ... ELSE ... AS result  -> error 1064
--   Every CASE must close with END before the alias.
--
-- Missing comma before CASE
--   SELECT name, marks CASE ...  -> error 1064
--   CASE is a column in the SELECT list, so it needs a comma.
--
-- NULL marks
--   NULL >= 50 is not TRUE, so NULL marks fall to ELSE -> 'Fail'.
--   To label them separately, check first:
--     WHEN marks IS NULL THEN 'Absent'
--
-- Without ELSE
--   Rows that match no WHEN get NULL as the result.
-- ============================================================