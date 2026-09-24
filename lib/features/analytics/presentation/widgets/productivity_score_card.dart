import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';

class ProductivityScoreCard extends StatelessWidget {
  final int score; // 0 to 100
  final double completionRate;
  final int currentStreak;

  const ProductivityScoreCard({
    super.key,
    required this.score,
    required this.completionRate,
    required this.currentStreak,
  });

  String get _ratingTitle {
    if (score >= 85) return 'Iron Will (Apex)';
    if (score >= 70) return 'High Focus (Consistent)';
    if (score >= 50) return 'Developing Discipline';
    return 'Rebuild Momentum';
  }

  Color get _ratingColor {
    if (score >= 85) return AppColors.primary;
    if (score >= 70) return AppColors.accent;
    if (score >= 50) return AppColors.secondary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 46.0,
            lineWidth: 9.0,
            percent: (score / 100).clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _ratingColor,
                  ),
                ),
                const Text(
                  'SCORE',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            progressColor: _ratingColor,
            backgroundColor: isDark ? AppColors.darkCard : Colors.grey.shade200,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _ratingColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _ratingTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _ratingColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Productivity Index',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calculated from task completion (${(completionRate * 100).toInt()}%), active streak ($currentStreak days), and priority compliance.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
