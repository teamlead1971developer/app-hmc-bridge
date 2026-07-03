# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

This is a Flutter project scaffolded with `flutter create` and not yet customized — `lib/main.dart` is still the default counter-app template, and `test/widget_test.dart` is the default smoke test. There is no custom architecture, routing, state management, or backend integration yet. Bundle/application IDs are still the default `com.example.app_hmc_bridge` placeholders (`android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`) — update these before shipping.

Targets configured: Android, iOS, Linux, macOS, Web, Windows (all under their respective platform directories at the repo root).

- Dart SDK constraint: `^3.12.2` (see `pubspec.yaml`)
- Lint rules: `package:flutter_lints/flutter.yaml` via `analysis_options.yaml` (defaults, unmodified)

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
