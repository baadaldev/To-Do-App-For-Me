import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../../features/gamification/models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const BadgeCard({super.key, required this.badge});

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
      'flag' => Icons.flag_rounded,
      'local_fire_department' => Icons.local_fire_department_rounded,
      'military_tech' => Icons.military_tech_rounded,
      'verified' => Icons.verified_rounded,
      'workspace_premium' => Icons.workspace_premium_rounded,
      _ => Icons.emoji_events_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = badge.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF1C2230) : const Color(0xFFF0FDF4))
            : (isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? AppColors.accent.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isUnlocked ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppColors.accent.withValues(alpha: 0.18)
                  : (isDark ? AppColors.darkCard : const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              isUnlocked ? _resolveIcon(badge.iconName) : Icons.lock_outline_rounded,
              size: 28,
              color: isUnlocked ? AppColors.accent : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        badge.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'UNLOCKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                if (isUnlocked && badge.unlockedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Unlocked: ${DateFormat('MMM dd, yyyy').format(badge.unlockedAt!)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.accent),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
