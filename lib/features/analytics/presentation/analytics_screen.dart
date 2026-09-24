import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/analytics_provider.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/completion_bar_chart.dart';
import 'widgets/productivity_score_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Performance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Productivity Score Card
          ProductivityScoreCard(
            score: analytics.productivityScore,
            completionRate: analytics.weekRate,
            currentStreak: analytics.currentStreak,
          ),
          const SizedBox(height: 16),

          // 2. High-level Progress Metric Pills (Today, Week, Month)
          Row(
            children: [
              _buildProgressPill(
                context,
                title: 'Today',
                rate: analytics.todayRate,
                completed: analytics.todayCompleted,
                total: analytics.todayTotal,
                accentColor: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildProgressPill(
                context,
                title: 'This Week',
                rate: analytics.weekRate,
                completed: analytics.weekCompleted,
                total: analytics.weekTotal,
                accentColor: AppColors.secondary,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildProgressPill(
                context,
                title: 'This Month',
                rate: analytics.monthRate,
                completed: analytics.monthCompleted,
                total: analytics.monthTotal,
                accentColor: AppColors.accent,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Lifetime Counts (Completed vs Missed)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${analytics.lifetimeCompleted}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const Text('Completed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${analytics.lifetimeMissed}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                          const Text('Missed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Weekly Trend Bar Chart
          CompletionBarChart(weekData: analytics.weeklyTrend),
          const SizedBox(height: 20),

          // 5. Category Breakdown Card
          CategoryBreakdownCard(
            categoryCounts: analytics.categoryCompletedCounts,
            totalCompleted: analytics.lifetimeCompleted,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPill(
    BuildContext context, {
    required String title,
    required double rate,
    required int completed,
    required int total,
    required Color accentColor,
    required bool isDark,
  }) {
    final pct = (rate * 100).toInt();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              '$pct%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor),
            ),
            const SizedBox(height: 4),
            Text(
              '$completed of $total done',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
