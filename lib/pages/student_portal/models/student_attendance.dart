/// Per-subject attendance summary returned by `/api/student/attendance`.
class SubjectAttendance {
  final int subjectId;
  final String subjectName;
  final int totalSessions;
  final int presentSessions;
  final int absentSessions;
  final double attendancePct;

  const SubjectAttendance({
    required this.subjectId,
    required this.subjectName,
    required this.totalSessions,
    required this.presentSessions,
    required this.absentSessions,
    required this.attendancePct,
  });

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) =>
      SubjectAttendance(
        subjectId: (json['subject_id'] as num).toInt(),
        subjectName: (json['subject_name'] as String?) ?? '',
        totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
        presentSessions: (json['present_sessions'] as num?)?.toInt() ?? 0,
        absentSessions: (json['absent_sessions'] as num?)?.toInt() ?? 0,
        attendancePct: (json['attendance_pct'] as num?)?.toDouble() ?? 0,
      );
}

/// One row of the per-session list. Carries everything the mobile needs
/// to render the student-side attendance history, including the teacher
/// who recorded the session.
class StudentAttendanceSession {
  final int sessionId;
  final int? subjectId;
  final String? subjectName;
  final DateTime sessionDatetime;
  final bool wasAbsent;
  final String? excuse;
  final String? absenceDate;
  final DateTime? absenceCreatedAt;
  final String? notes;

  final int? teacherId;
  final String? teacherCode;
  final String? teacherName;

  const StudentAttendanceSession({
    required this.sessionId,
    required this.subjectId,
    required this.subjectName,
    required this.sessionDatetime,
    required this.wasAbsent,
    required this.excuse,
    required this.absenceDate,
    required this.absenceCreatedAt,
    required this.notes,
    required this.teacherId,
    required this.teacherCode,
    required this.teacherName,
  });

  factory StudentAttendanceSession.fromJson(Map<String, dynamic> json) =>
      StudentAttendanceSession(
        sessionId: (json['session_id'] as num).toInt(),
        subjectId: (json['subject_id'] as num?)?.toInt(),
        subjectName: json['subject_name'] as String?,
        sessionDatetime: DateTime.parse(json['session_datetime'] as String),
        wasAbsent: (json['was_absent'] as bool?) ?? false,
        excuse: json['excuse'] as String?,
        absenceDate: json['absence_date'] as String?,
        absenceCreatedAt: json['absence_created_at'] != null
            ? DateTime.parse(json['absence_created_at'] as String)
            : null,
        notes: json['notes'] as String?,
        teacherId: (json['teacher_id'] as num?)?.toInt(),
        teacherCode: json['teacher_code'] as String?,
        teacherName: json['teacher_name'] as String?,
      );
}

/// Top-level attendance payload from `/api/student/attendance`.
class StudentAttendanceReport {
  final String studentId;
  final String fullName;
  final int? classId;
  final int totalSessions;
  final int totalPresent;
  final int totalAbsent;
  final double attendancePct;
  final List<SubjectAttendance> subjects;
  final List<StudentAttendanceSession> sessions;

  const StudentAttendanceReport({
    required this.studentId,
    required this.fullName,
    required this.classId,
    required this.totalSessions,
    required this.totalPresent,
    required this.totalAbsent,
    required this.attendancePct,
    required this.subjects,
    required this.sessions,
  });

  factory StudentAttendanceReport.fromJson(Map<String, dynamic> json) {
    final subjects = (json['subjects'] as List?) ?? const [];
    final sessions = (json['sessions'] as List?) ?? const [];
    return StudentAttendanceReport(
      studentId: (json['student_id'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      classId: (json['class_id'] as num?)?.toInt(),
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      totalPresent: (json['total_present'] as num?)?.toInt() ?? 0,
      totalAbsent: (json['total_absent'] as num?)?.toInt() ?? 0,
      attendancePct: (json['attendance_pct'] as num?)?.toDouble() ?? 0,
      subjects: subjects
          .whereType<Map<String, dynamic>>()
          .map(SubjectAttendance.fromJson)
          .toList(growable: false),
      sessions: sessions
          .whereType<Map<String, dynamic>>()
          .map(StudentAttendanceSession.fromJson)
          .toList(growable: false),
    );
  }
}
