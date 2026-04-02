# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter clean && flutter pub get  # Full reset
```

No tests are configured. No linting beyond `flutter_lints`.

## What This App Is

MiniFoot Owner is a Flutter mobile app for **mini-football pitch owners in Senegal**. It lets owners manage pitches, bookings, availability slots, payments, revenues, notifications, and chat. Built by ELECTRONS TEAM (developer: Mamadou Sy).

**There is no backend yet** — all data is mock data hardcoded in controllers. The UI is fully built.

## Architecture

**GetX** is used for everything: state management (`.obs` + `Obx`), navigation (`Get.toNamed`), dependency injection (`Get.lazyPut` in bindings).

Each feature follows this structure:
```
features/<name>/
  bindings/<name>_binding.dart   # Get.lazyPut the controller
  controllers/<name>_controller.dart  # Business logic + mock data
  screens/<name>_screen.dart     # UI widgets
```

**Entry point**: `main.dart` initializes Firebase, loads `.env` (Mapbox token), sets up French locale (`fr_FR`) for `table_calendar`, and inits FCM via `NotificationService`.

**Routing**: All routes defined in `lib/routes/app_routes.dart` as `GetPage` entries with custom transitions. Routes class has static string constants.

**Core layer** (`lib/core/`):
- `theme/app_theme.dart` — All color constants (`kBg`, `kGreen`, `kGold`, etc.), shadows, gradients, and `ThemeData`
- `services/notification_service.dart` — FCM push: permission, token, foreground banner, background handler, tap-to-navigate by notification `type` field
- `widgets/` — Shared `shimmer_loading.dart`, `lottie_success_dialog.dart`

## Key Conventions

- **UI language is French** — all user-facing strings are hardcoded in French (no i18n)
- **Color constants** use `k` prefix: `kBg`, `kGreen`, `kTextPrim`, `kBorder`, etc.
- **Private widget builders** use `_build` prefix (e.g., `_buildPaymentCard()`) or private `_Widget` classes
- **Animations**: Use `flutter_animate` extension syntax: `.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0)`
- **Mock data** lives in controller `_loadMock...()` methods — replace these with API calls when backend is ready
- **Fonts**: Orbitron for titles/headings, DMSans for body text
- **Border radius**: 14px for inputs/buttons, 18px for cards
- **Payment methods**: Wave (blue `#00B0F0`), Orange Money (orange `#FF6D00`), Yas Money (gold `#FFD100`) — logos in `assets/images/`

## Important Gotchas

- `NotificationService.init()` runs before `runApp()` — navigation from `getInitialMessage` is delayed 800ms via `Future.delayed` to wait for GetMaterialApp mount
- `table_calendar` requires `initializeDateFormatting('fr_FR', null)` in `main()` or it throws `LocaleDataException`
- Never use `shrinkWrap: true` + `NeverScrollableScrollPhysics()` on a GridView/ListView inside `Expanded` — causes massive overflow
- `.env` file contains a Mapbox token and is bundled as a Flutter asset

## Feature Status

**Complete UI (mock data)**: auth flow (splash→onboarding→login→register→OTP), dashboard, terrain list/form, reservations, availability (calendar+slots+swipe+long-press), payments (grouped transactions+method breakdown+detail sheets), notifications (list+FCM push), profile (SliverAppBar+edit+security+payment methods), revenues, chat list

**Not yet implemented**: reports (PDF generation — `pdf`/`printing` packages already installed), real backend/API, real auth, real payment integration, real-time chat, map-based terrain views (`flutter_map` installed)
