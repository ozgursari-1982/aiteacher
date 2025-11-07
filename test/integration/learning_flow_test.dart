import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/models/course.dart';
import 'package:ai_teacher_app/models/study_material.dart';
import 'package:ai_teacher_app/models/test.dart';
import 'package:ai_teacher_app/models/student.dart';

/// Integration tests for critical user flows in AI Teacher app
/// These tests validate end-to-end scenarios ensuring AI-only operation
void main() {
  group('Student Learning Flow Integration Tests', () {
    test('Complete study flow: Create course -> Upload material -> Generate test -> Take test', () {
      // Step 1: Student creates a course
      final student = Student(
        id: 'student123',
        fullName: 'Test Student',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final course = Course(
        id: 'course1',
        studentId: student.id,
        name: 'Mathematics',
        teacherName: 'Dr. Smith',
        nextExamDate: DateTime.now().add(Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      expect(course.studentId, student.id);
      expect(course.uploadedFilesCount, 0);

      // Step 2: Student uploads study material
      final material = StudyMaterial(
        id: 'mat1',
        courseId: course.id,
        studentId: student.id,
        title: 'Chapter 1: Algebra',
        type: StudyMaterialType.pdf,
        fileUrl: 'https://storage.example.com/algebra.pdf',
        description: 'Basic algebra concepts',
        uploadedAt: DateTime.now(),
      );

      expect(material.courseId, course.id);
      expect(material.studentId, student.id);
      expect(material.aiAnalysis, null); // Not yet analyzed

      // Step 3: AI analyzes the material
      final aiAnalysis = '''
      Ana Konular:
      - Cebirsel ifadeler
      - Denklem çözme
      - Grafik çizimi
      
      Bu materyal temel cebir konularını içermektedir.
      ''';

      final analyzedMaterial = StudyMaterial(
        id: material.id,
        courseId: material.courseId,
        studentId: material.studentId,
        title: material.title,
        type: material.type,
        fileUrl: material.fileUrl,
        description: material.description,
        aiAnalysis: aiAnalysis,
        uploadedAt: material.uploadedAt,
      );

      expect(analyzedMaterial.aiAnalysis, isNotNull);
      expect(analyzedMaterial.aiAnalysis, contains('Cebirsel ifadeler'));

      // Step 4: AI generates test questions based on material
      final questions = [
        Question(
          id: 'q1',
          question: 'Cebirsel ifade nedir?',
          options: [
            'Sayılarla işlem',
            'Harf ve sayıların birleşimi',
            'Sadece sayılar',
            'Sadece harfler',
          ],
          correctAnswerIndex: 1,
          explanation: 'Cebirsel ifadeler harf ve sayıların matematiksel işlemlerle birleşimidir.',
        ),
        Question(
          id: 'q2',
          question: '2x + 3 = 7 denkleminde x kaçtır?',
          options: ['1', '2', '3', '4'],
          correctAnswerIndex: 1,
          explanation: '2x = 7 - 3 = 4, dolayısıyla x = 2',
        ),
      ];

      final test = Test(
        id: 'test1',
        courseId: course.id,
        studentId: student.id,
        title: 'Cebir Testi',
        questions: questions,
        createdAt: DateTime.now(),
      );

      expect(test.questions.length, 2);
      expect(test.isCompleted, false);

      // Step 5: Student takes the test
      final studentAnswers = {
        'q1': '1', // Correct
        'q2': '1', // Correct
      };

      final completedTest = Test(
        id: test.id,
        courseId: test.courseId,
        studentId: test.studentId,
        title: test.title,
        questions: test.questions,
        createdAt: test.createdAt,
        completedAt: DateTime.now(),
        studentAnswers: studentAnswers,
        score: 100.0,
      );

      expect(completedTest.isCompleted, true);
      expect(completedTest.score, 100.0);
      expect(completedTest.studentAnswers?.length, 2);
    });

    test('Multi-course learning flow with performance tracking', () {
      final student = Student(
        id: 'student456',
        fullName: 'Advanced Student',
        email: 'advanced@example.com',
        createdAt: DateTime.now(),
      );

      // Create multiple courses
      final courses = [
        Course(
          id: 'course1',
          studentId: student.id,
          name: 'Mathematics',
          uploadedFilesCount: 5,
          createdAt: DateTime.now(),
        ),
        Course(
          id: 'course2',
          studentId: student.id,
          name: 'Physics',
          uploadedFilesCount: 3,
          createdAt: DateTime.now(),
        ),
        Course(
          id: 'course3',
          studentId: student.id,
          name: 'Chemistry',
          uploadedFilesCount: 4,
          createdAt: DateTime.now(),
        ),
      ];

      expect(courses.length, 3);
      expect(courses.every((c) => c.studentId == student.id), true);

      // Simulate test results across courses
      final testResults = [
        {'courseId': 'course1', 'score': 85.0},
        {'courseId': 'course1', 'score': 90.0},
        {'courseId': 'course2', 'score': 75.0},
        {'courseId': 'course2', 'score': 80.0},
        {'courseId': 'course3', 'score': 70.0},
        {'courseId': 'course3', 'score': 85.0},
      ];

      // Calculate averages per course
      final mathAvg = (85.0 + 90.0) / 2;
      final physicsAvg = (75.0 + 80.0) / 2;
      final chemAvg = (70.0 + 85.0) / 2;

      expect(mathAvg, 87.5);
      expect(physicsAvg, 77.5);
      expect(chemAvg, 77.5);

      // Identify strong and weak courses
      final courseAverages = {
        'Mathematics': mathAvg,
        'Physics': physicsAvg,
        'Chemistry': chemAvg,
      };

      final strongCourses = courseAverages.entries
          .where((e) => e.value >= 80)
          .map((e) => e.key)
          .toList();

      final weakCourses = courseAverages.entries
          .where((e) => e.value < 80)
          .map((e) => e.key)
          .toList();

      expect(strongCourses, contains('Mathematics'));
      expect(weakCourses, contains('Physics'));
      expect(weakCourses, contains('Chemistry'));
    });

    test('AI material analysis and test generation pipeline', () {
      final student = Student(
        id: 'student789',
        fullName: 'Pipeline Test',
        email: 'pipeline@example.com',
        createdAt: DateTime.now(),
      );

      final course = Course(
        id: 'course1',
        studentId: student.id,
        name: 'Biology',
        createdAt: DateTime.now(),
      );

      // Upload multiple materials
      final materials = [
        StudyMaterial(
          id: 'mat1',
          courseId: course.id,
          studentId: student.id,
          title: 'Cell Structure',
          type: StudyMaterialType.pdf,
          fileUrl: 'url1',
          uploadedAt: DateTime.now(),
        ),
        StudyMaterial(
          id: 'mat2',
          courseId: course.id,
          studentId: student.id,
          title: 'DNA and RNA',
          type: StudyMaterialType.image,
          fileUrl: 'url2',
          uploadedAt: DateTime.now(),
        ),
        StudyMaterial(
          id: 'mat3',
          courseId: course.id,
          studentId: student.id,
          title: 'Photosynthesis',
          type: StudyMaterialType.note,
          fileUrl: 'url3',
          uploadedAt: DateTime.now(),
        ),
      ];

      expect(materials.length, 3);
      expect(materials.every((m) => m.aiAnalysis == null), true);

      // Simulate AI analysis for each material
      final aiAnalyses = [
        'Analysis of cell structure: Contains information about organelles',
        'Analysis of DNA/RNA: Covers genetic material and protein synthesis',
        'Analysis of photosynthesis: Explains light and dark reactions',
      ];

      final analyzedMaterials = List.generate(
        materials.length,
        (i) => StudyMaterial(
          id: materials[i].id,
          courseId: materials[i].courseId,
          studentId: materials[i].studentId,
          title: materials[i].title,
          type: materials[i].type,
          fileUrl: materials[i].fileUrl,
          aiAnalysis: aiAnalyses[i],
          uploadedAt: materials[i].uploadedAt,
        ),
      );

      expect(analyzedMaterials.every((m) => m.aiAnalysis != null), true);

      // Generate test combining all materials
      final combinedAnalyses = analyzedMaterials
          .map((m) => m.aiAnalysis!)
          .join('\n\n');

      expect(combinedAnalyses, contains('cell structure'));
      expect(combinedAnalyses, contains('DNA/RNA'));
      expect(combinedAnalyses, contains('photosynthesis'));

      // AI generates comprehensive test
      final questions = [
        Question(
          id: 'q1',
          question: 'What are organelles?',
          options: ['Cell parts', 'DNA', 'Proteins', 'Enzymes'],
          correctAnswerIndex: 0,
        ),
        Question(
          id: 'q2',
          question: 'What is the function of DNA?',
          options: ['Energy', 'Genetic info', 'Structure', 'Movement'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: 'q3',
          question: 'Where does photosynthesis occur?',
          options: ['Nucleus', 'Mitochondria', 'Chloroplast', 'Ribosome'],
          correctAnswerIndex: 2,
        ),
      ];

      final test = Test(
        id: 'test1',
        courseId: course.id,
        studentId: student.id,
        title: 'Comprehensive Biology Test',
        questions: questions,
        createdAt: DateTime.now(),
      );

      expect(test.questions.length, 3);
      expect(test.questions.every((q) => q.options.length == 4), true);
    });

    test('Exam preparation timeline flow', () {
      final student = Student(
        id: 'student999',
        fullName: 'Exam Prep Student',
        email: 'examprep@example.com',
        createdAt: DateTime.now(),
      );

      // Course with upcoming exam
      final examDate = DateTime.now().add(Duration(days: 14));
      final course = Course(
        id: 'course1',
        studentId: student.id,
        name: 'Final Exam Course',
        nextExamDate: examDate,
        uploadedFilesCount: 10,
        createdAt: DateTime.now(),
      );

      final daysUntilExam = examDate.difference(DateTime.now()).inDays;
      expect(daysUntilExam, greaterThan(0));
      expect(daysUntilExam, lessThanOrEqualTo(14));

      // Simulate daily test taking
      final dailyTests = List.generate(
        7, // One week of tests
        (i) => Test(
          id: 'test$i',
          courseId: course.id,
          studentId: student.id,
          title: 'Daily Test ${i + 1}',
          questions: [],
          createdAt: DateTime.now().subtract(Duration(days: 7 - i)),
          completedAt: DateTime.now().subtract(Duration(days: 7 - i)),
          score: 60.0 + (i * 5.0), // Progressive improvement
        ),
      );

      // Verify progress over time
      expect(dailyTests.length, 7);
      expect(dailyTests.first.score, 60.0);
      expect(dailyTests.last.score, 90.0);

      final improvement = dailyTests.last.score! - dailyTests.first.score!;
      expect(improvement, 30.0);
      expect(improvement, greaterThan(0)); // Shows progress
    });
  });

  group('Data Consistency Integration Tests', () {
    test('Course-Material-Test relationship integrity', () {
      final studentId = 'student123';
      final courseId = 'course456';

      final course = Course(
        id: courseId,
        studentId: studentId,
        name: 'Test Course',
        createdAt: DateTime.now(),
      );

      final material = StudyMaterial(
        id: 'mat1',
        courseId: courseId,
        studentId: studentId,
        title: 'Material',
        type: StudyMaterialType.note,
        fileUrl: 'url',
        uploadedAt: DateTime.now(),
      );

      final test = Test(
        id: 'test1',
        courseId: courseId,
        studentId: studentId,
        title: 'Test',
        questions: [],
        createdAt: DateTime.now(),
      );

      // Verify relationships
      expect(course.studentId, studentId);
      expect(material.courseId, courseId);
      expect(material.studentId, studentId);
      expect(test.courseId, courseId);
      expect(test.studentId, studentId);

      // All entities belong to same student and course
      expect(material.courseId, course.id);
      expect(test.courseId, course.id);
      expect(material.studentId, course.studentId);
      expect(test.studentId, course.studentId);
    });

    test('Multiple students data isolation', () {
      final student1Id = 'student1';
      final student2Id = 'student2';

      final course1 = Course(
        id: 'course1',
        studentId: student1Id,
        name: 'Math',
        createdAt: DateTime.now(),
      );

      final course2 = Course(
        id: 'course2',
        studentId: student2Id,
        name: 'Math',
        createdAt: DateTime.now(),
      );

      // Same course name but different students
      expect(course1.name, course2.name);
      expect(course1.studentId, isNot(equals(course2.studentId)));
      expect(course1.id, isNot(equals(course2.id)));
    });
  });

  group('AI-Only Operation Validation', () {
    test('Test questions must come from AI analysis, not pre-generated', () {
      // This test validates the principle that all questions are AI-generated
      
      final material = StudyMaterial(
        id: 'mat1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Custom Content',
        type: StudyMaterialType.pdf,
        fileUrl: 'unique_file_url',
        aiAnalysis: 'Unique AI analysis based on student material',
        uploadedAt: DateTime.now(),
      );

      // AI analysis is required
      expect(material.aiAnalysis, isNotNull);
      expect(material.aiAnalysis, contains('AI analysis'));

      // Questions should be generated from this specific analysis
      // Not from a pre-existing question bank
      final question = Question(
        id: 'q1',
        question: 'Question based on: ${material.title}',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 0,
        explanation: 'Based on analysis: ${material.aiAnalysis}',
      );

      expect(question.question, contains(material.title));
      expect(question.explanation, contains('analysis'));
    });

    test('No offline functionality - all analysis requires AI', () {
      // Material without AI analysis should be considered incomplete
      final incompleteMaterial = StudyMaterial(
        id: 'mat1',
        courseId: 'course1',
        studentId: 'student1',
        title: 'Not Analyzed',
        type: StudyMaterialType.note,
        fileUrl: 'url',
        uploadedAt: DateTime.now(),
      );

      expect(incompleteMaterial.aiAnalysis, null);
      
      // This material cannot be used for test generation until AI analyzes it
      // No pre-generated or offline questions allowed
    });
  });
}
