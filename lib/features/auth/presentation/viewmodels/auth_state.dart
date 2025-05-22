import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Cele patru stări posibile în procesul de autentificare
enum AuthStatus { initial, loading, authenticated, error }

/// Model de stare expus de AuthViewModel
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
