# AI Öğretmen - Kişiselleştirilmiş Yapay Zeka Destekli Öğretmen Uygulaması

AI Öğretmen, öğrencilerin gerçek ders notlarını ve ödevlerini analiz ederek, sınav tarihlerine kadar kişiselleştirilmiş testler ve hazırlık planları sunan bir Flutter uygulamasıdır.

## 🎯 Özellikler

### 👤 Öğrenci Yönetimi

- E-posta/şifre ile kayıt ve giriş
- Google ile hızlı giriş
- Profil yönetimi

### 📚 Ders Yönetimi

- Ders ekleme ve düzenleme
- Öğretmen bilgileri ekleme
- Sınav tarihleri belirleme
- Ders materyalleri yükleme (PDF, resim, notlar)

### 🤖 AI Entegrasyonu (Gemini API)

- Ders materyallerinin otomatik analizi
- Öğrencinin çalıştığı konulara özel test oluşturma
- Test sonuçlarına göre performans analizi
- Zayıf konular için özel çalışma önerileri

### ✅ Test ve Değerlendirme

- AI tarafından oluşturulan çoktan seçmeli testler
- Zorluk seviyesi seçimi (kolay, orta, zor)
- Anlık skorlama ve değerlendirme
- Test geçmişi ve ilerleme takibi

### 📅 Sınav Takvimi

- Yaklaşan sınavların listesi
- Sınava kalan gün sayısı
- Sınav hatırlatmaları

## 🛠 Teknolojiler

- **Framework:** Flutter 3.9.2+
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **AI:** Google Gemini API
- **State Management:** Provider
- **Diller:** Dart, Material Design 3

## 📋 Gereksinimler

- Flutter SDK 3.9.2 veya üzeri
- Dart SDK 3.0+
- Android Studio / VS Code
- Firebase projesi
- Google Gemini API Key

## 🚀 Kurulum

### 1. Flutter Kurulumu

Flutter henüz yüklü değilse:

```bash
# Windows için
# https://docs.flutter.dev/get-started/install/windows adresinden indirin

# Kurulumu kontrol edin
flutter doctor
```

### 2. Projeyi İndirin

```bash
cd c:\Users\Neu\Desktop\Enes\ai_teacher_app
flutter pub get
```

### 3. Firebase Kurulumu

#### a. Firebase Projesi Oluşturun

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. Yeni proje oluşturun
3. Android uygulaması ekleyin
4. Package name: `com.example.ai_teacher_app` (veya kendi seçtiğiniz)

#### b. Firebase CLI'yi Yükleyin

```bash
npm install -g firebase-tools
firebase login
```

#### c. FlutterFire CLI'yi Kurun

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

#### d. Firebase Servislerini Etkinleştirin

Firebase Console'da:

- **Authentication**: Email/Password ve Google Sign-In metodlarını etkinleştirin
- **Firestore Database**: Database oluşturun (test modunda başlatın)
- **Storage**: Depolama oluşturun

#### e. Firestore Güvenlik Kuralları

Firestore Database > Rules sekmesinde:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcı kendi verilerine erişebilir
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

#### f. Storage Güvenlik Kuralları

Storage > Rules sekmesinde:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /students/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Gemini API Key Alın

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. API Key oluşturun
3. API Key'i kopyalayın

### 5. API Key'leri Yapılandırın

`lib/services/gemini_ai_service.dart` dosyasını açın ve API key'inizi ekleyin:

```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // Buraya API key'inizi yapıştırın
```

Ayrıca `lib/utils/constants.dart` dosyasında da:

```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

### 6. Uygulamayı Çalıştırın

```bash
# Android cihaz veya emulator'u bağlayın
flutter devices

