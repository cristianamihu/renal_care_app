import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool showToggle; // afișează eye-icon
  final VoidCallback? onToggle; // callback când dai tap pe eye-icon

  const AuthTextField({
    super.key,
    required this.icon,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    required this.onChanged,
    this.inputFormatters,
    this.showToggle = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: AppColors.whiteColor),
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.whiteColor),
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.whiteColor),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.whiteColor),
          borderRadius: BorderRadius.circular(8),
        ),

        // eye-icon la coadă, dacă e cazul
        suffixIcon:
            showToggle
                ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.whiteColor,
                  ),
                  onPressed: onToggle,
                )
                : null,
      ),
      onChanged: onChanged,
    );
  }
}
