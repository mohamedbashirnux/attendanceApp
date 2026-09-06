import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../connection/api_config.dart';
import 'models/student.dart';
import 'models/student_attendance.dart';
import 'models/student_timetable.dart';

/// Thrown by [StudentApiService] on any non-2xx response. The [message]
/// is whatever the server returned in the `error` field, or a generic
/// fallback.
class StudentApiException implements Exception {
  final String message;
  const StudentApiException(this.message);

  @override
  String toString() => message;
}

class StudentApiService {
  StudentApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<({String token, Student student})> login({
    required String studentId,
    required String password,
  }) async {
    final res = await _client
        .post(
          Uri.parse('${resolveBaseUrl()}/api/student/login'),
          headers: _jsonHeaders,
          body: jsonEncode({
            'student_id': studentId,
            'password': password,
          }),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);

    final token = body['token'] as String?;
    final studentJson = body['student'] as Map<String, dynamic>?;
    if (token == null || studentJson == null) {
      throw const StudentApiException('Invalid server response');
    }
    return (token: token, student: Student.fromJson(studentJson));
  }

  Future<Student> fetchMe(String token) async {
    final res = await _client
        .get(
          Uri.parse('${resolveBaseUrl()}/api/student/me'),
          headers: _authHeaders(token),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);
    return Student.fromJson(body);
  }

  Future<StudentAttendanceReport> fetchAttendance(String token) async {
    final res = await _client
        .get(
          Uri.parse('${resolveBaseUrl()}/api/student/attendance'),
          headers: _authHeaders(token),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);
    return StudentAttendanceReport.fromJson(body);
  }

  /// Weekly class schedule for the signed-in student. Returns the
  /// full payload (header + entries + by_day map). The backend already
  /// groups by Monday..Sunday, so the UI can render directly.
  Future<TimetableReport> fetchTimetable(String token) async {
    final res = await _client
        .get(
          Uri.parse('${resolveBaseUrl()}/api/student/timetable'),
          headers: _authHeaders(token),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);
    return TimetableReport.fromJson(body);
  }

  /// Changes the password for the currently signed-in student. The
  /// server requires the current password (proves the caller is the
  /// account owner, not someone who stole just the token) plus a new
  /// password of at least 8 characters. The student stays signed in
  /// on this device; other devices will need to log in again.
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _client
        .post(
          Uri.parse('${resolveBaseUrl()}/api/student/change-password'),
          headers: _authHeaders(token),
          body: jsonEncode({
            'current_password': currentPassword,
            'new_password': newPassword,
          }),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.body.isEmpty) return const {};
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }

  void _ensureOk(http.Response res, Map<String, dynamic> body) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final msg = (body['error'] as String?) ?? 'Request failed (${res.statusCode})';
    throw StudentApiException(msg);
  }
}
