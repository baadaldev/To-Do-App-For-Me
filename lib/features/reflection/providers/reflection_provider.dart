import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/gamification_engine.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/reflection_repository.dart';
import '../models/reflection_model.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ReflectionRepository(localStorage: storage);
});

class ReflectionState {
  final bool isLoading;
  final List<ReflectionModel> reflections;
  final String? error;

  const ReflectionState({
    this.isLoading = false,
    this.reflections = const [],
    this.error,
  });

  ReflectionState copyWith({
    bool? isLoading,
    List<ReflectionModel>? reflections,
    String? error,
  }) {
    return ReflectionState(
      isLoading: isLoading ?? this.isLoading,
      reflections: reflections ?? this.reflections,
      error: error,
    );
  }
}

class ReflectionNotifier extends StateNotifier<ReflectionState> {
  final ReflectionRepository _repo;
  final LocalStorageService _storage;
  final Ref _ref;

  ReflectionNotifier(this._repo, this._storage, this._ref)
      : super(const ReflectionState(isLoading: true)) {
    loadReflections();
  }

  String get _currentUserId => _ref.read(authProvider).user?.uid ?? 'guest_user';

  Future<void> loadReflections() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getReflections(_currentUserId);
      state = state.copyWith(isLoading: false, reflections: list);
    } catch (e) {
      final cached = _storage.getCachedReflections(_currentUserId);
      state = state.copyWith(isLoading: false, reflections: cached, error: e.toString());
    }
  }

  Future<int> addReflection(ReflectionModel reflection) async {
    final updated = [reflection, ...state.reflections];
    state = state.copyWith(reflections: updated);

    await _repo.saveReflection(reflection);

    // Award +50 XP for daily reflection
    final currentXp = _storage.getUserXp(_currentUserId);
    await _storage.setUserXp(_currentUserId, currentXp + GamificationEngine.xpPerReflection);

    return GamificationEngine.xpPerReflection;
  }
}

final reflectionNotifierProvider = StateNotifierProvider<ReflectionNotifier, ReflectionState>((ref) {
  final repo = ref.watch(reflectionRepositoryProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return ReflectionNotifier(repo, storage, ref);
});
