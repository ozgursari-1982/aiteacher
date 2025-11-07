class TeacherStyleProfile {
  String id;
  String teacherName;
  String courseName;
  String studentId;
  
  // SORU TİPİ DAĞILIMI
  Map<String, int> questionTypeDistribution;
  
  // KONU DAĞILIMI
  Map<String, TopicAnalysis> topicDistribution;
  
  // ZORLUK DAĞILIMI
  Map<String, int> difficultyDistribution;
  
  // SORU KAYNAKLARI
  List<QuestionSource> questionSources;
  
  // İSTATİSTİKLER
  int totalDocumentsAnalyzed;
  int totalQuestionsFound;
  DateTime lastUpdated;
  
  // ÖĞRETMEN KİŞİLİĞİ
  String teacherPersonality;
  
  // TAHMİN MODELİ
  ExamPrediction examPrediction;

  TeacherStyleProfile({
    required this.id,
    required this.teacherName,
    required this.courseName,
    required this.studentId,
    required this.questionTypeDistribution,
    required this.topicDistribution,
    required this.difficultyDistribution,
    required this.questionSources,
    required this.totalDocumentsAnalyzed,
    required this.totalQuestionsFound,
    required this.lastUpdated,
    required this.teacherPersonality,
    required this.examPrediction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherName': teacherName,
      'courseName': courseName,
      'studentId': studentId,
      'questionTypeDistribution': questionTypeDistribution,
      'topicDistribution': topicDistribution.map((key, value) => MapEntry(key, value.toMap())),
      'difficultyDistribution': difficultyDistribution,
      'questionSources': questionSources.map((e) => e.toMap()).toList(),
      'totalDocumentsAnalyzed': totalDocumentsAnalyzed,
      'totalQuestionsFound': totalQuestionsFound,
      'lastUpdated': lastUpdated.toIso8601String(),
      'teacherPersonality': teacherPersonality,
      'examPrediction': examPrediction.toMap(),
    };
  }

  factory TeacherStyleProfile.fromMap(Map<String, dynamic> map) {
    return TeacherStyleProfile(
      id: map['id'] ?? '',
      teacherName: map['teacherName'] ?? '',
      courseName: map['courseName'] ?? '',
      studentId: map['studentId'] ?? '',
      questionTypeDistribution: Map<String, int>.from(map['questionTypeDistribution'] ?? {}),
      topicDistribution: (map['topicDistribution'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, TopicAnalysis.fromMap(value))
      ) ?? {},
      difficultyDistribution: Map<String, int>.from(map['difficultyDistribution'] ?? {}),
      questionSources: (map['questionSources'] as List?)?.map((e) => QuestionSource.fromMap(e)).toList() ?? [],
      totalDocumentsAnalyzed: map['totalDocumentsAnalyzed'] ?? 0,
      totalQuestionsFound: map['totalQuestionsFound'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      teacherPersonality: map['teacherPersonality'] ?? '',
      examPrediction: ExamPrediction.fromMap(map['examPrediction'] ?? {}),
    );
  }
}

class TopicAnalysis {
  String topicName;
  int questionCount;
  double averageDifficulty;
  List<String> subTopics;
  List<DocumentReference> sourceDocuments;
  double examProbability;
  double teacherEmphasis;

  TopicAnalysis({
    required this.topicName,
    required this.questionCount,
    required this.averageDifficulty,
    required this.subTopics,
    required this.sourceDocuments,
    required this.examProbability,
    required this.teacherEmphasis,
  });

  Map<String, dynamic> toMap() {
    return {
      'topicName': topicName,
      'questionCount': questionCount,
      'averageDifficulty': averageDifficulty,
      'subTopics': subTopics,
      'sourceDocuments': sourceDocuments.map((e) => e.toMap()).toList(),
      'examProbability': examProbability,
      'teacherEmphasis': teacherEmphasis,
    };
  }

  factory TopicAnalysis.fromMap(Map<String, dynamic> map) {
    return TopicAnalysis(
      topicName: map['topicName'] ?? '',
      questionCount: map['questionCount'] ?? 0,
      averageDifficulty: map['averageDifficulty']?.toDouble() ?? 0.0,
      subTopics: List<String>.from(map['subTopics'] ?? []),
      sourceDocuments: (map['sourceDocuments'] as List?)?.map((e) => DocumentReference.fromMap(e)).toList() ?? [],
      examProbability: map['examProbability']?.toDouble() ?? 0.0,
      teacherEmphasis: map['teacherEmphasis']?.toDouble() ?? 0.0,
    );
  }
}

class DocumentReference {
  String documentId;
  String documentTitle;
  List<int> pages;
  int questionCount;
  String difficultyLevel;

  DocumentReference({
    required this.documentId,
    required this.documentTitle,
    required this.pages,
    required this.questionCount,
    required this.difficultyLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'documentTitle': documentTitle,
      'pages': pages,
      'questionCount': questionCount,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory DocumentReference.fromMap(Map<String, dynamic> map) {
    return DocumentReference(
      documentId: map['documentId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      pages: List<int>.from(map['pages'] ?? []),
      questionCount: map['questionCount'] ?? 0,
      difficultyLevel: map['difficultyLevel'] ?? '',
    );
  }
}

class QuestionSource {
  String documentId;
  String documentTitle;
  int pageNumber;
  String questionType;
  String topic;
  String difficulty;
  String questionPreview;

  QuestionSource({
    required this.documentId,
    required this.documentTitle,
    required this.pageNumber,
    required this.questionType,
    required this.topic,
    required this.difficulty,
    required this.questionPreview,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'documentTitle': documentTitle,
      'pageNumber': pageNumber,
      'questionType': questionType,
      'topic': topic,
      'difficulty': difficulty,
      'questionPreview': questionPreview,
    };
  }

  factory QuestionSource.fromMap(Map<String, dynamic> map) {
    return QuestionSource(
      documentId: map['documentId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      pageNumber: map['pageNumber'] ?? 0,
      questionType: map['questionType'] ?? '',
      topic: map['topic'] ?? '',
      difficulty: map['difficulty'] ?? '',
      questionPreview: map['questionPreview'] ?? '',
    );
  }
}

class ExamPrediction {
  Map<String, PredictedQuestion> predictedQuestions;
  List<String> criticalTopics;
  List<String> possibleTopics;
  List<String> unlikelyTopics;
  String reasoning;
  double overallConfidence;

  ExamPrediction({
    required this.predictedQuestions,
    required this.criticalTopics,
    required this.possibleTopics,
    required this.unlikelyTopics,
    required this.reasoning,
    required this.overallConfidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'predictedQuestions': predictedQuestions.map((key, value) => MapEntry(key, value.toMap())),
      'criticalTopics': criticalTopics,
      'possibleTopics': possibleTopics,
      'unlikelyTopics': unlikelyTopics,
      'reasoning': reasoning,
      'overallConfidence': overallConfidence,
    };
  }

  factory ExamPrediction.fromMap(Map<String, dynamic> map) {
    return ExamPrediction(
      predictedQuestions: (map['predictedQuestions'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, PredictedQuestion.fromMap(value))
      ) ?? {},
      criticalTopics: List<String>.from(map['criticalTopics'] ?? []),
      possibleTopics: List<String>.from(map['possibleTopics'] ?? []),
      unlikelyTopics: List<String>.from(map['unlikelyTopics'] ?? []),
      reasoning: map['reasoning'] ?? '',
      overallConfidence: map['overallConfidence']?.toDouble() ?? 0.0,
    );
  }
}

class PredictedQuestion {
  String topic;
  int predictedQuestionCount;
  double confidence;
  String reasoning;

  PredictedQuestion({
    required this.topic,
    required this.predictedQuestionCount,
    required this.confidence,
    required this.reasoning,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'predictedQuestionCount': predictedQuestionCount,
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }

  factory PredictedQuestion.fromMap(Map<String, dynamic> map) {
    return PredictedQuestion(
      topic: map['topic'] ?? '',
      predictedQuestionCount: map['predictedQuestionCount'] ?? 0,
      confidence: map['confidence']?.toDouble() ?? 0.0,
      reasoning: map['reasoning'] ?? '',
    );
  }
}
