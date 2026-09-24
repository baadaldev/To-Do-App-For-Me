import 'package:flutter/material.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/tasks/models/task_category.dart';
import '../../features/tasks/models/task_priority.dart';
import '../constants/app_colors.dart';

enum CoachInsightType { achievement, warning, suggestion, streak }

class CoachInsight {
  final CoachInsightType type;
  final String title;
  final String message;
  final String actionableTip;
  final IconData icon;
  final Color accentColor;

  const CoachInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.actionableTip,
    required this.icon,
    required this.accentColor,
  });
}

class AiCoachService {
  static List<CoachInsight> generateInsights({
    required List<TaskModel> tasks,
    required int currentStreak,
    required int longestStreak,
  }) {
    final insights = <CoachInsight>[];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final weekTasks = tasks.where((t) => t.dueDate.isAfter(sevenDaysAgo)).toList();

    // 1. Streak-based insights
    if (currentStreak >= 7) {
      insights.add(
        CoachInsight(
          type: CoachInsightType.streak,
          title: '🔥 Unstoppable Consistency!',
          message: 'You have maintained an unbroken $currentStreak-day streak!',
          actionableTip: 'Keep the momentum going. Even completing one small task today defends your streak.',
          icon: Icons.local_fire_department_rounded,
          accentColor: AppColors.streakFlame,
        ),
      );
    } else if (currentStreak > 0 && currentStreak < 7) {
      final daysRemaining = 7 - currentStreak;
      insights.add(
        CoachInsight(
          type: CoachInsightType.streak,
          title: '⚡ Habit Momentum Building',
          message: 'You are on a $currentStreak-day streak. Just $daysRemaining more day${daysRemaining > 1 ? 's' : ''} to unlock the Week Warrior badge!',
          actionableTip: 'Commit to your highest priority task early today.',
          icon: Icons.bolt_rounded,
          accentColor: AppColors.accent,
        ),
      );
    }

    if (weekTasks.isEmpty) {
      insights.add(
        const CoachInsight(
          type: CoachInsightType.suggestion,
          title: '📋 Kickstart Your Week',
          message: 'You don\'t have any tasks scheduled for this week yet.',
          actionableTip: 'Add at least 3 essential tasks to set the rhythm for high discipline.',
          icon: Icons.add_task_rounded,
          accentColor: AppColors.primary,
        ),
      );
      return insights;
    }

    // 2. Category Performance Analysis
    for (final category in TaskCategory.values) {
      final catTasks = weekTasks.where((t) => t.category == category).toList();
      if (catTasks.isEmpty) continue;

      final catCompleted = catTasks.where((t) => t.isCompleted).length;
      final catMissed = catTasks.where((t) => t.isMissed).length;
      final completionPct = ((catCompleted / catTasks.length) * 100).round();

      // High achievement in category
      if (completionPct >= 80 && catTasks.length >= 3) {
        insights.add(
          CoachInsight(
            type: CoachInsightType.achievement,
            title: '🎯 Outstanding ${category.displayName} Discipline',
            message: 'You completed $completionPct% of ${category.displayName.toLowerCase()} tasks this week ($catCompleted of ${catTasks.length}).',
            actionableTip: 'Your physical and mental commitment to ${category.displayName.toLowerCase()} is rock solid.',
            icon: category.icon,
            accentColor: category.color,
          ),
        );
      }

      // Missed pattern detection
      if (catMissed >= 2) {
        String specificTip = switch (category) {
          TaskCategory.coding => 'Try scheduling coding earlier in the day when cognitive energy is highest.',
          TaskCategory.gym => 'Pack your workout clothes the night before to eliminate resistance.',
          TaskCategory.reading => 'Commit to reading just 10 pages before sleep or right after waking.',
          TaskCategory.study => 'Use the Pomodoro technique (25 min focus, 5 min break) to prevent burnout.',
          TaskCategory.work => 'Tackle your hardest work task first thing in the morning (Eat the Frog).',
          TaskCategory.personal => 'Allocate a dedicated personal review window on weekend mornings.',
        };

        insights.add(
          CoachInsight(
            type: CoachInsightType.warning,
            title: '⚠️ ${category.displayName} Tasks Need Attention',
            message: 'You missed ${category.displayName.toLowerCase()} tasks $catMissed time${catMissed > 1 ? 's' : ''} this week.',
            actionableTip: specificTip,
            icon: Icons.warning_amber_rounded,
            accentColor: AppColors.warning,
          ),
        );
      }
    }

    // 3. Time Window Behavioral Analysis
    final completedWithTime = tasks.where((t) => t.isCompleted && t.completedAt != null).toList();
    if (completedWithTime.length >= 5) {
      int morningCount = 0;
      int afternoonCount = 0;
      int eveningCount = 0;

      for (final t in completedWithTime) {
        final hour = t.completedAt!.hour;
        if (hour >= 5 && hour < 12) {
          morningCount++;
        } else if (hour >= 12 && hour < 18) {
          afternoonCount++;
        } else {
          eveningCount++;
        }
      }

      if (morningCount >= afternoonCount && morningCount >= eveningCount) {
        insights.add(
          const CoachInsight(
            type: CoachInsightType.suggestion,
            title: '🌅 Golden Focus Window: Morning',
            message: 'Historical data shows your task completion peaks between 8:00 AM and 11:30 AM.',
            actionableTip: 'Block high-priority tasks in the morning before distractions arrive.',
            icon: Icons.wb_sunny_rounded,
            accentColor: AppColors.accent,
          ),
        );
      } else if (eveningCount > morningCount && eveningCount > afternoonCount) {
        insights.add(
          const CoachInsight(
            type: CoachInsightType.suggestion,
            title: '🌙 Night Owl Productivity Pattern',
            message: 'You complete most of your tasks in the evening hours.',
            actionableTip: 'Make sure to wind down 30 minutes before sleep so recovery isn\'t compromised.',
            icon: Icons.nights_stay_rounded,
            accentColor: AppColors.secondary,
          ),
        );
      }
    }

    // 4. Priority Completion Analysis
    final highPriorityTasks = weekTasks.where((t) => t.priority == TaskPriority.high).toList();
    if (highPriorityTasks.isNotEmpty) {
      final highCompleted = highPriorityTasks.where((t) => t.isCompleted).length;
      final highPct = ((highCompleted / highPriorityTasks.length) * 100).round();
      if (highPct < 50) {
        insights.add(
          CoachInsight(
            type: CoachInsightType.warning,
            title: '🚩 Protect Your Non-Negotiables',
            message: 'You only completed $highPct% of high-priority tasks this week.',
            actionableTip: 'Identify your 1 single non-negotiable task tomorrow and do it before anything else.',
            icon: Icons.priority_high_rounded,
            accentColor: AppColors.error,
          ),
        );
      }
    }

    // Default Fallback Tip if list has few entries
    if (insights.length < 2) {
      insights.add(
        const CoachInsight(
          type: CoachInsightType.suggestion,
          title: '💡 The Power of Micro-Habits',
          message: 'Consistency trumps intensity. Doing 10 minutes every day beats 2 hours once a week.',
          actionableTip: 'Break your largest goal into bite-sized daily increments.',
          icon: Icons.psychology_rounded,
          accentColor: AppColors.primary,
        ),
      );
    }

    return insights;
  }
}
