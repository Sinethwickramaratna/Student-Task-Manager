# Spring Security 6 + JWT Setup - Complete Guide

## ✅ What's Been Implemented

This server now has a **production-ready** Spring Security 6 + JWT setup with:

- ✅ **Three Roles**: Admin, Teacher, Student
- ✅ **JWT Authentication**: Token-based (no sessions)
- ✅ **@PreAuthorize**: Method-level security with roles
- ✅ **Role-based API Protection**: Different endpoints for each role
- ✅ **Custom UserDetailsService**: Loads users from database
- ✅ **BCrypt Password Encoding**: Secure password hashing

---

## 🗄️ Database Setup

### 1. Create Roles Table
```sql
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- Insert the three required roles
INSERT INTO roles (role_name) VALUES
('ROLE_Admin'),
('ROLE_Teacher'),
('ROLE_Student');
```

### 2. Update Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_name VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- BCrypt hash
    created_at DATE DEFAULT CURRENT_DATE,
    last_login DATE,
    role_id UUID NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);
```

### 3. Insert Sample User
```sql
INSERT INTO users (user_name, email, password, role_id)
VALUES (
    'admin1',
    'admin@mail.com',
    '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM', -- password: admin123
    (SELECT id FROM roles WHERE role_name = 'ROLE_Admin')
);

INSERT INTO users (user_name, email, password, role_id)
VALUES (
    'teacher1',
    'teacher@mail.com',
    '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM', -- password: admin123
    (SELECT id FROM roles WHERE role_name = 'ROLE_Teacher')
);

INSERT INTO users (user_name, email, password, role_id)
VALUES (
    'student1',
    'student@mail.com',
    '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM', -- password: admin123
    (SELECT id FROM roles WHERE role_name = 'ROLE_Student')
);
```

> **Note**: Password hash above is for `admin123`. Generate your own using BCrypt.

---

## 🔑 Environment Variables

Add to your `.env` file or system environment:

```bash
SECRET_KEY=your-very-long-secret-key-at-least-32-characters-long-for-hs256
DB_HOST=localhost:5432
DB_NAME=your_database_name
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

---

## 📡 API Endpoints

### 1. **Auth Endpoints** (Public)

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username_email": "admin1",
  "password": "admin123"
}

RESPONSE:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "username": "admin1",
    "email": "admin@mail.com",
    "role": "ROLE_Admin"
  }
}
```

#### Logout
```
POST /api/auth/logout
Authorization: Bearer <token>
```

---

### 2. **Admin Endpoints** (Requires Admin Role)

```
GET    /api/admin/dashboard
GET    /api/admin/users
POST   /api/admin/users
PUT    /api/admin/users/{id}
DELETE /api/admin/users/{id}
Authorization: Bearer <admin-token>
```

---

### 3. **Teacher Endpoints** (Requires Teacher Role)

```
GET    /api/teacher/dashboard
GET    /api/teacher/tasks
POST   /api/teacher/tasks
PUT    /api/teacher/tasks/{id}
DELETE /api/teacher/tasks/{id}
Authorization: Bearer <teacher-token>
```

---

### 4. **Student Endpoints** (Requires Student Role)

```
GET    /api/student/dashboard
GET    /api/student/tasks
PUT    /api/student/tasks/{id}
Authorization: Bearer <student-token>
```

---

## 🔐 Role Convention (CRITICAL)

### Database Storage
```sql
ROLE_Admin
ROLE_Teacher
ROLE_Student
```

### Code Usage (@PreAuthorize)
```java
@PreAuthorize("hasRole('Admin')")      // ✅ Correct
@PreAuthorize("hasRole('ROLE_Admin')") // ❌ Wrong - Spring strips ROLE_
```

### UserPrincipal Storage
```java
// Stores FULL name with prefix
new SimpleGrantedAuthority("ROLE_Admin")
```

---

## 🛠️ Testing with Postman/cURL

### 1. Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username_email": "admin1",
    "password": "admin123"
  }'
```

### 2. Access Protected Endpoint
```bash
curl -X GET http://localhost:8080/api/admin/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🐛 Troubleshooting

### Common Issues

**1. "JWT signature does not match"**
- Check that `SECRET_KEY` is the same key used to generate the token
- Ensure key is at least 32 characters for HS256

**2. "Access Denied" even with valid token**
- Check user's role in database
- Verify role name has `ROLE_` prefix
- Check `@PreAuthorize` annotation on controller

**3. "Cannot load UserDetailsService"**
- Ensure `CustomUserDetailsService` is annotated with `@Service`
- Check database connection and user table structure

**4. Database connection fails**
- Verify PostgreSQL is running
- Check database credentials in environment variables
- Ensure database exists

---

## 🎯 Key Files

| File | Purpose |
|------|---------|
| `SecurityConfig.java` | Spring Security 6 configuration |
| `JwtAuthFilter.java` | Validates JWT on every request |
| `JwtUtil.java` | JWT token generation/validation |
| `CustomUserDetailsService.java` | Loads users from database |
| `UserPrincipal.java` | Spring Security UserDetails implementation |
| `application.properties` | Database and JWT configuration |

---

## 📖 Additional Resources

- [Spring Security 6 Documentation](https://docs.spring.io/spring-security/reference/index.html)
- [JWT.io](https://jwt.io/) - JWT Debugger
- [BCrypt Generator](https://bcrypt-generator.com/) - Generate password hashes

---

## ✅ Verification Checklist

- [ ] Database tables created (roles, users)
- [ ] Sample users inserted
- [ ] Environment variables configured
- [ ] Application starts without errors
- [ ] Can login and receive JWT token
- [ ] Can access role-specific endpoints with token
- [ ] Role-based access control working correctly
