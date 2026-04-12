import 'package:flutter/material.dart';

class AppColors {
  // Strict 2-Color Architecture
  static const Color primary = Color(0xFF005248); // Dark Teal
  static const Color secondary = Color(0xFFFC9C09); // Vibrant Orange

  // Structural Neutral Shades (Derived from Primary, functionally greyscale/off-white)
  static const Color primaryLightest = Color(0xFFF2F7F6); // Barely off-white Teal wash for cards
  static const Color primaryLighter = Color(0xFFD9E8E5); // Muted Teal border lines
  static const Color primaryLight = Color(0xFF80A9A4); // Disabled elements

  // Darker Structural Shades
  static const Color primaryDark = Color(0xFF003A33);
  static const Color primaryDarker = Color(0xFF00231E);
  static const Color primaryDarkest = Color(0xFF00100D);

  // Background & Core
  static const Color background = Color(0xFFFFFFFF); // Pure White constraint
  static const Color text = Color(0xFF1E293B); // Slate-900 for ultra-crisp typography
  static const Color accent = secondary; // Ban the old pink accent, force Orange

  static const Color white = Color(0xFFFFFFFF);
}

const MaterialColor customWhite = MaterialColor(
  0xFF005248,
  <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFB3DEC9),
    200: Color(0xFF80C9A6),
    300: Color(0xFF4DB383),
    400: Color(0xFF26A46A),
    500: Color(0xFF00A86B),
    600: Color(0xFF009A61),
    700: Color(0xFF008955),
    800: Color(0xFF007949),
    900: Color(0xFF005F35),
  },
);
