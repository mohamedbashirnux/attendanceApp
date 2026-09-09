class TeacherClass {
  final int allocationId;
  final int subjectClassId;
  final int classId;
  final String className;
  final String departmentName;
  final String facultyName;
  final String studyMode;
  final String semester;
  final String academicYear;
  final int subjectId;
  final String subjectName;
  final String startTime;
  final String endTime;
  final String status;

  const TeacherClass({
    required this.allocationId,
    required this.subjectClassId,
    required this.classId,
    required this.className,
    required this.departmentName,
    required this.facultyName,
    required this.studyMode,
    required this.semester,
    required this.academicYear,
    required this.subjectId,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) {
    return TeacherClass(
      allocationId: _parseInt(json['allocation_id']),
      subjectClassId: _parseInt(json['subject_class_id']),
      classId: _parseInt(json['class_id']),
      className: (json['class_name'] ?? '') as String,
      departmentName: (json['department_name'] ?? '') as String,
      facultyName: (json['faculty_name'] ?? '') as String,
      studyMode: (json['study_mode'] ?? '') as String,
      semester: (json['semester'] ?? '') as String,
      academicYear: (json['academic_year'] ?? '') as String,
      subjectId: _parseInt(json['subject_id']),
      subjectName: (json['subject_name'] ?? '') as String,
      startTime: _trimTime(json['start_time'] as String?),
      endTime: _trimTime(json['end_time'] as String?),
      status: (json['status'] ?? '') as String,
    );
  }
}

/// Represents a distinct academic class along with all subject allocations
/// taught by this teacher in that class.
class TeacherClassGroup {
  final int classId;
  final String className;
  final String departmentName;
  final String facultyName;
  final String studyMode;
  final String semester;
  final String academicYear;
  final List<TeacherClass> allocations;

  const TeacherClassGroup({
    required this.classId,
    required this.className,
    required this.departmentName,
    required this.facultyName,
    required this.studyMode,
    required this.semester,
    required this.academicYear,
    required this.allocations,
  });

  /// Groups a flat list of allocations (from /api/teacher/classes) by [classId].
  static List<TeacherClassGroup> fromAllocations(List<TeacherClass> allocations) {
    final Map<int, List<TeacherClass>> map = {};
    for (final a in allocations) {
      map.putIfAbsent(a.classId, () => []).add(a);
    }
    return map.entries.map((entry) {
      final first = entry.value.first;
      return TeacherClassGroup(
        classId: entry.key,
        className: first.className,
        departmentName: first.departmentName,
        facultyName: first.facultyName,
        studyMode: first.studyMode,
        semester: first.semester,
        academicYear: first.academicYear,
        allocations: entry.value,
      );
    }).toList(growable: false);
  }
}


/// Tolerant int parser — Prisma serializes big integers as JSON strings
/// (so JS doesn't lose precision for `Int` > 2^53), but sometimes as
/// numbers. Handle both without crashing.
int _parseInt(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}

/// The classes API returns `start_time` / `end_time` as `HH:mm:ss`
/// (e.g. `"10:00:00"`). For display we only want `HH:mm`.
String _trimTime(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.length >= 5 && raw[2] == ':') {
    return raw.substring(0, 5);
  }
  return raw;
}
