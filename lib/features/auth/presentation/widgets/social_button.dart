import 'package:flutter/material.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String assetPath;
  final String text;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.assetPath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.whiteColor,
          foregroundColor: AppColors.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Image.asset(assetPath, width: 24, height: 24),
        label: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}
