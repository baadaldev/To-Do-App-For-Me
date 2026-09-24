import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_coach_service.dart';
import '../../../core/utils/gamification_engine.dart';
import '../../tasks/providers/task_provider.dart';

final aiCoachProvider = Provider<List<CoachInsight>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final allTasks = taskState.allTasks;

  final streaks = GamificationEngine.calculateStreaks(allTasks);

  return AiCoachService.generateInsights(
    tasks: allTasks,
    currentStreak: streaks.currentStreak,
    longestStreak: streaks.longestStreak,
  );
});
