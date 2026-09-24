import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/gamification_engine.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/task_repository.dart';
import '../models/task_category.dart';
import '../models/task_model.dart';

enum TaskFilterStatus { all, pending, completed, missed }

class TaskFilterState {
  final DateTime selectedDate;
  final TaskCategory? category;
  final TaskFilterStatus status;

  const TaskFilterState({
    required this.selectedDate,
    this.category,
    this.status = TaskFilterStatus.all,
  });

  TaskFilterState copyWith({
    DateTime? selectedDate,
    TaskCategory? category,
    bool clearCategory = false,
    TaskFilterStatus? status,
  }) {
    return TaskFilterState(
      selectedDate: selectedDate ?? this.selectedDate,
      category: clearCategory ? null : (category ?? this.category),
      status: status ?? this.status,
    );
  }
}

final taskFilterProvider = StateProvider<TaskFilterState>((ref) {
  return TaskFilterState(selectedDate: DateTimeUtils.startOfDay(DateTime.now()));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return TaskRepository(localStorage: localStorage);
});

class TaskState {
  final bool isLoading;
  final List<TaskModel> allTasks;
  final String? errorMessage;

  const TaskState({
    this.isLoading = false,
    this.allTasks = const [],
    this.errorMessage,
  });

  TaskState copyWith({
    bool? isLoading,
    List<TaskModel>? allTasks,
    String? errorMessage,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      allTasks: allTasks ?? this.allTasks,
      errorMessage: errorMessage,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final LocalStorageService _localStorage;
  final Ref _ref;

  TaskNotifier(this._repository, this._localStorage, this._ref)
      : super(const TaskState(isLoading: true)) {
    loadTasks();
  }

  String get _currentUserId => _ref.read(authProvider).user?.uid ?? 'guest_user';

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await _repository.getTasks(_currentUserId);
      state = state.copyWith(isLoading: false, allTasks: tasks);
    } catch (e) {
      // Fallback to local cache
      final cached = _localStorage.getCachedTasks(_currentUserId);
      state = state.copyWith(
        isLoading: false,
        allTasks: cached,
        errorMessage: 'Loaded cached tasks: $e',
      );
    }
  }

  Future<void> addTask(TaskModel task) async {
    final updatedList = [task, ...state.allTasks];
    state = state.copyWith(allTasks: updatedList);
    await _repository.addTask(task);
  }

  Future<void> updateTask(TaskModel task) async {
    final updatedList = state.allTasks.map((t) => t.id == task.id ? task : t).toList();
    state = state.copyWith(allTasks: updatedList);
    await _repository.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    final updatedList = state.allTasks.where((t) => t.id != taskId).toList();
    state = state.copyWith(allTasks: updatedList);
    await _repository.deleteTask(_currentUserId, taskId);
  }

  Future<int> toggleTaskCompletion(TaskModel task, bool isCompleted) async {
    final updatedTask = task.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    final updatedList = state.allTasks.map((t) => t.id == task.id ? updatedTask : t).toList();
    state = state.copyWith(allTasks: updatedList);

    await _repository.toggleTaskCompletion(task, isCompleted);

    int earnedXp = 0;
    if (isCompleted) {
      final streaks = GamificationEngine.calculateStreaks(updatedList);
      earnedXp = GamificationEngine.calculateTaskXp(task.priority, streaks.currentStreak);

      final currentXp = _localStorage.getUserXp(_currentUserId);
      await _localStorage.setUserXp(_currentUserId, currentXp + earnedXp);
    }

    return earnedXp;
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return TaskNotifier(repo, storage, ref);
});

// Filtered tasks selector for current selected date, category, and status
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final filter = ref.watch(taskFilterProvider);

  return taskState.allTasks.where((task) {
    // 1. Date matching
    final matchesDate = DateTimeUtils.isSameDay(task.dueDate, filter.selectedDate);
    if (!matchesDate) return false;

    // 2. Category matching
    if (filter.category != null && task.category != filter.category) {
      return false;
    }

    // 3. Status matching
    switch (filter.status) {
      case TaskFilterStatus.all:
        return true;
      case TaskFilterStatus.pending:
        return !task.isCompleted && !task.isMissed;
      case TaskFilterStatus.completed:
        return task.isCompleted;
      case TaskFilterStatus.missed:
        return task.isMissed;
    }
  }).toList()
    ..sort((a, b) {
      // Uncompleted first, then by priority (high to low)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.priority.index.compareTo(a.priority.index);
    });
});
