import 'package:flutter/material.dart';

class AppTheme {
  // Vibrant Premium Palette
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color cardBorderDark = Color(0xFF334155); // Slate 700

  static const Color primaryNeon = Color(0xFF8B5CF6); // Purple 500
  static const Color primaryAccent = Color(0xFF6366F1); // Indigo 500
  static const Color successGreen = Color(0xFF10B981); // Emerald 500
  static const Color warningAmber = Color(0xFFF59E0B); // Amber 500
  static const Color dangerRose = Color(0xFFF43F5E); // Rose 500
  static const Color infoBlue = Color(0xFF3B82F6); // Blue 500

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: primaryAccent,
        surface: cardDark,
        error: dangerRose,
        onSurface: Colors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorderDark, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF334155),
        disabledColor: Colors.grey,
        selectedColor: primaryNeon,
        secondarySelectedColor: primaryAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
        secondaryLabelStyle: const TextStyle(fontSize: 13, color: Colors.white),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryNeon, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      ),
    );
  }

  // App Package Brand Colors
  static Color getPackageColor(String packageName) {
    final p = packageName.toLowerCase();
    if (p.contains('whatsapp')) return const Color(0xFF25D366);
    if (p.contains('telegram')) return const Color(0xFF0088CC);
    if (p.contains('slack')) return const Color(0xFFE01E5A);
    if (p.contains('gm') || p.contains('gmail')) return const Color(0xFFEA4335);
    if (p.contains('bank') || p.contains('chase')) return const Color(0xFF117ACA);
    if (p.contains('stripe')) return const Color(0xFF635BFF);
    if (p.contains('github')) return const Color(0xFF24292E);
    if (p.contains('uber')) return const Color(0xFF06C167);
    if (p.contains('twitter') || p.contains('x.app')) return const Color(0xFF1DA1F2);
    if (p.contains('instagram')) return const Color(0xFFE1306C);
    if (p.contains('system') || p.contains('android')) return const Color(0xFF3DDC84);
    return primaryAccent;
  }

  // App Package Brand Icon
  static IconData getPackageIcon(String packageName) {
    final p = packageName.toLowerCase();
    if (p.contains('whatsapp')) return Icons.chat_bubble_rounded;
    if (p.contains('telegram')) return Icons.send_rounded;
    if (p.contains('slack')) return Icons.work_rounded;
    if (p.contains('gm') || p.contains('gmail')) return Icons.email_rounded;
    if (p.contains('bank') || p.contains('chase')) return Icons.account_balance_rounded;
    if (p.contains('stripe')) return Icons.credit_card_rounded;
    if (p.contains('github')) return Icons.code_rounded;
    if (p.contains('uber')) return Icons.fastfood_rounded;
    if (p.contains('twitter') || p.contains('x.app')) return Icons.tag_rounded;
    if (p.contains('instagram')) return Icons.camera_alt_rounded;
    if (p.contains('system') || p.contains('android')) return Icons.android_rounded;
    return Icons.notifications_active_rounded;
  }
}
