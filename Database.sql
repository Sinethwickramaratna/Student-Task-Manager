CREATE ROLE admin_role;
CREATE ROLE teacher_role;
CREATE ROLE student_role;

CREATE TYPE gender_type AS ENUM('Male','Female');

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(50),
    entity_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	role_name VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE users(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	user_name VARCHAR(50) UNIQUE NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	password VARCHAR(255) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	last_login TIMESTAMP DEFAULT NULL,
	role_id UUID NOT NULL,

	CONSTRAINT fk_users_role
		FOREIGN KEY(role_id)
		REFERENCES roles(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE teachers(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	f_name VARCHAR(50) NOT NULL,
	l_name VARCHAR(50) NOT NULL,
	gender gender_type NOT NULL,
	birthdate DATE NOT NULL,
	user_id UUID UNIQUE,
	profile_picture VARCHAR(255) DEFAULT NULL,

	CONSTRAINT fk_teachers_user
		FOREIGN KEY(user_id)
		REFERENCES users(id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

CREATE TABLE classes(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	class_name VARCHAR(20) NOT NULL,
	grade INT NOT NULL 
);

CREATE TABLE assigned_classes(
	class_id UUID,
	teacher_id UUID,
	assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT pk_assigned_classes PRIMARY KEY(class_id, teacher_id),

	CONSTRAINT fk_teachers_assigned_class
		FOREIGN KEY(teacher_id)
		REFERENCES teachers(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT fk_assigned_class
		FOREIGN KEY(class_id)
		REFERENCES classes(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE students(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	f_name VARCHAR(50) NOT NULL,
	l_name VARCHAR(50) NOT NULL,
	gender gender_type NOT NULL,
	birthdate DATE NOT NULL,
	class_id UUID NOT NULL,
	user_id UUID UNIQUE,
	profile_picture VARCHAR(255) DEFAULT NULL,

	CONSTRAINT fk_students_class
		FOREIGN KEY(class_id)
		REFERENCES classes(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT fk_students_user
		FOREIGN KEY(user_id)
		REFERENCES users(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE tasks(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	title VARCHAR(100),
	description TEXT,
	deadline DATE NOT NULL,
	class_id UUID NULL,
	teacher_id UUID NOT NULL,
	assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT fk_tasks_class
		FOREIGN KEY(class_id)
		REFERENCES classes(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT fk_tasks_teacher
		FOREIGN KEY(teacher_id)
		REFERENCES teachers(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE assigned_tasks(
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	student_id UUID NOT NULL,
	task_id UUID NOT NULL,
	completed BOOL DEFAULT FALSE,
	completed_date TIMESTAMP DEFAULT NULL,

	CONSTRAINT uq_student_task UNIQUE (student_id, task_id),

	CONSTRAINT fk_assigned_tasks_student
		FOREIGN KEY(student_id)
		REFERENCES students(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT fk_assigned_tasks_task
		FOREIGN KEY(task_id)
		REFERENCES tasks(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

-- Users
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_name ON users(user_name);

-- Teachers
CREATE INDEX idx_teachers_full_name ON teachers(f_name, l_name);

-- Classes
CREATE INDEX idx_classes_grade_class ON classes(grade, class_name);

-- Students
CREATE INDEX idx_students_full_name ON students(l_name,f_name);
CREATE INDEX idx_students_class ON students(class_id);
CREATE INDEX idx_students_class_gender ON students(class_id, gender);

-- Tasks
CREATE INDEX idx_tasks_title ON tasks(title);
CREATE INDEX idx_tasks_teacher ON tasks(teacher_id);

-- Assigned Tasks
CREATE INDEX idx_assigned_tasks_student_completed	ON assigned_tasks(student_id, completed);
CREATE INDEX idx_assigned_tasks_task_completed	ON assigned_tasks(task_id, completed);

-- Audit Logs
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_time ON audit_logs(created_at);

CREATE OR REPLACE FUNCTION check_class_capacity()
RETURNS TRIGGER AS $$
DECLARE
	male_count INT;
	female_count INT;
BEGIN
	IF TG_OP = 'UPDATE' AND OLD.class_id = NEW.class_id THEN
		RETURN NEW;
	END IF;
	SELECT 
		COUNT(*) FILTER (WHERE gender = 'Male'),
		COUNT(*) FILTER (WHERE gender = 'Female')
	INTO male_count, female_count
	FROM students
	WHERE class_id = NEW.class_id;
	
	IF NEW.gender='Male' AND male_count >=30 THEN
		RAISE EXCEPTION 'Class % already has 30 male students', NEW.class_id;
	ELSIF NEW.gender = 'Female' AND female_count >=20 THEN
		RAISE EXCEPTION 'Class % already has 20 female students', NEW.class_id;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_age(birthdate DATE)
RETURNS INT AS $$
BEGIN
	RETURN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate))::INT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID AS $$
BEGIN
	RETURN current_setting('app.current_user_id')::UUID;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION assign_task_to_class_students()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO assigned_tasks (student_id, task_id)
	SELECT
		s.id,
		NEW.id
	FROM students s
	JOIN teachers t ON t.id = NEW.teacher_id
	WHERE s.class_id = NEW.class_id
		AND t.user_id = current_user_id();

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assign_task_to_class
AFTER INSERT ON tasks
FOR EACH ROW
WHEN (NEW.class_id IS NOT NULL)
EXECUTE FUNCTION assign_task_to_class_students();

CREATE TRIGGER trg_check_class_capacity
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW 
EXECUTE FUNCTION check_class_capacity();

ALTER TABLE assigned_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE assigned_classes ENABLE ROW LEVEL SECURITY;


CREATE POLICY student_can_view_self
ON students
FOR SELECT
TO student_role
USING (
	user_id = current_user_id()
);

CREATE POLICY student_can_view_class_tasks
ON TASKS
FOR SELECT
TO student_role
USING(
	class_id = (
		SELECT class_id
		FROM students
		WHERE user_id = current_user_id()
	)
);

CREATE POLICY student_can_view_own_assigned_tasks
ON assigned_tasks
FOR SELECT
TO student_role
USING(
	student_id = (
		SELECT id
		FROM students
		WHERE user_id = current_user_id()
	)
);

CREATE POLICY student_can_update_own_task_status
ON assigned_tasks
FOR UPDATE
TO student_role
USING(
	student_id = (
		SELECT id
		FROM students
		WHERE user_id =  current_user_id()
	)
)
WITH CHECK(
	student_id = (
		SELECT id
		FROM students
		WHERE user_id = current_user_id()
	)
);

CREATE POLICY students_can_see_their_own_class_students
ON students
FOR SELECT 
TO student_role
USING(
	id IN(
		SELECT id
		FROM students s
		WHERE s.class_id = (
			SELECT id
			FROM students s1
			WHERE s1.user_id = current_user_id()
		)
	)
);

CREATE POLICY students_can_see_class_assigned_teachers
ON teachers
FOR SELECT
TO student_role
USING(
	id IN (
		SELECT ac.teacher_id
		FROM assigned_classes ac
		JOIN students s ON s.class_id = ac.class_id
		WHERE s.user_id = current_user_id()
	)
);

CREATE POLICY teacher_can_view_own_class_students
ON students
FOR SELECT
TO teacher_role
USING(
	class_id IN (
		SELECT ac.class_id
		FROM assigned_classes ac
		JOIN teachers t ON t.id = ac.teacher_id
		WHERE t.user_id = current_user_id()
	)
);

CREATE POLICY teacher_can_view_own_class_tasks
ON tasks
FOR SELECT
TO teacher_role
USING(
	class_id IN (
		SELECT ac.class_id
		FROM assigned_classes ac
		JOIN teachers t ON t.id = ac.teacher_id
		WHERE t.user_id = current_user_id()
	)
);

CREATE POLICY teacher_can_insert_tasks_for_own_classes
ON tasks
FOR INSERT
TO teacher_role
WITH CHECK(
	class_id IN (
		SELECT ac.class_id
		FROM assigned_classes ac
		JOIN teachers t ON t.id = ac.teacher_id
		WHERE t.user_id = current_user_id()
	)
);

CREATE POLICY teacher_can_assign_tasks
ON tasks
FOR INSERT
TO teacher_role
WITH CHECK(
	teacher_id = (
		SELECT id
		FROM teachers
		WHERE user_id = current_user_id()
	) AND id IN(
		SELECT id FROM tasks WHERE teacher_id = (
			SELECT id FROM teachers WHERE user_id = current_user_id()
		)
	)
);

CREATE POLICY teacher_can_view_own_classes
ON classes
FOR SELECT
TO teacher_role
USING (
	id IN (
		SELECT ac.class_id
		FROM assigned_classes ac
		JOIN teachers t ON t.id = ac.teacher_id
		WHERE t.user_id = current_user_id()
	)
);


CREATE OR REPLACE VIEW teacher_classes_view AS
SELECT
	c.id AS class_id,
	c.class_name,
	c.grade,
	ac.assigned_at
FROM classes c
JOIN assigned_classes ac ON c.id = ac.class_id
JOIN teachers t ON ac.teacher_id = t.id
WHERE t.user_id = current_user_id();

CREATE OR REPLACE VIEW teacher_class_students_view AS
SELECT
	s.id AS student_id,
	s.f_name,
	s.l_name,
	s.gender,
	s.birthdate,
	s.class_id,
	c.class_name,
	c.grade
FROM students s
JOIN classes c ON s.class_id = c.id
JOIN assigned_classes ac ON c.id = ac.class_id
JOIN teachers t ON ac.teacher_id = t.id
WHERE t.user_id = current_user_id();

CREATE OR REPLACE VIEW teacher_class_tasks_view AS
SELECT
	t.id AS task_id,
	t.title,
	t.description,
	t.deadline,
	t.assigned_date,
	t.class_id,
	c.class_name,
	t.teacher_id
FROM tasks t
JOIN classes c ON t.class_id = c.id
JOIN assigned_classes ac ON c.id = ac.class_id
JOIN teachers th ON ac.teacher_id = th.id
WHERE th.user_id = current_user_id();

CREATE OR REPLACE VIEW teacher_dashboard_view AS
SELECT
    t.id AS teacher_id,
    t.f_name,
    t.l_name,
    t.profile_picture,
    c.id AS class_id,
    c.class_name,
    c.grade,
    
    -- Overall class metrics
    COUNT(DISTINCT s.id) AS total_students,
    COUNT(DISTINCT ts.id) AS total_tasks,
    COUNT(DISTINCT at.id) FILTER (WHERE at.completed = TRUE) AS completed_tasks,
    COUNT(DISTINCT at.id) FILTER (WHERE at.completed = FALSE AND ts.deadline < CURRENT_DATE) AS overdue_tasks,
    
    -- Per-student progress aggregated as JSON
    JSON_AGG(
        JSON_BUILD_OBJECT(
            'student_id', s.id,
            'student_name', s.f_name || ' ' || s.l_name,
            'total_tasks', student_task.total_tasks,
            'completed_tasks', student_task.completed_tasks,
            'progress_percent', 
                CASE WHEN student_task.total_tasks > 0 THEN
                    ROUND((student_task.completed_tasks::DECIMAL / student_task.total_tasks) * 100, 2)
                ELSE 0
                END
        )
    ) AS students_progress,
    
    -- Class average completion %
    CASE WHEN COUNT(DISTINCT ts.id) > 0 THEN
        ROUND(
            (COUNT(DISTINCT at.id) FILTER (WHERE at.completed = TRUE)::DECIMAL / COUNT(DISTINCT ts.id)) * 100, 2
        )
    ELSE 0
    END AS class_average_completion_percent

FROM teachers t
JOIN assigned_classes ac ON t.id = ac.teacher_id
JOIN classes c ON ac.class_id = c.id
LEFT JOIN students s ON s.class_id = c.id
LEFT JOIN tasks ts ON ts.class_id = c.id
LEFT JOIN assigned_tasks at ON at.task_id = ts.id

-- Subquery for per-student total/completed tasks
LEFT JOIN LATERAL (
    SELECT 
        s2.id AS student_id,
        COUNT(at2.id) AS total_tasks,
        COUNT(at2.id) FILTER (WHERE at2.completed = TRUE) AS completed_tasks
    FROM students s2
    LEFT JOIN assigned_tasks at2 ON at2.student_id = s2.id
    LEFT JOIN tasks t2 ON t2.id = at2.task_id
    WHERE s2.class_id = c.id
    GROUP BY s2.id
) AS student_task ON student_task.student_id = s.id

WHERE t.user_id = current_user_id()
GROUP BY t.id, t.f_name, t.l_name, t.profile_picture, c.id, c.class_name, c.grade;


CREATE OR REPLACE VIEW student_classmates_view AS
SELECT
	s.id  AS student_id,
	s.f_name,
	s.l_name,
	s.gender,
	s.birthdate,
	s.class_id,
	c.class_name,
	c.grade
FROM students s
JOIN classes c ON s.class_id = c.id
WHERE s.class_id = (
	SELECT class_id
	FROM students
	WHERE user_id = current_user_id()
);

CREATE OR REPLACE VIEW student_class_teacher_view AS
SELECT
	t.id AS teacher_id,
	t.f_name,
	t.l_name,
	t.gender,
	t.birthdate
FROM teachers t
JOIN assigned_classes ac ON t.id = ac.teacher_id
JOIN students s ON ac.class_id = s.class_id
WHERE s.user_id = current_user_id();

CREATE OR REPLACE VIEW student_dashboard_view AS
SELECT
    s.id AS student_id,
    s.f_name,
    s.l_name,
    s.profile_picture,
    c.id AS class_id,
    c.class_name,
    c.grade,
    
    -- Task counts
    COUNT(DISTINCT at.id) AS total_tasks,
    COUNT(DISTINCT at.id) FILTER (WHERE at.completed = TRUE) AS completed_tasks,
    COUNT(DISTINCT at.id) FILTER (WHERE at.completed = FALSE AND t.deadline < CURRENT_DATE) AS overdue_tasks,
    
    -- Progress percentage
    CASE WHEN COUNT(DISTINCT at.id) > 0 THEN
        ROUND(
            (COUNT(DISTINCT at.id) FILTER (WHERE at.completed = TRUE)::DECIMAL / COUNT(DISTINCT at.id)) * 100, 2
        )
    ELSE 0
    END AS progress_percent,
    
    -- Class teachers
    STRING_AGG(DISTINCT te.f_name || ' ' || te.l_name, ', ') AS class_teachers

FROM students s
JOIN classes c ON s.class_id = c.id
LEFT JOIN assigned_tasks at ON at.student_id = s.id
LEFT JOIN tasks t ON t.id = at.task_id
LEFT JOIN assigned_classes ac ON ac.class_id = c.id
LEFT JOIN teachers te ON te.id = ac.teacher_id

WHERE s.user_id = current_user_id()

GROUP BY s.id, s.f_name, s.l_name, s.profile_picture, c.id, c.class_name, c.grade;


------- Admin Dashboard Views--------------------

CREATE OR REPLACE VIEW admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM teachers) AS total_teachers,
    (SELECT COUNT(*) FROM students) AS total_students,
    (SELECT COUNT(*) FROM classes) AS total_classes,
    (SELECT COUNT(*) FROM users WHERE last_login > CURRENT_TIMESTAMP - INTERVAL '1 day') AS active_users;

CREATE OR REPLACE VIEW admin_users_by_role AS
SELECT r.role_name, COUNT(u.id) AS count
FROM roles r
LEFT JOIN users u ON u.role_id = r.id
GROUP BY r.role_name;

CREATE OR REPLACE VIEW admin_students_by_grade AS
SELECT c.grade, COUNT(s.id) AS count
FROM classes c
LEFT JOIN students s ON s.class_id = c.id
GROUP BY c.grade
ORDER BY c.grade;

CREATE OR REPLACE VIEW admin_task_completion AS
SELECT
    COUNT(*) FILTER (WHERE completed = TRUE) AS completed,
    COUNT(*) FILTER (WHERE completed = FALSE) AS pending
FROM assigned_tasks;


-- ============================
-- Admin Role Grants
-- ============================

-- Tables: full access
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE users, teachers, students, classes, assigned_classes, tasks, assigned_tasks, roles TO admin_role;

-- Views: only SELECT makes sense for views
GRANT SELECT ON teacher_classes_view TO admin_role;
GRANT SELECT ON teacher_class_students_view TO admin_role;
GRANT SELECT ON teacher_class_tasks_view TO admin_role;
GRANT SELECT ON teacher_dashboard_view TO admin_role;
GRANT SELECT ON student_classmates_view TO admin_role;
GRANT SELECT ON student_class_teacher_view TO admin_role;
GRANT SELECT ON student_dashboard_view TO admin_role;

-- Functions
GRANT EXECUTE ON FUNCTION check_class_capacity() TO admin_role;
GRANT EXECUTE ON FUNCTION calculate_age(DATE) TO admin_role;
GRANT EXECUTE ON FUNCTION current_user_id() TO admin_role;
GRANT EXECUTE ON FUNCTION assign_task_to_class_students() TO admin_role;

-- ============================
-- Teacher Role Grants
-- ============================

-- Tables
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE students, classes, tasks, assigned_tasks, assigned_classes TO teacher_role;

-- Views
GRANT SELECT ON teacher_classes_view TO teacher_role;
GRANT SELECT ON teacher_class_students_view TO teacher_role;
GRANT SELECT ON teacher_class_tasks_view TO teacher_role;
GRANT SELECT ON teacher_dashboard_view TO teacher_role;

-- Functions
GRANT EXECUTE ON FUNCTION current_user_id() TO teacher_role;

-- ============================
-- Student Role Grants
-- ============================

-- Tables: students can select and update their own data
GRANT SELECT, UPDATE ON TABLE students, assigned_tasks TO student_role;
GRANT SELECT ON TABLE classes, teachers, tasks TO student_role;

-- Views
GRANT SELECT ON student_classmates_view TO student_role;
GRANT SELECT ON student_class_teacher_view TO student_role;
GRANT SELECT ON student_dashboard_view TO student_role;

-- Functions
GRANT EXECUTE ON FUNCTION current_user_id() TO student_role;



