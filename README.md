
# Student Task Management

Student Task Management is a full-stack app with a Flutter client and a Spring Boot backend secured by JWT. It supports role-based access for Admin, Teacher, and Student users.

## Features

- JWT authentication with role-based access control
- Admin, Teacher, and Student dashboards
- Secure password hashing with BCrypt
- Flutter client integration and role-based navigation
- PostgreSQL database with roles and users

## Tech Stack

- Client: Flutter (Dart)
- Server: Spring Boot (Java 17, Spring Security 6)
- Database: PostgreSQL
- Build tools: Gradle (Android), Maven (Server)

## Repository Structure

```
client/   Flutter app
server/   Spring Boot API
Database.sql, DATABASE_SETUP.sql  Database scripts
```

## Prerequisites

- Flutter SDK
- Java 17+
- Maven 3.6+
- PostgreSQL 12+

## Quick Start

### 1) Database setup

Run the SQL script in the project root:

```sql
-- Use one of these scripts depending on your needs
-- DATABASE_SETUP.sql is the recommended full setup
```

### 2) Server setup

Create a .env file in the project root:

```env
SECRET_KEY=your-very-long-secret-key-at-least-32-characters-long-for-hs256
DB_HOST=localhost:5432
DB_NAME=student_task_db
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

Build and run the server:

```bash
cd server
mvn clean install
mvn spring-boot:run
```

The API starts on http://localhost:8080

### 3) Client setup

```bash
cd client
flutter pub get
flutter run
```

Update your API base URL in the Flutter client for your emulator or device. See the integration guide for details.

## Test Credentials

After running DATABASE_SETUP.sql:

| Username | Email | Password | Role |
|---|---|---|---|
| admin1 | admin@mail.com | admin123 | Admin |
| teacher1 | teacher@mail.com | admin123 | Teacher |
| student1 | student@mail.com | admin123 | Student |

## API Overview

Public endpoints:

- POST /api/auth/login
- POST /api/auth/logout

Role-protected endpoints:

- GET /api/admin/dashboard
- GET /api/teacher/dashboard
- GET /api/teacher/tasks
- GET /api/student/dashboard
- GET /api/student/tasks

## Documentation

- Flutter integration: FLUTTER_INTEGRATION.md
- Security setup: server/SECURITY_SETUP.md
- Security implementation: server/SECURITY_IMPLEMENTATION.md
- Server recovery details: server/README.md

## Notes

- JWT roles use ROLE_ prefix in the database and authorities.
- For production, change default credentials and rotate the JWT secret.

