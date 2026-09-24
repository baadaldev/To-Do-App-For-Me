import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);

  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color accent = Color(0xFFF59E0B); // Amber / Gold
  static const Color streakFlame = Color(0xFFFF5722); // Deep Orange

  // Neutral Colors (Dark Mode First - modern sleek GitHub / terminal aesthetic)
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);

  // Neutral Colors (Light Mode)
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF656D76);

  // GitHub Heatmap Colors (Dark Mode)
  static const Color heatLevel0Dark = Color(0xFF161B22);
  static const Color heatLevel1Dark = Color(0xFF0E4429);
  static const Color heatLevel2Dark = Color(0xFF006D32);
  static const Color heatLevel3Dark = Color(0xFF26A641);
  static const Color heatLevel4Dark = Color(0xFF39D353);

  // GitHub Heatmap Colors (Light Mode)
  static const Color heatLevel0Light = Color(0xFFEBEDF0);
  static const Color heatLevel1Light = Color(0xFF9BE9A8);
  static const Color heatLevel2Light = Color(0xFF40C463);
  static const Color heatLevel3Light = Color(0xFF30A14E);
  static const Color heatLevel4Light = Color(0xFF216E39);

  // Priority Colors
  static const Color priorityLow = Color(0xFF3B82F6); // Blue
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityHigh = Color(0xFFEF4444); // Red

  // Category Colors
  static const Color categoryStudy = Color(0xFF8B5CF6); // Purple
  static const Color categoryCoding = Color(0xFF10B981); // Emerald
  static const Color categoryGym = Color(0xFFFF6B4A); // Orange
  static const Color categoryReading = Color(0xFF06B6D4); // Cyan
  static const Color categoryPersonal = Color(0xFFEC4899); // Pink
  static const Color categoryWork = Color(0xFFF59E0B); // Amber

  // Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
