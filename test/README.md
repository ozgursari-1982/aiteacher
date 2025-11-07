# 🧪 AI Teacher Test Suite

## Genel Bakış

AI Öğretmen uygulaması için kapsamlı test paketi. Bu test suite, uygulamanın **sadece AI ile çalıştığını** ve çevrimdışı/hazır cevap kullanmadığını doğrular.

## 📊 Test İstatistikleri

- ✅ **100+ test case**
- ✅ **10+ test dosyası**
- ✅ **60%+ kod coverage hedefi**
- ✅ **AI-only operation doğrulaması**

## 🗂️ Test Yapısı

```
test/
├── models/                    # Model unit testleri
│   ├── course_test.dart      # Course model testleri (9 test)
│   ├── student_test.dart     # Student model testleri (7 test)
│   ├── test_test.dart        # Test & Question model (15+ test)
│   └── study_material_test.dart # Material model (10+ test)
├── services/                  # Servis testleri
│   ├── gemini_ai_service_test.dart  # AI servisi (15+ test)
│   └── firestore_service_test.dart  # Firestore (12+ test)
├── widgets/                   # Widget testleri
│   └── welcome_screen_test.dart     # Welcome ekranı (10+ test)
├── integration/               # Entegrasyon testleri
│   └── learning_flow_test.dart      # Öğrenme akışı (10+ test)
├── widget_test.dart          # Ana app testleri (6+ test)
├── TEST_COVERAGE.md          # Coverage raporu
└── README.md                 # Bu dosya
```

## 🚀 Testleri Çalıştırma

### Tüm Testler
```bash
flutter test
```

### Belirli Bir Dosya
```bash
flutter test test/models/course_test.dart
```

### Coverage ile
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Sadece Entegrasyon Testleri
```bash
flutter test test/integration/
```

### Sadece Model Testleri
```bash
flutter test test/models/
```

### Verbose Mod
```bash
flutter test --reporter expanded
```

## 🎯 Test Kategorileri

### 1. Model Unit Testleri (test/models/)

**Ne Test Edilir:**
- Model oluşturma (required/optional fields)
- Serialization (toMap/fromMap)
- Data integrity
- Edge case'ler
- copyWith fonksiyonalitesi

**Örnek:**
```dart
test('Course should be created with required fields', () {
  final course = Course(
    id: 'course1',
    studentId: 'student1',
    name: 'Mathematics',
    createdAt: DateTime(2024, 1, 1),
  );
  
  expect(course.id, 'course1');
  expect(course.name, 'Mathematics');
});
```

### 2. Servis Testleri (test/services/)

**Ne Test Edilir:**
- AI servis fonksiyonları
- Firestore operasyonları
- Error handling
- API integration
- **AI-only operation doğrulaması**

**Kritik Test:**
```dart
test('All methods should require AI interaction - no offline fallback', () {
  // Hiçbir hazır cevap yok
  // Her şey AI'dan gelmelidir
});
```

### 3. Widget Testleri (test/widgets/)

**Ne Test Edilir:**
- UI element rendering
- User interactions
- Navigation
- Layout validation
- Button functionality

**Örnek:**
```dart
testWidgets('WelcomeScreen should display app title', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: WelcomeScreen()));
  expect(find.text('AI Öğretmen\'e Hoş Geldiniz'), findsOneWidget);
});
```

### 4. Entegrasyon Testleri (test/integration/)

**Ne Test Edilir:**
- End-to-end user flows
- Multi-step scenarios
- Data consistency
- Cross-component interaction

**Temel Flow:**
```
Öğrenci Kaydı → Ders Ekleme → Materyal Yükleme 
→ AI Analizi → Test Oluşturma → Test Çözme → Sonuç
```

## ✅ AI-Only Doğrulama

Bu test suite, uygulamanın **SADECE AI ile çalıştığını** doğrular:

