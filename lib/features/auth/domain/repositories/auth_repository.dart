import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Interfață pentru operațiuni de autentificare
abstract class AuthRepository {
  /// Autentificare cu email și parolă
  Future<User> signIn({required String email, required String password});

  /// Autentificare cu Google
  Future<User> signInWithGoogle();

  /// Înregistrare cont cu email și parolă
  Future<User> signUp({
    required String email,
    required String password,
    required UserRole role,
  });

  /// Deconectare
  Future<void> signOut();
}
