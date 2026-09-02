class Teacher {
  final String id;
  final String fullName;
  final String username;
  final String facultyId;
  final String facultyName;

  const Teacher({
    required this.id,
    required this.fullName,
    required this.username,
    required this.facultyId,
    required this.facultyName,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: (json['teacher_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      facultyId: (json['faculty_id'] ?? '').toString(),
      facultyName: (json['faculty_name'] ?? '') as String,
    );
  }
}
