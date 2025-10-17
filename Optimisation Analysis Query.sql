-- unoptimised query --
-- Naive baseline
EXPLAIN FORMAT=JSON

SELECT 
    c.course_id,
    c.course_code,
    c.title,
    COUNT(e.enrollment_id) AS total_enrollments,
    SUM(CASE WHEN e.grade IN ('A','B','C') THEN 1 ELSE 0 END) AS pass_count,
    ROUND(SUM(CASE WHEN e.grade IN ('A','B','C') THEN 1 ELSE 0 END) * 1.0 / COUNT(e.enrollment_id), 2) AS pass_rate
FROM 
    course c
JOIN 
    enrollment e ON c.course_id = e.course_id
WHERE 
    e.enrollment_status = 'completed'
    AND e.grade IS NOT NULL
GROUP BY 
    c.course_id, c.course_code, c.title
HAVING 
    COUNT(e.enrollment_id) >= 5
    AND (SUM(CASE WHEN e.grade IN ('A','B','C') THEN 1 ELSE 0 END) * 1.0 / COUNT(e.enrollment_id)) < 0.6;



-- Optimised Query --
EXPLAIN FORMAT=JSON
SELECT
  c.course_id,
  c.course_code,
  c.title,
  t.total_enrollments,
  t.pass_count,
  ROUND(t.pass_count * 1.0 / t.total_enrollments, 2) AS pass_rate
FROM course c
JOIN (
  SELECT course_id,
         COUNT(*) AS total_enrollments,
         SUM(CASE WHEN grade IN ('A','B','C') THEN 1 ELSE 0 END) AS pass_count
  FROM enrollment
  WHERE enrollment_status = 'completed' AND grade IS NOT NULL
  GROUP BY course_id
) t ON t.course_id = c.course_id
WHERE t.total_enrollments >= 5 AND (t.pass_count * 1.0 / t.total_enrollments) < 0.6;
