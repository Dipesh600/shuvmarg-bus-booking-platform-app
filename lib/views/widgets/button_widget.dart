import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final IconData? icon;

  const ButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
        icon: icon != null
            ? Icon(
                icon,
                color: AppColors.white,
              )
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w400,
              fontSize: 18),
        ),
      ),
    );
  }
}
