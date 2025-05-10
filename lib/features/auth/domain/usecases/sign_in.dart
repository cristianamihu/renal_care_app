import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Use-case pentru autentificare — returnează User
class SignIn {
  final AuthRepository _repo;
  SignIn(this._repo);

  Future<User> call({required String email, required String password}) {
    return _repo.signIn(email: email, password: password);
  }
}
