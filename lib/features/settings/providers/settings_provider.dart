import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool morningReminder;
  final bool eveningReminder;
  final bool taskDueReminder;

  const SettingsState({
    required this.themeMode,
    required this.morningReminder,
    required this.eveningReminder,
    required this.taskDueReminder,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? morningReminder,
    bool? eveningReminder,
    bool? taskDueReminder,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      morningReminder: morningReminder ?? this.morningReminder,
      eveningReminder: eveningReminder ?? this.eveningReminder,
      taskDueReminder: taskDueReminder ?? this.taskDueReminder,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final LocalStorageService _storage;
  final NotificationService _notificationService;

  SettingsNotifier(this._storage, this._notificationService)
      : super(SettingsState(
          themeMode: _storage.isDarkMode() ? ThemeMode.dark : ThemeMode.light,
          morningReminder: _storage.getMorningReminderEnabled(),
          eveningReminder: _storage.getEveningReminderEnabled(),
          taskDueReminder: _storage.getTaskDueReminderEnabled(),
        ));

  Future<void> toggleDarkMode(bool isDark) async {
    await _storage.setDarkMode(isDark);
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleMorningReminder(bool enabled) async {
    await _storage.setMorningReminderEnabled(enabled);
    state = state.copyWith(morningReminder: enabled);
    if (enabled) {
      await _notificationService.scheduleDailyMorningReminder();
    }
  }

  Future<void> toggleEveningReminder(bool enabled) async {
    await _storage.setEveningReminderEnabled(enabled);
    state = state.copyWith(eveningReminder: enabled);
    if (enabled) {
      await _notificationService.scheduleDailyEveningReminder();
    }
  }

  Future<void> toggleTaskDueReminder(bool enabled) async {
    await _storage.setTaskDueReminderEnabled(enabled);
    state = state.copyWith(taskDueReminder: enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsNotifier(storage, NotificationService.instance);
});
