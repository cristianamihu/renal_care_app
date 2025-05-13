class Validators {
  /// Verifică că [value] e un email valid.
  /// Returnează mesaj de eroare sau `null` dacă e OK.
  static String? email(String value) {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!regExp.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  /// Parola trebuie să aibă cel puțin 8 caractere.
  static String? password(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  /// Verifică că [value] nu e gol.
  static String? notEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  /// Verifică că [value] e un număr de telefon valid (doar cifre, opțional '+' la început, între 7 și 15 caractere)
  static String? phone(String value) {
    if (value.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    // permite cifre și, opțional, semnul '+' la început
    final pattern = r'^\+?[0-9]{7,15}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return 'Invalid phone number';
    }
    return null;
  }
}
