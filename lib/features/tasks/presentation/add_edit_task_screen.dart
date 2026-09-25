import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/task_category.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';
import '../providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;
  final DateTime? initialDate;

  const AddEditTaskScreen({
    super.key,
    this.taskToEdit,
    this.initialDate,
  });

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskCategory _selectedCategory;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _hasReminder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedCategory = task?.category ?? TaskCategory.coding;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    final initial = task?.dueDate ?? widget.initialDate ?? DateTime.now();
    _selectedDate = DateTimeUtils.startOfDay(initial);
    _selectedTime = task != null
        ? TimeOfDay(hour: task.dueHour, minute: task.dueMinute)
        : const TimeOfDay(hour: 20, minute: 0);
    _hasReminder = task?.hasReminder ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = DateTimeUtils.startOfDay(picked));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _aiRefineGoal() {
    final current = _titleController.text.trim();
    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type a quick keyword (e.g. "code", "gym", "read") to refine with AI.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final lower = current.toLowerCase();
    if (lower.contains('code') || lower.contains('dev') || lower.contains('program') || lower.contains('flutter') || lower.contains('dsa')) {
      setState(() {
        _titleController.text = 'Deep Code: Build Feature & Clean Tests';
        _descController.text = 'Uninterrupted focus sprint. Zero tab switching, modular architecture.';
        _selectedCategory = TaskCategory.coding;
        _selectedPriority = TaskPriority.high;
      });
    } else if (lower.contains('read') || lower.contains('book') || lower.contains('study') || lower.contains('exam')) {
      setState(() {
        _titleController.text = 'Read 25 Pages & Summarize Top 3 Lessons';
        _descController.text = 'Active recall session. Take concise notes without phone distractions.';
        _selectedCategory = TaskCategory.reading;
        _selectedPriority = TaskPriority.medium;
      });
    } else if (lower.contains('gym') || lower.contains('workout') || lower.contains('run') || lower.contains('walk')) {
      setState(() {
        _titleController.text = '45-Min High-Discipline Physical Workout';
        _descController.text = 'Proper hydration, full range of motion, complete all scheduled sets.';
        _selectedCategory = TaskCategory.gym;
        _selectedPriority = TaskPriority.high;
      });
    } else if (lower.contains('meditat') || lower.contains('mind') || lower.contains('breath') || lower.contains('journal')) {
      setState(() {
        _titleController.text = '15-Min Breathwork & Clarity Meditation';
        _descController.text = 'Box breathing (4-4-4-4) to lower stress and sharpen tactical focus.';
        _selectedCategory = TaskCategory.personal;
        _selectedPriority = TaskPriority.medium;
      });
    } else {
      setState(() {
        _titleController.text = 'Deep Focus: $current (Sprint)';
        _descController.text = 'Non-negotiable execution block. Complete core requirements with high urgency.';
        _selectedPriority = TaskPriority.high;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('AI refined goal into an actionable discipline target!'),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).user;
      final userId = user?.uid ?? 'guest_user';

      final isEditing = widget.taskToEdit != null;
      final now = DateTime.now();

      final task = TaskModel(
        id: widget.taskToEdit?.id ?? const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        dueDate: DateTimeUtils.startOfDay(_selectedDate),
        dueHour: _selectedTime.hour,
        dueMinute: _selectedTime.minute,
        priority: _selectedPriority,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
        completedAt: widget.taskToEdit?.completedAt,
        hasReminder: _hasReminder,
        createdAt: widget.taskToEdit?.createdAt ?? now,
        updatedAt: now,
      );

      if (isEditing) {
        await ref.read(taskNotifierProvider.notifier).updateTask(task);
      } else {
        await ref.read(taskNotifierProvider.notifier).addTask(task);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Task updated!' : 'Task added to planner!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Disciplined Goal'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Title Field with AI Refine action
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _titleController,
                      label: 'Task Title',
                      hint: 'e.g. Complete LeetCode 3 problems',
                      prefixIcon: Icons.task_alt_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _aiRefineGoal,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
                          SizedBox(height: 2),
                          Text(
                            'AI Refine',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isEditing) ...[
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTemplateChip('Deep Work Sprint', 'High focus dev block', TaskCategory.coding, TaskPriority.high),
                      const SizedBox(width: 8),
                      _buildTemplateChip('Gym & Lifting', 'Push past comfort zone', TaskCategory.gym, TaskPriority.high),
                      const SizedBox(width: 8),
                      _buildTemplateChip('Read 25 Pages', 'Active book notes', TaskCategory.reading, TaskPriority.medium),
                      const SizedBox(width: 8),
                      _buildTemplateChip('15m Reflection', 'Mental reset & clarity', TaskCategory.personal, TaskPriority.low),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Description Field
              CustomTextField(
                controller: _descController,
                label: 'Description / Goal Notes (Optional)',
                hint: 'Details, context, or milestones...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    label: Text(
                      category.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: category.color,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Priority Selector
              const Text(
                'Priority Level',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPriority = priority),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.color.withValues(alpha: 0.18)
                                : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? priority.color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                priority.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? priority.color : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+${priority.xpReward} XP',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? priority.color : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Due Date & Time Pickers
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Date',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Time',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Reminder Toggle Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: const Text('Set Reminder Notification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Receive a notification at scheduled due time', style: TextStyle(fontSize: 12)),
                value: _hasReminder,
                onChanged: (val) => setState(() => _hasReminder = val),
              ),
              const SizedBox(height: 28),

              // Action Button
              CustomButton(
                text: isEditing ? 'Update Task' : 'Add to Schedule',
                icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
                isLoading: _isLoading,
                onPressed: _saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateChip(
    String title,
    String desc,
    TaskCategory category,
    TaskPriority priority,
  ) {
    return ActionChip(
      avatar: const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
      label: Text(title, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        setState(() {
          _titleController.text = title;
          _descController.text = desc;
          _selectedCategory = category;
          _selectedPriority = priority;
        });
      },
    );
  }
}
