# 📱 AI Öğretmen - Proje Özeti

## 🎓 Proje Tanımı

AI Öğretmen, öğrencilerin gerçek ders notlarını, ödevlerini ve PDF'lerini analiz ederek, sınav tarihlerine kadar kişiselleştirilmiş testler ve çalışma önerileri sunan bir mobil uygulamadır.

## ✨ Temel Özellikler

### 1. Öğrenci Odaklı Sistem
- ✅ Her öğrenci kendi hesabıyla giriş yapar
- ✅ Kişisel dersler ve materyaller
- ✅ Özel test geçmişi ve performans takibi

### 2. Akıllı Materyal Analizi
- ✅ PDF, resim ve belge yükleme
- ✅ Gemini AI ile otomatik içerik analizi
- ✅ Önemli konuların tespiti
- ✅ Öğrenme noktalarının belirlenmesi

### 3. Kişiselleştirilmiş Test Oluşturma
- ✅ Öğrencinin yüklediği materyallere göre sorular
- ✅ 3 zorluk seviyesi (kolay, orta, zor)
- ✅ Özelleştirilebilir soru sayısı (5-20)
- ✅ Çoktan seçmeli format

### 4. Akıllı Değerlendirme
- ✅ Otomatik puanlama
- ✅ Detaylı soru açıklamaları
- ✅ Performans analizi
- ✅ Zayıf konuların tespiti

### 5. Sınav Yönetimi
- ✅ Sınav tarihleri takibi
- ✅ Geri sayım
- ✅ Yaklaşan sınavlar listesi
- ✅ Hazırlık durumu analizi

## 🏗 Mimari

### Frontend (Flutter)
```
- Material Design 3
- Responsive tasarım
- Modern UI/UX
- Smooth animations
```

### Backend (Firebase)
```
- Authentication (Email/Password, Google)
- Firestore (NoSQL database)
- Storage (Dosya depolama)
- Real-time updates
```

### AI (Gemini API)
```
- Materyal analizi
- Test soruları oluşturma
- Performans değerlendirmesi
- Çalışma önerileri
```

## 📊 Veri Modeli

### Student (Öğrenci)
```dart
{
  id: String,
  fullName: String,
  email: String,
  photoUrl: String?,
  createdAt: DateTime
}
```

### Course (Ders)
```dart
{
  id: String,
  studentId: String,
  name: String,
  teacherName: String?,
  description: String?,
  nextExamDate: DateTime?,
  uploadedFilesCount: int,
  createdAt: DateTime
}
```

### StudyMaterial (Ders Materyali)
```dart
{
  id: String,
  courseId: String,
  studentId: String,
  title: String,
  type: MaterialType, // note, homework, pdf, image
  fileUrl: String,
  description: String?,
  aiAnalysis: String?,
  uploadedAt: DateTime
}
```

### Test (Test)
```dart
{
  id: String,
  courseId: String,
  studentId: String,
  title: String,
  questions: List<Question>,
  createdAt: DateTime,
  completedAt: DateTime?,
  studentAnswers: Map<String, String>?,
  score: double?
}
```

### Question (Soru)
```dart
{
  id: String,
  question: String,
  options: List<String>,
  correctAnswerIndex: int,
  explanation: String?
}
```

## 🎨 Ekranlar

### 1. Welcome Screen (Hoş Geldiniz)
- Uygulama tanıtımı
- Kayıt ol / Giriş yap butonları

### 2. Login Screen (Giriş)
- Email/şifre girişi
- Google ile giriş
- Şifremi unuttum (TODO)

### 3. SignUp Screen (Kayıt)
- Ad soyad, email, şifre
- Google ile kayıt
- Hizmet şartları

### 4. Dashboard (Ana Sayfa)
- Dersler grid görünümü
- Ders kartları (isim, belge sayısı, sınav tarihi)
- Bottom navigation
- Floating action button (ders ekle)

### 5. Course Detail (Ders Detayı)
- Materyaller sekmesi
- Testler sekmesi
- Materyal/test ekleme

### 6. Add Course (Ders Ekle)
- Ders adı
- Öğretmen adı
- Açıklama
- Sınav tarihi

