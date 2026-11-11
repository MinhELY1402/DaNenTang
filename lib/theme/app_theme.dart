import 'package:flutter/material.dart';

/// Hệ thống Design System & Tokens cho toàn bộ ứng dụng:
/// Tuân thủ nguyên lý UI Engineering chuẩn SaaS (Stripe, Linear, Shopify):
/// Bảng màu chuyên nghiệp, phân cấp thị giác rõ ràng, loại bỏ hoàn toàn "AI Aesthetic".
class AppTheme {
  // 1. Semantic Color Tokens
  static const Color background = Color(0xFFF8FAFC);   // Slate 50
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color border = Color(0xFFE2E8F0);       // Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color textSecondary = Color(0xFF475569);// Slate 600
  static const Color textMuted = Color(0xFF94A3B8);    // Slate 400

  // Primary Brand (Deep Indigo)
  static const Color primary = Color(0xFF4F46E5);      // Indigo 600
  static const Color primaryDark = Color(0xFF4338CA);  // Indigo 700
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color primaryBorder = Color(0xFFC7D2FE);// Indigo 200

  // Status: In Stock (Emerald)
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color successBg = Color(0xFFECFDF5);    // Emerald 50
  static const Color successText = Color(0xFF065F46);  // Emerald 800
  static const Color successBorder = Color(0xFFA7F3D0);// Emerald 200

  // Status: Low Stock (Amber)
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color warningBg = Color(0xFFFFFBEB);    // Amber 50
  static const Color warningText = Color(0xFF92400E);  // Amber 800
  static const Color warningBorder = Color(0xFFFDE68A);// Amber 200

  // Status: Out of Stock / Danger (Rose)
  static const Color danger = Color(0xFFF43F5E);       // Rose 500
  static const Color dangerBg = Color(0xFFFFF1F2);     // Rose 50
  static const Color dangerText = Color(0xFF9F1239);   // Rose 800
  static const Color dangerBorder = Color(0xFFFECDD3); // Rose 200

  // Sidebar Dark Style
  static const Color sidebarBg = Color(0xFF0F172A);    // Slate 900
  static const Color sidebarHover = Color(0xFF1E293B); // Slate 800
  static const Color sidebarBorder = Color(0xFF334155);// Slate 700

  // 2. Shadows (Subtle & Elevation-less)
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // 3. ThemeData Generator
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: surface,
        error: danger,
      ),
      fontFamily: 'Segoe UI', // Fallback standard font
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
