import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository _repo;
  UpdateProfile(this._repo);

  Future<User> call({
    required String uid,
    required String phone,
    required String county,
    required String city,
    required String street,
    required String houseNumber,
    required DateTime dateOfBirth,
  }) {
    return _repo.updateProfile(
      uid: uid,
      phone: phone,
      county: county,
      city: city,
      street: street,
      houseNumber: houseNumber,
      dateOfBirth: dateOfBirth,
    );
  }
}