### 7. Upload Material (Materyal Yükle)
- Galeri seçimi
- Kamera çekimi
- PDF/Belge seçimi
- Başlık ve açıklama
- AI analizi

### 8. Generate Test (Test Oluştur)
- Soru sayısı slider
- Zorluk seviyesi seçimi
- AI ile otomatik oluşturma

### 9. Take Test (Test Çöz)
- Progress bar
- Soru gösterimi
- Çoktan seçmeli şıklar
- Önceki/Sonraki navigasyon
- Sonuç ekranı

### 10. Exam Calendar (Sınav Takvimi)
- Aylık görünüm
- Yaklaşan sınavlar listesi
- Geri sayım
- Aciliyet renklendirmesi

### 11. Profile (Profil)
- Kullanıcı bilgileri
- Hesap ayarları
- Yardım & Destek
- Hakkında
- Çıkış yap

## 🔐 Güvenlik

### Authentication
- Firebase Authentication
- Secure token management
- Google OAuth 2.0

### Database
- User-specific data access
- Firestore security rules
- Role-based permissions

### Storage
- User-isolated file storage
- Secure upload/download
- File type validation

## 🚀 Performans

### Optimizasyonlar
- Lazy loading
- Image caching
- Efficient queries
- Real-time listeners

### Best Practices
- State management (Provider)
- Error handling
- Loading states
- Offline support (TODO)

## 📱 Platform Desteği

### ✅ Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 33 (Android 13)
- Fully supported

### ❌ iOS
- Not implemented yet
- Firebase configuration needed
- Additional setup required

## 🔄 Gelecek Güncellemeler

### Kısa Vadeli (v1.1)
- [ ] Şifre sıfırlama
- [ ] Test sonuçları detay sayfası
- [ ] Push bildirimleri
- [ ] Profil fotoğrafı güncelleme

### Orta Vadeli (v1.2)
- [ ] Performans grafikleri
- [ ] Çalışma planı oluşturma
- [ ] Sesli not kaydı
- [ ] Video materyal desteği

### Uzun Vadeli (v2.0)
- [ ] iOS desteği
- [ ] Web uygulaması
- [ ] Çevrimdışı mod
- [ ] Grup çalışması
- [ ] Öğretmen paneli

## 📊 Teknoloji Stack Özeti

| Kategori | Teknoloji |
|----------|-----------|
| Framework | Flutter 3.9.2+ |
| Dil | Dart 3.0+ |
| UI | Material Design 3 |
| Backend | Firebase |
| Database | Firestore |
| Storage | Firebase Storage |
| Auth | Firebase Auth |
| AI | Google Gemini API |
| State | Provider |
| HTTP | google_generative_ai |
| Images | image_picker |
| Files | file_picker |
| Fonts | Google Fonts |

## 🎯 Hedef Kitle

- İlköğretim öğrencileri
- Ortaöğretim öğrencileri
- Lise öğrencileri
- Üniversite öğrencileri
- Sınava hazırlanan herkes

## 💡 Fark Yaratan Özellikler

### 1. Gerçek Materyallere Dayalı
Genel testler yerine, öğrencinin **kendi ders notlarına** göre sorular

### 2. Öğretmen Odaklı
Öğrencinin **gerçek öğretmeninin** anlattığı konulardan sorular

### 3. Zamanlama
**Sınav tarihine** göre hazırlık planı

### 4. Adaptif Öğrenme
**Zayıf konuları** tespit edip özel çalışma önerileri

### 5. Kolay Kullanım
Basit arayüz, hızlı materyal yükleme

## 📈 Başarı Metrikleri

- Yüklenen materyal sayısı
- Oluşturulan test sayısı
- Ortalama test skoru
- Aktif kullanıcı sayısı
- Kullanım süresi

## 🎓 Eğitim Değeri

Bu uygulama:
- ✅ Öğrenmeyi kişiselleştirir
- ✅ Zaman yönetimi geliştirir
- ✅ Kendini değerlendirme becerisi kazandırır
- ✅ Teknoloji ile öğrenmeyi birleştirir
- ✅ Motivasyonu artırır

---

**Proje Durumu:** ✅ Tamamlandı (v1.0)
**Geliştirme Süresi:** ~2 saat
**Toplam Dosya:** 25+ dosya
**Kod Satırı:** ~3000+ satır

