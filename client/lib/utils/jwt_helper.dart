import 'package:jwt_decode/jwt_decode.dart';

class JwtHelper{
  static Map<String, dynamic> decode(String token){
    return Jwt.parseJwt(token);
  }

  static bool isExpired(String token){
    return Jwt.isExpired(token);
  }

  static String getRoleName(String token){
    final decoded = decode(token);
    return decoded['role_name'];
  }
}