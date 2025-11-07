import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/models/course.dart';

void main() {
  group('Course Model Tests', () {
    test('Course should be created with required fields', () {
      final course = Course(
        id: 'course1',
        studentId: 'student1',
        name: 'Mathematics',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(course.id, 'course1');
      expect(course.studentId, 'student1');
      expect(course.name, 'Mathematics');
      expect(course.uploadedFilesCount, 0);
      expect(course.teacherName, null);
      expect(course.description, null);
      expect(course.nextExamDate, null);
    });

    test('Course should be created with optional fields', () {
      final examDate = DateTime(2024, 12, 31);
      final course = Course(
        id: 'course1',
        studentId: 'student1',
        name: 'Physics',
        teacherName: 'Dr. Smith',
        description: 'Advanced Physics Course',
        nextExamDate: examDate,
        uploadedFilesCount: 5,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(course.teacherName, 'Dr. Smith');
      expect(course.description, 'Advanced Physics Course');
      expect(course.nextExamDate, examDate);
      expect(course.uploadedFilesCount, 5);
    });

    test('Course toMap should convert to map correctly', () {
      final examDate = DateTime(2024, 12, 31);
      final createdAt = DateTime(2024, 1, 1);
      final course = Course(
        id: 'course1',
        studentId: 'student1',
        name: 'Chemistry',
        teacherName: 'Prof. Johnson',
        description: 'Organic Chemistry',
        nextExamDate: examDate,
        uploadedFilesCount: 3,
        createdAt: createdAt,
      );

      final map = course.toMap();

      expect(map['studentId'], 'student1');
      expect(map['name'], 'Chemistry');
      expect(map['teacherName'], 'Prof. Johnson');
      expect(map['description'], 'Organic Chemistry');
      expect(map['nextExamDate'], examDate.toIso8601String());
      expect(map['uploadedFilesCount'], 3);
      expect(map['createdAt'], createdAt.toIso8601String());
    });

    test('Course fromMap should create course from map', () {
      final examDate = DateTime(2024, 12, 31);
      final createdAt = DateTime(2024, 1, 1);
      final map = {
        'studentId': 'student1',
        'name': 'Biology',
        'teacherName': 'Dr. Williams',
        'description': 'Molecular Biology',
        'nextExamDate': examDate.toIso8601String(),
        'uploadedFilesCount': 7,
        'createdAt': createdAt.toIso8601String(),
      };

      final course = Course.fromMap(map, 'course1');

      expect(course.id, 'course1');
      expect(course.studentId, 'student1');
      expect(course.name, 'Biology');
      expect(course.teacherName, 'Dr. Williams');
      expect(course.description, 'Molecular Biology');
      expect(course.nextExamDate, examDate);
      expect(course.uploadedFilesCount, 7);
      expect(course.createdAt, createdAt);
    });

    test('Course fromMap should handle null optional fields', () {
      final createdAt = DateTime(2024, 1, 1);
      final map = {
        'studentId': 'student1',
        'name': 'History',
        'createdAt': createdAt.toIso8601String(),
      };

      final course = Course.fromMap(map, 'course1');

      expect(course.teacherName, null);
      expect(course.description, null);
      expect(course.nextExamDate, null);
      expect(course.uploadedFilesCount, 0);
    });

    test('Course copyWith should create new instance with updated fields', () {
      final course = Course(
        id: 'course1',
        studentId: 'student1',
        name: 'Geography',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedCourse = course.copyWith(
        name: 'Advanced Geography',
        teacherName: 'Prof. Brown',
        uploadedFilesCount: 10,
      );

      expect(updatedCourse.id, 'course1');
      expect(updatedCourse.studentId, 'student1');
      expect(updatedCourse.name, 'Advanced Geography');
      expect(updatedCourse.teacherName, 'Prof. Brown');
      expect(updatedCourse.uploadedFilesCount, 10);
      expect(updatedCourse.createdAt, course.createdAt);
    });

    test('Course copyWith should keep original values if not specified', () {
      final course = Course(
        id: 'course1',
        studentId: 'student1',
        name: 'Literature',
        teacherName: 'Dr. Davis',
        uploadedFilesCount: 5,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedCourse = course.copyWith(name: 'Modern Literature');

      expect(updatedCourse.teacherName, 'Dr. Davis');
      expect(updatedCourse.uploadedFilesCount, 5);
    });

    test('Course serialization roundtrip should preserve data', () {
      final examDate = DateTime(2024, 12, 31);
      final createdAt = DateTime(2024, 1, 1);
      final originalCourse = Course(
        id: 'course1',
        studentId: 'student1',
        name: 'Computer Science',
        teacherName: 'Prof. Wilson',
        description: 'Data Structures',
        nextExamDate: examDate,
        uploadedFilesCount: 12,
        createdAt: createdAt,
      );

      final map = originalCourse.toMap();
      final reconstructedCourse = Course.fromMap(map, originalCourse.id);

      expect(reconstructedCourse.id, originalCourse.id);
      expect(reconstructedCourse.studentId, originalCourse.studentId);
      expect(reconstructedCourse.name, originalCourse.name);
      expect(reconstructedCourse.teacherName, originalCourse.teacherName);
      expect(reconstructedCourse.description, originalCourse.description);
      expect(reconstructedCourse.nextExamDate, originalCourse.nextExamDate);
      expect(reconstructedCourse.uploadedFilesCount, originalCourse.uploadedFilesCount);
      expect(reconstructedCourse.createdAt, originalCourse.createdAt);
    });
  });
}