# Uygulamayı çalıştırın
flutter run
```

## 📱 Kullanım

### İlk Kullanım

1. **Kayıt Olun**: E-posta/şifre veya Google ile kayıt olun
2. **Ders Ekleyin**: + butonuna tıklayarak yeni ders ekleyin
3. **Materyal Yükleyin**: Ders notlarınızı, ödevlerinizi yükleyin
4. **AI Analizi**: AI materyallerinizi otomatik analiz edecek
5. **Test Oluşturun**: AI size özel testler hazırlayacak
6. **Test Çözün**: Testleri çözerek ilerlemenizi takip edin

### Ders Ekleme

1. Anasayfada + butonuna tıklayın
2. Ders adını girin (örn: Matematik)
3. Öğretmen adını ekleyin (opsiyonel)
4. Sınav tarihini seçin (opsiyonel)
5. Dersi kaydedin

### Materyal Yükleme

1. Bir derse tıklayın
2. "Materyaller" sekmesinde + butonuna tıklayın
3. Galeri, kamera veya belge seçin
4. Başlık ve açıklama ekleyin
5. "Yükle & Analiz Et" butonuna tıklayın

### Test Oluşturma

1. Bir derse tıklayın
2. "Testler" sekmesine geçin
3. - butonuna tıklayın
4. Soru sayısı ve zorluk seviyesi seçin
5. "Test Oluştur" butonuna tıklayın
6. AI sizin için özel test hazırlayacak

## 🏗 Proje Yapısı

```
lib/
├── models/              # Veri modelleri
│   ├── student.dart
│   ├── course.dart
│   ├── study_material.dart
│   └── test.dart
├── screens/            # Ekranlar
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── course_detail_screen.dart
│   ├── add_course_screen.dart
│   ├── upload_material_screen.dart
│   ├── generate_test_screen.dart
│   ├── take_test_screen.dart
│   ├── exam_calendar_screen.dart
│   └── profile_screen.dart
├── services/           # Backend servisleri
│   ├── firebase_auth_service.dart
│   ├── firestore_service.dart
│   ├── firebase_storage_service.dart
│   └── gemini_ai_service.dart
├── utils/             # Yardımcı dosyalar
│   ├── app_theme.dart
│   └── constants.dart
└── main.dart          # Ana dosya
```

## 🔒 Güvenlik

- Firebase Authentication ile güvenli giriş
- Firestore güvenlik kuralları ile veri koruması
- Her kullanıcı sadece kendi verilerine erişebilir
- API anahtarları güvenli şekilde saklanmalı (production'da environment variables kullanın)

## 🐛 Sorun Giderme

### Firebase bağlantı hatası

```bash
flutter clean
flutter pub get
flutterfire configure
```

### Gemini API hatası

- API key'in doğru olduğundan emin olun
- API kotanızı kontrol edin
- İnternet bağlantınızı kontrol edin

### Build hatası

```bash
flutter clean
flutter pub get
flutter run
```

## 📝 TODO (Gelecek Özellikler)

- [ ] Şifre sıfırlama özelliği
- [ ] Push bildirimleri (sınav hatırlatmaları)
- [ ] Test sonuçları detay sayfası
- [ ] Performans grafikleri
- [ ] Sesli ders notu kaydı
- [ ] Çevrimdışı mod
- [ ] Karanlık tema
- [ ] Dil desteği (İngilizce)

## 👨‍💻 Geliştirici

Bu proje, öğrencilerin sınav hazırlık süreçlerini kolaylaştırmak için geliştirilmiştir.

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

## 🙏 Teşekkürler

- Flutter Team
- Firebase Team
- Google AI Team (Gemini API)

---

**Not:** Bu uygulama sadece Android platformu için geliştirilmiştir. iOS desteği için ek yapılandırma gereklidir.

---

## 📊 Proje Analizi

Bu proje kapsamlı bir analiz sürecinden geçmiştir. Detaylı değerlendirme raporlarını aşağıdaki dosyalarda bulabilirsiniz:

### Analiz Raporları

- **[ANALIZ_OZET.md](./ANALIZ_OZET.md)** - Hızlı özet rapor
  - En güçlü 10 yön
  - En kritik 10 eksik  
  - Puanlama tabloları
  - Acil öneriler
  
- **[DETAYLI_ANALIZ.md](./DETAYLI_ANALIZ.md)** - Kapsamlı detaylı analiz (1,600+ satır)
  - Teknik mimari analizi
  - Her özelliğin detaylı incelemesi
  - Güvenlik değerlendirmesi
  - Performans analizi
  - Kod kalitesi incelemesi
  - İyileştirme önerileri
  - Ticari potansiyel değerlendirmesi

### Genel Değerlendirme

**Puan:** ⭐⭐⭐⭐ (4/5)

**En Güçlü Yönleri:**
- 🤖 Mükemmel AI entegrasyonu (Gemini 2.0 Flash)
- �� Benzersiz konsept (Kişiselleştirilmiş öğrenme)
- 🎨 Modern UI/UX (Material Design 3)

**Kritik İyileştirme Alanları:**
- 🚨 API key güvenliği (acil)
- 🧪 Test coverage eklenmeli
- 📱 iOS desteği tamamlanmalı

**Ticari Potansiyel:** ⭐⭐⭐⭐⭐ (Yüksek)

