import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;
  final NotificationService _notificationService;

  TaskRepository({
    FirebaseFirestore? firestore,
    required LocalStorageService localStorage,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _localStorage = localStorage,
        _notificationService = notificationService ?? NotificationService.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await _userTasksRef(userId).orderBy('dueDate', descending: false).get();
      final tasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();

      // Cache locally
      await _localStorage.saveTasksToCache(userId, tasks);
      return tasks;
    } catch (e) {
      // Offline fallback: load from local cache
      return _localStorage.getCachedTasks(userId);
    }
  }

  @override
  Stream<List<TaskModel>> streamTasks(String userId) {
    return _userTasksRef(userId).snapshots().map((snapshot) {
      final tasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
      // Keep local cache synced in background
      _localStorage.saveTasksToCache(userId, tasks);
      return tasks;
    }).handleError((error) {
      // In case of network stream error, emit cached tasks
      return _localStorage.getCachedTasks(userId);
    });
  }

  @override
  Future<void> addTask(TaskModel task) async {
    // 1. Save to local cache first for instant optimistic UI
    await _localStorage.saveSingleTaskToCache(task);

    // 2. Schedule notification if enabled
    if (task.hasReminder) {
      await _notificationService.scheduleTaskReminder(task);
    }

    // 3. Sync to Cloud Firestore
    try {
      await _userTasksRef(task.userId).doc(task.id).set(task.toJson());
    } catch (_) {
      // Offline: cached copy remains available
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _localStorage.saveSingleTaskToCache(task);

    if (task.hasReminder && !task.isCompleted) {
      await _notificationService.scheduleTaskReminder(task);
    } else {
      await _notificationService.cancelTaskReminder(task.id);
    }

    try {
      await _userTasksRef(task.userId).doc(task.id).update(task.toJson());
    } catch (_) {
      // Handled via local storage
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _localStorage.deleteTaskFromCache(userId, taskId);
    await _notificationService.cancelTaskReminder(taskId);

    try {
      await _userTasksRef(userId).doc(taskId).delete();
    } catch (_) {
      // Handled via local storage
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
