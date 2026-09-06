import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../connection/api_config.dart';
import 'models/attendance_report.dart';
import 'models/student.dart';
import 'models/teacher.dart';
import 'models/teacher_class.dart';

/// Thrown by [TeacherApiService] on any non-2xx response. The [message] is
/// whatever the server returned in the `error` field, or a generic fallback.
class TeacherApiException implements Exception {
  final String message;
  const TeacherApiException(this.message);

  @override
  String toString() => message;
}

class TeacherApiService {
  TeacherApiService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<({String token, Teacher teacher})> login({
    required String username,
    required String password,
  }) async {
    final res = await _client
        .post(
          Uri.parse('${resolveBaseUrl()}/api/teacher/login'),
          headers: _jsonHeaders,
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);

    final token = body['token'] as String?;
    final teacherJson = body['teacher'] as Map<String, dynamic>?;
    if (token == null || teacherJson == null) {
      throw const TeacherApiException('Invalid server response');
    }
    return (token: token, teacher: Teacher.fromJson(teacherJson));
  }

  Future<List<TeacherClass>> fetchClasses(String token) async {
    final res = await _client
        .get(
          Uri.parse('${resolveBaseUrl()}/api/teacher/classes'),
          headers: _authHeaders(token),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);

    final list = (body['classes'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(TeacherClass.fromJson)
        .toList(growable: false);
  }

  Future<({String className, List<Student> students})> fetchStudents({
    required int classId,
    required String token,
  }) async {
    final res = await _client
        .get(
          Uri.parse('${resolveBaseUrl()}/api/teacher/class/$classId/students'),
          headers: _authHeaders(token),
        )
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);

    final list = (body['students'] as List?) ?? const [];
    return (
      className: (body['class_name'] ?? '') as String,
      students: list
          .whereType<Map<String, dynamic>>()
          .map(Student.fromJson)
          .toList(growable: false),
    );
  }

  Future<AttendanceReport> fetchReport({
    required int classId,
    required int subjectId,
    required String token,
  }) async {
    final uri = Uri.parse('${resolveBaseUrl()}/api/teacher/report').replace(
      queryParameters: {
        'class_id': '$classId',
        'subject_id': '$subjectId',
      },
    );
    final res = await _client
        .get(uri, headers: _authHeaders(token))
        .timeout(_timeout);

    final body = _decode(res);
    _ensureOk(res, body);
    return AttendanceReport.fromJson(body);
  }

  /// Submits attendance for one session. The server stores an
  /// `attendance_sessions` row plus one `absences` row per absent
  /// student (with the excuse enum string). Returns a [SubmitAttendanceResult]
  /// that distinguishes three cases:
  ///   - ok: 201 — session recorded; `body` is the parsed response
  ///   - alreadySubmitted: 409 — server says this teacher already
  ///     submitted attendance for this class today (or the allocation
  ///     is now locked)
  ///   - error: any other non-2xx — the server error text is in `message`
  Future<SubmitAttendanceResult> submitAttendance({
    required int classId,
    required int subjectId,
    required String token,
    required List<({int studentId, String excuse})> absences,
    String? notes,
  }) async {
    final res = await _client
        .post(
          Uri.parse('${resolveBaseUrl()}/api/teacher/attendance'),
          headers: _authHeaders(token),
          body: jsonEncode({
            'class_id': classId,
            'subject_id': subjectId,
            'absences': absences
                .map((a) => {'student_id': a.studentId, 'excuse': a.excuse})
                .toList(),
            if (notes != null && notes.isNotEmpty) 'notes': notes,
          }),
        )
        .timeout(_timeout);

    final body = _decode(res);
    if (res.statusCode == 201) {
      return SubmitAttendanceResult.ok(body);
    }
    if (res.statusCode == 409 &&
        body['already_submitted'] == true) {
      return SubmitAttendanceResult.alreadySubmitted(
        message: (body['error'] as String?) ?? 'Already submitted',
        sessionId: body['session_id'],
        sessionDatetime: body['session_datetime'],
      );
    }
    final msg = (body['error'] as String?) ?? 'Request failed (${res.statusCode})';
    return SubmitAttendanceResult.error(msg);
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
    throw TeacherApiException(msg);
  }
}

/// Discriminated result of [TeacherApiService.submitAttendance].
class SubmitAttendanceResult {
  final bool isOk;
  final bool isAlreadySubmitted;
  final Map<String, dynamic>? body;
  final String? message;
  final Object? sessionId;
  final String? sessionDatetime;

  const SubmitAttendanceResult._({
    required this.isOk,
    required this.isAlreadySubmitted,
    this.body,
    this.message,
    this.sessionId,
    this.sessionDatetime,
  });

  factory SubmitAttendanceResult.ok(Map<String, dynamic> body) =>
      SubmitAttendanceResult._(isOk: true, isAlreadySubmitted: false, body: body);

  factory SubmitAttendanceResult.alreadySubmitted({
    required String message,
    Object? sessionId,
    String? sessionDatetime,
  }) =>
      SubmitAttendanceResult._(
        isOk: false,
        isAlreadySubmitted: true,
        message: message,
        sessionId: sessionId,
        sessionDatetime: sessionDatetime,
      );

  factory SubmitAttendanceResult.error(String message) =>
      SubmitAttendanceResult._(
        isOk: false,
        isAlreadySubmitted: false,
        message: message,
      );
}
