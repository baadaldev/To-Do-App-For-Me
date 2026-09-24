# Discipline Tracker — Production Mobile Application

A production-ready mobile application built with **Flutter**, **Firebase**, **Hive**, and **Riverpod** following **Clean Architecture**. Designed to help users forge unwavering discipline, build daily habits, defend streaks, and visualize their consistency via a GitHub-inspired contribution heatmap.

---

## 📱 Features Overview

1. **Authentication Suite**
   - Email & Password sign-up and login with input validation
   - Google Sign-In integration
   - Password reset flow with automated email links
   - User Profile management with level, XP, badges, and stats

2. **Daily Planner & Task Management**
   - Add, edit, delete, and filter daily tasks
   - 6 Core Categories with distinct color identities: `Study`, `Coding`, `Gym`, `Reading`, `Personal`, `Work`
   - Priority levels: `Low (+15 XP)`, `Medium (+25 XP)`, `High (+40 XP)`
   - Due date and time scheduling with customizable reminders
   - Interactive date strip and multi-filter tabs (All, Pending, Completed, Missed)

3. **Reminder & Notification Engine**
   - Local notifications with `timezone` exact alarm scheduling
   - **Daily Morning Briefing (8:00 AM)**: Motivational briefing & task lineup
   - **Daily Evening Reflection (9:00 PM)**: Review tasks and record daily journal
   - **Task Due Reminders**: Alerts right before or at task due time
   - **Missed Task Alerts**: Flags tasks that are overdue to safeguard streaks

4. **Task Completion & Metric Tracking**
   - Instant optimistic completion toggling with vibration & snackbar feedback
   - Exact `completedAt` timestamp logging
   - Real-time Daily, Weekly, and Monthly completion percentages

5. **GitHub-Style Heatmap**
   - Interactive contribution-style grid with 5 color intensity levels (Level 0 through 4)
   - Toggle between **Yearly View** (52-week horizontal scroll) and **Monthly View**
   - Interactive tap on any block to open a bottom sheet with completed & missed task drilldowns
   - 30-Day Consistency Index calculation

6. **Streak System & Streak Shields**
   - Current Streak and Longest Streak calculations
   - **Streak Freeze Protection**: Tokens that automatically preserve streaks when unexpected life events occur
   - Unbroken consistency multipliers

7. **Analytics Dashboard**
   - Circular Productivity Score Gauge (0–100 algorithm considering task execution rate, streaks, and high-priority compliance)
   - Weekly Completion vs. Missed trend bar chart (using `fl_chart`)
   - Category distribution progress bars
   - Lifetime completed vs. missed KPI counters

8. **Gamification & Rewards**
   - Tiered XP system: Task priority XP + streak multiplier bonus (up to +50%)
   - Level progression system (Novice → Apprentice → Consistent → Iron Will → Discipline Master)
   - Badges:
     - `First Task Completed` (First Step)
     - `7 Day Streak` (Week Warrior)
     - `30 Day Streak` (Habit Master)
     - `100 Tasks Completed` (Centurion)
     - `Discipline Master` (Grandmaster)

9. **AI Behavioral Coach**
   - Rule-based cognitive engine analyzing task execution patterns
   - Generates contextual insights (e.g., *"You completed 90% of gym tasks this week"*, *"You missed coding tasks 3 times this week. Try scheduling coding earlier in the day when cognitive energy is highest"*)
   - Identifies Golden Productivity Windows (Morning focus vs. Night Owl)

10. **Daily Reflection Journal**
    - Guided 3-question evening review:
      1. *What did you accomplish today?*
      2. *What went wrong or challenged you?*
      3. *What will you do tomorrow to stay on track?*
    - Daily discipline rating (1 to 5 stars)
    - Awards **+50 XP** per completed reflection
    - Historical reflection timeline archive

11. **Settings & PDF Progress Exporter**
    - Material 3 Dark Mode (terminal-style GitHub aesthetic) & Light Mode
    - Notification preferences toggles
    - Force Cloud Backup (syncs Hive local database with Cloud Firestore)
    - **Export Progress to PDF**: Generates a PDF summary report with KPI cards, category breakdown tables, and recent accomplishments.

---

## 🏗️ Folder Structure (Clean Architecture)

