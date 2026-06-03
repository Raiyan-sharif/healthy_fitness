import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_fitness/models/workout.dart';
import 'package:healthy_fitness/services/workout_history_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    required this.user,
    this.historyService,
  });

  final Workout workout;
  final User user;
  final WorkoutHistoryService? historyService;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late final WorkoutHistoryService _historyService =
      widget.historyService ?? WorkoutHistoryService();
  bool _completing = false;

  Future<void> _completeWorkout() async {
    setState(() => _completing = true);
    try {
      await _historyService.addCompletedWorkout(
        uid: widget.user.uid,
        workout: widget.workout,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.workout.title} saved to history')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save workout: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _completing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Workout workout = widget.workout;

    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(workout.icon, size: 40),
            title: Text('${workout.durationMinutes} minutes'),
            subtitle: Text(workout.description),
          ),
          const SizedBox(height: 16),
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...workout.exercises.map(
            (WorkoutExercise exercise) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(exercise.name),
                subtitle: Text(
                  '${exercise.sets} sets · ${exercise.repsOrDuration}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _completing ? null : _completeWorkout,
            icon: _completing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              _completing ? 'Saving...' : 'Mark workout complete',
            ),
          ),
        ],
      ),
    );
  }
}
