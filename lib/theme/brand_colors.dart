import 'package:flutter/material.dart';

/// Single source of truth for the Capital University brand palette.
///
/// The accent is the university brand color: HSL(224.3°, 76.3%, 48%).
/// Change [accent] in this file and every screen updates at once.
class BrandColors {
  BrandColors._();

  // Brand
   static const Color accent = Color(0xFF3B82F6);
  static const Color accentDark = Color(0xFF2563EB);   // blue-600
  static const Color accentLight = Color(0xFF60A5FA);  // blue-400
  static const Color accentSoft = Color(0xFFEFF6FF);   // blue-50
  static const Color accentSofter = Color(0xFFDBEAFE); // blue-100
  

  // Gradients
  static const List<Color> accentGradient = [accent, accentLight];
  static const List<Color> accentGradientHorizontal = [accent, accentLight];
  static const List<Color> accentGradientDiagonal = [
    accent,
    accentLight,
    Color(0xFF60A5FA), // blue-400
  ];

  // Status / semantic
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color successSoft = Color(0xFFDCFCE7); // green-100
  static const Color warning = Color(0xFFE89B2A); // amber
  static const Color warningSoft = Color(0xFFFEF3E0); // amber-100
  static const Color warningInk = Color(0xFF8B5A00);
  static const Color danger = Color(0xFFE5484D);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color dangerInk = Color(0xFFB91C1C); // red-700

  // Surfaces / text
  static const Color surface = Color(0xFFFAFAFB);
  static const Color surfaceCard = Colors.white;
  static const Color border = Color(0xFFEEF0EE);
  static const Color borderStrong = Color(0xFFDFE2DE);
  static const Color textPrimary = Color(0xFF1B1E22);
  static const Color textSecondary = Color(0xFF5B6167);
  static const Color textMuted = Color(0xFF8A8F95);
  static const Color textDisabled = Color(0xFFB5B9BE);
  static const Color inputFill = Color(0xFFF7F8FA);

  // Backwards-compatible alias for code that used 0xFF5F61E6.
  static const Color legacyAccent = accent;
}
