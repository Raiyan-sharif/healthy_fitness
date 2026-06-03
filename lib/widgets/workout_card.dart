import 'package:flutter/material.dart';
import 'package:healthy_fitness/models/workout.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  final Workout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(workout.icon),
        title: Text(workout.title),
        subtitle: Text('${workout.durationMinutes} min'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
