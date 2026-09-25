<div align="center">

  <h1>⚡ Discipline Tracker</h1>
  <p><strong>Forge Unwavering Consistency, Defend Your Streaks & Master Your Productivity</strong></p>

  <p>
    An offline-first, production-grade productivity mobile application built with <strong>Flutter</strong>, <strong>Riverpod 2.x</strong>, <strong>Firebase</strong>, and <strong>Hive</strong> following Clean Architecture.
  </p>

  <!-- Badges -->
  <p>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white&style=for-the-badge" alt="Flutter"></a>
    <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white&style=for-the-badge" alt="Dart"></a>
    <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State-Riverpod_2.x-blueviolet?style=for-the-badge" alt="Riverpod"></a>
    <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black&style=for-the-badge" alt="Firebase"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License: MIT"></a>
    <a href="https://github.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge" alt="PRs Welcome"></a>
  </p>

  <h4>
    <a href="#-key-features">Features</a> •
    <a href="#-architecture--tech-stack">Architecture</a> •
    <a href="#-quick-start">Quick Start</a> •
    <a href="#-roadmap">Roadmap</a> •
    <a href="#-contributing">Contributing</a>
  </h4>

</div>

---

## 💡 Why Discipline Tracker?

> *"Motivation gets you going, but discipline keeps you growing."*

Most habit trackers feel like boring spreadsheets. **Discipline Tracker** transforms routine building into an engaging, visual, and intelligent experience:
- 🟩 **Visual GitHub Heatmap:** See your consistency in real-time just like your GitHub commit activity.
- 🤖 **AI Behavioral Coach:** Identifies your peak focus hours (morning focus vs. night owl) and warns you before missed habits break your momentum.
- ⚡ **Offline-First & Lightning Fast:** Sub-millisecond local reads powered by Hive DB with automatic cloud backup to Firestore.
- 🛡️ **Streak Freeze Protection:** Real life happens—safeguard your streak tokens so a single emergency doesn't reset your hard-earned progress.

---

## 📱 App Highlights & UI Showcase

| 🗓️ Task Planner & Heatmap | 🤖 AI Behavioral Coach | 📊 Analytics & Badges |
| :---: | :---: | :---: |
| *(Add your screenshot here)* | *(Add your screenshot here)* | *(Add your screenshot here)* |

> 💡 **Tip:** Replace the placeholders above with screenshots or a 10-second demo GIF of your app!

---

## ✨ Key Features

### 1. 🗓️ Daily Planner & Task Engine
- **6 Core Productivity Domains:** `Coding`, `Study`, `Gym`, `Reading`, `Work`, and `Personal`.
- **Priority Matrix:** Low (+15 XP), Medium (+25 XP), High (+40 XP) with distinct color accents.
- **Instant Optimistic Toggles:** Haptic feedback, sound cues, and instantaneous offline persistence.
- **Smart Date Strip:** One-tap navigation between daily schedules with real-time completion progress rings.

### 2. 🟩 Interactive GitHub-Style Heatmap
- **Consistency Matrix:** 5 color intensity tiers (Level 0 through 4) based on daily task completion percentages.
- **Yearly & Monthly Views:** 52-week horizontal scroll view to visualize whole-year dedication.
- **Drilldown Inspection:** Tap any cell to view tasks completed and missed on that specific date.
- **30-Day Discipline Index:** Mathematically scores consistency over rolling 30-day windows.

### 3. 🤖 AI Behavioral Coach & Diagnostics
- **Pattern Detection:** Evaluates drop-off categories (e.g. *"You missed coding tasks 3 times this week"*).
- **Golden Focus Window:** Discovers when your cognitive energy is highest (Morning 8:00 AM – 11:30 AM vs. Evening Night Owl).
- **Actionable Micro-Tips:** Practical psychological nudges to eliminate friction.

### 4. 🏆 Gamification & Progression
- **XP Engine:** Earn XP based on task priority, daily reflection, and streak multipliers (up to +50% bonus).
- **Tiered Level Ranks:** Novice → Apprentice → Consistent → Iron Will → Discipline Master.
- **Milestone Badges:** Unlock badges for streaks (7-Day Week Warrior, 30-Day Habit Master, 100 Centurion).

### 5. 📖 Daily Reflection Journal & PDF Progress Report
- **Evening 3-Question Guided Journal:** Celebrate wins, diagnose obstacles, and set tomorrow's non-negotiables.
- **One-Tap PDF Export:** Generates clean, professional PDF progress reports ready for printing or sharing.

---

## 🏗️ Architecture & Tech Stack

The project strictly follows **Clean Architecture** with a feature-first folder organization:

```
lib/
├── app.dart                    # App initialization, MaterialApp & theme routing
├── main.dart                   # Service bootstrap (Hive, Firebase, Notifications)
│
├── core/                       # Shared modules across features
│   ├── constants/              # AppColors, AppStrings, AppTheme
│   ├── services/               # AI Coach, Notification, Hive Cache, PDF Export
│   ├── utils/                  # DateTime utilities, Gamification XP engine
│   └── widgets/                # Reusable UI components (Buttons, Inputs, Badges)
│
└── features/                   # Independent feature slices
    ├── auth/                   # Firebase Auth, Google Sign-in & profile
    ├── tasks/                  # Task CRUD, Priority matrix, Hive repos
    ├── heatmap/                # GitHub-style activity grid & 30-day index
    ├── ai_coach/               # Behavioral analytics & insight cards
    ├── analytics/              # Productivity gauge & FL Chart trends
    ├── gamification/           # Badges, XP levels & streak freeze
    ├── reflection/             # Evening journal entries & star ratings
    └── settings/               # Dark/Light theme, backup sync & PDF exporter
```

### 🧰 Dependencies & Tools
- **Framework:** [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management:** [Riverpod 2.x](https://riverpod.dev)
- **Local Storage:** [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter)
- **Cloud Backend:** [Firebase Core](https://firebase.google.com), [Cloud Firestore](https://firebase.google.com/docs/firestore), [Firebase Auth](https://firebase.google.com/docs/auth)
- **Charts & Graphs:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Reporting:** [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing)

---

## 🚀 Quick Start

Get the app running locally in less than 3 minutes:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.10.0)
- Git installed

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/baadaldev/To-Do-App-For-Me.git
   cd To-Do-App-For-Me
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   # Launch on Chrome / Web
   flutter run -d chrome

   # Launch on Android / iOS Simulator
   flutter run
   ```

---

## 🗺️ Roadmap

- [x] Complete daily task planner with categories and priorities
- [x] GitHub-style contribution heatmap with year & month views
- [x] Rule-based AI behavioral coach engine
- [x] Gamification, XP multiplier, and Streak Badges
- [x] Daily Evening Reflection journal
- [x] PDF summary export & printing
- [ ] Direct Google Gemini AI Live Coach integration
- [ ] Home screen interactive widgets (iOS & Android)
- [ ] Habit sound effects & haptic feedback customization
- [ ] Social Leaderboard & friend accountability circles

---

## 🤝 Contributing

Contributions make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**!

Check out our [Contributing Guidelines](CONTRIBUTING.md) to get started.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

---

<div align="center">

  ### ⭐ Support the Project

  If you find this project helpful or inspiring, please consider giving it a **Star**!  
  It helps the project gain visibility and motivates ongoing improvements.

  <a href="https://github.com/baadaldev/To-Do-App-For-Me">
    <img src="https://img.shields.io/github/stars/baadaldev/To-Do-App-For-Me?style=social" alt="GitHub Stars">
  </a>

</div>
