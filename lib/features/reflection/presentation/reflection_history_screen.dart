import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/reflection_provider.dart';

class ReflectionHistoryScreen extends ConsumerWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(reflectionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflection Journal History'),
      ),
      body: state.isLoading
          ? const LoadingIndicator(message: 'Loading reflections...')
          : state.reflections.isEmpty
              ? const EmptyStateView(
                  icon: Icons.history_edu_rounded,
                  title: 'No reflections logged yet',
                  message: 'Complete your evening debrief in the Reflection tab to record your journey.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.reflections.length,
                  itemBuilder: (context, index) {
                    final item = state.reflections[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(item.date),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Row(
                                children: List.generate(
                                  item.rating,
                                  (_) => const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          _buildSection('🏆 Accomplishments', item.accomplishments, isDark),
                          const SizedBox(height: 10),
                          _buildSection('⚡ Challenges Faced', item.challenges, isDark),
                          const SizedBox(height: 10),
                          _buildSection('🎯 Tomorrow\'s Focus', item.tomorrowPlan, isDark),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
