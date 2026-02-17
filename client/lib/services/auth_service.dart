import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../core/routers.dart';
import '../utils/jwt_helper.dart';

class AuthService{
  final _storage = const FlutterSecureStorage();
  
  Future<String?> login(String usernameOrEmail, String password) async{
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppRoutes.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username_email': usernameOrEmail,
        'password': password,
      }),
    );

    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      String? token = body['token'];

      if (token == null){
        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null){
          token = rawCookie.split(';')[0].split('=')[1];
        }
      }

      if(token != null){
        await _storage.write(key: 'jwt', value: token);
        return JwtHelper.getRoleName(token);
      }
    } else {
      // Throw exception with status code for easier debugging
      throw Exception('Login failed: Server returned ${response.statusCode} ${response.body}');
    }

    throw Exception('Login failed: No token received');
  }

  Future<void> logout() async{
    await _storage.delete(key: 'jwt');
  }

}
