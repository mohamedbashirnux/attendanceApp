import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'models/student.dart';
import 'models/student_attendance.dart';

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
