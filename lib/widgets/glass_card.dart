import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(
              color: AppTheme.stroke,
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5900564E), // rgba(0,86,78,0.35)
                blurRadius: 40.0,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
