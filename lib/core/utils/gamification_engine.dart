import '../constants/app_strings.dart';
import '../../features/gamification/models/badge_model.dart';
import '../../features/gamification/models/user_level.dart';
import '../../features/tasks/models/task_priority.dart';
import '../../features/tasks/models/task_model.dart';
import 'date_time_utils.dart';

class GamificationEngine {
  GamificationEngine._();

  static const int xpPerLowPriority = 15;
  static const int xpPerMediumPriority = 25;
  static const int xpPerHighPriority = 40;
  static const int xpPerReflection = 50;
  static const int xpPerLevelBase = 200;

  static int calculateTaskXp(TaskPriority priority, int currentStreak) {
    int base = switch (priority) {
      TaskPriority.low => xpPerLowPriority,
      TaskPriority.medium => xpPerMediumPriority,
      TaskPriority.high => xpPerHighPriority,
    };

    // Streak multiplier bonus: +5% per streak day, max +50%
    double multiplier = 1.0 + (currentStreak * 0.05).clamp(0.0, 0.5);
    return (base * multiplier).round();
  }

  static UserLevel calculateLevel(int totalXp) {
    if (totalXp <= 0) {
      return const UserLevel(level: 1, title: 'Novice Initiate', currentXp: 0, nextLevelXp: xpPerLevelBase);
    }

    int level = (totalXp ~/ xpPerLevelBase) + 1;
    int currentLevelFloorXp = (level - 1) * xpPerLevelBase;
    int nextLevelCeilXp = level * xpPerLevelBase;
    int progressInLevel = totalXp - currentLevelFloorXp;
    int neededForNext = nextLevelCeilXp - currentLevelFloorXp;

    String title = switch (level) {
      1 => 'Novice Initiate',
      2 => 'Apprentice Builder',
      3 => 'Consistent Achiever',
      4 => 'Iron Will Guardian',
      5 => 'Focus Strategist',
      6 => 'Resilience Champion',
      7 => 'Habit Architect',
      8 => 'Unstoppable Force',
      9 => 'Apex Disciplinarian',
      _ => 'Discipline Grandmaster',
    };

    return UserLevel(
      level: level,
      title: title,
      currentXp: progressInLevel,
      nextLevelXp: neededForNext,
    );
  }

  static List<BadgeModel> evaluateBadges({
    required List<TaskModel> allTasks,
    required int currentStreak,
    required int longestStreak,
  }) {
    final completedTasks = allTasks.where((t) => t.isCompleted).toList();
    final completedCount = completedTasks.length;

    return [
      BadgeModel(
        id: 'badge_first_task',
        title: AppStrings.badgeFirstTask,
        description: 'Completed your very first task on Discipline Tracker',
        iconName: 'flag',
        isUnlocked: completedCount >= 1,
        unlockedAt: completedCount >= 1 ? completedTasks.first.completedAt : null,
      ),
      BadgeModel(
        id: 'badge_7_day_streak',
        title: AppStrings.badge7DayStreak,
        description: 'Maintained an unbroken consistency streak for 7 consecutive days',
        iconName: 'local_fire_department',
        isUnlocked: currentStreak >= 7 || longestStreak >= 7,
      ),
      BadgeModel(
        id: 'badge_30_day_streak',
        title: AppStrings.badge30DayStreak,
        description: 'Forged iron discipline with a 30-day streak of relentless consistency',
        iconName: 'military_tech',
        isUnlocked: currentStreak >= 30 || longestStreak >= 30,
      ),
      BadgeModel(
        id: 'badge_100_tasks',
        title: AppStrings.badge100Tasks,
        description: 'Demonstrated mastery by completing 100 disciplined tasks',
        iconName: 'verified',
        isUnlocked: completedCount >= 100,
      ),
      BadgeModel(
        id: 'badge_discipline_master',
        title: AppStrings.badgeDisciplineMaster,
        description: 'Achieved Level 10 and maintained over 85% monthly completion rate',
        iconName: 'workspace_premium',
        isUnlocked: completedCount >= 150 && (currentStreak >= 30 || longestStreak >= 30),
      ),
    ];
  }

  /// Calculates the active streak from a list of completed tasks and streak freeze status
  static ({int currentStreak, int longestStreak}) calculateStreaks(
    List<TaskModel> tasks, {
    int streakFreezesAvailable = 0,
  }) {
    final completedDays = tasks
        .where((t) => t.isCompleted && t.completedAt != null)
        .map((t) => DateTimeUtils.startOfDay(t.completedAt!))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    if (completedDays.isEmpty) {
      return (currentStreak: 0, longestStreak: 0);
    }

    final today = DateTimeUtils.startOfDay(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    int current = 0;
    DateTime checkDate = today;

    // If no task today, check if yesterday was completed
    if (!completedDays.any((d) => DateTimeUtils.isSameDay(d, today))) {
      if (completedDays.any((d) => DateTimeUtils.isSameDay(d, yesterday))) {
        checkDate = yesterday;
      } else {
        return (currentStreak: 0, longestStreak: _computeLongest(completedDays));
      }
    }

    while (true) {
      if (completedDays.any((d) => DateTimeUtils.isSameDay(d, checkDate))) {
        current++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    int longest = _computeLongest(completedDays);
    if (current > longest) longest = current;

    return (currentStreak: current, longestStreak: longest);
  }

  static int _computeLongest(List<DateTime> daysDesc) {
    if (daysDesc.isEmpty) return 0;
    final sortedAsc = daysDesc.toSet().toList()..sort();
    int maxStreak = 1;
    int current = 1;

    for (int i = 1; i < sortedAsc.length; i++) {
      if (sortedAsc[i].difference(sortedAsc[i - 1]).inDays == 1) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else if (sortedAsc[i].difference(sortedAsc[i - 1]).inDays > 1) {
        current = 1;
      }
    }
    return maxStreak;
  }
}