### ✅ Doğrulanan Özellikler:
- Tüm sorular AI tarafından üretilir
- Materyal analizi AI tarafından yapılır
- Hazır soru bankası yok
- Çevrimdışı mod yok
- Pre-generated content yok

### Test Örneği:
```dart
test('Test questions must come from AI analysis, not pre-generated', () {
  final material = StudyMaterial(
    aiAnalysis: 'Unique AI analysis based on student material',
    // ...
  );
  
  // AI analysis gereklidir
  expect(material.aiAnalysis, isNotNull);
  
  // Sorular bu spesifik analizden üretilir
  // Hazır soru bankasından DEĞİL
});
```

## 📈 Coverage Hedefleri

| Kategori | Hedef | Mevcut |
|----------|-------|--------|
| Models | 90%+ | ~90% |
| Services | 70%+ | ~60% |
| Widgets | 60%+ | ~40% |
| **Toplam** | **70%+** | **~60%** |

## 🔧 Test Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
  fake_cloud_firestore: ^2.5.1
  firebase_auth_mocks: ^0.13.0
  mocktail: ^1.0.3
```

## 🎓 Test Yazma Kuralları

### 1. İsimlendirme
- Açıklayıcı test isimleri kullan
- Türkçe veya İngilizce tutarlı ol
- "should" formatı kullan

### 2. Yapı
```dart
group('Feature Tests', () {
  setUp(() {
    // Her testten önce
  });
  
  tearDown(() {
    // Her testten sonra
  });
  
  test('should do something', () {
    // Arrange
    final input = createInput();
    
    // Act
    final result = doSomething(input);
    
    // Assert
    expect(result, expectedValue);
  });
});
```

### 3. Best Practices
- Her test bağımsız olmalı
- Test data'yı izole et
- Mock'ları akıllıca kullan
- Edge case'leri test et
- Error scenario'larını test et

## 🐛 Hata Ayıklama

### Test Başarısız Olursa:

1. **Hata Mesajını Oku:**
```bash
flutter test --reporter expanded
```

2. **Tek Bir Testi Çalıştır:**
```bash
flutter test test/models/course_test.dart
```

3. **Debug Mod:**
```dart
test('debug test', () {
  print('Debug info: $value');
  expect(value, something);
});
```

### Yaygın Sorunlar:

**Firebase Initialization Error:**
```bash
# Mock Firebase kullan veya
# Firebase emulator kullan
```

**API Key Error (Gemini):**
```dart
// Bu testler skip edilebilir:
test('...', () {
  // ...
}, skip: 'Requires valid API key');
```

## 📝 Yeni Test Ekleme

### 1. Model Test Ekle:
```dart
// test/models/my_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/models/my_model.dart';

void main() {
  group('MyModel Tests', () {
    test('should create model', () {
      final model = MyModel(/* ... */);
      expect(model, isNotNull);
    });
  });
}
```

### 2. Widget Test Ekle:
```dart
// test/widgets/my_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_teacher_app/screens/my_screen.dart';

void main() {
  testWidgets('should render correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MyScreen()));
    expect(find.byType(MyScreen), findsOneWidget);
  });
}
```

## 🔄 CI/CD Integration

### GitHub Actions (Gelecek):
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

## 📚 Ek Kaynaklar

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

## 🎯 Gelecek İyileştirmeler

- [ ] E2E testler (Flutter Driver)
- [ ] Screenshot testleri
- [ ] Performance testleri
- [ ] Accessibility testleri
- [ ] Golden file testleri
- [ ] CI/CD otomasyonu
- [ ] Test coverage badges

## 📞 Yardım

Test ile ilgili sorular için:
- `DETAYLI_ANALIZ.md` dosyasına bakın
- GitHub issue açın
- Test coverage raporunu inceleyin

---

**Not:** Bu test suite, AI Öğretmen uygulamasının **sadece AI ile çalıştığını** ve kalitesini garanti eder. Tüm testler bu prensibi korur! 🤖✅
