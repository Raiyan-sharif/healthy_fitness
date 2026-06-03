import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_fitness/models/user_profile.dart';
import 'package:healthy_fitness/services/auth_service.dart';
import 'package:healthy_fitness/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    this.authService,
    this.profileService,
  });

  final User user;
  final AuthService? authService;
  final ProfileService? profileService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService = widget.authService ?? AuthService();
  late final ProfileService _profileService =
      widget.profileService ?? ProfileService();

  final TextEditingController _nameController = TextEditingController();
  String _fitnessGoal = 'General fitness';
  bool _loading = true;
  bool _saving = false;

  static const List<String> _fitnessGoals = [
    'General fitness',
    'Lose weight',
    'Build muscle',
    'Improve mobility',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final UserProfile? profile =
        await _profileService.getProfile(widget.user.uid);
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text =
          profile?.displayName ?? widget.user.displayName ?? 'Fitness User';
      _fitnessGoal = profile?.fitnessGoal ?? 'General fitness';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final UserProfile profile = UserProfile(
      uid: widget.user.uid,
      email: widget.user.email ?? '',
      displayName: _nameController.text.trim().isEmpty
          ? 'Fitness User'
          : _nameController.text.trim(),
      photoUrl: widget.user.photoURL,
      fitnessGoal: _fitnessGoal,
    );
    await _profileService.saveProfile(profile);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : null,
              child: widget.user.photoURL == null
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              widget.user.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _fitnessGoal,
            decoration: const InputDecoration(
              labelText: 'Fitness goal',
              border: OutlineInputBorder(),
            ),
            items: _fitnessGoals
                .map(
                  (String goal) => DropdownMenuItem<String>(
                    value: goal,
                    child: Text(goal),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _fitnessGoal = value);
              }
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _saveProfile,
            child: Text(_saving ? 'Saving...' : 'Save profile'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
