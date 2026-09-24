import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../tasks/providers/task_provider.dart';
import '../models/heat_map_entry.dart';

class HeatmapStats {
  final Map<DateTime, HeatMapEntry> entriesMap;
  final int totalActiveDays;
  final int totalContributions;
  final double consistencyScore;

  const HeatmapStats({
    required this.entriesMap,
    required this.totalActiveDays,
    required this.totalContributions,
    required this.consistencyScore,
  });
}

final heatmapStatsProvider = Provider<HeatmapStats>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final allTasks = taskState.allTasks;

  final Map<DateTime, List<dynamic>> grouped = {};
  for (final t in allTasks) {
    final dateKey = DateTimeUtils.startOfDay(t.dueDate);
    grouped.putIfAbsent(dateKey, () => []).add(t);
  }

  final Map<DateTime, HeatMapEntry> entries = {};
  int activeDays = 0;
  int completedCountTotal = 0;

  grouped.forEach((date, tasksList) {
    final total = tasksList.length;
    final completed = tasksList.where((t) => t.isCompleted == true).length;
    final intensity = HeatMapEntry.computeIntensity(completed);

    if (completed > 0) {
      activeDays++;
      completedCountTotal += completed;
    }

    entries[date] = HeatMapEntry(
      date: date,
      completedCount: completed,
      totalCount: total,
      intensityLevel: intensity,
    );
  });

  // Calculate consistency over last 30 days
  final last30Days = DateTimeUtils.getLastNDays(30);
  int daysWithCompletions = 0;
  for (final d in last30Days) {
    final e = entries[d];
    if (e != null && e.completedCount > 0) {
      daysWithCompletions++;
    }
  }
  final consistencyScore = (daysWithCompletions / 30.0) * 100;

  return HeatmapStats(
    entriesMap: entries,
    totalActiveDays: activeDays,
    totalContributions: completedCountTotal,
    consistencyScore: consistencyScore,
  );
});
