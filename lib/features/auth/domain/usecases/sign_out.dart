import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';

/// Use-case pentru sign out
class SignOut {
  final AuthRepository _repo;
  SignOut(this._repo);

  Future<void> call() => _repo.signOut();
}
