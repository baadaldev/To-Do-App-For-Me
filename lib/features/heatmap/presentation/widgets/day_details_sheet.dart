import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../tasks/models/task_model.dart';

class DayDetailsSheet extends StatelessWidget {
  final DateTime date;
  final List<TaskModel> allTasks;

  const DayDetailsSheet({
    super.key,
    required this.date,
    required this.allTasks,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dayTasks = allTasks.where((t) => DateTimeUtils.isSameDay(t.dueDate, date)).toList();
    final completed = dayTasks.where((t) => t.isCompleted).toList();
    final missedOrPending = dayTasks.where((t) => !t.isCompleted).toList();

    final completionPct = dayTasks.isEmpty ? 0 : ((completed.length / dayTasks.length) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Date Header & Status summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(date),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${completed.length} of ${dayTasks.length} tasks completed ($completionPct%)',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: completed.isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkCard : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completionPct%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: completed.isNotEmpty ? AppColors.primary : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (dayTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'No activity logged for this date.',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Completed Tasks Section
                if (completed.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Completed Tasks (${completed.length})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...completed.map((t) => _buildMiniTaskTile(context, t, isDone: true)),
                  const SizedBox(height: 16),
                ],

                // Missed or Pending Tasks Section
                if (missedOrPending.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        DateTimeUtils.isToday(date) ? Icons.pending_actions_rounded : Icons.cancel_rounded,
                        size: 18,
                        color: DateTimeUtils.isToday(date) ? AppColors.accent : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateTimeUtils.isToday(date)
                            ? 'Pending for Today (${missedOrPending.length})'
                            : 'Missed Tasks (${missedOrPending.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: DateTimeUtils.isToday(date) ? AppColors.accent : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...missedOrPending.map((t) => _buildMiniTaskTile(context, t, isDone: false)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTaskTile(BuildContext context, TaskModel task, {required bool isDone}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(task.category.icon, size: 16, color: task.category.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : null,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: task.priority.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.priority.displayName,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: task.priority.color),
            ),
          ),
        ],
      ),
    );
  }
}
