# 🚀 Quick Start Guide - Spring Boot Server

## 📋 Prerequisites

- Java 17 or higher
- Maven 3.6+ (or use included Maven Wrapper)
- PostgreSQL 12+
- Git (optional)

---

## ⚡ Quick Setup (3 Steps)

### 1️⃣ Setup Database
```bash
# Create PostgreSQL database
createdb student_task_db

# Run the initialization script (from project root)
psql -U postgres -d student_task_db -f ../Database.sql
```

### 2️⃣ Configure Environment
```bash
# Copy environment template
cp .env.example .env

# Edit .env and set your values:
# - DB_PASSWORD (your PostgreSQL password)
# - SECRET_KEY (generate a strong 32+ character key)
```

### 3️⃣ Run the Server
```bash
# Using Maven Wrapper (recommended)
./mvnw spring-boot:run              # Unix/Linux/Mac
mvnw.cmd spring-boot:run            # Windows

# Or using Maven directly
mvn spring-boot:run
```

Server starts at: `http://localhost:8080`

---

## 🔧 Build Commands

```bash
# Clean and build
./mvnw clean install

# Run tests
./mvnw test

# Package as JAR
./mvnw package

# Run the JAR
java -jar target/server-0.0.1-SNAPSHOT.jar

# Skip tests during build
./mvnw clean install -DskipTests
```

---

## 🧪 Testing the API

### Login (Get JWT Token)
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username_email": "admin1",
    "password": "admin123"
  }'
```

### Access Protected Endpoint
```bash
curl -X GET http://localhost:8080/api/admin/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## 📦 Project Structure at a Glance

```
server_backup/
├── src/main/java/           Java source code
│   └── com.sineth.server/
│       ├── config/          Configuration
│       ├── controller/      REST endpoints
│       ├── dao/             Repositories
│       ├── dto/             Request/Response models
│       ├── model/           JPA entities
│       ├── security/        JWT & Security
│       └── service/         Business logic
│
├── src/main/resources/      Configuration files
│   ├── application.properties
│   └── static/, templates/
│
├── src/test/                Tests
│
├── pom.xml                  Dependencies
├── mvnw, mvnw.cmd          Maven wrapper
└── .env.example            Environment template
```

---

## 🔐 Default Test Users

| Username | Email | Password | Role |
|----------|-------|----------|------|
| admin1 | admin@mail.com | admin123 | Admin |
| teacher1 | teacher@mail.com | admin123 | Teacher |
| student1 | student@mail.com | admin123 | Student |

⚠️ **Change these in production!**

---

## 📚 API Endpoints

### Public
- `POST /api/auth/login` - Login

### Admin (requires Admin role)
- `GET /api/admin/dashboard`
- `GET /api/admin/users`
- `POST /api/admin/users`
- `PUT /api/admin/users/{id}`
- `DELETE /api/admin/users/{id}`

### Teacher (requires Teacher role)
- `GET /api/teacher/dashboard`
- `GET /api/teacher/tasks`
- `POST /api/teacher/tasks`

### Student (requires Student role)
- `GET /api/student/dashboard`
- `GET /api/student/tasks`
- `PUT /api/student/tasks/{id}`

---

## 🔍 Common Issues

**Port 8080 already in use:**
```bash
# Change port in application.properties
server.port=8081
```

**Database connection failed:**
```bash
# Check PostgreSQL is running
systemctl status postgresql    # Linux
brew services list             # Mac
# Check credentials in .env file
```

**JWT token errors:**
```bash
# Ensure SECRET_KEY is at least 32 characters in .env
SECRET_KEY=your-very-long-secret-key-here-min-32-chars
```

---

## 📖 Documentation

- **[FILES_ORGANIZED.md](FILES_ORGANIZED.md)** - Complete file organization
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Detailed structure
- **[SECURITY_SETUP.md](SECURITY_SETUP.md)** - Security configuration
- **[README.md](README.md)** - Full documentation

---

## 🛠️ Development

### Run in Development Mode
```bash
# Active development profile with debug logging
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Run in Production Mode
```bash
# Active production profile
./mvnw spring-boot:run -Dspring-boot.run.profiles=prod
```

---

## 🎯 Next Steps

1. ✅ Setup complete - Server is ready to run
2. 📝 Review security settings in SECURITY_SETUP.md
3. 🔧 Customize configuration in application.properties
4. 🧪 Run tests with `./mvnw test`
5. 🚀 Deploy as JAR file

---

**Need help?** Check the documentation files or open an issue!

**Ready to code!** 🎉
