/// Roluri posibile pentru un utilizator
enum UserRole { patient, doctor }

/// Reprezintă un utilizator în aplicație
class User {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? county;
  final String? city;
  final String? street;
  final String? houseNumber;
  final DateTime? dateOfBirth;
  final bool profileComplete; // true once the user has filled in their form

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.county,
    this.city,
    this.street,
    this.houseNumber,
    this.dateOfBirth,
    this.profileComplete = false,
  });

  /// Getter auxiliar: profil complet dacă toate câmpurile sunt nenule
  //bool get isProfileComplete =>
  //    phone != null &&
  //    county != null &&
  //    city != null &&
  //    street != null &&
  //    houseNumber != null &&
  //    dateOfBirth != null;
}
