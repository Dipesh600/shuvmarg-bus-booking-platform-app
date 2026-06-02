import 'package:flutter/material.dart';

class AppTheme {
  // Core Palette
  static const Color primary = Color(0xFF00564E);
  static const Color primaryDark = Color(0xFF003D38);
  static const Color primaryDarker = Color(0xFF002B27);
  static const Color primaryDarkest = Color(0xFF001917);
  static const Color secondary = Color(0xFF568C82);
  static const Color accentLime = Color(0xFFD3D925);
  static const Color accentGold = Color(0xFFD9CD25);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFFB7C7C3);
  static const Color textAccent = Color(0xFFD3D925);
  
  // Notification Colors
  static const Color success = Color(0xFFD3D925);
  static const Color error = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF00F0C6);
  static const Color warning = Color(0xFFFFB020);
  
  // Structural
  static const Color stroke = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color cardBg = Color(0xE000564E); // rgba(0,86,78,0.88)
  static const Color inputBg = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)

  // Typography Scale (Using existing Geometria font which matches geometric reqs)
  static const String fontFamily = 'Geometria';

  static const TextStyle heroStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle headingStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: primaryDark,
  );
}
