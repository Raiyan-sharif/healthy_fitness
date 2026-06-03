# Healthy Fitness

A Flutter fitness app with daily goals, quick workouts, trainer live-session modes, and real-time step tracking from the device pedometer.

## Features

- **Home dashboard** — Today’s goal, quick workout cards, and progress overview
- **Live training modes** (UI)
  - **1:1 personal session** — Trainer and one student in a private live session
  - **Group live class** — Trainer goes live and teaches all students in parallel
- **Real-time steps** — Device sensor stream with a daily baseline so today’s count starts at 0 and updates as you walk
- **Daily step goal** — Default target of 8,000 steps with progress bar

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.9+)
- A **physical phone** for reliable step counting (emulators often lack a real pedometer)

## Getting started

```bash
git clone <your-repo-url>
cd healthy_fitness
flutter pub get
flutter run
```

Run tests and static analysis:

```bash
flutter test
flutter analyze
```

## Step tracking

The app uses the `pedometer` package to read the system step counter. Raw sensor values are cumulative; the app stores a **baseline** per calendar day (via `shared_preferences`) and shows:

`today’s steps = current sensor steps − baseline`

The baseline is set on the first reading each day and resets automatically when the date changes.

### Permissions

| Platform | Permission / usage |
|----------|-------------------|
| Android | `ACTIVITY_RECOGNITION` (requested at runtime) |
| iOS | Motion & Fitness (`NSMotionUsageDescription` in `Info.plist`) |

Grant activity/motion access when prompted. Walk a short distance on a real device if the count does not move immediately.

## Project structure

```
lib/
  main.dart          # App entry, home UI, step tracking logic
test/
  widget_test.dart   # Widget smoke tests
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `pedometer` | Live step count stream |
| `permission_handler` | Android activity recognition |
| `shared_preferences` | Daily step baseline persistence |

## Platforms

Generated Flutter targets: **Android**, **iOS**, **macOS**, **Web**, **Windows**, **Linux**. Step tracking is intended for mobile (Android/iOS).

## Roadmap (planned)

- Live session flows (create/join room, 1:1 vs group)
- Login and user roles (trainer / student)
- Workout history, calories, and background step sync

## License

Private project (`publish_to: 'none'`). Add a license file if you open-source the repo.
