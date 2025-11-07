import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/models/test.dart';

void main() {
  group('Question Model Tests', () {
    test('Question should be created with all fields', () {
      final question = Question(
        id: 'q1',
        question: 'What is 2+2?',
        options: ['2', '3', '4', '5'],
        correctAnswerIndex: 2,
        explanation: '2+2 equals 4',
      );

      expect(question.id, 'q1');
      expect(question.question, 'What is 2+2?');
      expect(question.options.length, 4);
      expect(question.correctAnswerIndex, 2);
      expect(question.explanation, '2+2 equals 4');
    });

    test('Question correctAnswerValue should return correct option', () {
      final question = Question(
        id: 'q1',
        question: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswerIndex: 2,
      );

      expect(question.correctAnswerValue, 'Paris');
    });

    test('Question correctAnswerKey should return correct letter', () {
      final question = Question(
        id: 'q1',
        question: 'Test question',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 0,
      );
      expect(question.correctAnswerKey, 'A');

      final question2 = Question(
        id: 'q2',
        question: 'Test question',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 3,
      );
      expect(question2.correctAnswerKey, 'D');
    });

    test('Question correctAnswerValue should return N/A for invalid index', () {
      final question = Question(
        id: 'q1',
        question: 'Test',
        options: ['A', 'B'],
        correctAnswerIndex: 5,
      );

      expect(question.correctAnswerValue, 'N/A');
      expect(question.correctAnswerKey, 'N/A');
    });

    test('Question toMap should convert to map correctly', () {
      final question = Question(
        id: 'q1',
        question: 'What is AI?',
        options: ['Artificial Intelligence', 'Actual Intelligence', 'None', 'Both'],
        correctAnswerIndex: 0,
        explanation: 'AI stands for Artificial Intelligence',
      );

      final map = question.toMap();

      expect(map['id'], 'q1');
      expect(map['question'], 'What is AI?');
      expect(map['options'], ['Artificial Intelligence', 'Actual Intelligence', 'None', 'Both']);
      expect(map['correctAnswerIndex'], 0);
      expect(map['explanation'], 'AI stands for Artificial Intelligence');
    });

    test('Question fromMap should create question from map', () {
      final map = {
        'id': 'q1',
        'question': 'Test question?',
        'options': ['Option 1', 'Option 2', 'Option 3'],
        'correctAnswerIndex': 1,
        'explanation': 'This is the explanation',
      };

      final question = Question.fromMap(map);

      expect(question.id, 'q1');
      expect(question.question, 'Test question?');
      expect(question.options, ['Option 1', 'Option 2', 'Option 3']);
      expect(question.correctAnswerIndex, 1);
      expect(question.explanation, 'This is the explanation');
    });

    test('Question serialization roundtrip should preserve data', () {
      final original = Question(
        id: 'q1',
        question: 'Sample question?',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 2,
        explanation: 'Explanation text',
      );

      final map = original.toMap();
      final reconstructed = Question.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.question, original.question);
      expect(reconstructed.options, original.options);
      expect(reconstructed.correctAnswerIndex, original.correctAnswerIndex);
      expect(reconstructed.explanation, original.explanation);
    });
  });

  group('Test Model Tests', () {
    final question1 = Question(
      id: 'q1',
      question: 'Question 1?',
      options: ['A', 'B', 'C', 'D'],
      correctAnswerIndex: 0,
    );

    final question2 = Question(
      id: 'q2',
      question: 'Question 2?',
      options: ['A', 'B', 'C', 'D'],
      correctAnswerIndex: 1,
    );

    test('Test should be created with required fields', () {
      final test = Test(
        id: 'test1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Math Test',
        questions: [question1, question2],
        createdAt: DateTime(2024, 1, 1),
      );

      expect(test.id, 'test1');
      expect(test.courseId, 'course1');
      expect(test.studentId, 'student1');
      expect(test.title, 'Math Test');
      expect(test.questions.length, 2);
      expect(test.completedAt, null);
      expect(test.studentAnswers, null);
      expect(test.score, null);
      expect(test.isCompleted, false);
    });

    test('Test should be created with completion data', () {
      final completedAt = DateTime(2024, 1, 2);
      final test = Test(
        id: 'test1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Physics Test',
        questions: [question1],
        createdAt: DateTime(2024, 1, 1),
        completedAt: completedAt,
        studentAnswers: {'q1': '0'},
        score: 85.5,
      );

      expect(test.completedAt, completedAt);
      expect(test.studentAnswers, {'q1': '0'});
      expect(test.score, 85.5);
      expect(test.isCompleted, true);
    });

    test('Test isCompleted should return correct value', () {
      final test1 = Test(
        id: 'test1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Test',
        questions: [question1],
        createdAt: DateTime.now(),
      );
      expect(test1.isCompleted, false);

      final test2 = Test(
        id: 'test2',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Test',
        questions: [question1],
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      expect(test2.isCompleted, true);
    });

    test('Test toMap should convert to map correctly', () {
      final createdAt = DateTime(2024, 1, 1);
      final completedAt = DateTime(2024, 1, 2);
      final test = Test(
        id: 'test1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Chemistry Test',
        questions: [question1, question2],
        createdAt: createdAt,
        completedAt: completedAt,
        studentAnswers: {'q1': '0', 'q2': '1'},
        score: 90.0,
      );

      final map = test.toMap();

      expect(map['courseId'], 'course1');
      expect(map['studentId'], 'student1');
      expect(map['title'], 'Chemistry Test');
      expect(map['questions'].length, 2);
      expect(map['createdAt'], createdAt.toIso8601String());
      expect(map['completedAt'], completedAt.toIso8601String());
      expect(map['studentAnswers'], {'q1': '0', 'q2': '1'});
      expect(map['score'], 90.0);
    });

    test('Test fromMap should create test from map', () {
      final createdAt = DateTime(2024, 1, 1);
      final completedAt = DateTime(2024, 1, 2);
      final map = {
        'courseId': 'course1',
        'studentId': 'student1',
        'title': 'Biology Test',
        'questions': [
          question1.toMap(),
          question2.toMap(),
        ],
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'studentAnswers': {'q1': '0'},
        'score': 75.5,
      };

      final test = Test.fromMap(map, 'test1');

      expect(test.id, 'test1');
      expect(test.courseId, 'course1');
      expect(test.studentId, 'student1');
      expect(test.title, 'Biology Test');
      expect(test.questions.length, 2);
      expect(test.createdAt, createdAt);
      expect(test.completedAt, completedAt);
      expect(test.studentAnswers, {'q1': '0'});
      expect(test.score, 75.5);
    });

    test('Test fromMap should handle incomplete test', () {
      final createdAt = DateTime(2024, 1, 1);
      final map = {
        'courseId': 'course1',
        'studentId': 'student1',
        'title': 'History Test',
        'questions': [question1.toMap()],
        'createdAt': createdAt.toIso8601String(),
      };

      final test = Test.fromMap(map, 'test1');

      expect(test.completedAt, null);
      expect(test.studentAnswers, null);
      expect(test.score, null);
      expect(test.isCompleted, false);
    });

    test('Test serialization roundtrip should preserve data', () {
      final createdAt = DateTime(2024, 1, 1);
      final completedAt = DateTime(2024, 1, 2);
      final original = Test(
        id: 'test1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Final Exam',
        questions: [question1, question2],
        createdAt: createdAt,
        completedAt: completedAt,
        studentAnswers: {'q1': '0', 'q2': '1'},
        score: 95.0,
      );

      final map = original.toMap();
      final reconstructed = Test.fromMap(map, original.id);

      expect(reconstructed.id, original.id);
      expect(reconstructed.courseId, original.courseId);
      expect(reconstructed.studentId, original.studentId);
      expect(reconstructed.title, original.title);
      expect(reconstructed.questions.length, original.questions.length);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.completedAt, original.completedAt);
      expect(reconstructed.studentAnswers, original.studentAnswers);
      expect(reconstructed.score, original.score);
    });
  });
}
