/// Roluri posibile pentru un utilizator
enum UserRole { patient, doctor }

/// Reprezintă un utilizator în aplicație
class User {
  final String uid;
  final String email;
  final UserRole role;

  User({required this.uid, required this.email, required this.role});
}
