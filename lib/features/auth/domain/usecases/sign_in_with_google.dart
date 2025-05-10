import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repo;
  SignInWithGoogle(this._repo);

  Future<User> call() {
    return _repo.signInWithGoogle();
  }
}
