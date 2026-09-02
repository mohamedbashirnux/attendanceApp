class SessionRecord {
  final int sessionId;
  final DateTime sessionDatetime;
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;
  final double attendancePercentage;
  final String? notes;

  const SessionRecord({
    required this.sessionId,
    required this.sessionDatetime,
    required this.totalStudents,
    required this.presentStudents,
    required this.absentStudents,
    required this.attendancePercentage,
    this.notes,
  });

  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    return SessionRecord(
      sessionId: _parseInt(json['session_id']),
      sessionDatetime: DateTime.parse(json['session_datetime'] as String),
      totalStudents: _parseInt(json['total_students']),
      presentStudents: _parseInt(json['present_students']),
      absentStudents: _parseInt(json['absent_students']),
      attendancePercentage:
          _parseDouble(json['attendance_percentage']),
      notes: json['notes'] as String?,
    );
  }
}

class StudentAbsentDate {
  final DateTime date;
  final String excuse;

  const StudentAbsentDate({required this.date, required this.excuse});

  factory StudentAbsentDate.fromJson(Map<String, dynamic> json) {
    return StudentAbsentDate(
      date: DateTime.parse(json['date'] as String),
      excuse: (json['excuse'] ?? 'No_Excuse') as String,
    );
  }
}

class StudentReport {
  final int number;
  final int studentId;
  final String fullName;
  final int absentSessions;
  final int presentSessions;
  final int totalSessions;
  final double attendancePct;
  final bool neverAttended;
  final List<StudentAbsentDate> absentDates;

  const StudentReport({
    required this.number,
    required this.studentId,
    required this.fullName,
    required this.absentSessions,
    required this.presentSessions,
    required this.totalSessions,
    required this.attendancePct,
    required this.neverAttended,
    required this.absentDates,
  });

  factory StudentReport.fromJson(Map<String, dynamic> json) {
    return StudentReport(
      number: _parseInt(json['number']),
      studentId: _parseInt(json['student_id']),
      fullName: (json['full_name'] ?? '') as String,
      absentSessions: _parseInt(json['absent_sessions']),
      presentSessions: _parseInt(json['present_sessions']),
      totalSessions: _parseInt(json['total_sessions']),
      attendancePct: _parseDouble(json['attendance_pct']),
      neverAttended: (json['never_attended'] ?? false) as bool,
      absentDates: ((json['absent_dates'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StudentAbsentDate.fromJson)
          .toList(growable: false),
    );
  }
}

class AttendanceReport {
  final int classId;
  final String className;
  final String departmentName;
  final int subjectId;
  final String subjectName;
  final int subjectClassId;
  final int totalSessions;
  final int totalStudents;
  final int totalAbsentCount;
  final double classAttendanceRate;
  final int neverAttendedCount;
  final DateTime? lastSessionDate;
  final List<SessionRecord> sessions;
  final List<StudentReport> students;

  const AttendanceReport({
    required this.classId,
    required this.className,
    required this.departmentName,
    required this.subjectId,
    required this.subjectName,
    required this.subjectClassId,
    required this.totalSessions,
    required this.totalStudents,
    required this.totalAbsentCount,
    required this.classAttendanceRate,
    required this.neverAttendedCount,
    this.lastSessionDate,
    required this.sessions,
    required this.students,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    return AttendanceReport(
      classId: _parseInt(json['class_id']),
      className: (json['class_name'] ?? '') as String,
      departmentName: (json['department_name'] ?? '') as String,
      subjectId: _parseInt(json['subject_id']),
      subjectName: (json['subject_name'] ?? '') as String,
      subjectClassId: _parseInt(json['subject_class_id']),
      totalSessions: _parseInt(json['total_sessions']),
      totalStudents: _parseInt(json['total_students']),
      totalAbsentCount: _parseInt(json['total_absent_count']),
      classAttendanceRate: _parseDouble(json['class_attendance_rate']),
      neverAttendedCount: _parseInt(json['never_attended_count']),
      lastSessionDate: json['last_session_date'] != null
          ? DateTime.parse(json['last_session_date'] as String)
          : null,
      sessions: ((json['sessions'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionRecord.fromJson)
          .toList(growable: false),
      students: ((json['students'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StudentReport.fromJson)
          .toList(growable: false),
    );
  }
}

int _parseInt(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}

double _parseDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? 0;
  return 0;
}
