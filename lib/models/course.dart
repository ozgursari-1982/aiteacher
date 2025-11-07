class Course {
  final String id;
  final String studentId;
  final String name;
  final String? teacherName;
  final String? description;
  final DateTime? nextExamDate;
  final int uploadedFilesCount;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.studentId,
    required this.name,
    this.teacherName,
    this.description,
    this.nextExamDate,
    this.uploadedFilesCount = 0,
    required this.createdAt,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      teacherName: map['teacherName'],
      description: map['description'],
      nextExamDate: map['nextExamDate'] != null
          ? DateTime.parse(map['nextExamDate'])
          : null,
      uploadedFilesCount: map['uploadedFilesCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'teacherName': teacherName,
      'description': description,
      'nextExamDate': nextExamDate?.toIso8601String(),
      'uploadedFilesCount': uploadedFilesCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Course copyWith({
    String? id,
    String? studentId,
    String? name,
    String? teacherName,
    String? description,
    DateTime? nextExamDate,
    int? uploadedFilesCount,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      description: description ?? this.description,
      nextExamDate: nextExamDate ?? this.nextExamDate,
      uploadedFilesCount: uploadedFilesCount ?? this.uploadedFilesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

