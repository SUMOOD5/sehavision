import 'package:flutter/material.dart';

class AppTheme {
  // Health & AI Inspired Dark Theme Colors
  // Primary - Deep Medical Green (صحة)
  static const Color primaryColor = Color(0xFF00C896);
  static const Color primaryLightColor = Color(0xFF4DD4B0);
  static const Color primaryDarkColor = Color(0xFF009A73);

  // Secondary - AI Blue (ذكاء اصطناعي)
  static const Color secondaryColor = Color(0xFF4A90E2);
  static const Color secondaryLightColor = Color(0xFF7BB3F0);
  static const Color secondaryDarkColor = Color(0xFF2E5BBA);

  // Accent - Medical Purple (تقنية طبية)
  static const Color accentColor = Color(0xFF8B5CF6);
  static const Color accentLightColor = Color(0xFFA78BFA);
  static const Color accentDarkColor = Color(0xFF7C3AED);

  // Status Colors
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFFB347);
  static const Color successColor = Color(0xFF51CF66);
  static const Color infoColor = Color(0xFF74C0FC);

  // Dark Background Colors
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color surfaceVariantColor = Color(0xFF2A2A2A);
  static const Color cardColor = Color(0xFF1F1F1F);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFFF8F9FA);
  static const Color textSecondaryColor = Color(0xFFB8BCC8);
  static const Color textTertiaryColor = Color(0xFF6C7293);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF00C896);
  static const Color gradientEnd = Color(0xFF4A90E2);

  // Legacy colors for compatibility
  static const Color darkBackgroundColor = backgroundColor;
  static const Color darkSurfaceColor = surfaceColor;
  static const Color darkTextPrimaryColor = textPrimaryColor;
  static const Color darkTextSecondaryColor = textSecondaryColor;

  // Arabic Typography Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: textPrimaryColor,
    height: 1.2,
    fontFamily: 'IBMPlexSansArabic',
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    height: 1.3,
    fontFamily: 'IBMPlexSansArabic',
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    height: 1.3,
    fontFamily: 'IBMPlexSansArabic',
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    height: 1.6,
    fontFamily: 'IBMPlexSansArabic',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    height: 1.5,
    fontFamily: 'IBMPlexSansArabic',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondaryColor,
    height: 1.4,
    fontFamily: 'IBMPlexSansArabic',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiaryColor,
    height: 1.3,
    fontFamily: 'IBMPlexSansArabic',
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'IBMPlexSansArabic',
    letterSpacing: 0.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
    fontFamily: 'IBMPlexSansArabic',
  );

  // Main Dark Theme (Health & AI Inspired) - Only Theme
  static ThemeData get lightTheme => darkTheme; // Force dark theme only

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'IBMPlexSansArabic',

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        surfaceVariant: surfaceVariantColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textPrimaryColor,
        onSurfaceVariant: textSecondaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
        outline: textTertiaryColor,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primaryColor.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: buttonText,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textTertiaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textTertiaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: bodyMedium.copyWith(color: textSecondaryColor),
        hintStyle: bodyMedium.copyWith(color: textTertiaryColor),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: textPrimaryColor,
        size: 24,
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: heading1,
        headlineMedium: heading2,
        headlineSmall: heading3,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: buttonText,
        labelSmall: caption,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: textTertiaryColor.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariantColor,
        labelStyle: bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Gradient decorations
  static BoxDecoration get primaryGradient => BoxDecoration(
        gradient: const LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration get cardGradient => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor,
            cardColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textTertiaryColor.withOpacity(0.1),
          width: 1,
        ),
      );

  // Shadow styles
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
