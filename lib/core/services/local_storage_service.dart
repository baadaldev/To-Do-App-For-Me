import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/tasks/models/task_category.dart';
import '../../features/tasks/models/task_priority.dart';
import '../../features/reflection/models/reflection_model.dart';

class LocalStorageService {
  static const String _tasksBoxName = 'tasks_box';
  static const String _reflectionsBoxName = 'reflections_box';
  static const String _settingsBoxName = 'settings_box';

  Box? _tasksBox;
  Box? _reflectionsBox;
  Box? _settingsBox;

  // In-memory fallback if Hive box is not yet opened (e.g. during testing)
  final Map<String, dynamic> _memorySettings = {};
  final Map<String, List<dynamic>> _memoryTasks = {};
  final Map<String, List<dynamic>> _memoryReflections = {};

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _tasksBox = await Hive.openBox(_tasksBoxName);
      _reflectionsBox = await Hive.openBox(_reflectionsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } catch (_) {
      // In tests or headless environments where disk access is restricted
    }
  }

  // --- Active User Session ---
  Map<String, String>? getActiveUser() {
    final raw = (_settingsBox?.get('active_user') ?? _memorySettings['active_user']) as String?;
    if (raw == null) return null;
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveUser({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final data = jsonEncode({
      'uid': uid,
      'email': email,
      'displayName': displayName,
    });
    _memorySettings['active_user'] = data;
    await _settingsBox?.put('active_user', data);
  }

  Future<void> clearActiveUser() async {
    _memorySettings.remove('active_user');
    await _settingsBox?.delete('active_user');
  }

  // --- Tasks Cache ---
  bool hasSeededTasks(String userId) {
    return (_settingsBox?.get('seeded_$userId', defaultValue: false) ??
        _memorySettings['seeded_$userId'] ??
        false) as bool;
  }

  void _markSeeded(String userId) {
    _memorySettings['seeded_$userId'] = true;
    _settingsBox?.put('seeded_$userId', true);
  }

  List<TaskModel> getCachedTasks(String userId) {
    final rawList = (_tasksBox?.get(userId, defaultValue: <dynamic>[]) ??
        _memoryTasks[userId] ??
        <dynamic>[]) as List<dynamic>;

    // If empty and never seeded, auto-seed starter habits so the user gets a rich initial dashboard
    if (rawList.isEmpty && !hasSeededTasks(userId)) {
      final starterTasks = _generateStarterTasks(userId);
      saveTasksToCache(userId, starterTasks);
      _markSeeded(userId);
      return starterTasks;
    }

    return rawList.map((e) {
      if (e is String) {
        return TaskModel.fromJson(jsonDecode(e) as Map<String, dynamic>);
      }
      return TaskModel.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();
  }

  List<TaskModel> _generateStarterTasks(String userId) {
    final now = DateTime.now();
    return [
      TaskModel(
        id: 'starter_task_1',
        userId: userId,
        title: '30-Minute Morning Workout',
        description: 'Cardio, pushups, and stretching',
        category: TaskCategory.gym,
        dueDate: now,
        dueHour: 8,
        dueMinute: 0,
        priority: TaskPriority.high,
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 2)),
        hasReminder: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      TaskModel(
        id: 'starter_task_2',
        userId: userId,
        title: 'Deep Focus Coding Session (2 Hours)',
        description: 'Work on personal mobile development project',
        category: TaskCategory.coding,
        dueDate: now,
        dueHour: 15,
        dueMinute: 30,
        priority: TaskPriority.high,
        isCompleted: false,
        hasReminder: true,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'starter_task_3',
        userId: userId,
        title: 'Read 15 Pages of Atomic Habits',
        description: 'Read and highlight key habit stacking concepts',
        category: TaskCategory.reading,
        dueDate: now,
        dueHour: 21,
        dueMinute: 0,
        priority: TaskPriority.medium,
        isCompleted: false,
        hasReminder: true,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'starter_task_4',
        userId: userId,
        title: 'Review System Design Principles',
        description: 'Scalability, microservices, and databases',
        category: TaskCategory.study,
        dueDate: now.subtract(const Duration(days: 1)),
        dueHour: 17,
        dueMinute: 0,
        priority: TaskPriority.medium,
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 1)),
        hasReminder: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
    ];
  }

  Future<void> saveTasksToCache(String userId, List<TaskModel> tasks) async {
    _markSeeded(userId);
    final serialized = tasks.map((t) => jsonEncode(t.toJson())).toList();
    _memoryTasks[userId] = serialized;
    await _tasksBox?.put(userId, serialized);
  }

  Future<void> saveSingleTaskToCache(TaskModel task) async {
    _markSeeded(task.userId);
    final tasks = getCachedTasks(task.userId);
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.insert(0, task);
    }
    await saveTasksToCache(task.userId, tasks);
  }

  Future<void> deleteTaskFromCache(String userId, String taskId) async {
    final tasks = getCachedTasks(userId);
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasksToCache(userId, tasks);
  }

  Future<void> migrateGuestDataToUser(String targetUserId) async {
    if (targetUserId == 'guest_user') return;
    try {
      final guestTasks = getCachedTasks('guest_user');
      if (guestTasks.isNotEmpty) {
        final existing = getCachedTasks(targetUserId);
        final Map<String, TaskModel> map = {for (var t in existing) t.id: t};
        for (final gt in guestTasks) {
          if (!map.containsKey(gt.id)) {
            map[gt.id] = gt.copyWith(userId: targetUserId);
          }
        }
        await saveTasksToCache(targetUserId, map.values.toList());
      }
    } catch (_) {}
  }

  // --- AI Chat History ---
  Future<void> saveAiChatHistory(String userId, List<Map<String, dynamic>> messages) async {
    final key = 'ai_chat_$userId';
    final serialized = messages.map((m) => jsonEncode(m)).toList();
    _memorySettings[key] = serialized;
    await _settingsBox?.put(key, serialized);
  }

  List<Map<String, dynamic>> getAiChatHistory(String userId) {
    final key = 'ai_chat_$userId';
    final rawList = (_settingsBox?.get(key, defaultValue: <dynamic>[]) ??
        _memorySettings[key] ??
        <dynamic>[]) as List<dynamic>;
    return rawList.map((e) {
      if (e is String) {
        return Map<String, dynamic>.from(jsonDecode(e) as Map);
      }
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }

  // --- Reflections Cache ---
  List<ReflectionModel> getCachedReflections(String userId) {
    final rawList = (_reflectionsBox?.get(userId, defaultValue: <dynamic>[]) ??
        _memoryReflections[userId] ??
        <dynamic>[]) as List<dynamic>;
    return rawList.map((e) {
      if (e is String) {
        return ReflectionModel.fromJson(jsonDecode(e) as Map<String, dynamic>);
      }
      return ReflectionModel.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();
  }

  Future<void> saveReflectionsToCache(String userId, List<ReflectionModel> list) async {
    final serialized = list.map((r) => jsonEncode(r.toJson())).toList();
    _memoryReflections[userId] = serialized;
    await _reflectionsBox?.put(userId, serialized);
  }

  // --- Settings & Preferences ---
  bool isDarkMode() {
    return (_settingsBox?.get('dark_mode', defaultValue: true) ??
        _memorySettings['dark_mode'] ??
        true) as bool;
  }

  Future<void> setDarkMode(bool value) async {
    _memorySettings['dark_mode'] = value;
    await _settingsBox?.put('dark_mode', value);
  }

  bool getMorningReminderEnabled() {
    return (_settingsBox?.get('morning_reminder', defaultValue: true) ??
        _memorySettings['morning_reminder'] ??
        true) as bool;
  }

  Future<void> setMorningReminderEnabled(bool value) async {
    _memorySettings['morning_reminder'] = value;
    await _settingsBox?.put('morning_reminder', value);
  }

  bool getEveningReminderEnabled() {
    return (_settingsBox?.get('evening_reminder', defaultValue: true) ??
        _memorySettings['evening_reminder'] ??
        true) as bool;
  }

  Future<void> setEveningReminderEnabled(bool value) async {
    _memorySettings['evening_reminder'] = value;
    await _settingsBox?.put('evening_reminder', value);
  }

  bool getTaskDueReminderEnabled() {
    return (_settingsBox?.get('task_due_reminder', defaultValue: true) ??
        _memorySettings['task_due_reminder'] ??
        true) as bool;
  }

  Future<void> setTaskDueReminderEnabled(bool value) async {
    _memorySettings['task_due_reminder'] = value;
    await _settingsBox?.put('task_due_reminder', value);
  }

  int getUserXp(String userId) {
    return (_settingsBox?.get('xp_$userId', defaultValue: 0) ??
        _memorySettings['xp_$userId'] ??
        0) as int;
  }

  Future<void> setUserXp(String userId, int xp) async {
    _memorySettings['xp_$userId'] = xp;
    await _settingsBox?.put('xp_$userId', xp);
  }

  int getStreakFreezes(String userId) {
    return (_settingsBox?.get('freezes_$userId', defaultValue: 2) ??
        _memorySettings['freezes_$userId'] ??
        2) as int;
  }

  Future<void> setStreakFreezes(String userId, int count) async {
    _memorySettings['freezes_$userId'] = count;
    await _settingsBox?.put('freezes_$userId', count);
  }
}
