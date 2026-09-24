import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../../auth/presentation/profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authProvider).user;
    final gamification = ref.watch(gamificationProvider);
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account / Profile Tile
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                user?.displayName ?? 'Disciplined User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user?.email ?? 'Logged in', style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          const Text('APPEARANCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: SwitchListTile(
              secondary: Icon(
                settings.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('GitHub terminal-inspired dark theme', style: TextStyle(fontSize: 12)),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).toggleDarkMode(val);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          const Text('NOTIFICATIONS & REMINDERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.wb_sunny_outlined, color: AppColors.accent),
                  title: const Text('Daily Morning Briefing (8:00 AM)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Review tasks and prepare for consistency', style: TextStyle(fontSize: 12)),
                  value: settings.morningReminder,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleMorningReminder(val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.nights_stay_outlined, color: AppColors.secondary),
                  title: const Text('Evening Reflection Reminder (9:00 PM)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Record achievements and claim daily reflection XP', style: TextStyle(fontSize: 12)),
                  value: settings.eveningReminder,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleEveningReminder(val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm_rounded, color: AppColors.primary),
                  title: const Text('Task Due Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Exact notification when scheduled task is due', style: TextStyle(fontSize: 12)),
                  value: settings.taskDueReminder,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleTaskDueReminder(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data & Export Section
          const Text('DATA & EXPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                  title: const Text('Export Progress to PDF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Generate detailed printable progress & streak report', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.file_download_outlined),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating PDF Report...'), duration: Duration(seconds: 1)),
                    );

                    await PdfExportService.exportProgressReport(
                      userName: user?.displayName ?? 'Warrior',
                      currentStreak: gamification.currentStreak,
                      longestStreak: gamification.longestStreak,
                      totalXp: gamification.totalXp,
                      level: gamification.level.level,
                      allTasks: taskState.allTasks,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_rounded, color: AppColors.secondary),
                  title: const Text('Force Cloud Backup', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Sync offline Hive database with Cloud Firestore', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.sync_rounded),
                  onTap: () async {
                    await ref.read(taskNotifierProvider.notifier).loadTasks();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Offline database synced with cloud!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // App Info Footer
          const Center(
            child: Column(
              children: [
                Text(
                  'Discipline Tracker • Version 1.0.0 (Production)',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Clean Architecture • Riverpod • Offline-First Hive',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
