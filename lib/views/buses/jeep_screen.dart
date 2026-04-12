import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';

class JeepScreen extends StatelessWidget {
  const JeepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                size: 50,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Jeep",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Coming Soon",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We're working hard to bring you\nJeep booking services soon!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
