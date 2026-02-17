-- ============================================
-- Student Task Management - Database Setup
-- ============================================
-- Run this script on your PostgreSQL database
-- Make sure to adjust credentials if needed

-- ============================================
-- 1. CREATE ROLES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert the three required roles
INSERT INTO roles (role_name) VALUES ('ROLE_Admin')
ON CONFLICT (role_name) DO NOTHING;

INSERT INTO roles (role_name) VALUES ('ROLE_Teacher')
ON CONFLICT (role_name) DO NOTHING;

INSERT INTO roles (role_name) VALUES ('ROLE_Student')
ON CONFLICT (role_name) DO NOTHING;

-- ============================================
-- 2. UPDATE/CREATE USERS TABLE
-- ============================================
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_name VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at DATE DEFAULT CURRENT_DATE,
    last_login DATE,
    role_id UUID NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- ============================================
-- 3. CREATE INDEX FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_users_username ON users(user_name);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);

-- ============================================
-- 4. INSERT SAMPLE USERS
-- ============================================
-- Note: Password hashes are for "admin123"
-- Generate your own: Use BCryptPasswordEncoder in Spring

-- Admin User
INSERT INTO users (user_name, email, password, role_id)
VALUES (
    'admin1',
    'admin@mail.com',
    '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM',
    (SELECT id FROM roles WHERE role_name = 'ROLE_Admin')
)
ON CONFLICT (user_name) DO NOTHING;

-- Teacher User
INSERT INTO users (user_name, email, password, role_id)
VALUES (
    'teacher1',
    'teacher@mail.com',
    '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM',
    (SELECT id FROM roles WHERE role_name = 'ROLE_Teacher')
)
ON CONFLICT (user_name) DO NOTHING;

-- Student User
INSERT INTO users (user_name, email, password, role_id)
VALUES (
    'student1',
    'student@mail.com',
    '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM',
    (SELECT id FROM roles WHERE role_name = 'ROLE_Student')
)
ON CONFLICT (user_name) DO NOTHING;

-- ============================================
-- 5. VERIFY DATA
-- ============================================
SELECT 'Roles Created:' AS info;
SELECT id, role_name FROM roles ORDER BY role_name;

SELECT '' AS spacer;
SELECT 'Users Created:' AS info;
SELECT u.id, u.user_name, u.email, r.role_name FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY u.user_name;

-- ============================================
-- NOTES:
-- ============================================
-- Login credentials:
-- Username: admin1, Password: admin123, Role: Admin
-- Username: teacher1, Password: admin123, Role: Teacher
-- Username: student1, Password: admin123, Role: Student
--
-- To generate new BCrypt hashes, use:
-- On Java: new BCryptPasswordEncoder().encode("your-password")
-- Online: https://bcrypt-generator.com/
