-- DROP existing to allow re-run
DROP TABLE IF EXISTS student_advisor, student, advisor, course_resource, resource, course_prerequisite, program_course, instructor_assignment, enrollment, schedule, classroom, semester, instructor, course, program, department;

-- department
CREATE TABLE department (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_code VARCHAR(20) NOT NULL UNIQUE,
  dept_name VARCHAR(100) NOT NULL
);

-- program
CREATE TABLE program (
  program_id INT AUTO_INCREMENT PRIMARY KEY,
  program_code VARCHAR(30) NOT NULL UNIQUE,
  program_name VARCHAR(150) NOT NULL,
  department_id INT,
  duration_years DECIMAL(3,1),
  FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- course
CREATE TABLE course (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  course_code VARCHAR(20) NOT NULL UNIQUE,
  title VARCHAR(200) NOT NULL,
  credits DECIMAL(3,1) NOT NULL,
  department_id INT,
  active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (department_id) REFERENCES department(department_id)
);
CREATE INDEX idx_course_code ON course(course_code);

-- instructor
CREATE TABLE instructor (
  instructor_id INT AUTO_INCREMENT PRIMARY KEY,
  instructor_code VARCHAR(30) NOT NULL UNIQUE,
  role VARCHAR(50),
  hire_date DATE
);

-- semester
CREATE TABLE semester (
  semester_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE, -- e.g., 2025-S1
  start_date DATE,
  end_date DATE
);

-- classroom
CREATE TABLE classroom (
  classroom_id INT AUTO_INCREMENT PRIMARY KEY,
  room_code VARCHAR(50) NOT NULL UNIQUE,
  capacity INT
);

-- resource (lab/equipment)
CREATE TABLE resource (
  resource_id INT AUTO_INCREMENT PRIMARY KEY,
  resource_code VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255),
  quantity INT DEFAULT 1
);

-- program_course (program ⇄ course, M:N)
CREATE TABLE program_course (
  program_id INT NOT NULL,
  course_id INT NOT NULL,
  is_required BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (program_id, course_id),
  FOREIGN KEY (program_id) REFERENCES program(program_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
);

-- course_prerequisite (course ⇄ course, M:N self)
CREATE TABLE course_prerequisite (
  course_id INT NOT NULL,
  prerequisite_course_id INT NOT NULL,
  PRIMARY KEY (course_id, prerequisite_course_id),
  FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
  FOREIGN KEY (prerequisite_course_id) REFERENCES course(course_id) ON DELETE CASCADE
);

-- course_resource (course ⇄ resource, M:N)
CREATE TABLE course_resource (
  course_id INT NOT NULL,
  resource_id INT NOT NULL,
  required_qty INT NOT NULL DEFAULT 1,
  PRIMARY KEY (course_id, resource_id),
  FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
  FOREIGN KEY (resource_id) REFERENCES resource(resource_id) ON DELETE CASCADE
);

-- student
CREATE TABLE student (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  student_code VARCHAR(30) NOT NULL UNIQUE, -- e.g., STU-0001
  enrollment_year YEAR,
  status VARCHAR(30) DEFAULT 'active'
);

-- advisor
CREATE TABLE advisor (
  advisor_id INT AUTO_INCREMENT PRIMARY KEY,
  advisor_code VARCHAR(30) NOT NULL UNIQUE,
  department_id INT,
  FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- student_advisor (student ⇄ advisor, M:N)
CREATE TABLE student_advisor (
  student_id INT NOT NULL,
  advisor_id INT NOT NULL,
  assigned_date DATE,
  PRIMARY KEY (student_id, advisor_id),
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
  FOREIGN KEY (advisor_id) REFERENCES advisor(advisor_id) ON DELETE CASCADE
);

-- enrollment (student ⇄ course, M:N)
CREATE TABLE enrollment (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  semester_id INT NOT NULL,
  enrollment_status VARCHAR(30) DEFAULT 'enrolled',
  grade VARCHAR(10), -- letter grade or NULL
  credits_earned DECIMAL(4,1) DEFAULT 0,
  enrolled_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
  FOREIGN KEY (semester_id) REFERENCES semester(semester_id)
);
CREATE INDEX idx_enrollment_student ON enrollment(student_id);
CREATE INDEX idx_enrollment_course_sem ON enrollment(course_id, semester_id);

-- instructor_assignment (instructor ⇄ course for a semester) M:N
CREATE TABLE instructor_assignment (
  assignment_id INT AUTO_INCREMENT PRIMARY KEY,
  instructor_id INT NOT NULL,
  course_id INT NOT NULL,
  semester_id INT NOT NULL,
  role_in_course VARCHAR(50), -- e.g., lead, co-lecturer, TA
  FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id),
  FOREIGN KEY (course_id) REFERENCES course(course_id),
  FOREIGN KEY (semester_id) REFERENCES semester(semester_id)
);
CREATE INDEX idx_instructor_assignment ON instructor_assignment(instructor_id, semester_id);

-- schedule (course offering scheduled in classroom at time)
CREATE TABLE schedule (
  schedule_id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  semester_id INT NOT NULL,
  classroom_id INT NOT NULL,
  day_of_week ENUM('Mon','Tue','Wed','Thu','Fri','Sat','Sun') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  FOREIGN KEY (course_id) REFERENCES course(course_id),
  FOREIGN KEY (semester_id) REFERENCES semester(semester_id),
  FOREIGN KEY (classroom_id) REFERENCES classroom(classroom_id)
);

-- indexes to help common analytics
CREATE INDEX idx_course_department ON course(department_id);
CREATE INDEX idx_program_department ON program(department_id);
