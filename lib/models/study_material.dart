enum StudyMaterialType {
  note,
  homework,
  pdf,
  image,
}

class StudyMaterial {
  final String id;
  final String courseId;
  final String studentId;
  final String title;
  final StudyMaterialType type;
  final String fileUrl;
  final String? description;
  final String? aiAnalysis;
  final DateTime uploadedAt;

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.title,
    required this.type,
    required this.fileUrl,
    this.description,
    this.aiAnalysis,
    required this.uploadedAt,
  });

  factory StudyMaterial.fromMap(Map<String, dynamic> map, String id) {
    return StudyMaterial(
      id: id,
      courseId: map['courseId'] ?? '',
      studentId: map['studentId'] ?? '',
      title: map['title'] ?? '',
      type: StudyMaterialType.values.firstWhere(
        (e) => e.toString() == 'StudyMaterialType.${map['type']}',
        orElse: () => StudyMaterialType.note,
      ),
      fileUrl: map['fileUrl'] ?? '',
      description: map['description'],
      aiAnalysis: map['aiAnalysis'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'studentId': studentId,
      'title': title,
      'type': type.toString().split('.').last,
      'fileUrl': fileUrl,
      'description': description,
      'aiAnalysis': aiAnalysis,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

