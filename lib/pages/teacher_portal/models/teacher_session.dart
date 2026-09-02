import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'teacher.dart';

/// Persisted login session for the teacher portal. Loads on app start so a
/// logged-in teacher stays logged in; cleared on logout.
class TeacherSession {
  static const _kToken = 'teacher_token';
  static const _kTeacher = 'teacher_payload';

  final String token;
  final Teacher teacher;

  const TeacherSession({required this.token, required this.teacher});

  static Future<TeacherSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    final payload = prefs.getString(_kTeacher);
    if (token == null || token.isEmpty || payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final teacher = Teacher.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );
      return TeacherSession(token: token, teacher: teacher);
    } catch (_) {
      return null;
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kTeacher, jsonEncode({
      'teacher_id': teacher.id,
      'full_name': teacher.fullName,
      'username': teacher.username,
      'faculty_id': teacher.facultyId,
      'faculty_name': teacher.facultyName,
    }));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kTeacher);
  }
}
