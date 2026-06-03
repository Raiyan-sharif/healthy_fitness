import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_fitness/data/workout_catalog.dart';
import 'package:healthy_fitness/models/workout.dart';
import 'package:healthy_fitness/screens/profile/profile_screen.dart';
import 'package:healthy_fitness/screens/workout/workout_detail_screen.dart';
import 'package:healthy_fitness/screens/workout/workout_history_screen.dart';
import 'package:healthy_fitness/services/auth_service.dart';
import 'package:healthy_fitness/widgets/live_mode_card.dart';
import 'package:healthy_fitness/widgets/progress_tile.dart';
import 'package:healthy_fitness/widgets/workout_card.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key, this.authService});

  final AuthService? authService;

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  static const int _dailyGoal = 8000;
  static const String _baselineStepsKey = 'baseline_steps';
  static const String _baselineDateKey = 'baseline_date';

  StreamSubscription<StepCount>? _stepSubscription;
  int? _sensorStepCount;
  int? _baselineSteps;
  String _stepStatus = 'Preparing step tracker...';

  User? get _user => widget.authService?.currentUser;

  @override
  void initState() {
    super.initState();
    _initStepTracking();
  }

  Future<void> _initStepTracking() async {
    final bool hasPermission = await _requestActivityPermission();
    if (!mounted) {
      return;
    }

    if (!hasPermission) {
      setState(() {
        _stepStatus = 'Activity permission denied.';
      });
      return;
    }

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!mounted) {
          return;
        }
        _onStepEvent(event.steps);
      },
      onError: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _stepStatus = 'No live sensor data. Walk a few steps and retry.';
        });
      },
      cancelOnError: false,
    );
  }

  Future<bool> _requestActivityPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final PermissionStatus permission =
        await Permission.activityRecognition.request();
    return permission.isGranted;
  }

  Future<void> _onStepEvent(int sensorSteps) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String today = _todayKey();
    final String? storedDate = prefs.getString(_baselineDateKey);
    int? baseline = prefs.getInt(_baselineStepsKey);

    if (storedDate != today || baseline == null || baseline > sensorSteps) {
      baseline = sensorSteps;
      await prefs.setString(_baselineDateKey, today);
      await prefs.setInt(_baselineStepsKey, baseline);
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _sensorStepCount = sensorSteps;
      _baselineSteps = baseline;
      _stepStatus = 'Live updates enabled';
    });
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  void _openWorkout(Workout workout) {
    final User? user = _user;
    if (user == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailScreen(
          workout: workout,
          user: user,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int steps = _sensorStepCount == null
        ? 0
        : (_sensorStepCount! - (_baselineSteps ?? _sensorStepCount!))
            .clamp(0, 1000000);
    final double progress = (steps / _dailyGoal).clamp(0, 1).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Fitness'),
        actions: [
          IconButton(
            tooltip: 'Workout history',
            icon: const Icon(Icons.history),
            onPressed: _user == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            WorkoutHistoryScreen(user: _user!),
                      ),
                    );
                  },
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: _user == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(user: _user!),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Goal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hi, ${_user?.displayName ?? 'Athlete'} — burn 450 kcal and hit $_dailyGoal steps.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Workouts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...workoutCatalog.map(
            (Workout workout) => WorkoutCard(
              workout: workout,
              onTap: () => _openWorkout(workout),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Live Training Modes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const LiveModeCard(
            icon: Icons.person,
            title: '1:1 Personal Session',
            description: 'Trainer and one student in a private live session.',
          ),
          const LiveModeCard(
            icon: Icons.groups,
            title: 'Group Live Class',
            description:
                'Trainer goes live and teaches all students in parallel.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ProgressTile(
            label: 'Steps',
            value: '$steps / $_dailyGoal',
            subtitle: _stepStatus,
            progress: progress,
          ),
          const ProgressTile(
            label: 'Water',
            value: '1.8L / 2.5L',
          ),
        ],
      ),
    );
  }
}
