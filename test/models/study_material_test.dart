import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/models/study_material.dart';

void main() {
  group('StudyMaterial Model Tests', () {
    test('StudyMaterial should be created with required fields', () {
      final material = StudyMaterial(
        id: 'mat1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Math Notes',
        type: StudyMaterialType.note,
        fileUrl: 'https://example.com/file.pdf',
        uploadedAt: DateTime(2024, 1, 1),
      );

      expect(material.id, 'mat1');
      expect(material.courseId, 'course1');
      expect(material.studentId, 'student1');
      expect(material.title, 'Math Notes');
      expect(material.type, StudyMaterialType.note);
      expect(material.fileUrl, 'https://example.com/file.pdf');
      expect(material.description, null);
      expect(material.aiAnalysis, null);
    });

    test('StudyMaterial should be created with optional fields', () {
      final material = StudyMaterial(
        id: 'mat1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Physics Homework',
        type: StudyMaterialType.homework,
        fileUrl: 'https://example.com/homework.pdf',
        description: 'Chapter 5 exercises',
        aiAnalysis: 'AI analyzed content about mechanics',
        uploadedAt: DateTime(2024, 1, 1),
      );

      expect(material.description, 'Chapter 5 exercises');
      expect(material.aiAnalysis, 'AI analyzed content about mechanics');
    });

    test('StudyMaterial should support all material types', () {
      expect(StudyMaterialType.note, isNotNull);
      expect(StudyMaterialType.homework, isNotNull);
      expect(StudyMaterialType.pdf, isNotNull);
      expect(StudyMaterialType.image, isNotNull);
    });

    test('StudyMaterial toMap should convert to map correctly', () {
      final uploadedAt = DateTime(2024, 1, 1);
      final material = StudyMaterial(
        id: 'mat1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Chemistry PDF',
        type: StudyMaterialType.pdf,
        fileUrl: 'https://example.com/chem.pdf',
        description: 'Organic chemistry notes',
        aiAnalysis: 'Contains information about chemical bonds',
        uploadedAt: uploadedAt,
      );

      final map = material.toMap();

      expect(map['courseId'], 'course1');
      expect(map['studentId'], 'student1');
      expect(map['title'], 'Chemistry PDF');
      expect(map['type'], 'pdf');
      expect(map['fileUrl'], 'https://example.com/chem.pdf');
      expect(map['description'], 'Organic chemistry notes');
      expect(map['aiAnalysis'], 'Contains information about chemical bonds');
      expect(map['uploadedAt'], uploadedAt.toIso8601String());
    });

    test('StudyMaterial fromMap should create material from map', () {
      final uploadedAt = DateTime(2024, 1, 1);
      final map = {
        'courseId': 'course1',
        'studentId': 'student1',
        'title': 'Biology Image',
        'type': 'image',
        'fileUrl': 'https://example.com/cell.jpg',
        'description': 'Cell structure diagram',
        'aiAnalysis': 'Image shows plant cell with labeled parts',
        'uploadedAt': uploadedAt.toIso8601String(),
      };

      final material = StudyMaterial.fromMap(map, 'mat1');

      expect(material.id, 'mat1');
      expect(material.courseId, 'course1');
      expect(material.studentId, 'student1');
      expect(material.title, 'Biology Image');
      expect(material.type, StudyMaterialType.image);
      expect(material.fileUrl, 'https://example.com/cell.jpg');
      expect(material.description, 'Cell structure diagram');
      expect(material.aiAnalysis, 'Image shows plant cell with labeled parts');
      expect(material.uploadedAt, uploadedAt);
    });

    test('StudyMaterial fromMap should handle null optional fields', () {
      final uploadedAt = DateTime(2024, 1, 1);
      final map = {
        'courseId': 'course1',
        'studentId': 'student1',
        'title': 'History Notes',
        'type': 'note',
        'fileUrl': 'https://example.com/history.txt',
        'uploadedAt': uploadedAt.toIso8601String(),
      };

      final material = StudyMaterial.fromMap(map, 'mat1');

      expect(material.description, null);
      expect(material.aiAnalysis, null);
    });

    test('StudyMaterial fromMap should handle unknown type', () {
      final uploadedAt = DateTime(2024, 1, 1);
      final map = {
        'courseId': 'course1',
        'studentId': 'student1',
        'title': 'Unknown Type',
        'type': 'unknown_type',
        'fileUrl': 'https://example.com/file.txt',
        'uploadedAt': uploadedAt.toIso8601String(),
      };

      final material = StudyMaterial.fromMap(map, 'mat1');

      // Should default to note type
      expect(material.type, StudyMaterialType.note);
    });

    test('StudyMaterial serialization roundtrip should preserve data', () {
      final uploadedAt = DateTime(2024, 1, 1);
      final original = StudyMaterial(
        id: 'mat1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Complete Homework',
        type: StudyMaterialType.homework,
        fileUrl: 'https://example.com/complete.pdf',
        description: 'Final project submission',
        aiAnalysis: 'Comprehensive analysis of the submitted work',
        uploadedAt: uploadedAt,
      );

      final map = original.toMap();
      final reconstructed = StudyMaterial.fromMap(map, original.id);

      expect(reconstructed.id, original.id);
      expect(reconstructed.courseId, original.courseId);
      expect(reconstructed.studentId, original.studentId);
      expect(reconstructed.title, original.title);
      expect(reconstructed.type, original.type);
      expect(reconstructed.fileUrl, original.fileUrl);
      expect(reconstructed.description, original.description);
      expect(reconstructed.aiAnalysis, original.aiAnalysis);
      expect(reconstructed.uploadedAt, original.uploadedAt);
    });

    test('StudyMaterial should correctly serialize all material types', () {
      final types = [
        StudyMaterialType.note,
        StudyMaterialType.homework,
        StudyMaterialType.pdf,
        StudyMaterialType.image,
      ];

      for (final type in types) {
        final material = StudyMaterial(
          id: 'mat1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'Test Material',
          type: type,
          fileUrl: 'https://example.com/file',
          uploadedAt: DateTime.now(),
        );

        final map = material.toMap();
        final reconstructed = StudyMaterial.fromMap(map, 'mat1');

        expect(reconstructed.type, type, reason: 'Failed for type: $type');
      }
    });
  });
}
