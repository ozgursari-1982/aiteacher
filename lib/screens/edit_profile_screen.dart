import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Controllers
  final _schoolController = TextEditingController();
  final _goalsController = TextEditingController();
  final _notesController = TextEditingController();
  
  // State variables
  int? _selectedGrade;
  String? _selectedLearningStyle;
  List<String> _favoriteCourses = [];
  List<String> _difficultCourses = [];
  
  // Options
  final List<int> _grades = [9, 10, 11, 12];
  final List<String> _learningStyles = [
    'Görsel (Resim, Şema, Video)',
    'İşitsel (Dinleme, Anlatma)',
    'Okuma-Yazma (Not, Kitap)',
    'Kinestetik (Uygulama, Deneyim)',
  ];
  
  final List<String> _allCourses = [
    'Matematik',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Türkçe',
    'Tarih',
    'Coğrafya',
    'İngilizce',
    'Felsefe',
    'Edebiyat',
    'Geometri',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final profile = await _firestoreService.getStudentProfile(userId);
      if (profile != null && mounted) {
        setState(() {
          _selectedGrade = profile['grade'] as int?;
          _schoolController.text = profile['schoolName'] ?? '';
          _goalsController.text = profile['studyGoals'] ?? '';
          _notesController.text = profile['notes'] ?? '';
          _selectedLearningStyle = profile['learningStyle'] as String?;
          _favoriteCourses = profile['favoriteCourses'] != null
              ? List<String>.from(profile['favoriteCourses'])
              : [];
          _difficultCourses = profile['difficultCourses'] != null
              ? List<String>.from(profile['difficultCourses'])
              : [];
        });
      }
    } catch (e) {
      print('❌ Profil yükleme hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateStudentProfile(userId, {
        'grade': _selectedGrade,
        'schoolName': _schoolController.text.trim(),
        'studyGoals': _goalsController.text.trim(),
        'notes': _notesController.text.trim(),
        'learningStyle': _selectedLearningStyle,
        'favoriteCourses': _favoriteCourses,
        'difficultCourses': _difficultCourses,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil bilgileri kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _goalsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hesap Bilgileri')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Bilgileri'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu bilgiler AI\'nın size daha kişiselleştirilmiş öneriler sunmasına yardımcı olur',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sınıf seviyesi
            const Text(
              '📚 Sınıf Seviyesi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedGrade,
              decoration: const InputDecoration(
                hintText: 'Sınıfınızı seçin',
                border: OutlineInputBorder(),
              ),
              items: _grades.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text('$grade. Sınıf'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGrade = value),
            ),
            const SizedBox(height: 24),

            // Okul adı
            const Text(
              '🏫 Okul Adı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _schoolController,
              decoration: const InputDecoration(
                hintText: 'Okuluğunuzun adı (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Öğrenme stili
            const Text(
              '🧠 Öğrenme Stilim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLearningStyle,
              decoration: const InputDecoration(
                hintText: 'Nasıl öğrenirsiniz?',
                border: OutlineInputBorder(),
              ),
              items: _learningStyles.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedLearningStyle = value),
            ),
            const SizedBox(height: 24),

            // Sevdiğim dersler
            const Text(
              '💚 Sevdiğim Dersler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allCourses.map((course) {
                final isSelected = _favoriteCourses.contains(course);
                return FilterChip(
                  label: Text(course),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _favoriteCourses.add(course);
                        _difficultCourses.remove(course);
                      } else {
                        _favoriteCourses.remove(course);
                      }
                    });
                  },
                  selectedColor: Colors.green.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Zorlandığım dersler
            const Text(
              '⚠️ Zorlandığım Dersler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allCourses.map((course) {
                final isSelected = _difficultCourses.contains(course);
                return FilterChip(
                  label: Text(course),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _difficultCourses.add(course);
                        _favoriteCourses.remove(course);
                      } else {
                        _difficultCourses.remove(course);
                      }
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Hedefler
            const Text(
              '🎯 Hedeflerim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _goalsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Örn: Üniversite sınavında 500+ puan almak, Matematik ortalamasını yükseltmek...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Notlar
            const Text(
              '📝 Ek Notlar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'AI\'nın bilmesini istediğiniz başka şeyler...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

