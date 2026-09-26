import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/tasks/models/task_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const int morningReminderId = 1001;
  static const int eveningReminderId = 1002;
  static const int missedTasksReminderId = 1003;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification click action
        },
      );

      // Request permissions for Android 13+
      final androidImpl = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
        await androidImpl.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('NotificationService init notice: $e');
    }
  }

  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        showWhen: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // --- Show Instant Notification ---
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        _notificationDetails(
          channelId: 'discipline_general',
          channelName: 'General Notifications',
          channelDescription: 'General app notifications and achievements',
        ),
        payload: payload,
      );
    } catch (_) {}
  }

  // --- Schedule Task Due Reminder ---
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (kIsWeb || !task.hasReminder || task.isCompleted) return;
    try {
      final dueDateTime = task.dueDateTime;
      if (dueDateTime.isBefore(DateTime.now())) return;

      final scheduledTz = tz.TZDateTime.from(dueDateTime, tz.local);
      final notificationId = task.id.hashCode.abs();

      await _localNotifications.zonedSchedule(
        notificationId,
        'Task Reminder: ${task.title}',
        'Category: ${task.category.displayName} • Priority: ${task.priority.displayName}',
        scheduledTz,
        _notificationDetails(
          channelId: 'task_reminders',
          channelName: 'Task Due Reminders',
          channelDescription: 'Alerts for when your scheduled tasks are due',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (_) {}
  }

  // --- Cancel Task Reminder ---
  Future<void> cancelTaskReminder(String taskId) async {
    if (kIsWeb) return;
    try {
      final notificationId = taskId.hashCode.abs();
      await _localNotifications.cancel(notificationId);
    } catch (_) {}
  }

  // --- Schedule Daily Morning Reminder (8:00 AM) ---
  Future<void> scheduleDailyMorningReminder({int hour = 8, int minute = 0}) async {
    if (kIsWeb) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        morningReminderId,
        '🌅 Morning Discipline Briefing',
        'Review today\'s planner, lock in your habits, and maintain your streak!',
        scheduledDate,
        _notificationDetails(
          channelId: 'daily_briefing',
          channelName: 'Daily Briefings',
          channelDescription: 'Morning motivational briefings and task overviews',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  // --- Schedule Daily Evening Review Reminder (9:00 PM) ---
  Future<void> scheduleDailyEveningReminder({int hour = 21, int minute = 0}) async {
    if (kIsWeb) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        eveningReminderId,
        '🌙 Evening Reflection Time',
        'Time to log your daily reflection, review completed goals, and earn XP!',
        scheduledDate,
        _notificationDetails(
          channelId: 'daily_reflection',
          channelName: 'Daily Reflection',
          channelDescription: 'Evening reflection and journal reminders',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  // --- Missed Task Alert ---
  Future<void> triggerMissedTaskNotification(int missedCount) async {
    if (kIsWeb || missedCount <= 0) return;
    try {
      await _localNotifications.show(
        missedTasksReminderId,
        '⚠️ Uncompleted Tasks Detected',
        'You have $missedCount task${missedCount > 1 ? 's' : ''} pending past due. Protect your streak today!',
        _notificationDetails(
          channelId: 'missed_tasks',
          channelName: 'Missed Task Alerts',
          channelDescription: 'Alerts when tasks pass their scheduled due time',
        ),
      );
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _localNotifications.cancelAll();
    } catch (_) {}
  }
}
