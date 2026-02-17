class TeacherModel {
  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final String? birthdate;
  final String userId;
  final String? profilePictureUrl;

  TeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.birthdate,
    required this.userId,
    this.profilePictureUrl,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id']?.toString() ?? '',
      firstName: json['f_name'] ?? json['firstName'] ?? '',
      lastName: json['l_name'] ?? json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      birthdate: _formatDateTime(json['birthdate']),
      userId: json['user_id'] ?? json['userId'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ??
          json['profilePictureUrl'] ??
          json['profile_picture'],
    );
  }

  static String? _formatDateTime(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is String) {
      return dateValue;
    }

    if (dateValue is Map) {
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
