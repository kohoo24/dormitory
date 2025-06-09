import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Brand colors - refined color palette
  static const Color primaryBlue = Color(0xFF246BFD);  // More vibrant blue
  static const Color secondaryBlue = Color(0xFF3A7BFF); // Lighter blue for gradients
  static const Color tertiaryBlue = Color(0xFFEEF4FF);  // Very light blue for backgrounds
  
  static const Color primaryGreen = Color(0xFF00C566);  // Vibrant green
  static const Color secondaryGreen = Color(0xFF34D399); // Lighter green for gradients
  static const Color tertiaryGreen = Color(0xFFEBFFF6);  // Very light green for backgrounds
  
  static const Color primaryRed = Color(0xFFFF4D4F);  // Vibrant red
  static const Color secondaryRed = Color(0xFFFF7D85); // Lighter red for gradients
  static const Color tertiaryRed = Color(0xFFFFF2F3);  // Very light red for backgrounds
  
  // Neutral colors - refined for better contrast and readability
  static const Color black = Color(0xFF111827);      // Deeper black for better contrast
  static const Color darkGrey = Color(0xFF374151);    // Darker grey for important text
  static const Color mediumGrey = Color(0xFF6B7280);  // Medium grey for secondary text
  static const Color grey = Color(0xFF9CA3AF);        // Grey for placeholder text
  static const Color lightGrey = Color(0xFFE5E7EB);    // Light grey for borders
  static const Color ultraLightGrey = Color(0xFFF9FAFB); // Ultra light grey for backgrounds
  static const Color white = Color(0xFFFFFFFF);        // Pure white
  
  // Accent colors for variety
  static const Color accentYellow = Color(0xFFFFC542);  // Vibrant yellow for highlights
  static const Color accentPurple = Color(0xFF8B5CF6);  // Purple for variety
  static const Color accentTeal = Color(0xFF06B6D4);    // Teal for variety
  
  // Gradients for modern look
  static const LinearGradient primaryBlueGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGreenGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryRedGradient = LinearGradient(
    colors: [primaryRed, secondaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows for depth
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Text styles with modern typography
  static const String fontFamily = 'Roboto';  // Using Roboto font
  
  static TextStyle get h1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,  // Bold
    letterSpacing: -0.5,          // Tighter letter spacing for headings
    fontFamily: fontFamily,
    height: 1.2,                  // Tighter line height for headings
  );
  
  static TextStyle get h2 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static TextStyle get h3 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,  // Semi-bold
    letterSpacing: -0.25,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static TextStyle get h4 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static TextStyle get subtitle1 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,  // Medium
    letterSpacing: 0,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static TextStyle get subtitle2 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static TextStyle get body1 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,  // Regular
    letterSpacing: 0.1,
    fontFamily: fontFamily,
    height: 1.5,                  // More comfortable line height for body text
  );
  
  static TextStyle get body2 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  static TextStyle get button => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,  // Semi-bold for buttons
    letterSpacing: 0.2,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  static TextStyle get overline => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  // Theme data with modern design principles
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        tertiary: accentPurple,
        error: primaryRed,
        surface: ultraLightGrey,
        surfaceContainerHighest: white,
        onPrimary: white,
        onSecondary: white,
        onTertiary: white,
        onError: white,
        onSurface: black,
        onSurfaceVariant: black,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: ultraLightGrey,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        titleTextStyle: subtitle1.copyWith(
          color: black,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: darkGrey,
          size: 24,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mediumGrey.withOpacity(0.7),
        selectedLabelStyle: caption.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: caption.copyWith(
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          textStyle: button,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: button,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue),
        ),
        labelStyle: body1.copyWith(color: darkGrey),
        errorStyle: caption.copyWith(color: primaryRed),
        prefixIconColor: mediumGrey,
        suffixIconColor: mediumGrey,
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
        space: 1,
      ),
      fontFamily: 'Roboto',
    );
  }
}
