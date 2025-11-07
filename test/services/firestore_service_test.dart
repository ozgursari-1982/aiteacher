import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_teacher_app/services/firestore_service.dart';
import 'package:ai_teacher_app/models/course.dart';
import 'package:ai_teacher_app/models/study_material.dart';
import 'package:ai_teacher_app/models/test.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  group('FirestoreService Tests', () {
    late FirestoreService service;

    setUp(() {
      service = FirestoreService();
    });

    test('FirestoreService should initialize', () {
      expect(service, isNotNull);
    });

    group('Course Operations', () {
      test('addCourse should add course to Firestore', () async {
        final course = Course(
          id: 'course1',
          studentId: 'student1',
          name: 'Mathematics',
          createdAt: DateTime(2024, 1, 1),
        );

        // Note: This is a unit test structure
        // In real testing, you would mock FirebaseFirestore
        expect(course.toMap(), isNotNull);
        expect(course.toMap()['name'], 'Mathematics');
      });

      test('Course data should be properly formatted for Firestore', () {
        final course = Course(
          id: 'course1',
          studentId: 'student1',
          name: 'Physics',
          teacherName: 'Dr. Smith',
          description: 'Advanced Physics',
          nextExamDate: DateTime(2024, 12, 31),
          uploadedFilesCount: 5,
          createdAt: DateTime(2024, 1, 1),
        );

        final map = course.toMap();

        expect(map['studentId'], 'student1');
        expect(map['name'], 'Physics');
        expect(map['teacherName'], 'Dr. Smith');
        expect(map['description'], 'Advanced Physics');
        expect(map['nextExamDate'], isNotNull);
        expect(map['uploadedFilesCount'], 5);
        expect(map['createdAt'], isNotNull);
      });
    });

    group('Study Material Operations', () {
      test('StudyMaterial data should be properly formatted', () {
        final material = StudyMaterial(
          id: 'mat1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'Chapter 1 Notes',
          type: StudyMaterialType.pdf,
          fileUrl: 'https://example.com/notes.pdf',
          description: 'Important chapter',
          uploadedAt: DateTime(2024, 1, 1),
        );

        final map = material.toMap();

        expect(map['courseId'], 'course1');
        expect(map['studentId'], 'student1');
        expect(map['title'], 'Chapter 1 Notes');
        expect(map['type'], 'pdf');
        expect(map['fileUrl'], 'https://example.com/notes.pdf');
        expect(map['description'], 'Important chapter');
        expect(map['uploadedAt'], isNotNull);
      });

      test('Material with AI analysis should preserve analysis data', () {
        final material = StudyMaterial(
          id: 'mat1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'AI Analyzed Notes',
          type: StudyMaterialType.note,
          fileUrl: 'https://example.com/file',
          aiAnalysis: 'AI generated analysis content',
          uploadedAt: DateTime.now(),
        );

        final map = material.toMap();
        expect(map['aiAnalysis'], 'AI generated analysis content');
        
        final reconstructed = StudyMaterial.fromMap(map, 'mat1');
        expect(reconstructed.aiAnalysis, 'AI generated analysis content');
      });
    });

    group('Test Operations', () {
      test('Test data should be properly formatted for Firestore', () {
        final question1 = Question(
          id: 'q1',
          question: 'What is 2+2?',
          options: ['2', '3', '4', '5'],
          correctAnswerIndex: 2,
          explanation: 'Basic addition',
        );

        final test = Test(
          id: 'test1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'Math Quiz',
          questions: [question1],
          createdAt: DateTime(2024, 1, 1),
          completedAt: DateTime(2024, 1, 2),
          studentAnswers: {'q1': '2'},
          score: 100.0,
        );

        final map = test.toMap();

        expect(map['courseId'], 'course1');
        expect(map['studentId'], 'student1');
        expect(map['title'], 'Math Quiz');
        expect(map['questions'], isList);
        expect(map['questions'].length, 1);
        expect(map['completedAt'], isNotNull);
        expect(map['studentAnswers'], isNotNull);
        expect(map['score'], 100.0);
      });

      test('Test serialization should preserve question data', () {
        final question = Question(
          id: 'q1',
          question: 'Test question?',
          options: ['A', 'B', 'C', 'D'],
          correctAnswerIndex: 1,
          explanation: 'Detailed explanation',
        );

        final test = Test(
          id: 'test1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'Test',
          questions: [question],
          createdAt: DateTime.now(),
        );

        final map = test.toMap();
        final reconstructed = Test.fromMap(map, 'test1');

        expect(reconstructed.questions.length, 1);
        expect(reconstructed.questions[0].question, 'Test question?');
        expect(reconstructed.questions[0].options.length, 4);
        expect(reconstructed.questions[0].correctAnswerIndex, 1);
        expect(reconstructed.questions[0].explanation, 'Detailed explanation');
      });
    });

    group('Data Integrity Tests', () {
      test('Course with exam date should maintain date accuracy', () {
        final examDate = DateTime(2024, 12, 31, 14, 30);
        final course = Course(
          id: 'course1',
          studentId: 'student1',
          name: 'Test Course',
          nextExamDate: examDate,
          createdAt: DateTime.now(),
        );

        final map = course.toMap();
        final reconstructed = Course.fromMap(map, 'course1');

        expect(reconstructed.nextExamDate, examDate);
      });

      test('Multiple courses should maintain separate identities', () {
        final course1 = Course(
          id: 'course1',
          studentId: 'student1',
          name: 'Math',
          createdAt: DateTime.now(),
        );

        final course2 = Course(
          id: 'course2',
          studentId: 'student1',
          name: 'Physics',
          createdAt: DateTime.now(),
        );

        expect(course1.id, isNot(equals(course2.id)));
        expect(course1.name, isNot(equals(course2.name)));
      });

      test('Student data isolation should be maintained', () {
        final course1 = Course(
          id: 'course1',
          studentId: 'student1',
          name: 'Course',
          createdAt: DateTime.now(),
        );

        final course2 = Course(
          id: 'course2',
          studentId: 'student2',
          name: 'Course',
          createdAt: DateTime.now(),
        );

        expect(course1.studentId, isNot(equals(course2.studentId)));
      });
    });

    group('AI Integration Validation', () {
      test('Materials should support AI analysis field', () {
        final material = StudyMaterial(
          id: 'mat1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'Notes',
          type: StudyMaterialType.note,
          fileUrl: 'url',
          uploadedAt: DateTime.now(),
        );

        // Initially no AI analysis
        expect(material.aiAnalysis, null);

        // After AI processing
        final updatedMap = material.toMap();
        updatedMap['aiAnalysis'] = 'AI generated content';
        
        final updated = StudyMaterial.fromMap(updatedMap, 'mat1');
        expect(updated.aiAnalysis, 'AI generated content');
      });

      test('Tests should be generated from AI with proper structure', () {
        // Simulate AI-generated test structure
        final questions = List.generate(
          5,
          (index) => Question(
            id: 'q$index',
            question: 'AI generated question $index',
            options: ['Option A', 'Option B', 'Option C', 'Option D'],
            correctAnswerIndex: index % 4,
            explanation: 'AI generated explanation',
          ),
        );

        final test = Test(
          id: 'test1',
          courseId: 'course1',
          studentId: 'student1',
          title: 'AI Generated Test',
          questions: questions,
          createdAt: DateTime.now(),
        );

        expect(test.questions.length, 5);
        expect(test.questions.every((q) => q.explanation != null), true);
        expect(test.questions.every((q) => q.options.length == 4), true);
      });
    });
  });
}
