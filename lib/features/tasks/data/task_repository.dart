import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/task_model.dart';

abstract class ITaskRepository {
  Future<List<TaskModel>> getTasks(String userId);
  Stream<List<TaskModel>> streamTasks(String userId);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String userId, String taskId);
  Future<void> toggleTaskCompletion(TaskModel task, bool isCompleted);
}

class TaskRepository implements ITaskRepository {
  FirebaseFirestore? _firestore;
  final LocalStorageService _localStorage;
  final NotificationService _notificationService;

  TaskRepository({
    FirebaseFirestore? firestore,
    required LocalStorageService localStorage,
    NotificationService? notificationService,
  })  : _firestore = firestore,
        _localStorage = localStorage,
        _notificationService = notificationService ?? NotificationService.instance;

  FirebaseFirestore? get _firestoreInstance {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      debugPrint('FirebaseFirestore unavailable (operating in offline-first mode): $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userTasksRef(String userId) {
    try {
      return _firestoreInstance?.collection('users').doc(userId).collection('tasks');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    // 1. Always load local cache first for instant, guaranteed availability
    final localTasks = _localStorage.getCachedTasks(userId);

    final ref = _userTasksRef(userId);
    if (ref == null) return localTasks;

    // 2. Attempt remote Firestore sync with quick timeout
    try {
      final snapshot = await ref
          .orderBy('dueDate', descending: false)
          .get()
          .timeout(const Duration(seconds: 3));

      final remoteTasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();

      if (remoteTasks.isEmpty) {
        // If remote has no records yet, sync all local tasks up to Firestore in background
        for (final t in localTasks) {
          ref.doc(t.id).set(t.toJson()).catchError((_) {});
        }
        return localTasks;
      }

      // Safe bidirectional merge: never delete tasks that exist locally
      final Map<String, TaskModel> taskMap = {for (var t in localTasks) t.id: t};
      for (final rt in remoteTasks) {
        if (!taskMap.containsKey(rt.id) || rt.updatedAt.isAfter(taskMap[rt.id]!.updatedAt)) {
          taskMap[rt.id] = rt;
        }
      }

      final mergedList = taskMap.values.toList();
      await _localStorage.saveTasksToCache(userId, mergedList);
      return mergedList;
    } catch (e) {
      // Offline or Firebase not available: return local cache safely
      debugPrint('Firestore getTasks notice (using local offline cache): $e');
      return localTasks;
    }
  }

  @override
  Stream<List<TaskModel>> streamTasks(String userId) {
    final ref = _userTasksRef(userId);
    if (ref == null) {
      return Stream.value(_localStorage.getCachedTasks(userId));
    }

    return ref.snapshots().map((snapshot) {
      final remoteTasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
      final localTasks = _localStorage.getCachedTasks(userId);

      // Merge rather than blindly overwrite
      final Map<String, TaskModel> taskMap = {for (var t in localTasks) t.id: t};
      for (final rt in remoteTasks) {
        taskMap[rt.id] = rt;
      }

      final merged = taskMap.values.toList();
      _localStorage.saveTasksToCache(userId, merged);
      return merged;
    }).handleError((error) {
      debugPrint('Firestore streamTasks fallback: $error');
      return _localStorage.getCachedTasks(userId);
    });
  }

  @override
  Future<void> addTask(TaskModel task) async {
    // 1. Save to local cache first for instant UI response (0ms lag)
    await _localStorage.saveSingleTaskToCache(task);

    // 2. Safe notification scheduling with error boundary
    if (task.hasReminder) {
      try {
        await _notificationService.scheduleTaskReminder(task);
      } catch (e) {
        debugPrint('Task reminder schedule notice: $e');
      }
    }

    // 3. Background Sync to Cloud Firestore with strict timeout
    final ref = _userTasksRef(task.userId);
    if (ref != null) {
      try {
        await ref.doc(task.id).set(task.toJson()).timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Firestore background addTask notice: $e');
      }
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    // 1. Update local cache immediately
    await _localStorage.saveSingleTaskToCache(task);

    // 2. Safe notification updating
    try {
      if (task.hasReminder && !task.isCompleted) {
        await _notificationService.scheduleTaskReminder(task);
      } else {
        await _notificationService.cancelTaskReminder(task.id);
      }
    } catch (_) {}

    // 3. Background Firestore update with timeout
    final ref = _userTasksRef(task.userId);
    if (ref != null) {
      try {
        await ref.doc(task.id).update(task.toJson()).timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Firestore background updateTask notice: $e');
      }
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    // 1. Remove from local cache immediately
    await _localStorage.deleteTaskFromCache(userId, taskId);

    // 2. Cancel reminder safely
    try {
      await _notificationService.cancelTaskReminder(taskId);
    } catch (_) {}

    // 3. Background Firestore deletion with timeout
    final ref = _userTasksRef(userId);
    if (ref != null) {
      try {
        await ref.doc(taskId).delete().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Firestore background deleteTask notice: $e');
      }
    }
  }

  @override
  Future<void> toggleTaskCompletion(TaskModel task, bool isCompleted) async {
    final updatedTask = task.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    await updateTask(updatedTask);
  }
}
