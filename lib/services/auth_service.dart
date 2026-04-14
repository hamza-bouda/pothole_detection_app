// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  /// Crée un utilisateur, renvoie `User` si OK, ou lance une exception
  Future<User> signup(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  /// Connexion, renvoie `User` si OK, ou lance une exception
  Future<User> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  /// Déconnexion
  Future<void> logout() => _auth.signOut();

  /// L’utilisateur courant, ou `null` s’il n’est pas connecté
  User? get currentUser => _auth.currentUser;
}
