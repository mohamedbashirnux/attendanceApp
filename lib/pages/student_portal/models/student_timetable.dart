/// One class on a student's weekly schedule, returned by
/// `/api/student/timetable`. Times are strings like "08:00" / "08:00:00"
/// (the backend trims to "HH:MM"). We keep them as strings so the
/// mobile doesn't accidentally convert to a timezone-shifted DateTime.
class TimetableEntry {
  final int id;
  final int allocationId;
  final String dayOfWeek; // "Monday".."Sunday"
  final String timeStart; // "HH:MM"
  final String timeEnd;   // "HH:MM"
  final String? locationHall;

  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherCode;
  final String teacherName;

  final int classId;
  final String className;
  final int departmentId;
  final String departmentName;
  final int facultyId;
  final String facultyName;

  const TimetableEntry({
    required this.id,
    required this.allocationId,
    required this.dayOfWeek,
    required this.timeStart,
    required this.timeEnd,
    required this.locationHall,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherCode,
    required this.teacherName,
    required this.classId,
    required this.className,
    required this.departmentId,
    required this.departmentName,
    required this.facultyId,
    required this.facultyName,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    String time(dynamic raw) {
      if (raw == null) return '';
      final s = raw.toString();
      return s.length >= 5 ? s.substring(0, 5) : s;
    }

    return TimetableEntry(
      id: (json['id'] as num).toInt(),
      allocationId: (json['allocation_id'] as num).toInt(),
      dayOfWeek: (json['day_of_week'] as String?) ?? '',
      timeStart: time(json['time_start']),
      timeEnd: time(json['time_end']),
      locationHall: json['location_hall'] as String?,
      subjectId: (json['subject_id'] as num).toInt(),
      subjectName: (json['subject_name'] as String?) ?? '',
      teacherId: (json['teacher_id'] as num).toInt(),
      teacherCode: (json['teacher_code'] as String?) ?? '',
      teacherName: (json['teacher_name'] as String?) ?? '',
      classId: (json['class_id'] as num).toInt(),
      className: (json['class_name'] as String?) ?? '',
      departmentId: (json['department_id'] as num?)?.toInt() ?? 0,
      departmentName: (json['department_name'] as String?) ?? '',
      facultyId: (json['faculty_id'] as num?)?.toInt() ?? 0,
      facultyName: (json['faculty_name'] as String?) ?? '',
    );
  }
}

/// Top-level response from `/api/student/timetable`.
///
/// The backend already groups entries by day-of-week into `by_day`
/// (Monday..Sunday, missing days map to []). We use that map directly
/// so the UI can render each day card without re-sorting.
class TimetableReport {
  final String studentId;
  final String fullName;
  final int? classId;
  final String? className;
  final String? departmentName;
  final String? facultyName;
  final int totalEntries;
  final List<TimetableEntry> entries;
  final Map<String, List<TimetableEntry>> byDay;

  const TimetableReport({
    required this.studentId,
    required this.fullName,
    required this.classId,
    required this.className,
    required this.departmentName,
    required this.facultyName,
    required this.totalEntries,
    required this.entries,
    required this.byDay,
  });

  factory TimetableReport.fromJson(Map<String, dynamic> json) {
    final entriesJson = (json['entries'] as List?) ?? const [];
    final entries = entriesJson
        .whereType<Map<String, dynamic>>()
        .map(TimetableEntry.fromJson)
        .toList(growable: false);

    // Day-of-week order: Monday first.
    const dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final byDayRaw = (json['by_day'] as Map?) ?? const {};
    final byDay = <String, List<TimetableEntry>>{};
    for (final day in dayOrder) {
      final list = byDayRaw[day];
      if (list is List) {
        byDay[day] = list
            .whereType<Map<String, dynamic>>()
            .map(TimetableEntry.fromJson)
            .toList(growable: false);
      } else {
        byDay[day] = const [];
      }
    }

    return TimetableReport(
      studentId: (json['student_id'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      classId: (json['class_id'] as num?)?.toInt(),
      className: json['class_name'] as String?,
      departmentName: json['department_name'] as String?,
      facultyName: json['faculty_name'] as String?,
      totalEntries: (json['total_entries'] as num?)?.toInt() ?? entries.length,
      entries: entries,
      byDay: byDay,
    );
  }

  /// "Monday".."Sunday" in week order.
  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Short 3-letter labels for compact UI.
  static const Map<String, String> dayShort = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun',
  };
}
