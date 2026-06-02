import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Fitness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const FitnessHomePage(),
    );
  }
}

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key});

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

    final PermissionStatus permission = await Permission.activityRecognition
        .request();
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
        centerTitle: false,
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Goal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Burn 450 kcal and complete 8,000 steps.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          const _WorkoutCard(
            icon: Icons.directions_run,
            title: 'Morning Cardio',
            duration: '25 min',
          ),
          const _WorkoutCard(
            icon: Icons.fitness_center,
            title: 'Strength Training',
            duration: '30 min',
          ),
          const _WorkoutCard(
            icon: Icons.self_improvement,
            title: 'Stretch & Mobility',
            duration: '15 min',
          ),
          const SizedBox(height: 20),
          const Text(
            'Live Training Modes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _LiveModeCard(
            icon: Icons.person,
            title: '1:1 Personal Session',
            description: 'Trainer and one student in a private live session.',
          ),
          const _LiveModeCard(
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
          _ProgressTile(
            label: 'Steps',
            value: '$steps / $_dailyGoal',
            subtitle: _stepStatus,
            progress: progress,
          ),
          const _ProgressTile(
            label: 'Water',
            value: '1.8L / 2.5L',
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.icon,
    required this.title,
    required this.duration,
  });

  final IconData icon;
  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(duration),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.label,
    required this.value,
    this.subtitle,
    this.progress,
  });

  final String label;
  final String value;
  final String? subtitle;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(subtitle!),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                    ],
                  ],
                ),
              ),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _LiveModeCard extends StatelessWidget {
  const _LiveModeCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
