/// Roluri posibile pentru un utilizator
enum UserRole { patient, doctor }

/// Reprezintă un utilizator în aplicație
class User {
  final String uid;
  final String name;
  final String email;
  final String role;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });
}
