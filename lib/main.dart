import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Hive Storage
  final localStorage = LocalStorageService();
  await localStorage.init();

  // 2. Initialize Local Notifications & Timezones
  try {
    await NotificationService.instance.init();
    if (localStorage.getMorningReminderEnabled()) {
      await NotificationService.instance.scheduleDailyMorningReminder();
    }
    if (localStorage.getEveningReminderEnabled()) {
      await NotificationService.instance.scheduleDailyEveningReminder();
    }
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  // 3. Initialize Firebase Suite with the generated platform config
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e (Operating in offline-first mode)');
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorage),
      ],
      child: const DisciplineTrackerApp(),
    ),
  );
}
