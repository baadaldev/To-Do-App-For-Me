import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/reflection_model.dart';
import '../providers/reflection_provider.dart';
import 'reflection_history_screen.dart';

class DailyReflectionScreen extends ConsumerStatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  ConsumerState<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends ConsumerState<DailyReflectionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _accomplishController = TextEditingController();
  final _challengesController = TextEditingController();
  final _tomorrowController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _accomplishController.dispose();
    _challengesController.dispose();
    _tomorrowController.dispose();
    super.dispose();
  }

  Future<void> _submitReflection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(authProvider).user;
      final userId = user?.uid ?? 'guest_user';

      final reflection = ReflectionModel(
        id: const Uuid().v4(),
        userId: userId,
        date: DateTime.now(),
        accomplishments: _accomplishController.text.trim(),
        challenges: _challengesController.text.trim(),
        tomorrowPlan: _tomorrowController.text.trim(),
        rating: _rating,
        createdAt: DateTime.now(),
      );

      final xp = await ref.read(reflectionNotifierProvider.notifier).addReflection(reflection);

      if (mounted) {
        _accomplishController.clear();
        _challengesController.clear();
        _tomorrowController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Reflection logged! +$xp XP awarded.'),
              ],
            ),
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reflection'),
        actions: [
          IconButton(
            tooltip: 'Reflection History',
            icon: const Icon(Icons.history_edu_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReflectionHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                        : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.self_improvement_rounded, color: AppColors.secondary, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evening Debrief',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'True discipline requires continuous introspection. Log today\'s lessons to claim +50 XP.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rating / Self-Evaluation Stars
              const Text(
                'How disciplined were you today?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  return IconButton(
                    iconSize: 32,
                    icon: Icon(
                      starNum <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.accent,
                    ),
                    onPressed: () => setState(() => _rating = starNum),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Prompt 1: Accomplishments
              CustomTextField(
                controller: _accomplishController,
                label: '1. What did you accomplish today?',
                hint: 'Goals conquered, habits executed, victories achieved...',
                prefixIcon: Icons.emoji_events_outlined,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please record at least one achievement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Prompt 2: Challenges
              CustomTextField(
                controller: _challengesController,
                label: '2. What went wrong or challenged you?',
                hint: 'Distractions encountered, missed intentions, energy drains...',
                prefixIcon: Icons.warning_amber_rounded,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please note challenges or write "Nothing major"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Prompt 3: Tomorrow's non-negotiables
              CustomTextField(
                controller: _tomorrowController,
                label: '3. What will you do tomorrow to stay on track?',
                hint: 'Tomorrow\'s primary focus and non-negotiable tasks...',
                prefixIcon: Icons.next_plan_outlined,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please write your commitment for tomorrow';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: 'Save Daily Reflection (+50 XP)',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSubmitting,
                onPressed: _submitReflection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
