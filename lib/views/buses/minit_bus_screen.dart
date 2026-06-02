import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';

class MiniBusScreen extends StatelessWidget {
  const MiniBusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 32.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.airport_shuttle_outlined,
                size: 38,
                color: AppTheme.accentLime,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mini Bus",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.3)),
              ),
              child: const Text(
                "COMING SOON",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentLime,
                  letterSpacing: 1.5,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We're working hard to bring you\nmini bus booking services soon!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
