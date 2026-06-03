import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_fitness/models/workout_history_entry.dart';
import 'package:healthy_fitness/services/workout_history_service.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({
    super.key,
    required this.user,
    this.historyService,
  });

  final User user;
  final WorkoutHistoryService? historyService;

  @override
  Widget build(BuildContext context) {
    final WorkoutHistoryService service =
        historyService ?? WorkoutHistoryService();
    return Scaffold(
      appBar: AppBar(title: const Text('Workout history')),
      body: StreamBuilder<List<WorkoutHistoryEntry>>(
        stream: service.watchHistory(user.uid),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<WorkoutHistoryEntry>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<WorkoutHistoryEntry> entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No completed workouts yet.\nFinish a workout to see it here.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final WorkoutHistoryEntry entry = entries[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.teal),
                  title: Text(entry.workoutTitle),
                  subtitle: Text(_formatDateTime(entry.completedAt)),
                  trailing: Text('${entry.durationMinutes} min'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final String month = dateTime.month.toString().padLeft(2, '0');
  final String day = dateTime.day.toString().padLeft(2, '0');
  final String hour = dateTime.hour.toString().padLeft(2, '0');
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day $hour:$minute';
}
