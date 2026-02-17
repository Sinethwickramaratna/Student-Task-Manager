import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'network_service.dart';

class ApiClient{
  final _storage = const FlutterSecureStorage();
  final NetworkService _networkService = NetworkService();

  Future<Map<String,String>> getHeaders() async{
    final token = await _storage.read(key: 'jwt');
    
    print('JWT Token from storage: ${token != null ? token.substring(0, 20) + '...' : 'null'}');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future <http.Response> get(Uri url) async{
    if (!_networkService.isConnected) {
      throw Exception('No network connection. Please check your internet connection.');
    }
    
    final headers = await getHeaders();
    print('API GET Request - URL: $url');
    print('API GET Request - Headers: $headers');
    
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(Uri url, String body) async{
    if (!_networkService.isConnected) {
      throw Exception('No network connection. Please check your internet connection.');
    }
    return http.post(url, headers: await getHeaders(), body: body);
  }
}