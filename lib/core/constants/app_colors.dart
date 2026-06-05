import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Oceanic Blue
  static const primary = Color(0xFF3B82F6);      // Bright blue
  static const primaryDark = Color(0xFF1D4ED8);  // Deep blue
  static const secondary = Color(0xFF60A5FA);    // Light blue accent
  
  // Status colors
  static const success = Color(0xFF10B981);      // Emerald
  static const warning = Color(0xFFF59E0B);      // Amber
  static const orange = Color(0xFFF97316);       // Orange
  static const error = Color(0xFFEF4444);        // Red
  
  // Dark theme backgrounds
  static const background = Color(0xFF0A1628);   // Deep navy (main bg)
  static const surface = Color(0xFF0F2847);      // Dark blue (cards)
  static const surfaceLight = Color(0xFF1A3A5C); // Lighter card variant
  
  // Glass effect colors
  static const glass = Color(0xFF1E3A5F);        // Glass card base
  static const glassBorder = Color(0xFF3B82F6);  // Glass border glow
  
  // Text colors for dark theme
  static const textPrimary = Color(0xFFFFFFFF);  // White
  static const textSecondary = Color(0xFF94A3B8); // Light gray
  static const textMuted = Color(0xFF64748B);    // Muted gray
  
  // Glow & accent
  static const glow = Color(0xFF60A5FA);         // Blue glow effect
  static const accent = Color(0xFF38BDF8);       // Cyan accent
  
  // Gradients
  static const gradientStart = Color(0xFF0A1628);
  static const gradientEnd = Color(0xFF1E3A5F);
  
  static Color getRiskColor(int score) {
    if (score <= 30) return success;
    if (score <= 60) return warning;
    if (score <= 80) return orange;
    return error;
  }
  
  // Glass decoration helper
  static BoxDecoration glassDecoration({
    double opacity = 0.15,
    double borderRadius = 20,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: glass.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder ? Border.all(
        color: glassBorder.withValues(alpha: 0.3),
        width: 1,
      ) : null,
      boxShadow: [
        BoxShadow(
          color: glow.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
