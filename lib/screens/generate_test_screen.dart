import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/test.dart';
import '../services/firestore_service.dart';
import '../services/gemini_ai_service.dart';

class GenerateTestScreen extends StatefulWidget {
  final Course course;

  const GenerateTestScreen({super.key, required this.course});

  @override
  State<GenerateTestScreen> createState() => _GenerateTestScreenState();
}

class _GenerateTestScreenState extends State<GenerateTestScreen> {
  final _firestoreService = FirestoreService();
  final _aiService = GeminiAIService();
  
  int _questionCount = 10;
  String _difficulty = 'orta';
  bool _isGenerating = false;

  Future<void> _generateTest() async {
    setState(() => _isGenerating = true);

    try {
      // Get materials for analysis
      final materials = await _firestoreService
          .getCourseMaterials(widget.course.id)
          .first;

      if (materials.isEmpty) {
        throw 'Bu ders için henüz materyal yüklemediniz.\n\nLütfen önce:\n• Materyaller sekmesinden\n• + butonuna tıklayın\n• Ders notlarınızı yükleyin';
      }

      // Get AI analyses
      final analyses = materials
          .where((m) => m.aiAnalysis != null)
          .map((m) => m.aiAnalysis!)
          .toList();

      final analyzedCount = analyses.length;
      final totalCount = materials.length;

      if (analyses.isEmpty) {
        throw 'Materyalleriniz henüz AI tarafından analiz edilmedi.\n\n'
              '📊 Durum: $analyzedCount/$totalCount materyal analiz edildi\n\n'
              'AI analizi birkaç saniye sürebilir. Lütfen:\n'
              '• 10-20 saniye bekleyin\n'
              '• Veya yeni materyal yükleyin\n'
              '• Materyaller sekmesinde analiz durumunu kontrol edin';
      }

      // Generate test questions
      final questions = await _aiService.generateTest(
        courseName: widget.course.name,
        materialAnalyses: analyses,
        questionCount: _questionCount,
        difficulty: _difficulty,
      );

      // Save test
      final test = Test(
        id: '',
        courseId: widget.course.id,
        studentId: widget.course.studentId,
        title: '${widget.course.name} - $_difficulty Test',
        questions: questions,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addTest(test);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Oluştur'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI, yüklediğiniz materyallere göre size özel sorular hazırlayacak',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Question count
              Text(
                'Soru Sayısı: $_questionCount',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _questionCount.toDouble(),
                min: 5,
                max: 20,
                divisions: 15,
                label: _questionCount.toString(),
                onChanged: (value) {
                  setState(() => _questionCount = value.toInt());
                },
              ),
              const SizedBox(height: 24),
              // Difficulty
              Text(
                'Zorluk Seviyesi',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'kolay',
                    label: Text('Kolay'),
                    icon: Icon(Icons.sentiment_satisfied),
                  ),
                  ButtonSegment(
                    value: 'orta',
                    label: Text('Orta'),
                    icon: Icon(Icons.sentiment_neutral),
                  ),
                  ButtonSegment(
                    value: 'zor',
                    label: Text('Zor'),
                    icon: Icon(Icons.sentiment_very_dissatisfied),
                  ),
                ],
                selected: {_difficulty},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _difficulty = newSelection.first);
                },
              ),
              const Spacer(),
              // Generate button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateTest,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Test Hazırlanıyor...' : 'Test Oluştur'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

