import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'dart:io';
import '../models/document_analysis.dart';
import '../models/teacher_style_profile.dart';
import '../models/test.dart';
import 'gemini_ai_service.dart';
import 'firestore_service.dart';

class TeacherStyleAnalyzer {
  final GeminiAIService _aiService = GeminiAIService();
  final FirestoreService _firestoreService = FirestoreService();

  /// 1. HER BELGE YÜKLENDİĞİNDE - Öğretmen stili için detaylı analiz
  Future<DocumentAnalysis> analyzeDocumentForTeacherStyle({
    required String filePath,
    required String courseName,
    required String documentTitle,
    required String teacherName,
    required String documentId,
  }) async {
    try {
      print('🎓 Öğretmen stili analizi: $documentTitle');
      
      final file = File(filePath);
      if (!await file.exists()) throw 'Dosya bulunamadı';

      final bytes = await file.readAsBytes();
      final extension = filePath.split('.').last.toLowerCase();
      
      String mimeType;
      if (extension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (['jpg', 'jpeg'].contains(extension)) {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else {
        mimeType = 'image/jpeg';
      }

      final prompt = '''
🎓 SEN BİR EĞİTİM ANALİZCİSİSİN

GÖREV: Öğretmenin verdiği bu belgeyi analiz et ve öğretim stilini çıkar!

BELGE: $documentTitle
DERS: $courseName
ÖĞRETMEN: $teacherName

DETAYLI ANALİZ:

1️⃣ BELGE TİPİ: ders_notu/ödev_kağıdı/sınav_kağıdı/çalışma_föyü/kitap_sayfası

2️⃣ KONU ANALİZİ:
- Ana konu
- Alt konular (liste)
- Derinlik: yüzeysel/orta/derinlemesine

3️⃣ SORU ANALİZİ (HER SORUYU SAY!):
Her soru için:
{
  "questionNumber": 1,
  "type": "hesaplama", // tanım/hesaplama/problem_çözme/analiz/sentez
  "difficulty": "kolay", // kolay/orta/zor
  "topic": "Çarpım Tablosu",
  "pageNumber": 1,
  "preview": "2 x 3 = ?"
}

4️⃣ ÖĞRETMEN STİLİ:
{
  "emphasizedTopics": ["konu1", "konu2"],
  "preferredQuestionTypes": ["tip1", "tip2"],
  "difficultyPreference": "orta_ağırlıklı",
  "usesVisuals": false,
  "usesRealLifeExamples": true,
  "focusOnMemorization": false,
  "additionalNotes": "notlar"
}

5️⃣ SINAV TAHMİNİ:
{
  "likelyQuestionCount": 5,
  "confidence": 0.8,
  "reasoning": "açıklama"
}

JSON ÇIKTI (sadece JSON):
{
  "documentType": "ödev_kağıdı",
  "mainTopic": "Çarpım Tablosu",
  "subTopics": ["2'ler", "5'ler"],
  "topicDepth": "orta",
  "questions": [...],
  "teacherStyleInsights": {...},
  "examPredictionHints": {...}
}
''';

      final response = await _aiService.model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, bytes),
        ])
      ]).timeout(Duration(seconds: 60));
      
      final text = response.text;
      if (text == null || text.isEmpty) throw 'AI boş yanıt';
      
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch == null) throw 'JSON bulunamadı';
      
      final jsonData = json.decode(jsonMatch.group(0)!);
      
      final analysis = DocumentAnalysis(
        documentId: documentId,
        documentTitle: documentTitle,
        documentType: jsonData['documentType'] ?? 'ders_notu',
        mainTopic: jsonData['mainTopic'] ?? '',
        subTopics: List<String>.from(jsonData['subTopics'] ?? []),
        topicDepth: jsonData['topicDepth'] ?? 'orta',
        questions: (jsonData['questions'] as List?)
            ?.map((q) => QuestionAnalysis.fromMap(q))
            .toList() ?? [],
        teacherStyleInsights: TeacherStyleInsights.fromMap(
            jsonData['teacherStyleInsights'] ?? {}),
        examPredictionHints: ExamPredictionHints.fromMap(
            jsonData['examPredictionHints'] ?? {}),
        analyzedAt: DateTime.now(),
      );
      
      print('✅ Analiz tamamlandı: ${analysis.questions.length} soru');
      return analysis;
      
    } catch (e) {
      print('❌ Belge analiz hatası: $e');
      rethrow;
    }
  }

  /// 2. ÖĞRETMEN PROFİLİ OLUŞTUR
  Future<TeacherStyleProfile?> buildTeacherProfile({
    required String courseId,
    required String studentId,
    required String courseName,
    required String teacherName,
  }) async {
    try {
      print('🎯 Öğretmen profili oluşturuluyor...');
      
      final materials = await _firestoreService
          .getCourseMaterials(courseId)
          .first;
      
      if (materials.length < 3) {
        print('⚠️ En az 3 belge gerekli. Şu an: ${materials.length}');
        return null;
      }

      // Basitleştirilmiş profil (gerçek implementasyonda tüm analizler toplanır)
      final profile = TeacherStyleProfile(
        id: '${courseId}_profile',
        teacherName: teacherName,
        courseName: courseName,
        studentId: studentId,
        questionTypeDistribution: {},
        topicDistribution: {},
        difficultyDistribution: {},
        questionSources: [],
        totalDocumentsAnalyzed: materials.length,
        totalQuestionsFound: 0,
        lastUpdated: DateTime.now(),
        teacherPersonality: 'Öğretmen profili ${materials.length} belgeden oluşturuluyor...',
        examPrediction: ExamPrediction(
          predictedQuestions: {},
          criticalTopics: [],
          possibleTopics: [],
          unlikelyTopics: [],
          reasoning: '',
          overallConfidence: 0.0,
        ),
      );
      
      print('✅ Profil oluşturuldu!');
      return profile;
      
    } catch (e) {
      print('❌ Profil hatası: $e');
      return null;
    }
  }

  /// 3. GERÇEK SINAV SİMÜLASYONU
  Future<List<Question>> generateRealisticExam({
    required TeacherStyleProfile teacherProfile,
    required int questionCount,
  }) async {
    try {
      print('📝 Gerçekçi sınav oluşturuluyor...');

      final prompt = '''
🎯 GERÇEK SINAV SİMÜLASYONU

ÖĞRETMEN: ${teacherProfile.teacherName}
DERS: ${teacherProfile.courseName}
ANALİZ EDİLEN BELGE: ${teacherProfile.totalDocumentsAnalyzed}

KİŞİLİK: "${teacherProfile.teacherPersonality}"

GÖREV: Bu öğretmenin GERÇEK sınavında çıkacak $questionCount soru hazırla!

JSON ÇIKTI:
{
  "questions": [
    {
      "question": "Soru metni?",
      "options": ["A", "B", "C", "D"],
      "correctAnswerIndex": 0,
      "explanation": "Detaylı açıklama..."
    }
  ]
}
''';

      final response = await _aiService.model.generateContent([
        Content.text(prompt)
      ]);
      
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response.text ?? '');
      if (jsonMatch == null) throw 'JSON bulunamadı';
      
      final examData = json.decode(jsonMatch.group(0)!);
      
      final questions = <Question>[];
      for (var q in examData['questions']) {
        questions.add(Question(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: q['question'],
          options: List<String>.from(q['options']),
          correctAnswerIndex: q['correctAnswerIndex'],
          explanation: q['explanation'],
        ));
      }
      
      print('✅ ${questions.length} soru oluşturuldu!');
      return questions;
      
    } catch (e) {
      print('❌ Sınav hatası: $e');
      rethrow;
    }
  }
}