```
discipline_tracker/
├── android/
│   └── app/src/main/AndroidManifest.xml     # Alarm, boot & notification permissions
├── ios/
│   └── Runner/Info.plist                    # iOS notification permissions
├── firestore.rules                          # Cloud Firestore security rules
├── pubspec.yaml                             # Dependencies & asset declarations
├── analysis_options.yaml                    # Dart linter configurations
└── lib/
    ├── app.dart                             # MaterialApp, theme configuration & auth routing
    ├── firebase_options.dart                # Firebase config template
    ├── main.dart                            # App initialization (Hive, Notifications, Firebase, Riverpod)
    │
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart              # Color palettes, GitHub greens & priorities
    │   │   ├── app_strings.dart             # Localized strings & motivational quotes
    │   │   └── app_theme.dart               # Material 3 Dark & Light Theme definitions
    │   ├── services/
    │   │   ├── ai_coach_service.dart        # Behavioral intelligence & coaching rules
    │   │   ├── local_storage_service.dart   # Hive offline cache & preferences
    │   │   ├── notification_service.dart    # flutter_local_notifications & exact scheduling
    │   │   └── pdf_export_service.dart      # PDF progress report generator & printing
    │   ├── utils/
    │   │   ├── date_time_utils.dart         # Date formatting & consecutive streak logic
    │   │   └── gamification_engine.dart     # XP calculations, levels, and badge evaluators
    │   └── widgets/
    │       ├── badge_card.dart              # Achievement badge tile widget
    │       ├── custom_button.dart           # Primary, secondary & outlined buttons with loaders
    │       ├── custom_text_field.dart       # Form inputs with password visibility toggle
    │       ├── empty_state_view.dart        # Friendly empty state illustrations
    │       ├── error_state_view.dart        # Reusable error cards with retry callbacks
    │       ├── loading_indicator.dart       # Modern loading spinner
    │       └── xp_progress_bar.dart         # Level gauge & XP fraction bar
    │
    └── features/
        ├── auth/
        │   ├── data/
        │   │   └── auth_repository.dart     # Firebase Auth & Google Sign-In implementation
        │   ├── presentation/
        │   │   ├── forgot_password_screen.dart
        │   │   ├── login_screen.dart
        │   │   ├── profile_screen.dart
        │   │   └── signup_screen.dart
        │   └── providers/
        │       └── auth_provider.dart       # Auth state notifier & session management
        │
        ├── tasks/
        │   ├── models/
        │   │   ├── task_category.dart       # Category enum (Study, Coding, Gym, etc.)
        │   │   ├── task_model.dart          # Core Task entity with JSON serialization
        │   │   └── task_priority.dart       # Priority enum (Low, Medium, High)
        │   ├── data/
        │   │   └── task_repository.dart     # Offline-first Firestore & Hive sync
        │   ├── presentation/
        │   │   ├── add_edit_task_screen.dart# Task creator & editor dialog
        │   │   ├── task_list_screen.dart    # Daily planner with date strip & filter tabs
        │   │   └── widgets/
        │   │       ├── category_chip.dart
        │   │       └── task_tile.dart
        │   └── providers/
        │       └── task_provider.dart       # Riverpod state notifier for tasks & filters
        │
        ├── heatmap/
        │   ├── models/
        │   │   └── heat_map_entry.dart      # Daily intensity models (0 to 4)
        │   ├── presentation/
        │   │   ├── heatmap_screen.dart      # Yearly & monthly interactive views
        │   │   └── widgets/
        │   │       ├── day_details_sheet.dart # Tap-to-inspect daily task breakdown
        │   │       └── github_heatmap_widget.dart # Custom contribution calendar
        │   └── providers/
        │       └── heatmap_provider.dart    # Aggregates tasks into heatmap matrix
        │
        ├── analytics/
        │   ├── presentation/
        │   │   ├── analytics_screen.dart
        │   │   └── widgets/
        │   │       ├── category_breakdown_card.dart
        │   │       ├── completion_bar_chart.dart
        │   │       └── productivity_score_card.dart
        │   └── providers/
        │       └── analytics_provider.dart  # Computes completion rates & productivity score
        │
        ├── gamification/
        │   ├── models/
        │   │   ├── badge_model.dart
        │   │   └── user_level.dart
        │   ├── presentation/
        │   │   └── gamification_screen.dart # Badges gallery & streak shield inventory
        │   └── providers/
        │       └── gamification_provider.dart
        │
        ├── ai_coach/
        │   ├── presentation/
        │   │   ├── ai_coach_screen.dart     # AI Coach advice hub
        │   │   └── widgets/
        │   │       └── coach_insight_card.dart
        │   └── providers/
        │       └── ai_coach_provider.dart
        │
        ├── reflection/
        │   ├── models/
        │   │   └── reflection_model.dart    # Journal reflection entity
        │   ├── data/
        │   │   └── reflection_repository.dart
        │   ├── presentation/
        │   │   ├── daily_reflection_screen.dart
        │   │   └── reflection_history_screen.dart
        │   └── providers/
        │       └── reflection_provider.dart
        │
        ├── dashboard/
        │   └── presentation/
        │       ├── dashboard_screen.dart    # Today overview, quote, streak flame, heatmap preview
        │       └── main_scaffold.dart       # Persistent bottom navigation bar shell
        │
        └── settings/
            ├── presentation/
            │   └── settings_screen.dart     # Dark mode, reminders, PDF export, backup
            └── providers/
                └── settings_provider.dart
```

