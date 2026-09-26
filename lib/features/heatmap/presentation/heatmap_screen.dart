import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../tasks/providers/task_provider.dart';
import '../providers/heatmap_provider.dart';
import 'widgets/day_details_sheet.dart';
import 'widgets/github_heatmap_widget.dart';

enum HeatmapViewMode { yearly, monthly }

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  HeatmapViewMode _viewMode = HeatmapViewMode.yearly;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _showDayDetails(DateTime date) {
    final allTasks = ref.read(taskNotifierProvider).allTasks;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DayDetailsSheet(date: date, allTasks: allTasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(heatmapStatsProvider);
    final now = DateTime.now();

    final DateTime startDate;
    final DateTime endDate;

    if (_viewMode == HeatmapViewMode.yearly) {
      // 365 days window or current calendar year
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year, 12, 31);
    } else {
      startDate = _selectedMonth;
      endDate = (_selectedMonth.month == 12)
          ? DateTime(_selectedMonth.year + 1, 1, 1).subtract(const Duration(days: 1))
          : DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1).subtract(const Duration(days: 1));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discipline Heatmap'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Consistency KPI Row
          Row(
            children: [
              _buildMetricCard(
                title: 'Active Days',
                value: '${stats.totalActiveDays}',
                subtitle: 'Days with completed tasks',
                icon: Icons.calendar_month_rounded,
                accentColor: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                title: 'Contributions',
                value: '${stats.totalContributions}',
                subtitle: 'Total completed items',
                icon: Icons.done_all_rounded,
                accentColor: AppColors.accent,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                title: '30-Day Index',
                value: '${stats.consistencyScore.toStringAsFixed(0)}%',
                subtitle: 'Monthly consistency',
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.secondary,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // View Mode Selector Segmented Button
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _viewMode = HeatmapViewMode.yearly),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _viewMode == HeatmapViewMode.yearly
                            ? (isDark ? AppColors.darkCard : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _viewMode == HeatmapViewMode.yearly
                            ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                            : null,
                      ),
                      child: Text(
                        'Yearly View (${now.year})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _viewMode == HeatmapViewMode.yearly ? FontWeight.bold : FontWeight.w500,
                          color: _viewMode == HeatmapViewMode.yearly ? AppColors.primary : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _viewMode = HeatmapViewMode.monthly),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _viewMode == HeatmapViewMode.monthly
                            ? (isDark ? AppColors.darkCard : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _viewMode == HeatmapViewMode.monthly
                            ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                            : null,
                      ),
                      child: Text(
                        'Monthly View',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _viewMode == HeatmapViewMode.monthly ? FontWeight.bold : FontWeight.w500,
                          color: _viewMode == HeatmapViewMode.monthly ? AppColors.primary : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // If monthly view, show month switcher
          if (_viewMode == HeatmapViewMode.monthly)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ),

          // Heatmap Container Card
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
                    Expanded(
                      child: Text(
                        _viewMode == HeatmapViewMode.yearly
                            ? '${now.year} Contribution Grid'
                            : DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tap any block for details',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GitHubHeatMapWidget(
                  entriesMap: stats.entriesMap,
                  startDate: startDate,
                  endDate: endDate,
                  onDayTap: _showDayDetails,
                  squareSize: _viewMode == HeatmapViewMode.yearly ? 13 : 20,
                  spacing: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Explanatory Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.insights_rounded, color: AppColors.primary, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Higher intensity blocks represent 7+ completed tasks in a single day. Maintaining high intensity blocks reinforces neurological habit wiring.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
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
            Icon(icon, size: 20, color: accentColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
