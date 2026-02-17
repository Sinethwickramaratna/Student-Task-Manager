import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'dart:convert';
import '../core/constants.dart';

class ApiService {
  static final _apiClient = ApiClient();
  static final String _baseUrl = AppConstants.baseUrl;

  /// Fetch admin dashboard data including stats and charts
  static Future<Map<String, dynamic>?> getAdminDashboard() async {
    try {
      final response = await _apiClient.get(
        Uri.parse('$_baseUrl/admin/dashboard'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        // Handle unauthorized
        if (kDebugMode) {
          print('Unauthorized: ${response.body}');
        }
        return null;
      } else if (response.statusCode == 403) {
        // Handle forbidden (role mismatch)
        if (kDebugMode) {
          print('Forbidden - User does not have Admin role: ${response.body}');
        }
        return null;
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dashboard: $e');
      }
      rethrow;
    }
  }
}