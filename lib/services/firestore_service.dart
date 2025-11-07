import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/study_material.dart';
import '../models/test.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============== COURSES ===============
  
  // Get all courses for a student (Stream)
  Stream<List<Course>> getStudentCourses(String studentId) {
    return _firestore
        .collection('courses')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get all courses for a student (Future - for analysis)
  Future<List<Course>> getCourses(String studentId) async {
    final snapshot = await _firestore
        .collection('courses')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
  }

  // Add a new course
  Future<String> addCourse(Course course) async {
    final docRef = await _firestore.collection('courses').add(course.toMap());
    return docRef.id;
  }

  // Update course
  Future<void> updateCourse(String courseId, Map<String, dynamic> data) async {
    await _firestore.collection('courses').doc(courseId).update(data);
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection('courses').doc(courseId).delete();
  }

  // =============== STUDY MATERIALS ===============
  
  // Get materials for a course
  Stream<List<StudyMaterial>> getCourseMaterials(String courseId) {
    return _firestore
        .collection('materials')
        .where('courseId', isEqualTo: courseId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StudyMaterial.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Add study material
  Future<String> addStudyMaterial(StudyMaterial material) async {
    final docRef = await _firestore.collection('materials').add(material.toMap());
    return docRef.id;
  }

  // Update material with AI analysis
  Future<void> updateMaterialAnalysis(String materialId, String aiAnalysis) async {
    await _firestore.collection('materials').doc(materialId).update({
      'aiAnalysis': aiAnalysis,
    });
  }

  // Delete material
  Future<void> deleteMaterial(String materialId) async {
    await _firestore.collection('materials').doc(materialId).delete();
  }

  // =============== TESTS ===============
  
  // Get tests for a course
  Stream<List<Test>> getCourseTests(String courseId) {
    return _firestore
        .collection('tests')
        .where('courseId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Test.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get all tests for a student (Stream)
  Stream<List<Test>> getStudentTests(String studentId) {
    return _firestore
        .collection('tests')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Test.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get tests for a specific course (Future - for analysis)
  Future<List<Test>> getTests(String studentId, String courseId) async {
    final snapshot = await _firestore
        .collection('tests')
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Test.fromMap(doc.data(), doc.id)).toList();
  }

  // Add a new test
  Future<String> addTest(Test test) async {
    final docRef = await _firestore.collection('tests').add(test.toMap());
    return docRef.id;
  }

  // Submit test answers
  Future<void> submitTestAnswers(
    String testId,
    Map<String, String> answers,
    double score,
  ) async {
    await _firestore.collection('tests').doc(testId).update({
      'studentAnswers': answers,
      'score': score,
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(), // Timestamp olarak kaydet (cache kontrolü için)
    });
  }

  // =============== EXAM DATES ===============
  
  // Get upcoming exams for a student
  Future<List<Course>> getUpcomingExams(String studentId) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('courses')
        .where('studentId', isEqualTo: studentId)
        .where('nextExamDate', isGreaterThanOrEqualTo: now.toIso8601String())
        .orderBy('nextExamDate')
        .get();

    return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
  }

  // Update exam date for a course
  Future<void> updateExamDate(String courseId, DateTime examDate) async {
    await _firestore.collection('courses').doc(courseId).update({
      'nextExamDate': examDate.toIso8601String(),
    });
  }

  // =============== ANALYSIS CACHE ===============
  
  // Kayıtlı analizi getir
  Future<Map<String, dynamic>?> getCachedAnalysis(String studentId) async {
    try {
      final doc = await _firestore.collection('analysis_cache').doc(studentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Cached analiz getirme hatası: $e');
      return null;
    }
  }
  
  // Analizi cache'le
  Future<void> saveAnalysisCache(String studentId, String analysis) async {
    await _firestore.collection('analysis_cache').doc(studentId).set({
      'analysis': analysis,
      'lastUpdated': FieldValue.serverTimestamp(),
      'studentId': studentId,
    });
  }
  
  // Son test zamanını kontrol et (cache geçerli mi?)
  Future<bool> isAnalysisCacheValid(String studentId) async {
    try {
      print('🔍 Cache geçerliliği kontrol ediliyor...');
      
      // Cached analizi al
      final cachedData = await getCachedAnalysis(studentId);
      if (cachedData == null) {
        print('❌ Cache bulunamadı');
        return false;
      }
      
      final lastAnalysisTime = (cachedData['lastUpdated'] as Timestamp?)?.toDate();
      if (lastAnalysisTime == null) {
        print('❌ Cache zamanı okunamadı');
        return false;
      }
      
      print('📅 Son analiz zamanı: $lastAnalysisTime');
      
      // Tüm completed testleri al (son analiz zamanından sonra tamamlananlar)
      final testsSnapshot = await _firestore
          .collection('tests')
          .where('studentId', isEqualTo: studentId)
          .get();
      
      if (testsSnapshot.docs.isEmpty) {
        print('✅ Hiç test yok, cache geçerli');
        return true;
      }
      
      // Son tamamlanan testi bul
      DateTime? lastTestTime;
      for (var doc in testsSnapshot.docs) {
        final data = doc.data();
        final completedAt = data['completedAt'];
        
        if (completedAt != null) {
          DateTime? testTime;
          if (completedAt is Timestamp) {
            testTime = completedAt.toDate();
          } else if (completedAt is String) {
            testTime = DateTime.parse(completedAt);
          }
          
          if (testTime != null) {
            if (lastTestTime == null || testTime.isAfter(lastTestTime)) {
              lastTestTime = testTime;
            }
          }
        }
      }
      
      if (lastTestTime == null) {
        print('✅ Completed test yok, cache geçerli');
        return true;
      }
      
      print('📅 Son test zamanı: $lastTestTime');
      
      // Eğer son test, son analizden önceyse, cache hala geçerli
      final isValid = lastTestTime.isBefore(lastAnalysisTime);
      print(isValid ? '✅ Cache geçerli' : '❌ Cache geçersiz, yeni test var');
      
      return isValid;
    } catch (e) {
      print('❌ Cache kontrol hatası: $e');
      return false;
    }
  }

  // Cache'i tamamen temizle (debug/test amaçlı)
  Future<void> clearAnalysisCache(String studentId) async {
    try {
      await _firestore.collection('analysis_cache').doc(studentId).delete();
      print('🗑️ Analiz cache temizlendi');
    } catch (e) {
      print('❌ Cache temizleme hatası: $e');
    }
  }

  // Öğrenci bilgilerini getir
  Future<Map<String, dynamic>?> getStudentProfile(String studentId) async {
    try {
      final doc = await _firestore.collection('students').doc(studentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Öğrenci profili getirme hatası: $e');
      return null;
    }
  }

  // Öğrenci profil bilgilerini güncelle
  Future<void> updateStudentProfile(String studentId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('students').doc(studentId).update(updates);
      print('✅ Öğrenci profili güncellendi');
    } catch (e) {
      print('❌ Öğrenci profili güncelleme hatası: $e');
      rethrow;
    }
  }
}

