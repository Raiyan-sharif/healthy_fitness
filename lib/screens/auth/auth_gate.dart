import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_fitness/screens/auth/login_screen.dart';
import 'package:healthy_fitness/screens/home/fitness_home_page.dart';
import 'package:healthy_fitness/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.authService});

  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final AuthService auth = authService ?? AuthService();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FitnessHomePage(authService: auth);
        }

        return LoginScreen(authService: auth);
      },
    );
  }
}
