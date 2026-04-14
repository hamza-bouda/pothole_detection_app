// lib/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pothole_detection_app/providers/auth_provider.dart';
import 'package:pothole_detection_app/screens/auth/login_screen.dart';
import 'package:pothole_detection_app/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // On démarre l'écoute dès que Provider est initialisé
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Tant que le stream n'a pas de valeur
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Si on a un user, on va à la HomeScreen
        if (snapshot.hasData) {
          return  HomeScreen();
        }
        // Sinon, on reste sur le login
        return  LoginScreen();
      },
    );
  }
}
