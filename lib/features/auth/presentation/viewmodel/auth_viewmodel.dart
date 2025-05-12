import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/auth/domain/usecases/sign_in.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_up.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/core/di/auth_providers.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_out.dart';

/// ViewModel pentru autentificare (StateNotifier expunând AuthState)
class AuthViewModel extends StateNotifier<AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  AuthViewModel(
    this._signIn,
    this._signUp,
    this._signInWithGoogle,
    this._signOut,
  ) : super(const AuthState());

  /// Începe flow-ul de login
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _signIn.call(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _signInWithGoogle.call();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Începe flow-ul de înregistrare
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _signUp.call(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Încheie sesiunea și resetează starea
  Future<void> signOut() async {
    await _signOut.call();
    state = const AuthState(); // revine la initial
  }
}

/// Provider global pentru AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final signInUC = ref.watch(signInUseCaseProvider);
  final signUpUC = ref.watch(signUpUseCaseProvider);
  final signInWithGoogleUC = ref.watch(googleSignInUseCaseProvider);
  final signOutUC = ref.watch(signOutUseCaseProvider);
  return AuthViewModel(signInUC, signUpUC, signInWithGoogleUC, signOutUC);
});
