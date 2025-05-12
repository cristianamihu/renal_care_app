import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:renal_care_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:renal_care_app/features/auth/data/services/auth_remote_service.dart';
import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_in.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_up.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:renal_care_app/features/auth/domain/usecases/sign_out.dart';

/// Provider pentru instanța FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider pentru serviciul remote de autentificare, injectează FirebaseAuth
final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteService(firebaseAuth: ref.watch(firebaseAuthProvider));
});

/// Provider pentru AuthRepository – implementează abstracția din domain
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteServiceProvider));
});

/// Provider pentru use-case-ul SignIn
/// Injectează AuthRepository și expune logica de business `signIn`
final signInUseCaseProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(authRepositoryProvider));
});

final googleSignInUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});

/// Provider pentru use-case-ul SignUp
/// Injectează AuthRepository și expune logica de business `signUp`
final signUpUseCaseProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});
