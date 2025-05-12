import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Use-case pentru înregistrare — returnează User
class SignUp {
  final AuthRepository _repo;
  SignUp(this._repo);

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _repo.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
