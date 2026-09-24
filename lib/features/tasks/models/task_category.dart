import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum TaskCategory {
  study,
  coding,
  gym,
  reading,
  personal,
  work;

  String get displayName => switch (this) {
        TaskCategory.study => 'Study',
        TaskCategory.coding => 'Coding',
        TaskCategory.gym => 'Gym',
        TaskCategory.reading => 'Reading',
        TaskCategory.personal => 'Personal',
        TaskCategory.work => 'Work',
      };

  IconData get icon => switch (this) {
        TaskCategory.study => Icons.school_rounded,
        TaskCategory.coding => Icons.code_rounded,
        TaskCategory.gym => Icons.fitness_center_rounded,
        TaskCategory.reading => Icons.menu_book_rounded,
        TaskCategory.personal => Icons.person_rounded,
        TaskCategory.work => Icons.work_rounded,
      };

  Color get color => switch (this) {
        TaskCategory.study => AppColors.categoryStudy,
        TaskCategory.coding => AppColors.categoryCoding,
        TaskCategory.gym => AppColors.categoryGym,
        TaskCategory.reading => AppColors.categoryReading,
        TaskCategory.personal => AppColors.categoryPersonal,
        TaskCategory.work => AppColors.categoryWork,
      };

  static TaskCategory fromString(String val) {
    return TaskCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => TaskCategory.personal,
    );
  }
}
