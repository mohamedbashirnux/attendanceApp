class Student {
  /// DB primary key — needed to submit absences.
  final int id;
  /// Human-readable id from the school (e.g. "S001"). Shown in the UI.
  final String studentId;
  final String fullName;

  const Student({
    required this.id,
    required this.studentId,
    required this.fullName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: _parseInt(json['id']),
      studentId: (json['student_id'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
    );
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
