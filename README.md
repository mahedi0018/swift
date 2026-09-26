# TaskFlow

A personal productivity and habit-tracking app for iOS, built with SwiftUI. TaskFlow combines a to-do list with a habit/streak tracker and gamifies both with streak counts, freeze tokens, milestone badges, and a GitHub-style activity heatmap.

<p align="center">
  <b>Tasks</b> · <b>Habits</b> · <b>Streaks</b> · <b>Analytics</b>
</p>

---

## Features

### Authentication
- Email/password sign-up and sign-in via Firebase Auth
- Sign in with Apple
- Password reset email, and change password with re-authentication
- Account deletion with local data cleanup

### Tasks
- Quick-add with title, category, and priority chips
- Four categories (Work, Health, Learning, Personal) and three priority levels
- Swipe-left to delete, tap the circle to complete
- Daily progress ring, progress bar, and "X left" counter

### Habits
- Create habits with a title, one of 17 SF Symbol icons, an accent color, a goal length, and a reminder time
- Toggling completion across a rolling 7-day grid
- Current and longest streak tracking
- **Freeze tokens** — long-press a missed day to spend a token and protect your streak
- Milestone alerts at 7, 30, and 100 days
- 12-week (84-day) activity heatmap on the detail screen
- Local notifications scheduled 30 minutes before each habit's reminder time

### Analytics
- Stat cards: tasks done this month, 30-day habit rate, current streak
- Interactive Swift Charts trend line comparing tasks vs. habit completion
- Three-level drill-down zoom: Week → 7-Month → Month detail (button, tap, or pinch)
- Per-category breakdown bars and best-performing weekday

### Settings
- Light / Dark / System theme, haptic feedback toggle, and a custom accent color picker
- Notification toggles for push, the daily 9:00 AM reminder, and per-habit alerts
- Export your data as JSON via the system share sheet
- Privacy & Security screen with change password, data export, and a two-step account deletion

---

## Tech Stack

| | |
|---|---|
| **UI** | SwiftUI, SwiftUI Charts |
| **State** | Swift Observation (`@Observable`) |
| **Local persistence** | RealmSwift (SPM, `community` branch) |
| **Backend** | Firebase — Auth only (FirebaseCore, FirebaseAuth) |
| **Other frameworks** | AuthenticationServices, UserNotifications, CryptoKit |
| **Concurrency** | `async`/`await` (no Combine) |
| **Language** | Swift 5 |

All task and habit data is stored **locally in Realm** and scoped to the signed-in user's Firebase UID. Firebase is used for identity only — see the in-app Privacy Policy.

---

## Requirements

| | |
|---|---|
| Xcode | 26.3+ |
| iOS | 26.2+ |
| Platforms | iPhone, iPad, visionOS |
| Dependencies | Swift Package Manager (auto-resolved) |

---

## Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/mahedi0018/swift.git
   cd swift
   ```

2. **Open the project**

   ```bash
   open TaskFlow/TaskFlow.xcodeproj
   ```

3. **Add your Firebase config.** `TaskFlow/TaskFlow/GoogleService-Info.plist` is already present, but it is committed to the repository. If you are setting up your own Firebase project, replace it with the file downloaded from the Firebase console.

   The bundle identifier must match the one registered in Firebase — currently `MMH.TaskFlow`. To use a different bundle ID, update it in the target settings and in the Firebase project.

4. **Select a signing team.** Set `DEVELOPMENT_TEAM` on the `TaskFlow` target (currently `T26823HHV8`).

5. **Build and run** (⌘R).

On first launch the app seeds six demo habits with realistic streaks and ~6 months of history, so the charts and heatmaps have data to show. Seeding only runs when the signed-in user has no habits.

> **Security note:** `GoogleService-Info.plist` contains a live API key and is tracked by git. Consider removing it from version control, ignoring it, and keeping a template file instead.

---

## Architecture

A feature-layered MVVM-ish structure. Views hold an `@Observable` view model, which talks to singleton services, which own the Realm instance.

```
TaskFlow/
├── TaskFlowApp.swift        @main — configures Firebase, applies theme
├── RootView.swift           Auth gate: LoginView ⇄ MainTabView
├── MainTabView.swift        Custom tab host, injects safe-area/tab-bar env values
│
├── Modles/                  Realm models + enums (Task, Habit, HabitCompletionLog, Tab)
├── ViewModles/              Observable view models (Task, Habit, Analytics, Settings)
├── Services/                RealmManager, AuthManager, NotificationManager, MockData
├── Utilities/               AppSettings, colors, gradients, chart/heatmap helpers
├── DesignSystem/Modifiers/  card styles, glass card, gradient border, animations
├── Core/Extensisons/        Date helpers (greeting, header date, streak date range)
└── Views/
    ├── Login/               LoginView, SignUpView
    ├── Home/                HomeView, AddTaskView, TaskRow, progress + streak cards
    ├── Habits/              HabitsView, HabitItemView, AddHabitView, detail, heatmap
    ├── Analytics/           AnalyticsView, TrendChartView
    ├── Settings/            SettingsView, PrivacySecurityView, PrivacyPolicyView
    ├── Components/          DailyMotivationBadge
    └── Reusable Component/  CustomTabBarView, HeaderView, CircularProgressView, StatCardView
