import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'student.dart';

/// Holds the logged-in student's token + profile so a returning user
/// doesn't have to sign in again. Persisted to SharedPreferences.
class StudentSession {
  static const _kToken = 'student_token';
  static const _kStudent = 'student_profile';

  static String? _token;
  static Student? _student;

  static String? get token => _token;
  static Student? get student => _student;
  static bool get isLoggedIn =>
      (_token != null && _token!.isNotEmpty) && _student != null;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    final raw = prefs.getString(_kStudent);
    if (raw != null && raw.isNotEmpty) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        _student = Student.fromJson(j);
      } catch (_) {
        _student = null;
      }
    }
  }

  static Future<void> save({
    required String token,
    required Student student,
  }) async {
    _token = token;
    _student = student;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kStudent, jsonEncode({
      'id': student.id,
      'student_id': student.studentId,
      'full_name': student.fullName,
      'phone': student.phone,
      'status': student.status,
      'class_id': student.classId,
      'class_name': student.className,
      'department_id': student.departmentId,
      'department_name': student.departmentName,
      'faculty_id': student.facultyId,
      'faculty_name': student.facultyName,
    }));
  }

  static Future<void> clear() async {
    _token = null;
    _student = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kStudent);
  }
}
