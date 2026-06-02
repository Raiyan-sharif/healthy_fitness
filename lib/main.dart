import 'package:flutter/material.dart';

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

class FitnessHomePage extends StatelessWidget {
  const FitnessHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
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
          const _ProgressTile(
            label: 'Steps',
            value: '5,320 / 8,000',
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
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