```

### Data flow

- **`RealmManager`** is a thin generic CRUD wrapper over a single `Realm` instance. It also owns completion logging, freeze application, demo seeding, and uid-scoped queries. It switches to an in-memory Realm automatically when running in Xcode Previews.
- **Reactivity** comes from two sources, used side by side: Realm's `Results.observe` inside view models (`observeTasks()`, `observeHabits()`), and the SwiftUI Realm wrappers `@ObservedRealmObject` / `@ObservedResults` in views.
- **View models** are `@Observable` and own derived state (streak recalculation, heatmap days, chart data, drill-down navigation level).
- **Singleton services** — `AuthManager.shared`, `RealmManager.shared`, `NotificationManager.shared`, `AppSettings.shared`.

### Data models

| Model | Purpose |
|---|---|
| `Task` | Title, completed flag, category, priority, due time, user id |
| `Habit` | Title, SF Symbol, current/longest streak, freeze tokens, goal, weekly completion, color, reminder time, user id |
| `HabitCompletionLog` | One row per habit per day, with completed and frozen flags — the source of truth for streaks and heatmaps |

`Habit` has a one-to-many relationship with `HabitCompletionLog` via `habitId`. Every model carries a `userId` and is always queried filtered by the Firebase UID. Enums (`TaskCategory`, `TaskPriority`, `HabitIcon`, `ThemeMode`, `ChartLevel`) are persisted as raw strings and bridged back through computed properties.

---

## Design System

- **29 semantic colors** in the asset catalog, each with light and dark variants (`accentPrimary`, `bgCard`, `textSecondary`, `categoryWork`, `success`, `danger`, …).
- **Glass cards** — `.glassCardStyle()` layers an `.ultraThinMaterial` base, a translucent tint, and a gradient hairline stroke. Used for most cards in the app.
- **Gradient borders** — `.gradientBorder()` renders a rotating `AngularGradient` stroke, combined with `.spinCustomAnimation()`.
- **Motion** — `.staggeredAppear(index:)` for list entrances, `.shimmerLight()` for sheen sweeps. Both respect Reduce Motion.

---

## Current Status

Working, but a few things are still stubs:

- **No test target.** The GitHub Actions workflow at the repo root is the stock iOS starter template and runs `test-without-building` against a target that has no tests.
- **Sign in with Apple** passes a hard-coded `nonce: "temp-nonce"` — it needs real nonce generation and validation before shipping.
- **Placeholders in Settings**: "TaskFlow Pro", "iCloud Sync", "Export Data", and "Help & Support" rows are static. There is no StoreKit integration and no cloud sync.
- `RealmManager` uses `deleteRealmIfMigrationNeeded: true` with an empty migration block, and force-tries (`try!`) around Realm calls.
- `TaskRow` shows a hard-coded "9:00 AM" instead of the task's stored `dueTime`.
- The habit-alert notification body says "in 10 minutes" but alerts are scheduled 30 minutes early.

## License

Private project. All rights reserved.

## Author

Md. Mahedi Hasan
