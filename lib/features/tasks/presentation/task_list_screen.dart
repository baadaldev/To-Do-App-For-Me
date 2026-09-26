import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/task_category.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';
import 'widgets/category_chip.dart';
import 'widgets/task_tile.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskState = ref.watch(taskNotifierProvider);
    final filter = ref.watch(taskFilterProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          IconButton(
            tooltip: 'Go to Today',
            icon: const Icon(Icons.today_rounded),
            onPressed: () {
              ref.read(taskFilterProvider.notifier).update(
                    (s) => s.copyWith(selectedDate: DateTimeUtils.startOfDay(DateTime.now())),
                  );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'planner_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(initialDate: filter.selectedDate),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // 1. Horizontal Date Strip
          _buildDateSelectorStrip(context, ref, filter.selectedDate),

          // 2. Category Filter Row
          _buildCategoryFilterRow(context, ref, filter.category),

          // 3. Status Tabs
          _buildStatusTabs(context, ref, filter.status),

          const Divider(height: 1),

          // 4. Task List Body
          Expanded(
            child: taskState.isLoading
                ? const LoadingIndicator(message: 'Loading your planner...')
                : filteredTasks.isEmpty
                    ? EmptyStateView(
                        icon: Icons.checklist_rounded,
                        title: 'No tasks scheduled',
                        message: filter.status == TaskFilterStatus.all
                            ? 'Set your daily non-negotiables and conquer the day.'
                            : 'No ${filter.status.name} tasks found for this filter.',
                        actionLabel: 'Schedule a Task',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(initialDate: filter.selectedDate),
                            ),
                          );
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(taskNotifierProvider.notifier).loadTasks(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
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
                                          Text('Discipline reward: +$xp XP earned!'),
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
                                _confirmDelete(context, ref, task);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorStrip(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    // 14 days window (7 days back, 7 days forward)
    final days = List.generate(21, (index) {
      return DateTimeUtils.startOfDay(today.subtract(const Duration(days: 7)).add(Duration(days: index)));
    });

    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = DateTimeUtils.isSameDay(date, selectedDate);
          final isCurrentDay = DateTimeUtils.isToday(date);

          return GestureDetector(
            onTap: () {
              ref.read(taskFilterProvider.notifier).update((s) => s.copyWith(selectedDate: date));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isCurrentDay
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                  width: isCurrentDay ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white70
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  if (isCurrentDay && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilterRow(BuildContext context, WidgetRef ref, TaskCategory? selectedCategory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Categories'),
            selected: selectedCategory == null,
            onSelected: (_) {
              ref.read(taskFilterProvider.notifier).update((s) => s.copyWith(clearCategory: true));
            },
          ),
          const SizedBox(width: 8),
          ...TaskCategory.values.map(
            (cat) => CategoryChip(
              category: cat,
              isSelected: selectedCategory == cat,
              onTap: () {
                ref.read(taskFilterProvider.notifier).update((s) {
                  return s.category == cat ? s.copyWith(clearCategory: true) : s.copyWith(category: cat);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(BuildContext context, WidgetRef ref, TaskFilterStatus currentStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: TaskFilterStatus.values.map((status) {
          final isSelected = currentStatus == status;
          return Expanded(
            child: InkWell(
              onTap: () {
                ref.read(taskFilterProvider.notifier).update((s) => s.copyWith(status: status));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  status.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to remove "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
