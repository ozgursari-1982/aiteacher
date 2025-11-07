import 'package:flutter/material.dart';
import '../models/test.dart';
import '../services/gemini_ai_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TestResultScreen extends StatefulWidget {
  final Test test;
  final Map<String, int> selectedAnswers;
  final int correctCount;
  final double score;

  const TestResultScreen({
    super.key,
    required this.test,
    required this.selectedAnswers,
    required this.correctCount,
    required this.score,
  });

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  final _aiService = GeminiAIService();
  String? _aiRecommendation;
  bool _isLoadingAI = true;

  @override
  void initState() {
    super.initState();
    _generateAIRecommendation();
  }

  Future<void> _generateAIRecommendation() async {
    try {
      // Test sonucuna göre AI önerisi al
      final wrongQuestions = <String>[];
      for (var question in widget.test.questions) {
        final userAnswer = widget.selectedAnswers[question.id];
        if (userAnswer != question.correctAnswerIndex) {
          wrongQuestions.add(question.question);
        }
      }

      final prompt = '''
Test Sonucu Değerlendirmesi:

Ders: ${widget.test.title}
Başarı Oranı: ${widget.score.toStringAsFixed(0)}%
Doğru: ${widget.correctCount} / ${widget.test.questions.length}
Yanlış: ${widget.test.questions.length - widget.correctCount}

${wrongQuestions.isNotEmpty ? '''
Yanlış Yapılan Sorular:
${wrongQuestions.map((q) => '- $q').join('\n')}
''' : ''}

Lütfen bu test sonucuna göre:
1. Öğrencinin bu testteki performansını değerlendir
2. Hangi konularda eksik olduğunu belirt
3. Nasıl çalışması gerektiğini öner (3-4 madde)
4. Motivasyon mesajı ver

Kısa ve net, öğrenci dostu bir dilde yaz. Emojiler kullan.
''';

      final content = [Content.text(prompt)];
      final response = await _aiService.model.generateContent(content).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Timeout',
      );
      _aiRecommendation = response.text;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('429') || errorMessage.contains('quota') || errorMessage.contains('rate limit')) {
        _aiRecommendation = 
            '⚠️ AI kota aşıldı. Lütfen daha sonra tekrar deneyin veya Google Cloud konsolunuzdan kota durumunu kontrol edin.';
      } else {
        _aiRecommendation = 'AI önerisi oluşturulamadı: $e';
      }
      print('❌ AI öneri hatası: $e');
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.test.questions.length;
    final wrongCount = totalQuestions - widget.correctCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonuçları'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Özet Kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.score >= 70
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : widget.score >= 50
                        ? [Colors.orange.shade400, Colors.orange.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.score.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.correctCount} Doğru • $wrongCount Yanlış',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getScoreMessage(widget.score),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // AI Recommendation + Sorular Listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.test.questions.length + 1, // +1 for AI card
              itemBuilder: (context, index) {
                // İlk item: AI Önerisi
                if (index == 0) {
                  return Column(
                    children: [
                      _buildAIRecommendationCard(),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                
                // Diğer itemler: Sorular
                final questionIndex = index - 1;
                final question = widget.test.questions[questionIndex];
                final userAnswerIndex = widget.selectedAnswers[question.id];
                final isCorrect = userAnswerIndex == question.correctAnswerIndex;
                
                return _buildQuestionCard(
                  context,
                  question,
                  questionIndex + 1,
                  userAnswerIndex,
                  isCorrect,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Anasayfaya Dön',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  '🤖 AI Değerlendirmesi & Öneriler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (_isLoadingAI)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('AI analiz yapıyor...'),
                  ],
                ),
              )
            else if (_aiRecommendation != null)
              SelectableText(
                _aiRecommendation!,
                style: const TextStyle(fontSize: 14, height: 1.6),
              )
            else
              const Text(
                '⚠️ AI önerisi oluşturulamadı. Lütfen daha sonra tekrar deneyin.',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    Question question,
    int number,
    int? userAnswerIndex,
    bool isCorrect,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık satırı
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Soru $number',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Soru metni
            Text(
              question.question,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Şıklar
            ...List.generate(question.options.length, (index) {
              final isUserAnswer = index == userAnswerIndex;
              final isCorrectAnswer = index == question.correctAnswerIndex;
              
              Color? backgroundColor;
              Color? textColor;
              IconData? icon;
              
              if (isUserAnswer && isCorrect) {
                // Doğru cevap verildi
                backgroundColor = Colors.green.withOpacity(0.1);
                textColor = Colors.green.shade700;
                icon = Icons.check_circle;
              } else if (isUserAnswer && !isCorrect) {
                // Yanlış cevap verildi
                backgroundColor = Colors.red.withOpacity(0.1);
                textColor = Colors.red.shade700;
                icon = Icons.cancel;
              } else if (isCorrectAnswer) {
                // Doğru cevap
                backgroundColor = Colors.green.withOpacity(0.1);
                textColor = Colors.green.shade700;
                icon = Icons.check_circle_outline;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: backgroundColor != null
                        ? (isCorrectAnswer ? Colors.green : Colors.red)
                        : Colors.grey.shade300,
                    width: backgroundColor != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor ?? Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(color: textColor ?? Colors.black87),
                      ),
                    ),
                    if (icon != null)
                      Icon(icon, color: textColor, size: 20),
                  ],
                ),
              );
            }),
            
            // Detaylı Açıklama
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Açıklama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation ?? 'Açıklama mevcut değil.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScoreMessage(double score) {
    if (score >= 90) {
      return '🎉 Mükemmel! Konuyu çok iyi anlamışsın!';
    } else if (score >= 70) {
      return '👍 Başarılı! İyi gidiyorsun!';
    } else if (score >= 50) {
      return '📚 Fena değil ama daha fazla çalışmalısın.';
    } else {
      return '💪 Bu konuları tekrar gözden geçirmelisin.';
    }
  }
}

