import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../auth/presentation/profile_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../heatmap/presentation/widgets/day_details_sheet.dart';
import '../../heatmap/presentation/widgets/github_heatmap_widget.dart';
import '../../heatmap/providers/heatmap_provider.dart';
import '../../tasks/presentation/add_edit_task_screen.dart';
import '../../tasks/presentation/widgets/task_tile.dart';
import '../../tasks/providers/task_provider.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToPlanner;
  final VoidCallback onNavigateToHeatmap;
  final VoidCallback onNavigateToAnalytics;

  const DashboardScreen({
    super.key,
    required this.onNavigateToPlanner,
    required this.onNavigateToHeatmap,
    required this.onNavigateToAnalytics,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getRandomQuote() {
    const quotes = AppStrings.disciplineQuotes;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final gamification = ref.watch(gamificationProvider);
    final analytics = ref.watch(analyticsProvider);
    final heatmapStats = ref.watch(heatmapStatsProvider);
    final taskState = ref.watch(taskNotifierProvider);

    final today = DateTimeUtils.startOfDay(DateTime.now());
    final todayTasks = taskState.allTasks
        .where((t) => DateTimeUtils.isSameDay(t.dueDate, today))
        .toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.priority.index.compareTo(a.priority.index);
      });

    final displayName = user?.displayName.split(' ').first ?? 'Warrior';

    // 14-week window for dashboard heatmap preview
    final previewEnd = DateTime.now();
    final previewStart = previewEnd.subtract(const Duration(days: 14 * 7));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, $displayName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Streak Flame Indicator in AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.streakFlame.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${gamification.currentStreak}d',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // User Profile & Sign Out Entry
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Tooltip(
                message: 'Warrior Profile & Sign Out',
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.primary,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(initialDate: DateTime.now()),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskNotifierProvider.notifier).loadTasks(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Daily Motivational Quote Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getRandomQuote(),
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Level & XP Progress
            XpProgressBar(
              userLevel: gamification.level,
              totalXp: gamification.totalXp,
            ),
            const SizedBox(height: 16),

            // 3. Quick Stats KPI Card
            Row(
              children: [
                _buildQuickCard(
                  title: 'Today\'s Progress',
                  value: '${(analytics.todayRate * 100).toInt()}%',
                  subtitle: '${analytics.todayCompleted}/${analytics.todayTotal} Tasks',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: onNavigateToAnalytics,
                ),
                const SizedBox(width: 12),
                _buildQuickCard(
                  title: 'Active Streak',
                  value: '${gamification.currentStreak} Days',
                  subtitle: 'Best: ${gamification.longestStreak} Days',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.streakFlame,
                  isDark: isDark,
                  onTap: onNavigateToHeatmap,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Heatmap Preview Card
            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Consistency Heatmap',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: onNavigateToHeatmap,
                        child: const Text(
                          'View Full Grid →',
                          style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GitHubHeatMapWidget(
                    entriesMap: heatmapStats.entriesMap,
                    startDate: previewStart,
                    endDate: previewEnd,
                    onDayTap: (date) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => DayDetailsSheet(date: date, allTasks: taskState.allTasks),
                      );
                    },
                    squareSize: 13,
                    spacing: 3.5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Today's Tasks Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Today\'s Focus (${todayTasks.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onNavigateToPlanner,
                  child: const Text('Full Planner →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Today's Task List
            if (todayTasks.isEmpty)
              EmptyStateView(
                icon: Icons.done_all_rounded,
                title: 'All clear for today!',
                message: 'No pending tasks scheduled for today. Add a new goal to protect your streak.',
                actionLabel: 'Schedule Task',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(initialDate: DateTime.now()),
                    ),
                  );
                },
              )
            else
              ...todayTasks.map((task) {
                return TaskTile(
                  task: task,
                  onToggleComplete: (val) async {
                    final xp = await ref
                        .read(taskNotifierProvider.notifier)
                        .toggleTaskCompletion(task, val);
                    if (val && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text('+$xp XP earned! Stay disciplined.'),
                            ],
                          ),
                          backgroundColor: isDark ? AppColors.darkCard : Colors.black87,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(taskToEdit: task),
                      ),
                    );
                  },
                  onDelete: () {
                    ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
                  },
                );
              }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 22),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
