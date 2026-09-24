import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/gamification_engine.dart';
import '../../tasks/models/task_category.dart';
import '../../tasks/models/task_priority.dart';
import '../../tasks/providers/task_provider.dart';

class AnalyticsData {
  final int todayTotal;
  final int todayCompleted;
  final int todayMissed;
  final double todayRate;

  final int weekTotal;
  final int weekCompleted;
  final int weekMissed;
  final double weekRate;

  final int monthTotal;
  final int monthCompleted;
  final int monthMissed;
  final double monthRate;

  final int lifetimeCompleted;
  final int lifetimeMissed;

  final int productivityScore;
  final int currentStreak;
  final int longestStreak;

  final List<({String dayLabel, int completed, int missed})> weeklyTrend;
  final Map<TaskCategory, int> categoryCompletedCounts;

  const AnalyticsData({
    required this.todayTotal,
    required this.todayCompleted,
    required this.todayMissed,
    required this.todayRate,
    required this.weekTotal,
    required this.weekCompleted,
    required this.weekMissed,
    required this.weekRate,
    required this.monthTotal,
    required this.monthCompleted,
    required this.monthMissed,
    required this.monthRate,
    required this.lifetimeCompleted,
    required this.lifetimeMissed,
    required this.productivityScore,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyTrend,
    required this.categoryCompletedCounts,
  });
}

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final allTasks = taskState.allTasks;

  final now = DateTime.now();
  final todayStart = DateTimeUtils.startOfDay(now);

  // Streaks
  final streaks = GamificationEngine.calculateStreaks(allTasks);

  // Today
  final todayTasks = allTasks.where((t) => DateTimeUtils.isSameDay(t.dueDate, todayStart)).toList();
  final todayCompleted = todayTasks.where((t) => t.isCompleted).length;
  final todayMissed = todayTasks.where((t) => t.isMissed).length;
  final todayRate = todayTasks.isEmpty ? 0.0 : (todayCompleted / todayTasks.length);

  // This Week (Last 7 days or Mon-Sun)
  final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  final weekTasks = allTasks.where((t) => !t.dueDate.isBefore(weekStart) && t.dueDate.isBefore(weekEnd)).toList();
  final weekCompleted = weekTasks.where((t) => t.isCompleted).length;
  final weekMissed = weekTasks.where((t) => t.isMissed).length;
  final weekRate = weekTasks.isEmpty ? 0.0 : (weekCompleted / weekTasks.length);

  // This Month
  final monthTasks = allTasks.where((t) => t.dueDate.year == now.year && t.dueDate.month == now.month).toList();
  final monthCompleted = monthTasks.where((t) => t.isCompleted).length;
  final monthMissed = monthTasks.where((t) => t.isMissed).length;
  final monthRate = monthTasks.isEmpty ? 0.0 : (monthCompleted / monthTasks.length);

  // Lifetime
  final lifetimeCompleted = allTasks.where((t) => t.isCompleted).length;
  final lifetimeMissed = allTasks.where((t) => t.isMissed).length;

  // Weekly Trend Bars (Mon to Sun)
  final daysOfWeekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<({String dayLabel, int completed, int missed})> weeklyTrend = [];
  for (int i = 0; i < 7; i++) {
    final dayDate = weekStart.add(Duration(days: i));
    final dayTasks = weekTasks.where((t) => DateTimeUtils.isSameDay(t.dueDate, dayDate)).toList();
    final comp = dayTasks.where((t) => t.isCompleted).length;
    final miss = dayTasks.where((t) => t.isMissed).length;
    weeklyTrend.add((dayLabel: daysOfWeekLabels[i], completed: comp, missed: miss));
  }

  // Category counts
  final Map<TaskCategory, int> categoryCounts = {};
  for (final cat in TaskCategory.values) {
    categoryCounts[cat] = allTasks.where((t) => t.category == cat && t.isCompleted).length;
  }

  // Productivity score calculation:
  // (Base completion rate 50%) + (Streak consistency factor 30%) + (High priority completion 20%)
  double score = 50.0;
  if (allTasks.isNotEmpty) {
    final overallRate = lifetimeCompleted / allTasks.length;
    final streakFactor = (streaks.currentStreak / 14.0).clamp(0.0, 1.0);

    final highTasks = allTasks.where((t) => t.priority == TaskPriority.high).toList();
    final highRate = highTasks.isEmpty ? 1.0 : (highTasks.where((t) => t.isCompleted).length / highTasks.length);

    score = (overallRate * 50.0) + (streakFactor * 30.0) + (highRate * 20.0);
  }

  return AnalyticsData(
    todayTotal: todayTasks.length,
    todayCompleted: todayCompleted,
    todayMissed: todayMissed,
    todayRate: todayRate,
    weekTotal: weekTasks.length,
    weekCompleted: weekCompleted,
    weekMissed: weekMissed,
    weekRate: weekRate,
    monthTotal: monthTasks.length,
    monthCompleted: monthCompleted,
    monthMissed: monthMissed,
    monthRate: monthRate,
    lifetimeCompleted: lifetimeCompleted,
    lifetimeMissed: lifetimeMissed,
    productivityScore: score.round().clamp(0, 100),
    currentStreak: streaks.currentStreak,
    longestStreak: streaks.longestStreak,
    weeklyTrend: weeklyTrend,
    categoryCompletedCounts: categoryCounts,
  );
});
