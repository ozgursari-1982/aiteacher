import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class ExamCalendarScreen extends StatefulWidget {
  final String studentId;

  const ExamCalendarScreen({super.key, required this.studentId});

  @override
  State<ExamCalendarScreen> createState() => _ExamCalendarScreenState();
}

class _ExamCalendarScreenState extends State<ExamCalendarScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav Takvimi'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Course>>(
          stream: _firestoreService.getStudentCourses(widget.studentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            }

            final courses = snapshot.data ?? [];
            final coursesWithExams = courses
                .where((c) => c.nextExamDate != null)
                .toList()
              ..sort((a, b) => a.nextExamDate!.compareTo(b.nextExamDate!));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar view (simplified)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now()),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${coursesWithExams.length} yaklaşan sınav',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Upcoming exams
                  if (coursesWithExams.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 48),
                          Icon(
                            Icons.event_available,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Yaklaşan sınav yok',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Derslerinize sınav tarihi ekleyebilirsiniz',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yaklaşan Sınavlar',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 16),
                        ...coursesWithExams.map((course) => _buildExamCard(course)),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamCard(Course course) {
    final daysUntil = course.nextExamDate!.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUrgent
              ? Colors.red.withOpacity(0.2)
              : Theme.of(context).primaryColor.withOpacity(0.2),
          child: Icon(
            Icons.event,
            color: isUrgent ? Colors.red : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(course.name),
        subtitle: Text(
          DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(course.nextExamDate!),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$daysUntil',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isUrgent ? Colors.red : Theme.of(context).primaryColor,
                  ),
            ),
            Text(
              'gün',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

