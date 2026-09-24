import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../models/heat_map_entry.dart';

class GitHubHeatMapWidget extends StatelessWidget {
  final Map<DateTime, HeatMapEntry> entriesMap;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onDayTap;
  final double squareSize;
  final double spacing;

  const GitHubHeatMapWidget({
    super.key,
    required this.entriesMap,
    required this.startDate,
    required this.endDate,
    required this.onDayTap,
    this.squareSize = 14,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Generate list of days from startDate aligned to week start (Monday)
    final adjustedStart = startDate.subtract(Duration(days: startDate.weekday - 1));
    final adjustedEnd = endDate.add(Duration(days: 7 - endDate.weekday));
    final totalDays = adjustedEnd.difference(adjustedStart).inDays + 1;
    final totalWeeks = (totalDays / 7).ceil();

    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heatmap Grid with Weekday Labels
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // Scroll to recent weeks
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(7, (i) {
                    final showLabel = i == 0 || i == 2 || i == 4; // Mon, Wed, Fri
                    return Container(
                      height: squareSize,
                      margin: EdgeInsets.only(bottom: spacing),
                      alignment: Alignment.centerRight,
                      child: Text(
                        showLabel ? weekdays[i] : '',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Week Columns
              ...List.generate(totalWeeks, (weekIndex) {
                return Padding(
                  padding: EdgeInsets.only(right: spacing),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(7, (dayIndex) {
                      final dayDate = adjustedStart.add(Duration(days: (weekIndex * 7) + dayIndex));
                      final normalizedDate = DateTimeUtils.startOfDay(dayDate);

                      final isOutOfRange = dayDate.isBefore(startDate) || dayDate.isAfter(endDate);
                      final entry = entriesMap[normalizedDate];
                      final intensity = isOutOfRange ? 0 : (entry?.intensityLevel ?? 0);

                      Color color;
                      if (isOutOfRange) {
                        color = isDark ? Colors.transparent : Colors.transparent;
                      } else if (isDark) {
                        color = switch (intensity) {
                          1 => AppColors.heatLevel1Dark,
                          2 => AppColors.heatLevel2Dark,
                          3 => AppColors.heatLevel3Dark,
                          4 => AppColors.heatLevel4Dark,
                          _ => AppColors.heatLevel0Dark,
                        };
                      } else {
                        color = switch (intensity) {
                          1 => AppColors.heatLevel1Light,
                          2 => AppColors.heatLevel2Light,
                          3 => AppColors.heatLevel3Light,
                          4 => AppColors.heatLevel4Light,
                          _ => AppColors.heatLevel0Light,
                        };
                      }

                      return Tooltip(
                        message: isOutOfRange
                            ? ''
                            : '${DateTimeUtils.toReadableDate(normalizedDate)}: ${entry?.completedCount ?? 0} tasks completed',
                        child: GestureDetector(
                          onTap: isOutOfRange ? null : () => onDayTap(normalizedDate),
                          child: Container(
                            width: squareSize,
                            height: squareSize,
                            margin: EdgeInsets.only(bottom: spacing),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: isOutOfRange
                                    ? Colors.transparent
                                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Legend row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (level) {
              Color legendColor;
              if (isDark) {
                legendColor = switch (level) {
                  1 => AppColors.heatLevel1Dark,
                  2 => AppColors.heatLevel2Dark,
                  3 => AppColors.heatLevel3Dark,
                  4 => AppColors.heatLevel4Dark,
                  _ => AppColors.heatLevel0Dark,
                };
              } else {
                legendColor = switch (level) {
                  1 => AppColors.heatLevel1Light,
                  2 => AppColors.heatLevel2Light,
                  3 => AppColors.heatLevel3Light,
                  4 => AppColors.heatLevel4Light,
                  _ => AppColors.heatLevel0Light,
                };
              }
              return Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: legendColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              );
            }),
            const SizedBox(width: 4),
            Text(
              'More',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
