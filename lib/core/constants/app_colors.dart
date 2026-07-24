import 'package:flutter/material.dart';

/// Central color palette for LibreFlow.
///
/// Keeping every color in one place makes it trivial to keep Light/Dark
/// themes, charts, and ad-hoc widgets visually consistent.
abstract final class AppColors {
  // Brand - Enterprise Palette
  static const Color primary = Color(0xFF1E293B); // Deep Navy
  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color royalBlue = Color(0xFF2563EB);
  static const Color accent = Color(0xFF10B981); // Emerald Green

  // Surfaces
  static const Color backgroundLight = Color(0xFFF0F4FF); // Soft Lavender/Blue tint
  static const Color backgroundDark = Color(0xFF0A0F1E); // Deep Black-Blue
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF161B2E);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626); // Crimson
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Borders / dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2D3748);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
  );

  /// Fixed palette used to color category tags / charts deterministically.
  static const List<Color> chartPalette = [
    primary,
    secondary,
    accent,
    warning,
    info,
    Color(0xFFEC4899),
  ];
}
