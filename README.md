# Child Safety Monitor

A privacy-first, serverless Flutter application designed to monitor child digital safety using intelligent, rule-based risk assessment.

## Key Features
- **Local SQLite Storage:** Uses Drift for high-performance offline data persistence.
- **Dart Risk Engine:** Rule-based algorithm based on screen time, contacts, and temporal factors.
- **Interactive Dashboard:** Beautiful visualizations using `fl_chart`.
- **Cross-Platform:** Single codebase for Web, Android, and iOS.

## Setup Instructions
1.  Ensure Flutter is installed.
2.  Run `flutter pub get`.
3.  Generate database boilerplate:
    `dart run build_runner build --delete-conflicting-outputs`
4.  Run the app: `flutter run -d chrome` (for Web).

## Tech Stack
- **UI:** Flutter Material 3
- **State Management:** Riverpod
- **Database:** Drift (SQLite)
- **Logic:** Custom Dart Risk Engine