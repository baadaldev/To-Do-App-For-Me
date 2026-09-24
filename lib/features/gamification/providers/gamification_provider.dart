import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/gamification_engine.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../models/badge_model.dart';
import '../models/user_level.dart';

class GamificationState {
  final int totalXp;
  final UserLevel level;
  final List<BadgeModel> badges;
  final int streakFreezes;
  final int currentStreak;
  final int longestStreak;

  const GamificationState({
    required this.totalXp,
    required this.level,
    required this.badges,
    required this.streakFreezes,
    required this.currentStreak,
    required this.longestStreak,
  });
}

final gamificationProvider = Provider<GamificationState>((ref) {
  final user = ref.watch(authProvider).user;
  final userId = user?.uid ?? 'guest_user';

  final localStorage = ref.watch(localStorageServiceProvider);
  final taskState = ref.watch(taskNotifierProvider);
  final allTasks = taskState.allTasks;

  // Streak
  final streaks = GamificationEngine.calculateStreaks(allTasks);

  // XP: stored in local storage, fallback to sum of completed tasks
  int xp = localStorage.getUserXp(userId);
  if (xp == 0 && allTasks.isNotEmpty) {
    // initialize from existing completed tasks
    for (final t in allTasks.where((t) => t.isCompleted)) {
      xp += t.priority.xpReward;
    }
  }

  final level = GamificationEngine.calculateLevel(xp);
  final badges = GamificationEngine.evaluateBadges(
    allTasks: allTasks,
    currentStreak: streaks.currentStreak,
    longestStreak: streaks.longestStreak,
  );
  final freezes = localStorage.getStreakFreezes(userId);

  return GamificationState(
    totalXp: xp,
    level: level,
    badges: badges,
    streakFreezes: freezes,
    currentStreak: streaks.currentStreak,
    longestStreak: streaks.longestStreak,
  );
});
