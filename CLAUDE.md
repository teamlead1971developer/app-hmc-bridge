# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

This is a Flutter project scaffolded with `flutter create`, still running the default counter-app demo (no real features yet). No routing, state management, or backend integration. Bundle/application IDs are still the default `com.example.app_hmc_bridge` placeholders (`android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`) — update these before shipping.

Targets configured: Android, iOS, Linux, macOS, Web, Windows (all under their respective platform directories at the repo root).

- Dart SDK constraint: `^3.12.2` (see `pubspec.yaml`)
- Lint rules: `package:flutter_lints/flutter.yaml` via `analysis_options.yaml` (defaults, unmodified)

## Architecture

`lib/` is organized by layer, not strict MVC — Flutter's `State` classes already fuse View+Controller, so there's no separate `controllers/`:

- `lib/main.dart` — entry point; holds `MyApp` (root `MaterialApp`/theme) only
- `lib/screens/` — top-level page widgets (one `Scaffold` per screen)
- `lib/widgets/` — reusable UI pieces shared across screens (create when the first one is needed)
- `lib/models/` — plain data classes
- `lib/services/` — API/DB calls, acts as the "controller" layer for data

`widgets/`, `models/`, `services/` are pre-created but empty (each has a `README.md` stating its purpose, kept in git as a placeholder) — drop new files straight in, no need to scaffold the folder itself. Dependency direction: `screens/` → `services/`/`models/`/`widgets/`, never the reverse.

## Commands

```bash
flutter pub get                        # install dependencies (run after any pubspec.yaml change)
flutter run                            # run on a connected device/simulator/emulator
flutter run -d chrome                  # run in a browser
flutter run -d macos                   # run as a native macOS app (or -d linux / -d windows)

flutter analyze                        # static analysis / lint check
flutter test                           # run all tests
flutter test test/widget_test.dart     # run a single test file
flutter test --plain-name "Counter increments smoke test"   # run a single test by name

flutter build apk                      # Android build
flutter build ios                      # iOS build
flutter build web                      # Web build
```

There is currently only one test file (`test/widget_test.dart`), and it exercises the default counter app in `lib/main.dart`.

## Target architecture (reference only — not yet implemented)

The user has stated a preferred stack/conventions for when real feature work starts. None of this exists in the codebase yet (no Riverpod/Dio/GoRouter/Freezed in `pubspec.yaml`) — do not assume it's in place, and do not scaffold it preemptively. Treat this as the plan to follow once that work begins:

- Feature-first structure: each feature in `lib/features/<name>/`, with a barrel export via `feature.dart` in the feature root
- State management: Riverpod with `@riverpod` code generation (`AsyncNotifier` pattern)
- HTTP: Dio, with interceptors in `lib/core/network/`
- Navigation: GoRouter, named routes defined in `lib/core/router/`
- Models: Freezed + JsonSerializable — run `dart run build_runner build --delete-conflicting-outputs` after any model change
- Conventions: monetary amounts stored as `int` in the smallest unit (e.g. kobo for NGN), never `double`; use `ref.invalidate()` not `ref.refresh()`; no business logic in widgets (goes in notifiers/repositories); one public widget per file, private widgets prefixed with `_`; API calls only through the repository layer, never directly in notifiers
- Do not add new packages without asking first; do not hand-edit `*.g.dart` or `*.freezed.dart` — regenerate with build_runner instead
