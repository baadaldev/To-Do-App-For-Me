import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HeatMapEntry {
  final DateTime date;
  final int completedCount;
  final int totalCount;
  final int intensityLevel; // 0, 1, 2, 3, 4

  const HeatMapEntry({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.intensityLevel,
  });

  double get completionRate {
    if (totalCount == 0) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  Color getColor(bool isDark) {
    if (isDark) {
      return switch (intensityLevel) {
        1 => AppColors.heatLevel1Dark,
        2 => AppColors.heatLevel2Dark,
        3 => AppColors.heatLevel3Dark,
        4 => AppColors.heatLevel4Dark,
        _ => AppColors.heatLevel0Dark,
      };
    } else {
      return switch (intensityLevel) {
        1 => AppColors.heatLevel1Light,
        2 => AppColors.heatLevel2Light,
        3 => AppColors.heatLevel3Light,
        4 => AppColors.heatLevel4Light,
        _ => AppColors.heatLevel0Light,
      };
    }
  }

  static int computeIntensity(int completed) {
    if (completed <= 0) return 0;
    if (completed <= 2) return 1;
    if (completed <= 4) return 2;
    if (completed <= 6) return 3;
    return 4;
  }
}
