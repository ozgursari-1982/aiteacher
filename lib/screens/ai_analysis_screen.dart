import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/gemini_ai_service.dart';
import '../models/course.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  final _firestoreService = FirestoreService();
  final _aiService = GeminiAIService();
  bool _isLoading = true;
  String? _aiAnalysis;
  List<Course> _courses = [];
  Map<String, double> _courseAverages = {};
  Map<String, int> _courseTestCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Dersleri yükle
      _courses = await _firestoreService.getCourses(userId);

      // Her ders için test sayısı ve ortalama
      for (var course in _courses) {
        final tests = await _firestoreService.getTests(userId, course.id);
        final completedTests = tests.where((t) => t.isCompleted).toList();
        
        _courseTestCounts[course.name] = completedTests.length;

        if (completedTests.isNotEmpty) {
          final avg = completedTests
                  .map((t) => t.score ?? 0)
                  .reduce((a, b) => a + b) /
              completedTests.length;
          _courseAverages[course.name] = avg;
        } else {
          _courseAverages[course.name] = 0;
        }
      }

      // AI analizini al
      await _generateAIAnalysis(forceRefresh: forceRefresh);
    } catch (e) {
      print('❌ Veri yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yükleme hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateAIAnalysis({bool forceRefresh = false}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Zorunlu yenileme ise cache'i temizle
      if (forceRefresh) {
        print('🗑️ Cache temizleniyor ve yeni analiz yapılıyor...');
        await _firestoreService.clearAnalysisCache(userId);
      } else {
        // Zorunlu yenileme değilse, cache kontrol et
        final isCacheValid = await _firestoreService.isAnalysisCacheValid(userId);
        
        if (isCacheValid) {
          print('📦 Cache\'ten analiz getiriliyor');
          final cachedData = await _firestoreService.getCachedAnalysis(userId);
          if (cachedData != null && cachedData['analysis'] != null) {
            if (mounted) {
              setState(() => _aiAnalysis = cachedData['analysis'] as String);
            }
            return;
          }
        }
      }

      // Yeni analiz yap
      print('🤖 Kişiselleştirilmiş AI analizi başlatılıyor...');
      
      final examDates = <String, DateTime?>{};
      for (var course in _courses) {
        examDates[course.name] = course.nextExamDate;
      }
      
      final totalMaterials = _courses.fold(0, (sum, c) => sum + c.uploadedFilesCount);
      
      // Öğrenci profil bilgilerini al
      final studentProfile = await _firestoreService.getStudentProfile(userId);
      
      final analysis = await _aiService.generatePersonalizedAnalysis(
        courseAverages: _courseAverages,
        courseTestCounts: _courseTestCounts,
        courseExamDates: examDates,
        totalMaterials: totalMaterials,
        studentProfile: studentProfile, // Profil bilgilerini gönder
      );
      
      await _firestoreService.saveAnalysisCache(userId, analysis);
      print('✅ AI analizi tamamlandı');
      
      if (mounted) {
        setState(() => _aiAnalysis = analysis);
      }
    } catch (e) {
      print('❌ AI analizi hatası: $e');
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('429') || errorMessage.contains('quota') || errorMessage.contains('kota aşıldı') || errorMessage.contains('rate limit')) {
        if (mounted) {
          setState(() => _aiAnalysis = 
              '⚠️ AI kota aşıldı. Lütfen bir süre sonra tekrar deneyin veya Google Cloud konsolunuzdan kota durumunu kontrol edin.');
        }
      } else {
        if (mounted) {
          setState(() => _aiAnalysis = '⚠️ AI analizi yapılamadı: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Durum Analizi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Yeni Analiz Yap (Cache Temizle)',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Cache temizleniyor ve yeni analiz yapılıyor...'),
                  duration: Duration(seconds: 2),
                ),
              );
              await _loadData(forceRefresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () => _loadData(forceRefresh: false),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(forceRefresh: false),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('AI analiz yapıyor...'),
                    SizedBox(height: 8),
                    Text(
                      'Bu biraz zaman alabilir',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bilgi kartı
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI sizin gerçek ders durumunuza göre kişiselleştirilmiş öneriler sunuyor',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // AI Analiz Kartı
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade50, Colors.blue.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Kişiselleştirilmiş Analiz',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 20),
                            if (_aiAnalysis == null)
                              const Center(
                                child: Text('AI analizi yükleniyor...'),
                              )
                            else
                              SelectableText(
                                _aiAnalysis!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.8,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

