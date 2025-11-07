import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/models/student.dart';

void main() {
  group('Student Model Tests', () {
    test('Student should be created with required fields', () {
      final student = Student(
        id: 'student1',
        fullName: 'John Doe',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(student.id, 'student1');
      expect(student.fullName, 'John Doe');
      expect(student.email, 'john@example.com');
      expect(student.photoUrl, null);
      expect(student.createdAt, DateTime(2024, 1, 1));
    });

    test('Student should be created with optional photoUrl', () {
      final student = Student(
        id: 'student1',
        fullName: 'Jane Smith',
        email: 'jane@example.com',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(student.photoUrl, 'https://example.com/photo.jpg');
    });

    test('Student toMap should convert to map correctly', () {
      final createdAt = DateTime(2024, 1, 1);
      final student = Student(
        id: 'student1',
        fullName: 'Alice Johnson',
        email: 'alice@example.com',
        photoUrl: 'https://example.com/alice.jpg',
        createdAt: createdAt,
      );

      final map = student.toMap();

      expect(map['fullName'], 'Alice Johnson');
      expect(map['email'], 'alice@example.com');
      expect(map['photoUrl'], 'https://example.com/alice.jpg');
      expect(map['createdAt'], createdAt.toIso8601String());
    });

    test('Student fromMap should create student from map', () {
      final createdAt = DateTime(2024, 1, 1);
      final map = {
        'fullName': 'Bob Williams',
        'email': 'bob@example.com',
        'photoUrl': 'https://example.com/bob.jpg',
        'createdAt': createdAt.toIso8601String(),
      };

      final student = Student.fromMap(map, 'student1');

      expect(student.id, 'student1');
      expect(student.fullName, 'Bob Williams');
      expect(student.email, 'bob@example.com');
      expect(student.photoUrl, 'https://example.com/bob.jpg');
      expect(student.createdAt, createdAt);
    });

    test('Student fromMap should handle null photoUrl', () {
      final createdAt = DateTime(2024, 1, 1);
      final map = {
        'fullName': 'Carol Davis',
        'email': 'carol@example.com',
        'createdAt': createdAt.toIso8601String(),
      };

      final student = Student.fromMap(map, 'student1');

      expect(student.photoUrl, null);
    });

    test('Student serialization roundtrip should preserve data', () {
      final createdAt = DateTime(2024, 1, 1);
      final originalStudent = Student(
        id: 'student1',
        fullName: 'David Brown',
        email: 'david@example.com',
        photoUrl: 'https://example.com/david.jpg',
        createdAt: createdAt,
      );

      final map = originalStudent.toMap();
      final reconstructedStudent = Student.fromMap(map, originalStudent.id);

      expect(reconstructedStudent.id, originalStudent.id);
      expect(reconstructedStudent.fullName, originalStudent.fullName);
      expect(reconstructedStudent.email, originalStudent.email);
      expect(reconstructedStudent.photoUrl, originalStudent.photoUrl);
      expect(reconstructedStudent.createdAt, originalStudent.createdAt);
    });

    test('Student should handle email validation edge cases', () {
      // Test various valid email formats
      final student1 = Student(
        id: 'student1',
        fullName: 'Test User',
        email: 'test.user@example.com',
        createdAt: DateTime.now(),
      );
      expect(student1.email, 'test.user@example.com');

      final student2 = Student(
        id: 'student2',
        fullName: 'Test User',
        email: 'test+tag@example.co.uk',
        createdAt: DateTime.now(),
      );
      expect(student2.email, 'test+tag@example.co.uk');
    });
  });
}
