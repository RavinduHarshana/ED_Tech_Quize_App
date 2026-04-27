# quize_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# TSHS Quiz App — Flutter Clean Architecture

A full-featured quiz application built with **Flutter**, **BLoC**, **SQLite (sqflite)**, and **Clean Architecture** principles.

---

## Features

- **Authentication** — Register, Login, Logout with hashed passwords (SHA-256)
- **SQLite Database** — All data persisted locally using sqflite
- **Quiz Engine** — Per-subject quizzes with animated question transitions
- **Dashboard** — Live stats: quizzes done, avg score, best score, total correct
- **Favorites** — Toggle subjects as favourites, persisted per user
- **Profile** — Edit name, change password, XP & trophy tracking
- **BLoC State Management** — AuthBloc, QuizBloc, SubjectBloc, DashboardBloc
- **Dependency Injection** — get_it service locator
- **Session Persistence** — shared_preferences keeps user logged in between launches

---

## Project Structure

```
lib/
├── main.dart                          # Entry point, MultiBlocProvider
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # All app colours
│   │   ├── app_theme.dart             # ThemeData
│   │   └── app_constants.dart         # DB name, table names, routes
│   ├── database/
│   │   └── database_helper.dart       # Singleton SQLite helper + seed data
│   ├── di/
│   │   └── injection.dart             # get_it registrations
│   ├── errors/
│   │   └── failures.dart              # Failure sealed classes
│   └── utils/
│       ├── hash_util.dart             # SHA-256 password hashing
│       └── validators.dart            # Form field validators
│
├── domain/                            # Pure Dart — no Flutter imports
│   ├── entities/
│   │   ├── user_entity.dart
│   │   ├── subject_entity.dart
│   │   ├── question_entity.dart
│   │   └── quiz_result_entity.dart
│   ├── repositories/
│   │   └── repositories.dart          # Abstract interfaces
│   └── usecases/
│       └── usecases.dart              # All use-case classes
│
├── data/
│   ├── models/
│   │   └── models.dart                # DB ↔ Entity mappers (fromMap/toMap)
│   ├── datasources/
│   │   └── local_datasource.dart      # SQLite + SharedPrefs operations
│   └── repositories/
│       └── repositories_impl.dart     # Concrete repository implementations
│
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart             # AuthEvent / AuthState / AuthBloc
    │   ├── quiz_bloc.dart             # QuizEvent / QuizState / QuizBloc
    │   ├── subject_bloc.dart          # SubjectEvent / SubjectState / SubjectBloc
    │   └── dashboard_bloc.dart        # DashboardEvent / DashboardState / DashboardBloc
    ├── pages/
    │   ├── splash_screen.dart         # Animated splash + auto auth check
    │   ├── auth/
    │   │   ├── login_page.dart
    │   │   └── register_page.dart
    │   ├── home/
    │   │   ├── main_shell.dart        # Bottom nav shell (IndexedStack)
    │   │   ├── home_screen.dart
    │   │   └── subjects_screen.dart
    │   ├── quiz/
    │   │   ├── quiz_screen.dart       # Animated quiz with slide transition
    │   │   └── result_screen.dart     # Score + XP reward screen
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── favorites/
    │   │   └── favorites_screen.dart
    │   └── profile/
    │       └── profile_screen.dart
    └── widgets/
        ├── subject_tile.dart          # Reusable subject card
        └── common_widgets.dart        # LoadingOverlay, EmptyState, GradientButton, ScoreBadge
```

---

## Database Schema

### `users`
| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Display name |
| email | TEXT UNIQUE | Lowercase stored |
| password_hash | TEXT | SHA-256 |
| avatar_path | TEXT | Nullable |
| xp_points | INTEGER | Default 0 |
| trophy_count | INTEGER | Default 0 |
| created_at | TEXT | ISO-8601 |

### `subjects`
| Column | Type |
|---|---|
| id | INTEGER PK |
| name | TEXT UNIQUE |
| icon | TEXT |
| total_questions | INTEGER |
| color_hex | TEXT |

### `questions`
| Column | Type |
|---|---|
| id | INTEGER PK |
| subject_id | INTEGER FK |
| text | TEXT |
| option_a/b/c/d | TEXT |
| correct_index | INTEGER (0–3) |

### `quiz_results`
| Column | Type |
|---|---|
| id | INTEGER PK |
| user_id | INTEGER FK |
| subject_id | INTEGER FK |
| subject_name | TEXT |
| correct | INTEGER |
| total | INTEGER |
| score_pct | INTEGER |
| taken_at | TEXT |

### `favorites`
| Column | Type |
|---|---|
| id | INTEGER PK |
| user_id | INTEGER FK |
| subject_id | INTEGER FK |
| UNIQUE(user_id, subject_id) | — |

---

## Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter plugin

### Steps

```bash
# 1. Clone or copy the project
cd tshs_quiz

# 2. Install dependencies
flutter pub get

# 3. Run on a device or emulator
flutter run

# 4. Build a release APK
flutter build apk --release
```

> The SQLite database is created and seeded automatically on first launch. No external server or setup required.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_bloc | ^8.1.4 | BLoC state management |
| equatable | ^2.0.5 | Value equality for states/events |
| sqflite | ^2.3.2 | SQLite local database |
| path | ^1.9.0 | DB file path resolution |
| get_it | ^7.6.7 | Dependency injection |
| crypto | ^3.0.3 | SHA-256 password hashing |
| shared_preferences | ^2.2.2 | Session persistence |

---

## Architecture Overview

```
UI (Widgets)
    │  dispatches Events
    ▼
BLoC Layer
    │  calls Use Cases
    ▼
Domain Layer  (Entities + Use Cases + Repository Interfaces)
    │  implemented by
    ▼
Data Layer  (Models + DataSources + Repository Implementations)
    │  reads/writes
    ▼
SQLite / SharedPreferences
```

**Key rules:**
- Domain layer has **zero Flutter/package dependencies** — pure Dart only
- BLoCs receive use cases via constructor injection (get_it)
- Repositories return `(Result?, Failure?)` record tuples — no exceptions leak upward
- Every BLoC state is immutable and extends `Equatable`

---

## Seeded Data

On first launch the database is seeded with **6 subjects** and **27 questions**:

| Subject | Questions |
|---|---|
| Biology | 9 |
| Mathematics | 4 |
| Foreign Language | 3 |
| History | 4 |
| Physics | 4 |
| Chemistry | 3 |

---

## Adding Questions

Insert rows into the `questions` table with the correct `subject_id`:

```dart
// In database_helper.dart → _seedQuestions()
{'subject_id': 1, 'text': 'Your question?',
 'option_a': 'A', 'option_b': 'B', 'option_c': 'C', 'option_d': 'D',
 'correct_index': 0},  // 0=A, 1=B, 2=C, 3=D
```

Or at runtime via `DatabaseHelper().insert(AppConstants.questionsTable, {...})`.