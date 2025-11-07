import 'package:flutter/material.dart';
import '../models/test.dart';

class TestReviewScreen extends StatelessWidget {
  final Test test;

  const TestReviewScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test İnceleme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test bilgi kartı
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(
                          Icons.quiz,
                          '${test.questions.length} Soru',
                          Colors.blue,
                        ),
                        if (test.isCompleted)
                          _buildInfoChip(
                            Icons.star,
                            '${test.score?.toStringAsFixed(0)}%',
                            test.score! >= 70
                                ? Colors.green
                                : test.score! >= 50
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                      ],
                    ),
                    if (test.isCompleted) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tamamlandı: ${_formatDate(test.completedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sorular ve cevaplar
            ...test.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final studentAnswer = test.studentAnswers?[question.id];
              final isCorrect = studentAnswer == question.correctAnswerKey;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Soru başlığı
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (test.isCompleted)
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 28,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Seçenekler
                      ...question.options.asMap().entries.map((optionEntry) {
                        final optionIndex = optionEntry.key;
                        final optionValue = optionEntry.value;
                        final optionKey = String.fromCharCode('A'.codeUnitAt(0) + optionIndex);

                        final isStudentChoice = studentAnswer == optionKey;
                        final isCorrectOption = optionIndex == question.correctAnswerIndex;

                        Color? backgroundColor;
                        Color? textColor;
                        IconData? icon;

                        if (test.isCompleted) {
                          if (isCorrectOption) {
                            backgroundColor = Colors.green.shade100;
                            textColor = Colors.green.shade900;
                            icon = Icons.check_circle;
                          } else if (isStudentChoice && !isCorrect) {
                            backgroundColor = Colors.red.shade100;
                            textColor = Colors.red.shade900;
                            icon = Icons.cancel;
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: backgroundColor != null
                                  ? (isCorrectOption
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: backgroundColor != null
                                      ? (isCorrectOption
                                          ? Colors.green
                                          : Colors.red)
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: icon != null
                                    ? Icon(icon, color: Colors.white, size: 18)
                                    : Text(
                                        optionKey,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionValue,
                                  style: TextStyle(
                                    color: textColor ?? Colors.black87,
                                    fontWeight: isCorrectOption || isStudentChoice
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Açıklama (varsa)
                      if (test.isCompleted &&
                          question.explanation != null &&
                          question.explanation!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
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
                                question.explanation!,
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

