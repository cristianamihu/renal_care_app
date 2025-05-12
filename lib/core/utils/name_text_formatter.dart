import 'package:flutter/services.dart';

/// Formatează textul astfel încât
/// prima literă şi orice literă după spaţiu sau cratimă să fie majusculă.
class NameTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    // RegExp care găsește începutul string-ului (^)
    // sau orice spațiu sau cratimă ([\s-]), urmat de o literă (\w)
    final formatted = text.replaceAllMapped(RegExp(r'(^|[\s-])(\w)'), (match) {
      final prefix = match.group(1)!; // spațiu, cratimă sau început
      final char = match.group(2)!.toUpperCase();
      return '$prefix$char';
    });
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset),
    );
  }
}
