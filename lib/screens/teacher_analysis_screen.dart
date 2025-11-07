import 'package:flutter/material.dart';
import '../models/teacher_style_profile.dart';

class TeacherAnalysisScreen extends StatelessWidget {
  final TeacherStyleProfile profile;

  const TeacherAnalysisScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğretmen Analizi'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İSTATİSTİK KARTI
            _buildStatisticsCard(context),
            const SizedBox(height: 16),
            
            // ÖĞRETMEN PROFİLİ
            _buildTeacherPersonalityCard(context),
            const SizedBox(height: 16),
            
            // KONU DAĞILIMI
            _buildTopicDistributionCard(context),
            const SizedBox(height: 16),
            
            // SINAV TAHMİNİ
            _buildExamPredictionCard(context),
            const SizedBox(height: 24),
            
            // SİMÜLASYON BUTONU
            _buildSimulationButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'ANALİZ İSTATİSTİKLERİ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.description,
                  label: 'Belge',
                  value: '${profile.totalDocumentsAnalyzed}',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.quiz,
                  label: 'Soru',
                  value: '${profile.totalQuestionsFound}',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.topic,
                  label: 'Konu',
                  value: '${profile.topicDistribution.length}',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTeacherPersonalityCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'ÖĞRETMEN PROFİLİ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.teacherPersonality.isNotEmpty
                  ? profile.teacherPersonality
                  : 'Öğretmen profili oluşturuluyor...',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicDistributionCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'KONU DAĞILIMI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.topicDistribution.isEmpty)
              const Text('Henüz yeterli veri yok')
            else
              ...profile.topicDistribution.entries.map((entry) {
                final topic = entry.value;
                return _buildTopicItem(topic);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(TopicAnalysis topic) {
    final probability = (topic.examProbability * 100).toInt();
    final emphasis = (topic.teacherEmphasis * 100).toInt();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: topic.examProbability > 0.8
            ? Colors.red.shade50
            : topic.examProbability > 0.5
                ? Colors.orange.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: topic.examProbability > 0.8
              ? Colors.red.shade200
              : topic.examProbability > 0.5
                  ? Colors.orange.shade200
                  : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topic.topicName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: topic.examProbability > 0.8
                      ? Colors.red
                      : topic.examProbability > 0.5
                          ? Colors.orange
                          : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$probability%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${topic.questionCount} soru • Önem: $emphasis%',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          if (topic.subTopics.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Alt konular: ${topic.subTopics.join(", ")}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExamPredictionCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'SINAV TAHMİNİ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (profile.examPrediction.criticalTopics.isNotEmpty) ...[
              const Text(
                '🔴 MUTLAKA ÇIKACAK:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...profile.examPrediction.criticalTopics.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $topic', style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              const SizedBox(height: 12),
            ],
            
            if (profile.examPrediction.possibleTopics.isNotEmpty) ...[
              const Text(
                '🟡 ÇIKABİLECEK:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...profile.examPrediction.possibleTopics.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $topic', style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gerçekçi sınav simülasyonu özelliği yakında!'),
            ),
          );
        },
        icon: const Icon(Icons.science, size: 28),
        label: const Text(
          'GERÇEK SINAV SİMÜLASYONU OLUŞTUR',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}