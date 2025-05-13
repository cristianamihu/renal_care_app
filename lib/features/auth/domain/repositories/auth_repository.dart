import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Interfață pentru operațiuni de autentificare
abstract class AuthRepository {
  /// Autentificare cu email și parolă
  Future<User> signIn({required String email, required String password});

  /// Autentificare cu Google
  Future<User> signInWithGoogle();

  /// Înregistrare cont cu email și parolă
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Deconectare
  Future<void> signOut();

  Future<User> updateProfile({
    required String uid,
    required String phone,
    required String county,
    required String city,
    required String street,
    required String houseNumber,
    required DateTime dateOfBirth,
  });
}
