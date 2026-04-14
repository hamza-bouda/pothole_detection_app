// lib/models/user.dart

class UserModel {
  final String uid;
  final String? email;

  /// Constructeur avec paramètres nommés `uid` et `email`
  UserModel({
    required this.uid,
    this.email,
  });
}
