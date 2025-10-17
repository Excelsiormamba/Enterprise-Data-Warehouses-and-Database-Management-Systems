-- departments (5)
INSERT INTO department (dept_code, dept_name) VALUES
('DPT-MATH','Department Math'),
('DPT-CS','Department Computer Science'),
('DPT-ENG','Department Engineering'),
('DPT-BUS','Department Business'),
('DPT-SCI','Department Science');

-- programs (5)
INSERT INTO program (program_code, program_name, department_id, duration_years) VALUES
('PRG-BSCS','BS Computer Science', 2, 4.0),
('PRG-BSENG','BS Engineering', 3, 4.0),
('PRG-BSBUS','BS Business', 4, 3.5),
('PRG-BSIT','BS Information Tech', 2, 4.0),
('PRG-MSDS','MS Data Science', 2, 1.5);

-- courses (8)
INSERT INTO course (course_code, title, credits, department_id) VALUES
('CS101','Intro to Computing',3.0,2),
('CS201','Data Structures',3.0,2),
('CS301','Databases',3.0,2),
('ENG101','Intro to Engineering',3.0,3),
('MATH101','Calculus I',4.0,1),
('BUS201','Principles of Management',3.0,4),
('DS501','Machine Learning',3.0,2),
('IT110','Networking Basics',2.5,2);

-- instructors (6)
INSERT INTO instructor (instructor_code, role, hire_date) VALUES
('INS-001','Professor','2018-09-01'),
('INS-002','Lecturer','2020-01-15'),
('INS-003','Assistant','2021-07-10'),
('INS-004','Professor','2015-03-20'),
('INS-005','Lecturer','2019-11-05'),
('INS-006','Adjunct','2024-02-01');

-- semester (3)
INSERT INTO semester (code, start_date, end_date) VALUES
('2025-S1','2025-01-10','2025-05-15'),
('2025-S2','2025-08-20','2025-12-15'),
('2024-S2','2024-08-20','2024-12-15');

-- classrooms (5)
INSERT INTO classroom (room_code, capacity) VALUES
('RM-101',40),
('RM-102',30),
('RM-201',60),
('LAB-01',25),
('LAB-02',20);

-- resources (5)
INSERT INTO resource (resource_code, description, quantity) VALUES
('RS-DB-SRV','Database Server',2),
('RS-LAB-PC','Lab PC',30),
('RS-PRJ','Projector',6),
('RS-NET-SW','Network Switch',4),
('RS-3DPRN','3D Printer',2);

-- program_course (program ⇄ course)
INSERT INTO program_course (program_id, course_id, is_required) VALUES
(1,1,TRUE), -- BSCS CS101
(1,2,TRUE), -- BSCS CS201
(1,3,TRUE),
(5,7,TRUE), -- MSDS DS501
(4,8,TRUE), -- BSIT IT110
(3,6,TRUE), -- BSBUS BUS201
(2,4,TRUE), -- BSENG ENG101
(1,5,FALSE); -- elective MATH101 for BSCS

-- course_prerequisite (course prerequisites)
INSERT INTO course_prerequisite (course_id, prerequisite_course_id) VALUES
(2,1), -- CS201 requires CS101
(3,2), -- CS301 requires CS201
(7,3), -- DS501 requires CS301
(8,1); -- IT110 requires CS101

-- course_resource (course uses resource)
INSERT INTO course_resource (course_id, resource_id, required_qty) VALUES
(3,1,1),  -- Databases uses DB Server
(3,3,1),  -- Projector
(1,2,1),  -- Intro to Computing uses some lab PCs
(7,1,1),  -- ML uses DB server
(7,2,5);  -- ML uses lab PCs

-- students (6)
INSERT INTO student (student_code, enrollment_year, status) VALUES
('STU-0001',2022,'active'),
('STU-0002',2023,'active'),
('STU-0003',2021,'active'),
('STU-0004',2024,'active'),
('STU-0005',2022,'inactive'),
('STU-0006',2020,'active');

-- advisors (4)
INSERT INTO advisor (advisor_code, department_id) VALUES
('ADV-001',2),
('ADV-002',1),
('ADV-003',3),
('ADV-004',4);

-- student_advisor assignments
INSERT INTO student_advisor (student_id, advisor_id, assigned_date) VALUES
(1,1,'2022-09-01'),
(2,1,'2023-09-01'),
(3,2,'2021-09-01'),
(4,3,'2024-09-01'),
(5,4,'2022-09-01'),
(6,1,'2020-09-01');

-- enrollments (student ⇄ course) — at least 8-10 rows
INSERT INTO enrollment (student_id, course_id, semester_id, enrollment_status, grade, credits_earned) VALUES
(1,1,1,'completed','A',3.0),
(1,2,2,'enrolled',NULL,0),
(2,1,1,'completed','B',3.0),
(3,5,1,'completed','A',4.0),
(4,1,2,'enrolled',NULL,0),
(5,6,1,'completed','C',3.0),
(6,3,3,'completed','B',3.0),
(2,3,3,'enrolled',NULL,0),
(1,3,3,'enrolled',NULL,0),
(4,8,2,'enrolled',NULL,0),
(7, 3, 1, 'completed', 'D', 0),
(8, 3, 1, 'completed', 'F', 0),
(9, 3, 1, 'completed', 'D', 0),
(10, 3, 1, 'completed', 'F', 0),
(11, 3, 1, 'completed', 'C', 3.0), 
(12, 3, 1, 'completed', 'F', 0),
(13, 3, 1, 'completed', 'D', 0),
(14, 3, 1, 'completed', 'F', 0),
(15, 4, 2, 'completed', 'B', 3.0), 
(16, 4, 2, 'completed', 'C', 3.0), 
(17, 4, 2, 'completed', 'D', 0),
(18, 4, 2, 'completed', 'F', 0),
(19, 4, 2, 'completed', 'D', 0);

-- instructor_assignment (who teaches what in semester)
INSERT INTO instructor_assignment (instructor_id, course_id, semester_id, role_in_course) VALUES
(1,1,1,'lead'),
(2,2,2,'lead'),
(1,3,3,'lead'),
(4,4,1,'lead'),
(5,6,1,'lead'),
(3,7,3,'co-lecturer');

-- schedules
INSERT INTO schedule (course_id, semester_id, classroom_id, day_of_week, start_time, end_time) VALUES
(1,1,1,'Mon','09:00:00','10:30:00'),
(2,2,2,'Tue','11:00:00','12:30:00'),
(3,3,3,'Wed','14:00:00','16:00:00'),
(7,3,4,'Thu','10:00:00','12:00:00'),
(8,2,5,'Fri','13:00:00','14:30:00');
