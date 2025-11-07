class AppConstants {
  // Firebase Collections
  static const String studentsCollection = 'students';
  static const String coursesCollection = 'courses';
  static const String materialsCollection = 'materials';
  static const String testsCollection = 'tests';

  // Gemini API
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE'; // Buraya API key'inizi ekleyin

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;

  // Test Settings
  static const int defaultQuestionCount = 10;
  static const List<String> difficultyLevels = ['kolay', 'orta', 'zor'];

  // File Upload
  static const int maxFileSizeInMB = 10;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];
}

