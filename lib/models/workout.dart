import 'package:flutter/material.dart';

class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.repsOrDuration,
  });

  final String name;
  final int sets;
  final String repsOrDuration;
}

class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.icon,
    required this.description,
    required this.exercises,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final IconData icon;
  final String description;
  final List<WorkoutExercise> exercises;
}
