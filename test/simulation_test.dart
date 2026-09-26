import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:discipline_tracker/app.dart';
import 'package:discipline_tracker/core/services/local_storage_service.dart';
import 'package:discipline_tracker/features/auth/data/auth_repository.dart';
import 'package:discipline_tracker/features/auth/presentation/login_screen.dart';
import 'package:discipline_tracker/features/auth/presentation/profile_screen.dart';
import 'package:discipline_tracker/features/auth/providers/auth_provider.dart';
import 'package:discipline_tracker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:discipline_tracker/features/dashboard/presentation/main_scaffold.dart';
import 'package:discipline_tracker/features/tasks/presentation/add_edit_task_screen.dart';
import 'package:discipline_tracker/features/ai_coach/presentation/ai_coach_screen.dart';
import 'package:discipline_tracker/features/heatmap/presentation/heatmap_screen.dart';
import 'package:discipline_tracker/features/analytics/presentation/analytics_screen.dart';

class MockAuthRepository implements IAuthRepository {
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
  late LocalStorageService mockStorage;

  setUp(() async {
    mockStorage = LocalStorageService();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(mockStorage),
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      child: const DisciplineTrackerApp(),
    );
  }

  testWidgets('Full Application End-to-End Simulation Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Launch App
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Verify initial screen is LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Discipline Tracker'), findsOneWidget);
    expect(find.text('🚀 Continue in Demo / Guest Mode'), findsOneWidget);

    // 2. Demo / Guest Login
    await tester.tap(find.text('🚀 Continue in Demo / Guest Mode'));
    await tester.pumpAndSettle();

    // Verify MainScaffold and DashboardScreen are active
    expect(find.byType(MainScaffold), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('Disciplined'), findsWidgets);

    // 3. Verify Dashboard Elements
    expect(find.text('Consistency Heatmap'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsWidgets); // FAB exists

    // 4. Open Warrior Profile via AppBar Avatar
    final profileTooltip = find.byTooltip('Warrior Profile & Sign Out');
    expect(profileTooltip, findsOneWidget);
    await tester.tap(profileTooltip);
    await tester.pumpAndSettle();

    // Verify ProfileScreen
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Discipline Records'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // Pop back from Profile to Dashboard
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // 5. Add New Disciplined Task via FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AddEditTaskScreen), findsOneWidget);
    expect(find.text('New Disciplined Goal'), findsOneWidget);

    // Enter Task Title & Description
    await tester.enterText(find.byType(TextFormField).at(0), 'Master Binary Search Trees');
    await tester.enterText(find.byType(TextFormField).at(1), 'Solve 3 medium LeetCode problems');
    await tester.pumpAndSettle();

    // Select Priority (High)
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();

    // Save Task
    await tester.tap(find.text('Add to Schedule'));
    await tester.pumpAndSettle();

    // Verify returned to Dashboard and task exists
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Master Binary Search Trees'), findsOneWidget);

    // 6. Navigate to Daily Planner Tab (Index 1)
    await tester.tap(find.byIcon(Icons.calendar_today_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Daily Planner'), findsOneWidget);
    expect(find.text('All Categories'), findsOneWidget);

    // 7. Navigate to Heatmap Calendar Tab (Index 2)
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HeatmapScreen), findsOneWidget);
    expect(find.text('Active Days'), findsOneWidget);
    expect(find.text('Monthly View'), findsOneWidget);

    // 8. Navigate to AI Coach Tab (Index 3)
    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AiCoachScreen), findsOneWidget);
    expect(find.text('Mentor Chat'), findsOneWidget);
    expect(find.textContaining('Insights'), findsWidgets);

    // Send AI quick prompt
    final quickPrompt = find.text('🎯 Give me a 3-step discipline plan for today');
    expect(quickPrompt, findsOneWidget);
    await tester.tap(quickPrompt);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify AI response arrived with actionable recommendations
    expect(find.text('AI Recommended Action Items:'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add'), findsWidgets);

    // Tap "Add" on AI recommended action item
    final addButton = find.widgetWithText(FilledButton, 'Add').first;
    await tester.ensureVisible(addButton);
    await tester.tap(addButton, warnIfMissed: false);
    await tester.pump();
    await tester.pumpAndSettle();

    // 9. Navigate to Analytics Tab (Index 4)
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsScreen), findsOneWidget);
    expect(find.text('Productivity Index'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);

    // 10. Open Drawer and Sign Out with Confirmation Dialog
    // Switch back to Dashboard first
    await tester.tap(find.byIcon(Icons.dashboard_rounded));
    await tester.pumpAndSettle();

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Drawer is open
    expect(find.text('Warrior Profile'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // Tap Sign Out in Drawer
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verify Confirmation Dialog
    expect(find.text('Are you sure you want to sign out? Your tasks and streaks are saved.'), findsOneWidget);

    // Confirm Sign Out
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
    await tester.pumpAndSettle();

    // Verify returned back to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
