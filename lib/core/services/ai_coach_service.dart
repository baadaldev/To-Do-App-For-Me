import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/tasks/models/task_category.dart';
import '../../features/tasks/models/task_priority.dart';
import '../../features/ai_coach/models/ai_chat_message.dart';
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

  /// Interactive AI Chat Assistant engine responding dynamically to queries
  static AiChatMessage respondToUserMessage({
    required String query,
    required List<TaskModel> allTasks,
    required int currentStreak,
    required int longestStreak,
  }) {
    final q = query.trim().toLowerCase();
    final now = DateTime.now();

    final todayTasks = allTasks.where((t) =>
        t.dueDate.year == now.year &&
        t.dueDate.month == now.month &&
        t.dueDate.day == now.day).toList();
    final completedToday = todayTasks.where((t) => t.isCompleted).length;
    final pendingToday = todayTasks.length - completedToday;

    // 1. Plan / Daily routine request
    if (q.contains('plan') || q.contains('today') || q.contains('routine') || q.contains('schedule') || q.contains('non-negotiable')) {
      final suggested = [
        const AiSuggestedTask(
          title: 'Deep Work: 90-Minute Uninterrupted Focus',
          description: 'Single-tasking on your highest leverage project or code module',
          category: TaskCategory.coding,
          priority: TaskPriority.high,
          dueHour: 10,
          dueMinute: 0,
        ),
        const AiSuggestedTask(
          title: 'Physical Conditioning (Workout / Run / Gym)',
          description: 'Cardio, resistance training, and mobility',
          category: TaskCategory.gym,
          priority: TaskPriority.medium,
          dueHour: 17,
          dueMinute: 30,
        ),
        const AiSuggestedTask(
          title: 'Evening Review & 20 Pages Reading',
          description: 'Atomic Habits or engineering architecture documentation',
          category: TaskCategory.reading,
          priority: TaskPriority.medium,
          dueHour: 21,
          dueMinute: 0,
        ),
      ];

      return AiChatMessage(
        id: const Uuid().v4(),
        isUser: false,
        text: 'Here is your **Tactical Discipline Protocol** for today:\n\n'
            '1. **Morning Non-Negotiable**: 90-min deep work block before digital distractions enter your mental bandwidth.\n'
            '2. **Physical Fortitude**: 45-min workout to prime dopamine receptor sensitivity.\n'
            '3. **Evening Review**: 20-min reading & calendar audit to guarantee tomorrow starts with zero friction.\n\n'
            'You currently have **$pendingToday pending tasks** and **$completedToday completed** today. Tap below to automatically inject these high-impact tasks into your planner:',
        timestamp: DateTime.now(),
        suggestedTasks: suggested,
        categoryTag: 'Daily Plan',
      );
    }

    // 2. Procrastination / Motivation problem
    if (q.contains('procrastinat') || q.contains('lazy') || q.contains('can\'t focus') || q.contains('distract') || q.contains('stuck')) {
      final suggested = [
        const AiSuggestedTask(
          title: '5-Minute Micro-Start (Friction Breaker)',
          description: 'Open the code editor or document and work for strictly 300 seconds',
          category: TaskCategory.study,
          priority: TaskPriority.high,
          dueHour: 14,
          dueMinute: 0,
        ),
      ];

      return AiChatMessage(
        id: const Uuid().v4(),
        isUser: false,
        text: 'Procrastination is **not laziness**; it is an emotional regulation hurdle caused by task ambiguity.\n\n'
            'Here is the neuro-discipline solution:\n'
            '• **The 5-Minute Rule**: Motivation does not precede action; action produces dopamine, which fuels motivation.\n'
            '• **Micro-Commitment**: Tell yourself you only have to work for strictly 5 minutes. If you want to stop at minute 6, you can.\n'
            '• **Remove Friction**: Put your phone in another room and close all browser tabs except one.\n\n'
            'Shall we lock in a 5-minute friction-breaker task right now?',
        timestamp: DateTime.now(),
        suggestedTasks: suggested,
        categoryTag: 'Focus Protocol',
      );
    }

    // 3. Streak / Consistency query
    if (q.contains('streak') || q.contains('consistency') || q.contains('heat map') || q.contains('momentum')) {
      return AiChatMessage(
        id: const Uuid().v4(),
        isUser: false,
        text: 'Your current streak is **$currentStreak days** (all-time longest: **$longestStreak days**).\n\n'
            'Key Streak Rule: **Never miss twice.**\n'
            'Missing one day is an accident; missing two is the birth of a new, negative habit. Even if you have an exhausting day, check off at least one light task (like 10 pages of reading or a 10-minute stretch) to keep the streak chain alive.',
        timestamp: DateTime.now(),
        categoryTag: 'Streak Discipline',
      );
    }

    // 4. Coding / Technical mastery
    if (q.contains('code') || q.contains('developer') || q.contains('flutter') || q.contains('leetcode') || q.contains('project')) {
      final suggested = [
        const AiSuggestedTask(
          title: 'Solve 2 DSA Medium Algorithmic Challenges',
          description: 'Focus on pattern recognition (Sliding Window / Two Pointers / Trees)',
          category: TaskCategory.coding,
          priority: TaskPriority.high,
          dueHour: 11,
          dueMinute: 0,
        ),
        const AiSuggestedTask(
          title: 'Feature Implementation & Git Commit',
          description: 'Write clean, test-driven architecture and push to GitHub',
          category: TaskCategory.coding,
          priority: TaskPriority.medium,
          dueHour: 16,
          dueMinute: 0,
        ),
      ];

      return AiChatMessage(
        id: const Uuid().v4(),
        isUser: false,
        text: 'To reach senior engineering velocity, split your coding time **70% building production software** and **30% algorithmic mastery**.\n\n'
            '• **Tactile Building**: Real engineers are judged by shipped software with tests, not tutorial completions.\n'
            '• **Deliberate Practice**: Don\'t look at solutions for at least 20 minutes when stuck on LeetCode.\n\n'
            'I have prepared two targeted engineering tasks for your planner below:',
        timestamp: DateTime.now(),
        suggestedTasks: suggested,
        categoryTag: 'Engineering',
      );
    }

    // Default intelligent coach response
    return AiChatMessage(
      id: const Uuid().v4(),
      isUser: false,
      text: 'Analyzing your discipline matrix: You have **${allTasks.length} total tasks** in your system and an active streak of **$currentStreak days**.\n\n'
          'Remember: **Discipline is choosing between what you want now and what you want most.**\n\n'
          'What specific area shall we sharpen today?\n'
          '• Ask: *"Give me a discipline plan for today"*\n'
          '• Ask: *"How do I stop procrastinating?"*\n'
          '• Ask: *"Break down my coding goals"*',
      timestamp: DateTime.now(),
      categoryTag: 'Discipline Mentorship',
    );
  }
}
