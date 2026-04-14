// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  /// Inscription
  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final firebaseUser = await _service.signup(email, password);
      _user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
      );
      return true;
    } on FirebaseAuthException {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final fbUser = await _service.login(email, password);
      // ← On peut maintenant passer uid et email en paramètres nommés
      _user = UserModel(
        uid: fbUser.uid,
        email: fbUser.email,
      );
      return true;
    } on FirebaseAuthException {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }
}
