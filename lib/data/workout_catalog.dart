import 'package:flutter/material.dart';
import 'package:healthy_fitness/models/workout.dart';

const List<Workout> workoutCatalog = [
  Workout(
    id: 'morning_cardio',
    title: 'Morning Cardio',
    durationMinutes: 25,
    icon: Icons.directions_run,
    description:
        'Light-to-moderate cardio to raise heart rate and burn calories.',
    exercises: [
      WorkoutExercise(name: 'Brisk walk / jog', sets: 1, repsOrDuration: '8 min'),
      WorkoutExercise(name: 'Jumping jacks', sets: 3, repsOrDuration: '45 sec'),
      WorkoutExercise(name: 'High knees', sets: 3, repsOrDuration: '40 sec'),
      WorkoutExercise(name: 'Cool-down walk', sets: 1, repsOrDuration: '5 min'),
    ],
  ),
  Workout(
    id: 'strength_training',
    title: 'Strength Training',
    durationMinutes: 30,
    icon: Icons.fitness_center,
    description: 'Full-body strength session with compound movements.',
    exercises: [
      WorkoutExercise(name: 'Squats', sets: 4, repsOrDuration: '12 reps'),
      WorkoutExercise(name: 'Push-ups', sets: 4, repsOrDuration: '10 reps'),
      WorkoutExercise(name: 'Lunges', sets: 3, repsOrDuration: '10/leg'),
      WorkoutExercise(name: 'Plank', sets: 3, repsOrDuration: '45 sec'),
    ],
  ),
  Workout(
    id: 'stretch_mobility',
    title: 'Stretch & Mobility',
    durationMinutes: 15,
    icon: Icons.self_improvement,
    description: 'Recovery-focused mobility and stretching routine.',
    exercises: [
      WorkoutExercise(name: 'Neck rolls', sets: 2, repsOrDuration: '30 sec'),
      WorkoutExercise(name: 'Hip flexor stretch', sets: 2, repsOrDuration: '45 sec/side'),
      WorkoutExercise(name: 'Hamstring stretch', sets: 2, repsOrDuration: '45 sec/side'),
      WorkoutExercise(name: 'Child\'s pose', sets: 2, repsOrDuration: '60 sec'),
    ],
  ),
];

Workout? workoutById(String id) {
  for (final Workout workout in workoutCatalog) {
    if (workout.id == id) {
      return workout;
    }
  }
  return null;
}
