import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../tasks/models/task_category.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final Map<TaskCategory, int> categoryCounts;
  final int totalCompleted;

  const CategoryBreakdownCard({
    super.key,
    required this.categoryCounts,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Focus & Distribution',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...TaskCategory.values.map((category) {
            final count = categoryCounts[category] ?? 0;
            final percentage = totalCompleted == 0 ? 0.0 : (count / totalCompleted);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(category.icon, size: 16, color: category.color),
                      const SizedBox(width: 8),
                      Text(
                        category.displayName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '$count tasks (${(percentage * 100).toInt()}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: isDark ? AppColors.darkCard : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
