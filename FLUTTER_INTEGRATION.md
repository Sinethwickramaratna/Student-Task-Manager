# Flutter Client - Server Integration Guide

This guide explains how to integrate your Flutter app with the Spring Security + JWT backend.

---

## 📡 API Base URLs

```dart
const String baseUrl = 'http://your-server:8080/api';
// For Android emulator: http://10.0.2.2:8080/api
// For iOS simulator: http://localhost:8080/api
```

---

## 🔐 Authentication Flow

### 1. Login Endpoint

```dart
Future<void> login(String usernameOrEmail, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username_email': usernameOrEmail,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final token = data['token'];
    final role = data['user']['role'];
    
    // Store token securely
    await FlutterSecureStorage().write(key: 'jwt_token', value: token);
    
    // Store role for navigation
    await FlutterSecureStorage().write(key: 'user_role', value: role);
  } else {
    throw Exception('Login failed');
  }
}
```

### 2. Logout Endpoint

```dart
Future<void> logout() async {
  final token = await FlutterSecureStorage().read(key: 'jwt_token');
  
  await http.post(
    Uri.parse('$baseUrl/auth/logout'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  // Clear local storage
  await FlutterSecureStorage().delete(key: 'jwt_token');
  await FlutterSecureStorage().delete(key: 'user_role');
}
```

---

## 🛡️ API Requests with JWT Token

### Create HTTP Client Class

```dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl});

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, {required Map body}) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
```

---

## 👤 Role-Based Navigation

### Check User Role and Navigate

```dart
class RoleBasedHome extends StatefulWidget {
  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateByRole();
  }

  Future<void> _navigateByRole() async {
    final role = await _storage.read(key: 'user_role');
    
    if (!mounted) return;

    switch (role) {
      case 'ROLE_Admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'ROLE_Teacher':
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
        break;
      case 'ROLE_Student':
        Navigator.pushReplacementNamed(context, '/student-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

---

## 📋 Example Screens

### Login Screen

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8080/api');

  Future<void> _handleLogin() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username_email': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await const FlutterSecureStorage().write(
          key: 'jwt_token',
          value: data['token'],
        );
        await const FlutterSecureStorage().write(
          key: 'user_role',
          value: data['user']['role'],
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError('Login failed');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Admin Dashboard

```dart
class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8080/api');

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final response = await _apiClient.get('/admin/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Dashboard: $data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _logout() async {
    await _apiClient.get('/auth/logout');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome Admin!'),
      ),
    );
  }
}
```

---

## 📦 Pubspec Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.0.0
```

---

## ⚠️ Important Notes

### 1. Token Storage
- Use `flutter_secure_storage` for storing JWT tokens
- Never store in SharedPreferences (not secure)
- Always delete token on logout

### 2. API Endpoints
- Public: `/api/auth/**`
- Admin only: `/api/admin/**`
- Teacher only: `/api/teacher/**`
- Student only: `/api/student/**`

### 3. Header Format
Always send: `Authorization: Bearer <your_jwt_token>`

### 4. Error Handling
```dart
Future<void> _handleResponse(http.Response response) {
  if (response.statusCode == 401) {
    // Token expired or invalid - redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  } else if (response.statusCode == 403) {
    // User doesn't have permission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You do not have permission')),
    );
  } else if (response.statusCode >= 500) {
    // Server error
    _showError('Server error occurred');
  }
}
```

### 5. Test Credentials

| Username | Password | Role |
|----------|----------|------|
| admin1 | admin123 | Admin |
| teacher1 | admin123 | Teacher |
| student1 | admin123 | Student |

---

## 🧪 Testing Flow

1. **Login** with test credentials
2. **Token stored** in secure storage
3. **Access role-specific endpoints** (e.g., `/api/admin/dashboard`)
4. **Token sent** in Authorization header
5. **Server validates** token and role
6. **Response received** or error if unauthorized

---

## 🔗 Example Request Flow

```
Client                                Server
  |                                     |
  |-- POST /api/auth/login ------------->|
  |   (username: admin1, password)       |
  |                                      |
  |<-- 200 OK + token + role ------------|
  |   (store token locally)              |
  |                                      |
  |-- GET /api/admin/dashboard -------->|
  |   (with Authorization: Bearer token) |
  |                                      |
  |<-- 200 OK + dashboard data ---------|
  |                                      |
```

---

**Happy coding!** 🚀
