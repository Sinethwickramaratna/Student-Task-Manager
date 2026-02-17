# Recovered Spring Boot Server

This directory contains the **recovered Java source code** from the compiled JAR file.

## 📁 Recovery Details

All files were recovered from the compiled JAR using CFR (Class File Reader) decompiler on **February 13, 2026**.

### ✅ Recovered Files

**Total: 22 Java Source Files + Configuration Files**

#### Source Code Structure:
```
src/main/java/com/sineth/server/
├── ServerApplication.java          # Main application entry point
├── config/
│   ├── CorsConfig.java            # CORS configuration
│   ├── EnvConfig.java             # Environment variable loader
│   └── SecurityConfig.java        # Spring Security 6 + JWT setup
├── controller/
│   ├── AdminDashboardController.java
│   ├── AdminUserController.java
│   ├── AuthController.java        # Login/Logout endpoints
│   ├── StudentController.java
│   └── TeacherController.java
├── dao/
│   ├── AdminDashboardDao.java
│   ├── RoleDao.java
│   └── UserDao.java
├── dto/
│   ├── LoginRequest.java
│   └── UserResponse.java
├── model/
│   ├── Role.java                  # JPA Entity
│   └── User.java                  # JPA Entity
├── security/
│   ├── CustomUserDetailsService.java
│   ├── JwtAuthFilter.java         # JWT validation filter
│   ├── JwtUtil.java               # JWT utility methods
│   └── UserPrincipal.java         # UserDetails implementation
└── service/
    ├── AdminDashboardService.java
    └── AdminUserService.java
```

#### Configuration Files:
```
src/main/resources/
└── application.properties          # Database and JWT configuration

pom.xml                             # Maven dependencies
.gitignore                          # Git ignore rules
HELP.md                             # Spring Boot reference docs
SECURITY_SETUP.md                   # Complete security setup guide
SECURITY_IMPLEMENTATION.md          # Implementation details
```

---

## 🚀 How to Use

### 1. Prerequisites
- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+

### 2. Database Setup
Run the `Database.sql` script from the project root to create all required tables.

### 3. Configure Environment
Create a `.env` file in the project root:
```env
SECRET_KEY=your-very-long-secret-key-at-least-32-characters-long-for-hs256
DB_HOST=localhost:5432
DB_NAME=student_task_db
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

### 4. Build and Run
```bash
# Install dependencies
mvn clean install

# Run the application
mvn spring-boot:run

# Or run the JAR
java -jar target/server-0.0.1-SNAPSHOT.jar
```

The server will start on `http://localhost:8080`

---

## 🔍 Decompiled Code Notice

⚠️ **Important**: This code was decompiled from compiled `.class` files. While the structure and logic are preserved:

- Variable names may differ from original source
- Comments from original code are not preserved (except CFR headers)
- Some code formatting may differ from original
- Generic type information may be incomplete in some cases

**The code is fully functional and can be compiled and run without modifications.**

---

## 📋 Technology Stack

- **Framework**: Spring Boot 4.0.2
- **Java**: 17
- **Security**: Spring Security 6 + JWT (JJWT 0.11.5)
- **Database**: PostgreSQL (via Spring Data JPA)
- **Password Encryption**: BCrypt
- **Build Tool**: Maven

---

## 🔐 Security Features

- JWT-based authentication (stateless)
- Role-based access control (Admin, Teacher, Student)
- BCrypt password hashing
- Method-level security with @PreAuthorize
- CORS configuration
- Custom authentication filter

---

## 📚 Documentation

- **SECURITY_SETUP.md** - Complete security setup guide with database scripts, API endpoints, and troubleshooting
- **SECURITY_IMPLEMENTATION.md** - Detailed implementation summary with file changes and role conventions
- **HELP.md** - Spring Boot reference documentation

---

## 🔗 Related Files

- **Database Schema**: `../Database.sql` (root level)
- **Flutter Integration Guide**: `../FLUTTER_INTEGRATION.md` (root level)
- **Project README**: `../README.md` (root level)

---

## ⚠️ Before Deployment

1. Change default test passwords in database
2. Generate a strong, unique JWT secret key
3. Update database credentials
4. Review and adjust CORS settings in `CorsConfig.java`
5. Set `spring.jpa.hibernate.ddl-auto` to `validate` in production
6. Remove or secure any debug/test endpoints

---

## 🛠️ Development

To make changes to the recovered code:

1. The code is ready to edit and compile
2. All dependencies are in `pom.xml`
3. Main application class: `ServerApplication.java`
4. Security configuration: `config/SecurityConfig.java`

---

## 📞 Need Help?

- Check `SECURITY_SETUP.md` for common issues and solutions
- Review Spring Boot logs for error details
- Verify database connection and schema

---

**Recovery Date**: February 13, 2026  
**Decompiler Used**: CFR (Class File Reader) 0.152  
**Original JAR**: server-0.0.1-SNAPSHOT.jar