---

## 🗄️ Cloud Firestore Database Schema

The database follows a user-scoped subcollection design for isolation, offline caching, and high performance.

### 1. `users/{userId}`
Top-level user profile document.
```json
{
  "uid": "USER_UID_STRING",
  "email": "warrior@discipline.local",
  "displayName": "Alex Mercer",
  "photoUrl": "https://...",
  "totalXp": 1450,
  "level": 7,
  "streakFreezes": 2,
  "currentStreak": 14,
  "longestStreak": 21,
  "createdAt": "2026-09-01T08:00:00.000Z",
  "lastActiveAt": "2026-09-24T07:58:00.000Z"
}
```

### 2. `users/{userId}/tasks/{taskId}`
Subcollection containing user tasks.
```json
{
  "id": "e6f4773c-7c01-4475-8854-5d9c02e1c9db",
  "userId": "USER_UID_STRING",
  "title": "Solve 3 Dynamic Programming problems",
  "description": "LeetCode daily problem and 2 practice graph questions",
  "category": "coding",
  "dueDate": "2026-09-24T00:00:00.000Z",
  "dueHour": 18,
  "dueMinute": 30,
  "priority": "high",
  "isCompleted": true,
  "completedAt": "2026-09-24T17:45:12.000Z",
  "hasReminder": true,
  "createdAt": "2026-09-24T07:00:00.000Z",
  "updatedAt": "2026-09-24T17:45:12.000Z"
}
```
**Index recommendation:**
- Composite index on `userId` (ASC), `dueDate` (ASC) for fast timeline queries.

### 3. `users/{userId}/reflections/{reflectionId}`
Daily evening journal entries.
```json
{
  "id": "93b1d74e-5a02-4ec4-9df2-9b2f281e57c1",
  "userId": "USER_UID_STRING",
  "date": "2026-09-24T21:00:00.000Z",
  "accomplishments": "Completed 100% of high priority tasks and completed intense 45m workout",
  "challenges": "Felt tired after lunch; needed coffee to refocus",
  "tomorrowPlan": "Wake up at 6:30 AM, read 20 pages of Deep Work",
  "rating": 5,
  "createdAt": "2026-09-24T21:15:00.000Z"
}
```

---

## 🔒 Security Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /tasks/{taskId} {
        allow read, write: if isOwner(userId);
      }

      match /reflections/{reflectionId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## 🚀 Firebase Setup Instructions

### Step 1: Install Firebase CLI & FlutterFire
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

### Step 2: Configure Firebase for the App
Run inside `discipline_tracker/`:
```bash
flutterfire configure
```
Select your Firebase project and select platforms: `android`, `ios`, `web`. This automatically links your `google-services.json` and `GoogleService-Info.plist`.

### Step 3: Enable Authentication Providers
In Firebase Console > **Authentication** > **Sign-in method**:
1. Enable **Email/Password**.
2. Enable **Google**.
   - Add your Android SHA-1 fingerprint:
     ```bash
     cd android && ./gradlew signingReport
     ```
   - Copy the SHA-1 to Firebase Project Settings > Android App.

### Step 4: Enable Cloud Firestore
In Firebase Console > **Firestore Database** > **Create database** > choose **Production Mode**. Then deploy the rules:
```bash
firebase deploy --only firestore:rules
```

---

## 📦 How to Build & Run

```bash
# 1. Navigate to the project
cd discipline_tracker

# 2. Get dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run

# 4. Build Release APK
flutter build apk --release

# 5. Build iOS Release
flutter build ipa --release
```

---

## 💡 Offline-First Architecture & Sync

1. Every write operation (`addTask`, `toggleComplete`, `saveReflection`) updates **Hive local storage first**. The UI reacts instantly with zero latency.
2. In the background, changes are committed to Cloud Firestore.
3. If the device is offline or network fails, the user continues uninterrupted. The local cache serves all queries, heatmap generation, streak evaluations, and AI coach analysis.
4. When connectivity restores, manual sync or next app boot syncs local data with the cloud.
