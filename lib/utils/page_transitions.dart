import 'package:flutter/material.dart';

/// A premium, calm transition that fades in and subtly scales up the new screen.
/// Designed to match the Sumarg Visual Language guidelines (400ms duration).
class PremiumFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  PremiumFadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth, calming curve
            const curve = Curves.easeOutCubic;
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
              reverseCurve: Curves.easeInCubic,
            );

            // Subtle scale from 95% to 100%
            final scaleTween = Tween<double>(begin: 0.95, end: 1.0);
            
            // Fade from 0% to 100%
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

            return FadeTransition(
              opacity: fadeTween.animate(curvedAnimation),
              child: ScaleTransition(
                scale: scaleTween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}
