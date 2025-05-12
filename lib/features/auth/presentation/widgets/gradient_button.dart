import 'package:flutter/material.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color start;
  final Color end;
  final double width;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.start = AppColors.gradient1,
    this.end = AppColors.gradient2,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(letterSpacing: 1.2)),
      ),
    );
  }
}
