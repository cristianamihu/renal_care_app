class Validators {
  /// Verifică că [value] e un email valid.
  /// Returnează mesaj de eroare sau `null` dacă e OK.
  static String? email(String value) {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Email-ul nu poate fi gol';
    }
    if (!regExp.hasMatch(value)) {
      return 'Email invalid';
    }
    return null;
  }

  /// Parola trebuie să aibă cel puțin 8 caractere.
  static String? password(String value) {
    if (value.isEmpty) {
      return 'Parola nu poate fi goală';
    }
    if (value.length < 8) {
      return 'Parola trebuie să aibă cel puțin 8 caractere';
    }
    return null;
  }

  /// Verifică că [value] nu e gol.
  static String? notEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName nu poate fi gol';
    }
    return null;
  }
}
