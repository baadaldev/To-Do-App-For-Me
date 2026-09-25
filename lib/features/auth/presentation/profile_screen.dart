import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final gamification = ref.watch(gamificationProvider);
    final taskState = ref.watch(taskNotifierProvider);

    final completedTasks = taskState.allTasks.where((t) => t.isCompleted).length;
    final displayName = user?.displayName ?? user?.email.split('@').first ?? 'Disciplined Warrior';
    final email = user?.email ?? 'offline_user@discipline.local';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warrior Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary,
                  child: CircleAvatar(
                    radius: 43,
                    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Level Progression Card
          XpProgressBar(
            userLevel: gamification.level,
            totalXp: gamification.totalXp,
          ),
          const SizedBox(height: 20),

          // Lifetime Stats Grid
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
                const Text('Discipline Records', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatItem('Current Streak', '${gamification.currentStreak} Days', AppColors.streakFlame),
                    _buildStatItem('Longest Streak', '${gamification.longestStreak} Days', AppColors.accent),
                    _buildStatItem('Completed Tasks', '$completedTasks', AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Unlocked Badges count
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.accent, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Badges Earned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '${gamification.badges.where((b) => b.isUnlocked).length} of ${gamification.badges.length} Unlocked',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Log out Button
          CustomButton(
            text: 'Sign Out',
            icon: Icons.logout_rounded,
            variant: ButtonVariant.outlined,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text(
                    'Are you sure you want to sign out? Your tasks and discipline streak are saved safely.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await ref.read(authProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
