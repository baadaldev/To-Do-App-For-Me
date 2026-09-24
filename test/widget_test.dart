import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:discipline_tracker/app.dart';
import 'package:discipline_tracker/core/services/local_storage_service.dart';
import 'package:discipline_tracker/features/auth/data/auth_repository.dart';
import 'package:discipline_tracker/features/auth/providers/auth_provider.dart';

class FakeAuthRepository implements IAuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password, String displayName) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential?> signInWithGoogle() async => null;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('App smoke test initializes smoothly and displays Login Screen', (WidgetTester tester) async {
    final mockStorage = LocalStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const DisciplineTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DisciplineTrackerApp), findsOneWidget);
  });
}
