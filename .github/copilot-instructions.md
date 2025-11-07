# AI Öğretmen - Copilot Instructions

## Project Overview

AI Öğretmen (AI Teacher) is a personalized AI-powered educational Flutter application that analyzes students' real study materials (notes, homework, PDFs) and creates customized tests and study recommendations based on their exam schedules. The app uses Google's Gemini AI for content analysis and intelligent test generation.

**Primary Language:** Turkish (UI and documentation)  
**Target Platform:** Android (iOS support planned)

## Tech Stack

### Frontend
- **Framework:** Flutter 3.9.2+
- **Language:** Dart 3.0+
- **UI:** Material Design 3
- **State Management:** Provider
- **Fonts:** Google Fonts

### Backend & Services
- **Backend:** Firebase
  - Authentication (Email/Password, Google Sign-In)
  - Firestore (NoSQL database)
  - Firebase Storage (file storage)
- **AI:** Google Gemini API (material analysis and test generation)

### Key Dependencies
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `google_sign_in: ^5.0.0` (stable version)
- `google_generative_ai` (Gemini AI integration)
- `image_picker`, `file_picker` (material uploads)
- `provider` (state management)
- `intl`, `uuid`, `path_provider`, `http`
- `fl_chart` (performance graphs)

## Project Structure

```
lib/
├── models/                 # Data models
│   ├── student.dart       # Student model
│   ├── course.dart        # Course/lesson model
│   ├── study_material.dart # Study material model
│   └── test.dart          # Test and question models
├── screens/               # UI screens
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── course_detail_screen.dart
│   ├── add_course_screen.dart
│   ├── upload_material_screen.dart
│   ├── generate_test_screen.dart
│   ├── take_test_screen.dart
│   ├── test_result_screen.dart
│   ├── test_review_screen.dart
│   ├── progress_analysis_screen.dart
│   ├── exam_calendar_screen.dart
│   └── profile_screen.dart
├── services/              # Backend services
│   ├── firebase_auth_service.dart    # Authentication
│   ├── firestore_service.dart        # Database operations
│   ├── firebase_storage_service.dart # File storage
│   └── gemini_ai_service.dart        # AI integration
├── utils/                 # Utilities
│   ├── app_theme.dart     # Theme configuration
│   └── constants.dart     # App constants
├── firebase_options.dart  # Firebase configuration
└── main.dart             # App entry point

test/
└── widget_test.dart      # Widget tests
```

## Data Models

### Student
- `id`, `fullName`, `email`, `photoUrl`, `createdAt`
- Each student has isolated data access

### Course (Ders)
- `id`, `studentId`, `name`, `teacherName`, `description`, `nextExamDate`, `uploadedFilesCount`
- Belongs to a specific student

### StudyMaterial (Ders Materyali)
- `id`, `courseId`, `studentId`, `title`, `type` (note/homework/pdf/image), `fileUrl`, `description`, `aiAnalysis`
- Contains uploaded study materials with AI analysis

### Test
- `id`, `courseId`, `studentId`, `title`, `questions`, `createdAt`, `completedAt`, `studentAnswers`, `score`
- Contains generated tests with questions

### Question (Soru)
- `id`, `question`, `options`, `correctAnswerIndex`, `explanation`
- Multiple choice questions with explanations

## Key Features & Workflows

### 1. Student Management
- Email/password and Google authentication
- Profile management with photo upload

### 2. Course Management
- Add/edit courses with teacher info and exam dates
- Track uploaded material count
- Exam countdown and calendar

### 3. AI Integration (Gemini API)
- Automatic analysis of uploaded materials (PDF, images, notes)
- Context-aware test question generation
- Performance analysis and weak topic identification
- Personalized study recommendations

### 4. Test System
- AI-generated multiple choice tests from student materials
- 3 difficulty levels (easy, medium, hard)
- Customizable question count (5-20)
- Instant scoring and detailed explanations
- Test history and progress tracking

## Coding Conventions

### Dart/Flutter Best Practices
- Use `const` constructors where possible for performance
- Follow Flutter naming conventions (camelCase for variables, PascalCase for classes)
- Use meaningful variable names in Turkish for domain concepts (e.g., `dersler`, `öğrenci`, `sınav`)
- Leverage Material Design 3 components
- Implement proper error handling with try-catch blocks
- Use loading states for async operations

### State Management
- Use Provider for app-wide state
- Keep UI and business logic separated
- Services handle all backend interactions

### File Organization
- Models contain only data structures and serialization
- Screens handle UI only
- Services contain business logic and external API calls
- Utils contain shared constants and helpers

## Building & Testing

