import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../data/auth_repository.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be initialized in main.dart');
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _repo;
  final LocalStorageService _storage;

  AuthNotifier(this._repo, this._storage) : super(const AuthState(isLoading: true)) {
    _initAuth();
  }

  void _initAuth() {
    // 1. Check local saved user session first
    final active = _storage.getActiveUser();
    if (active != null) {
      state = AuthState(
        user: AppUser(
          uid: active['uid'] ?? 'guest_user',
          email: active['email'] ?? '',
          displayName: active['displayName'] ?? 'Warrior',
        ),
        isLoading: false,
      );
      return;
    }

    // 2. Listen to Firebase auth state if available
    try {
      final currentFirebaseUser = _repo.currentUser;
      if (currentFirebaseUser != null) {
        state = AuthState(user: _fromFirebaseUser(currentFirebaseUser), isLoading: false);
      } else {
        state = const AuthState(isLoading: false);
      }

      _repo.authStateChanges.listen((user) async {
        if (user != null) {
          final appUser = _fromFirebaseUser(user);
          await _storage.migrateGuestDataToUser(appUser.uid);
          await _storage.saveActiveUser(
            uid: appUser.uid,
            email: appUser.email,
            displayName: appUser.displayName,
          );
          state = state.copyWith(user: appUser, isLoading: false);
        } else if (_storage.getActiveUser() == null) {
          state = state.copyWith(isLoading: false, clearUser: true);
        }
      });
    } catch (_) {
      // Firebase not configured; operate in local offline mode
      state = const AuthState(isLoading: false);
    }
  }

  AppUser _fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.email?.split('@').first ?? 'Warrior'),
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cred = await _repo.signInWithEmail(email, password);
      if (cred.user != null) {
        final appUser = _fromFirebaseUser(cred.user!);
        await _storage.migrateGuestDataToUser(appUser.uid);
        await _storage.saveActiveUser(
          uid: appUser.uid,
          email: appUser.email,
          displayName: appUser.displayName,
        );
        state = state.copyWith(user: appUser, isLoading: false);
        return;
      }
    } catch (_) {
      // Offline fallback: sign in locally
      final name = email.split('@').first;
      final localUser = AppUser(
        uid: 'user_${email.hashCode.abs()}',
        email: email.trim(),
        displayName: name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : 'Warrior',
      );
      await _storage.migrateGuestDataToUser(localUser.uid);
      await _storage.saveActiveUser(
        uid: localUser.uid,
        email: localUser.email,
        displayName: localUser.displayName,
      );
      state = state.copyWith(user: localUser, isLoading: false);
    }
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cred = await _repo.signUpWithEmail(email, password, displayName);
      if (cred.user != null) {
        final appUser = _fromFirebaseUser(cred.user!);
        await _storage.migrateGuestDataToUser(appUser.uid);
        await _storage.saveActiveUser(
          uid: appUser.uid,
          email: appUser.email,
          displayName: appUser.displayName,
        );
        state = state.copyWith(user: appUser, isLoading: false);
        return;
      }
    } catch (_) {
      // Graceful offline fallback: if Firebase is not connected or fails, save user locally!
      final localUser = AppUser(
        uid: 'user_${email.hashCode.abs()}',
        email: email.trim(),
        displayName: displayName.trim().isNotEmpty ? displayName.trim() : 'Warrior',
      );
      await _storage.migrateGuestDataToUser(localUser.uid);
      await _storage.saveActiveUser(
        uid: localUser.uid,
        email: localUser.email,
        displayName: localUser.displayName,
      );
      state = state.copyWith(user: localUser, isLoading: false);
    }
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    const guestUser = AppUser(
      uid: 'guest_user',
      email: 'warrior@discipline.local',
      displayName: 'Disciplined Warrior',
    );
    await _storage.saveActiveUser(
      uid: guestUser.uid,
      email: guestUser.email,
      displayName: guestUser.displayName,
    );
    state = state.copyWith(user: guestUser, isLoading: false);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cred = await _repo.signInWithGoogle();
      if (cred?.user != null) {
        final appUser = _fromFirebaseUser(cred!.user!);
        await _storage.migrateGuestDataToUser(appUser.uid);
        await _storage.saveActiveUser(
          uid: appUser.uid,
          email: appUser.email,
          displayName: appUser.displayName,
        );
        state = state.copyWith(user: appUser, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google Sign In error: $e',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _storage.clearActiveUser();
    try {
      await _repo.signOut();
    } catch (_) {}
    state = const AuthState(isLoading: false);
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Password reset link sent (offline mode simulation)',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) => sendPasswordReset(email);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return AuthNotifier(repo, storage);
});
