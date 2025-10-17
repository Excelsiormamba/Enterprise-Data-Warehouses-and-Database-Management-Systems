-- Query 1 — Multi-table JOIN + aggregation

SELECT
  p.program_code,
  p.program_name,
  COUNT(DISTINCT e.student_id) AS students_enrolled
FROM program p
JOIN program_course pc ON pc.program_id = p.program_id
JOIN course c ON c.course_id = pc.course_id
JOIN enrollment e ON e.course_id = c.course_id
JOIN student s ON s.student_id = e.student_id
WHERE s.status = 'active'
  AND e.enrollment_status IN ('enrolled','completed')
  AND e.enrolled_at >= CONCAT(YEAR(CURDATE()),'-01-01')
GROUP BY p.program_id, p.program_code, p.program_name
ORDER BY students_enrolled DESC;

-- Query 2 — GROUP BY + HAVING
SELECT 
    c.course_id,
    c.title,
    COUNT(e.student_id) AS total_enrollments,
    SUM(CASE WHEN e.grade IN ('A','B','C') THEN 1 ELSE 0 END) AS pass_count,
    ROUND(SUM(CASE WHEN e.grade IN ('A','B','C') THEN 1 ELSE 0 END) * 1.0 / COUNT(e.student_id), 2) AS pass_rate
FROM 
    course c
JOIN 
    enrollment e ON c.course_id = e.course_id
WHERE 
    e.enrollment_status = 'completed'
    AND e.grade IS NOT NULL
GROUP BY 
    c.course_id, c.title
HAVING 
    COUNT(e.student_id) >= 5
    AND (SUM(CASE WHEN e.grade IN ('A','B','C') THEN 1 ELSE 0 END) * 1.0 / COUNT(e.student_id)) < 0.6;




-- Query 3 — Non-correlated subquery

SELECT s.student_code, COALESCE(SUM(e.credits_earned),0) AS total_credits
FROM student s
LEFT JOIN enrollment e ON e.student_id = s.student_id
GROUP BY s.student_id, s.student_code
HAVING COALESCE(SUM(e.credits_earned),0) > (
  SELECT AVG(student_total) FROM (
    SELECT COALESCE(SUM(e2.credits_earned),0) AS student_total
    FROM student s2
    LEFT JOIN enrollment e2 ON e2.student_id = s2.student_id
    GROUP BY s2.student_id
  ) t
);


-- Query 4 — Correlated subquery

SELECT
  c.course_code,
  c.title,
  this_sem.count_current,
  hist.avg_historical,
  CASE WHEN this_sem.count_current > hist.avg_historical THEN 'above_avg' ELSE 'not_above' END AS compare_flag
FROM course c
LEFT JOIN (
  SELECT course_id, semester_id, COUNT(*) AS count_current
  FROM enrollment
  WHERE semester_id = (SELECT semester_id FROM semester WHERE code = '2025-S2') -- example target semester
  GROUP BY course_id, semester_id
) this_sem ON this_sem.course_id = c.course_id
LEFT JOIN (
  SELECT course_id, AVG(count_enrolled) AS avg_historical
  FROM (
    SELECT course_id, semester_id, COUNT(*) AS count_enrolled
    FROM enrollment
    GROUP BY course_id, semester_id
  ) x
  GROUP BY course_id
) hist ON hist.course_id = c.course_id;

-- Query 5 — Window functions (ranking/rolling)

WITH student_term_credits AS (
  SELECT
    s.student_id,
    s.student_code,
    sem.semester_id,
    sem.code    AS sem_code,
    sem.start_date,
    COALESCE(SUM(e.credits_earned), 0) AS credits_term
  FROM student s
  JOIN enrollment e ON e.student_id = s.student_id
  JOIN semester sem ON e.semester_id = sem.semester_id
  GROUP BY s.student_id, sem.semester_id, sem.code, sem.start_date
),
student_with_totals AS (
  SELECT
    student_id,
    student_code,
    sem_code,
    start_date,
    credits_term,
    -- 3-term rolling credits per student (current + 2 previous semesters by start_date)
    SUM(credits_term) OVER (
      PARTITION BY student_id
      ORDER BY start_date
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3term_credits,
    -- total credits per student (over all terms)
    SUM(credits_term) OVER (PARTITION BY student_id) AS total_credits
  FROM student_term_credits
)
SELECT
  student_id,
  student_code,
  sem_code,
  credits_term,
  rolling_3term_credits,
  total_credits,
  RANK() OVER (ORDER BY total_credits DESC) AS overall_rank
FROM student_with_totals
ORDER BY overall_rank, student_id, start_date;
