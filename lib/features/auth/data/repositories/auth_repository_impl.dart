import 'package:renal_care_app/features/auth/data/services/auth_remote_service.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Future<User> signIn({required String email, required String password}) async {
    final cred = await _remote.signIn(email: email, password: password);
    // În exemplu, îi atribuim automat rolul patient.
    // Ulterior poți citi rolul din Firestore dacă vrei distinție doctor/pacient.
    return User(
      uid: cred.user!.uid,
      email: cred.user!.email!,
      role: UserRole.patient,
    );
  }

  @override
  Future<User> signInWithGoogle() async {
    final cred = await _remote.signInWithGoogle();
    return User(
      uid: cred.user!.uid,
      email: cred.user!.email!,
      role: UserRole.patient, // poți seta un rol default sau salva în Firestore
    );
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final cred = await _remote.signUp(email: email, password: password);
    return User(uid: cred.user!.uid, email: cred.user!.email!, role: role);
  }

  @override
  Future<void> signOut() => _remote.signOut();
}
