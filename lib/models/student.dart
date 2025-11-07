class Student {
  final String id;
  final String fullName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  
  // Yeni profil bilgileri
  final int? grade; // Sınıf seviyesi (9, 10, 11, 12)
  final List<String>? favoriteCourses; // Sevdiği dersler
  final List<String>? difficultCourses; // Zorlandığı dersler
  final String? learningStyle; // Öğrenme stili (görsel, işitsel, okuma-yazma, kinestetik)
  final String? studyGoals; // Hedefler ve amaçlar
  final String? schoolName; // Okul adı
  final String? notes; // Ek notlar

  Student({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.grade,
    this.favoriteCourses,
    this.difficultCourses,
    this.learningStyle,
    this.studyGoals,
    this.schoolName,
    this.notes,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      grade: map['grade'] as int?,
      favoriteCourses: map['favoriteCourses'] != null
          ? List<String>.from(map['favoriteCourses'])
          : null,
      difficultCourses: map['difficultCourses'] != null
          ? List<String>.from(map['difficultCourses'])
          : null,
      learningStyle: map['learningStyle'] as String?,
      studyGoals: map['studyGoals'] as String?,
      schoolName: map['schoolName'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'grade': grade,
      'favoriteCourses': favoriteCourses,
      'difficultCourses': difficultCourses,
      'learningStyle': learningStyle,
      'studyGoals': studyGoals,
      'schoolName': schoolName,
      'notes': notes,
    };
  }

  // Copy with method for updates
  Student copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
    int? grade,
    List<String>? favoriteCourses,
    List<String>? difficultCourses,
    String? learningStyle,
    String? studyGoals,
    String? schoolName,
    String? notes,
  }) {
    return Student(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      grade: grade ?? this.grade,
      favoriteCourses: favoriteCourses ?? this.favoriteCourses,
      difficultCourses: difficultCourses ?? this.difficultCourses,
      learningStyle: learningStyle ?? this.learningStyle,
      studyGoals: studyGoals ?? this.studyGoals,
      schoolName: schoolName ?? this.schoolName,
      notes: notes ?? this.notes,
    );
  }
}

