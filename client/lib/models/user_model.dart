class UserModel {
  final String id; // UUID from server
  final String username;
  final String email;
  final String? lastLogin;
  final String createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.lastLogin,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      lastLogin: _formatDateTime(json['lastLogin']),
      createdAt: _formatDateTime(json['createdAt']) ?? '',
    );
  }
  
  static String? _formatDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    if (dateValue is String) {
      return dateValue;
    }
    
    if (dateValue is Map) {
      // Handle LocalDateTime object from Spring
      try {
        var year = dateValue['year'];
        var month = dateValue['month'];
        var day = dateValue['dayOfMonth'];
        var hour = dateValue['hour'];
        var minute = dateValue['minute'];
        var second = dateValue['second'];
        
        if (year != null) {
          return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} '
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        print('Error formatting datetime: $e');
      }
    }
    
    return dateValue.toString();
  }
}
