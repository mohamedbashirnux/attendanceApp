/// Student profile returned by `/api/student/login` and `/api/student/me`.
class Student {
  final int id;
  final String studentId; // e.g. "S001" — the human-readable code
  final String fullName;
  final String? phone;
  final String status;
  final int? classId;
  final String? className;
  final int? departmentId;
  final String? departmentName;
  final int? facultyId;
  final String? facultyName;

  const Student({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.status,
    this.phone,
    this.classId,
    this.className,
    this.departmentId,
    this.departmentName,
    this.facultyId,
    this.facultyName,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: (json['id'] as num).toInt(),
        studentId: (json['student_id'] as String?) ?? '',
        fullName: (json['full_name'] as String?) ?? '',
        status: (json['status'] as String?) ?? 'pending',
        phone: json['phone'] as String?,
        classId: (json['class_id'] as num?)?.toInt(),
        className: json['class_name'] as String?,
        departmentId: (json['department_id'] as num?)?.toInt(),
        departmentName: json['department_name'] as String?,
        facultyId: (json['faculty_id'] as num?)?.toInt(),
        facultyName: json['faculty_name'] as String?,
      );
}
