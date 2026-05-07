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

**Backend status**: authentication, password reset/change, terrain management, owner reservation listing/detail/refusal, QR check-in, owner profile display/edit/avatar/phone/payout info, dedicated owner dashboard, in-app notifications, revenues/payments, availability, controllers, and PDF reports are connected to the NestJS backend. Chat and tournaments still use mock data or need owner-specific endpoints.

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
- `services/in_app_notification_service.dart` — REST notifications in-app: list, mark read, mark all read
- `services/notification_service.dart` — FCM push shell: permission, token, foreground banner, background handler, tap-to-navigate by notification `type` field
- `widgets/` — Shared `shimmer_loading.dart`, `lottie_success_dialog.dart`

## Key Conventions

- **UI language is French** — all user-facing strings are hardcoded in French (no i18n)
- **Color constants** use `k` prefix: `kBg`, `kGreen`, `kTextPrim`, `kBorder`, etc.
- **Private widget builders** use `_build` prefix (e.g., `_buildPaymentCard()`) or private `_Widget` classes
- **Animations**: Use `flutter_animate` extension syntax: `.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0)`
- **Mock data** still lives in some controller `_loadMock...()` methods — replace module by module with service calls
- **Fonts**: Orbitron for titles/headings, DMSans for body text
- **Border radius**: 14px for inputs/buttons, 18px for cards
- **Payment methods**: Wave (blue `#00B0F0`), Orange Money (orange `#FF6D00`), Yas Money (gold `#FFD100`) — logos in `assets/images/`
- **PDF reports**: use built-in `pdf` fonts for generation; do not rely on the local `DMSans-Variable.ttf` asset unless it has been replaced with a real TTF file.

## Important Gotchas

- `NotificationService.init()` runs before `runApp()` — navigation from `getInitialMessage` is delayed 800ms via `Future.delayed` to wait for GetMaterialApp mount
- `table_calendar` requires `initializeDateFormatting('fr_FR', null)` in `main()` or it throws `LocaleDataException`
- Never use `shrinkWrap: true` + `NeverScrollableScrollPhysics()` on a GridView/ListView inside `Expanded` — causes massive overflow
- `.env` file contains a Mapbox token and is bundled as a Flutter asset

## Feature Status

**Connected**: auth flow (splash→onboarding→login→register→OTP), forgot/reset password, profile password change, profile avatar upload/display, phone change via OTP, owner payout info, terrain list/form CRUD, terrain image upload, terrain image display via storage proxy, Mapbox preview/geolocation in the terrain form, owner reservation list/detail/refusal, QR check-in, profile display and first/last name update, availability, dedicated `GET /owner/dashboard`, in-app notifications, revenues, payments, controllers, and PDF reports.

**Complete UI but still mock/partial**: FCM push registration, chat list, tournaments.

**Next backend task**: FCM token registration, chat owner, or tournaments.
