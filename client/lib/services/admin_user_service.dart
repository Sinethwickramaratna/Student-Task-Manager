import 'dart:convert';
import '../models/user_model.dart';
import '../core/constants.dart';
import 'api_client.dart';

class AdminUserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fetchUsers({
    required int page,
    required String sortBy,
    required String direction,
    String search = '',
  }) async {

    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}/admin/users?page=$page&size=10&sortBy=$sortBy&direction=$direction&search=$search');
      
      print('Fetching users from: $url');
      
      final response = await _apiClient.get(url)
          .timeout(const Duration(seconds: 10));

      print('Users API Response Status: ${response.statusCode}');
      print('Users API Response Body: ${response.body}');
      print('Users API Response Headers: ${response.headers}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load users: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);

      List<UserModel> users = (data['users'] as List?)
          ?.map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'users': users,
        'total': data['totalUsers'] ?? 0,
      };
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }
}
