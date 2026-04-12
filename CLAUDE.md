# mini_foot_OWNER_APP — App Flutter (propriétaire)

Application Flutter pour les propriétaires de terrains de mini-football.

## Stack
- Flutter SDK / Dart
- Architecture : `lib/core/` + `lib/features/` + `lib/routes/`

## Structure
```
lib/
  core/          # Config, thème, services partagés, réseau
  features/      # Un dossier par feature (screens/ widgets/ services/ models/)
  routes/        # Navigation/routing
  main.dart
```

## Règles
Mêmes règles que `minifoot_mobile/CLAUDE.md` pour :
- Logging (package `logger`, pas de `print`)
- Exceptions (un seul niveau de try-catch)
- Architecture (écrans vs services vs modèles)
- Design Material 3
- Sécurité (secure_storage, obfuscation)
- Performance (const, ListView.builder, cached_network_image)

## Architecture features
```
features/
  dashboard/
    screens/   dashboard_screen.dart
    widgets/   stats_card.dart
    models/    dashboard_stats.dart
    services/  dashboard_service.dart
  bookings/
    ...
  revenue/
    ...
```

## Git — commits activés
Utiliser `/commit` ou `/commit-push-pr` pour les commits.
