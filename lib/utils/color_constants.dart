import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF005248);
// Lighter Shades
  static const Color primaryLightest = Color(0xFFE0F1EF); // Mint Frost
  static const Color primaryLighter = Color(0xFFB2D6D0); // Pale Aqua
  static const Color primaryLight = Color(0xFF66AFA6); // Seafoam Green

// Darker Shades
  static const Color primaryDark = Color(0xFF003A33); // Dark Slate
  static const Color primaryDarker = Color(0xFF00231E); // Charcoal Teal
  static const Color primaryDarkest = Color(0xFF00100D); // Near Black Teal

  static const Color secondary = Color(0xFFFC9C09);
  static const Color background = Color(0xFFFAFAFA);
  static const Color text = Color(0xFF212121);
  static const Color accent = Color(0xFFE91E63);

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
