import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get displayName => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };

  Color get color => switch (this) {
        TaskPriority.low => AppColors.priorityLow,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.high => AppColors.priorityHigh,
      };

  int get xpReward => switch (this) {
        TaskPriority.low => 15,
        TaskPriority.medium => 25,
        TaskPriority.high => 40,
      };

  static TaskPriority fromString(String val) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}
