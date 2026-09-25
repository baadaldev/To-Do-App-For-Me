import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/ai_coach_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../models/ai_chat_message.dart';

class AiChatState {
  final List<AiChatMessage> messages;
  final bool isThinking;

  const AiChatState({
    this.messages = const [],
    this.isThinking = false,
  });

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isThinking,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final LocalStorageService _storage;
  final Ref _ref;

  AiChatNotifier(this._storage, this._ref) : super(const AiChatState()) {
    _loadMessages();
  }

  String get _userId => _ref.read(authProvider).user?.uid ?? 'guest_user';

  void _loadMessages() {
    final raw = _storage.getAiChatHistory(_userId);
    if (raw.isNotEmpty) {
      final list = raw.map((m) => AiChatMessage.fromJson(m)).toList();
      state = state.copyWith(messages: list);
    } else {
      // Starter mentor welcoming message
      final welcome = AiChatMessage(
        id: const Uuid().v4(),
        isUser: false,
        text: 'Greetings, Warrior! ⚔️\n\n'
            'I am your **AI Discipline Mentor**. I monitor your consistency, daily non-negotiables, and habit momentum.\n\n'
            'Ask me anything about structuring your day, overcoming procrastination, or generating disciplined daily routines. How can I assist you right now?',
        timestamp: DateTime.now(),
        categoryTag: 'Welcome',
      );
      state = state.copyWith(messages: [welcome]);
      _storage.saveAiChatHistory(_userId, [welcome.toJson()]);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiChatMessage(
      id: const Uuid().v4(),
      isUser: true,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    final updated = [...state.messages, userMsg];
    state = state.copyWith(messages: updated, isThinking: true);

    await Future.delayed(const Duration(milliseconds: 500));

    final allTasks = _ref.read(taskNotifierProvider).allTasks;
    final gamification = _ref.read(gamificationProvider);

    final response = AiCoachService.respondToUserMessage(
      query: text,
      allTasks: allTasks,
      currentStreak: gamification.currentStreak,
      longestStreak: gamification.longestStreak,
    );

    final finalList = [...updated, response];
    state = state.copyWith(messages: finalList, isThinking: false);
    await _storage.saveAiChatHistory(_userId, finalList.map((m) => m.toJson()).toList());
  }

  Future<void> addSuggestedTask(AiSuggestedTask suggested) async {
    final now = DateTime.now();
    final task = TaskModel(
      id: const Uuid().v4(),
      userId: _userId,
      title: suggested.title,
      description: suggested.description,
      category: suggested.category,
      dueDate: now,
      dueHour: suggested.dueHour,
      dueMinute: suggested.dueMinute,
      priority: suggested.priority,
      isCompleted: false,
      hasReminder: true,
      createdAt: now,
      updatedAt: now,
    );

    await _ref.read(taskNotifierProvider.notifier).addTask(task);
  }

  Future<void> clearHistory() async {
    final welcome = AiChatMessage(
      id: const Uuid().v4(),
      isUser: false,
      text: 'Chat history cleared. What discipline challenge shall we tackle next?',
      timestamp: DateTime.now(),
      categoryTag: 'Reset',
    );
    state = state.copyWith(messages: [welcome]);
    await _storage.saveAiChatHistory(_userId, [welcome.toJson()]);
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AiChatNotifier(storage, ref);
});
