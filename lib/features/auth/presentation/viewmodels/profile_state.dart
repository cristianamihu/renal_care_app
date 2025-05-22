enum ProfileStatus { initial, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final String? errorMessage;

  const ProfileState({this.status = ProfileStatus.initial, this.errorMessage});
}
