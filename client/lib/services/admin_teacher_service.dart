import 'dart:convert';
import '../models/teacher_model.dart';
import '../core/constants.dart';
import 'api_client.dart';

class AdminTeacherService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fetchTeachers({
    required int page,
    required String sortBy,
    required String direction,
    String search = '',
  }) async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}/admin/teachers?page=$page&size=10&sortBy=$sortBy&direction=$direction&search=$search');

      print('Fetching teachers from: $url');

      final response = await _apiClient.get(url)
          .timeout(const Duration(seconds: 10));

      print('Teachers API Response Status: ${response.statusCode}');
      print('Teachers API Response Body: ${response.body}');
      print('Teachers API Response Headers: ${response.headers}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load teachers: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);

      List<TeacherModel> teachers = (data['teachers'] as List?)
          ?.map((t) => TeacherModel.fromJson(t as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'teachers': teachers,
        'total': data['totalTeachers'] ?? 0,
      };
    } catch (e) {
      print('Error in fetchTeachers: $e');
      rethrow;
    }
  }

  Future<void> createTeacher(Map<String, dynamic> teacherData) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/admin/teachers');
      
      final response = await _apiClient.post(
        url,
        jsonEncode(teacherData),
      ).timeout(const Duration(seconds: 10));

      print('Create Teacher API Response Status: ${response.statusCode}');
      print('Create Teacher API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create teacher');
      }
    } catch (e) {
      print('Error creating teacher: $e');
      rethrow;
    }
  }
}