### Prerequisites
```bash
# Flutter SDK 3.9.2 or higher required
flutter doctor

# Install dependencies
flutter pub get
```

### Running the App
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in debug mode with hot reload
flutter run -d <device-id>
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Linting
```bash
# Analyze code
flutter analyze

# Check for lint issues
dart analyze
```

### Build
```bash
# Build APK for Android
flutter build apk

# Build app bundle for Google Play
flutter build appbundle

# Clean build artifacts
flutter clean
```

## Firebase Configuration

### Required Firebase Services
1. **Authentication:** Email/Password and Google Sign-In enabled
2. **Firestore Database:** Created with security rules
3. **Storage:** Enabled for file uploads

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /students/{studentId} {
      allow read, write: if request.auth != null && request.auth.uid == studentId;
    }
    match /courses/{courseId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.studentId;
    }
    match /materials/{materialId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.studentId;
    }
    match /tests/{testId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.studentId;
    }
  }
}
```

### Storage Security Rules
- Users can only access files in their own directory: `students/{userId}/`

## API Keys & Environment

### Gemini API Key
- Required for AI features
- Configure in `lib/services/gemini_ai_service.dart`
- Also set in `lib/utils/constants.dart`
- **Security:** DO NOT commit API keys to repository
- Use environment variables for production

### Firebase Configuration
- Generated via `flutterfire configure`
- Stored in `lib/firebase_options.dart`
- Platform-specific configs in `android/`, `ios/`, etc.

## Common Development Tasks

### Adding a New Screen
1. Create screen file in `lib/screens/`
2. Extend `StatefulWidget` or `StatelessWidget`
3. Use Material Design 3 components
4. Add navigation in relevant parent screen
5. Update imports in `main.dart` if needed

### Adding a New Model
1. Create model file in `lib/models/`
2. Include `toMap()` and `fromMap()` methods for Firestore serialization
3. Add proper null safety with `?` where appropriate
4. Include all necessary fields with Turkish comments

### Adding a Service Method
1. Add method to appropriate service in `lib/services/`
2. Handle exceptions with try-catch
3. Return appropriate data types or throw errors
4. Use async/await for asynchronous operations
5. Add loading states in UI

### Working with Gemini AI
- Service: `lib/services/gemini_ai_service.dart`
- Use structured prompts for consistent results
- Parse JSON responses carefully
- Handle API errors gracefully
- Consider rate limits and quotas

## Security Considerations

### Authentication
- Firebase Authentication manages tokens securely
- Google OAuth 2.0 for social login
- No passwords stored locally

### Data Access
- Firestore rules enforce user-specific data access
- Each user can only read/write their own data
- File uploads isolated per user in Storage

### API Keys
- Never commit API keys to repository
- Use environment variables or secure storage
- Rotate keys periodically

## Testing Strategy

### Unit Tests
- Test data models serialization
- Test service methods
- Mock Firebase services for isolated testing

### Widget Tests
- Test screen rendering
- Test user interactions
- Verify navigation flows

### Integration Tests
- Test complete user workflows
- Test Firebase integration
- Test AI service responses

## Performance Optimization

- Use `const` constructors
- Implement lazy loading for lists
- Cache images appropriately
- Optimize Firestore queries
- Use real-time listeners efficiently
- Minimize AI API calls (cache results when possible)

## Localization Notes

- Primary language: Turkish
- UI elements, messages, and comments in Turkish
- Consider English support in future versions
- Date formatting uses Turkish locale (`intl` package)

## Known Limitations

- Android only (iOS requires additional Firebase configuration)
- No offline mode yet (planned for v2.0)
- Test results currently don't have detailed analytics page
- No password reset feature yet (planned for v1.1)

## Future Roadmap

### v1.1 (Short-term)
- Password reset functionality
- Test results detail page
- Push notifications for exam reminders
- Profile photo update

### v1.2 (Mid-term)
- Performance graphs and analytics
- Study plan generation
- Voice note recording
- Video material support

### v2.0 (Long-term)
- iOS support
- Web application
- Offline mode
- Group study features
- Teacher dashboard

## Getting Help

- Review existing code in similar screens/services
- Check Firebase documentation for Firestore/Auth issues
- Refer to Flutter documentation for UI components
- Check Gemini API documentation for AI integration
- See Turkish comments in code for context-specific guidance

## Code Review Checklist

Before submitting changes:
- [ ] Code follows Dart style guide
- [ ] Added/updated Turkish comments for clarity
- [ ] Tested on Android device/emulator
- [ ] No hardcoded API keys
- [ ] Error handling implemented
- [ ] Loading states added for async operations
- [ ] Security rules respected
- [ ] Performance considered (no unnecessary rebuilds)
- [ ] Null safety properly handled
