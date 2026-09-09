class LessonMaterial {
  final int id;
  final int subjectClassId;
  final String title;
  final String? description;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String status;
  final String? subjectName;
  final String? className;
  final String? departmentName;
  final String? facultyName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LessonMaterial({
    required this.id,
    required this.subjectClassId,
    required this.title,
    this.description,
    this.filePath,
    this.fileName,
    this.fileSize,
    required this.status,
    this.subjectName,
    this.className,
    this.departmentName,
    this.facultyName,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonMaterial.fromJson(Map<String, dynamic> json) {
    return LessonMaterial(
      id: json['id'] is int
          ? json['id']
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      subjectClassId: json['subject_class_id'] is int
          ? json['subject_class_id']
          : int.tryParse('${json['subject_class_id'] ?? 0}') ?? 0,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      filePath: json['file_path'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] is int
          ? json['file_size']
          : int.tryParse('${json['file_size'] ?? 0}'),
      status: (json['status'] ?? 'active') as String,
      subjectName: json['subject_name'] as String?,
      className: json['class_name'] as String?,
      departmentName: json['department_name'] as String?,
      facultyName: json['faculty_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  String get fileSizeLabel {
    if (fileSize == null || fileSize == 0) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
