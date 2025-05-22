import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/core/di/auth_providers.dart';
import 'package:renal_care_app/features/auth/domain/usecases/update_profile.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/profile_state.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;
  final UpdateProfile _updateProfile;
  ProfileViewModel(this._ref, this._updateProfile)
    : super(const ProfileState());

  Future<void> submit({
    required String uid,
    required String phone,
    required String county,
    required String city,
    required String street,
    required String houseNumber,
    required DateTime dateOfBirth,
  }) async {
    state = const ProfileState(status: ProfileStatus.loading);
    try {
      // facem update și obținem noul User
      final updatedUser = await _updateProfile(
        uid: uid,
        phone: phone,
        county: county,
        city: city,
        street: street,
        houseNumber: houseNumber,
        dateOfBirth: dateOfBirth,
      );
      // setăm user-ul actualizat în AuthViewModel
      _ref.read(authViewModelProvider.notifier).setUser(updatedUser);

      state = const ProfileState(status: ProfileStatus.success);
    } catch (e) {
      state = ProfileState(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      return ProfileViewModel(ref, ref.watch(updateProfileUseCaseProvider));
    });
