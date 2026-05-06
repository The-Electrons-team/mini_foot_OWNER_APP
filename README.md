# MiniFoot Owner App

Application Flutter destinée aux propriétaires de terrains MiniFoot.

## Commandes

```bash
flutter pub get
flutter run
flutter clean && flutter pub get
flutter analyze
```

## Configuration

Le fichier `.env` doit contenir :

```env
API_URL=http://localhost:3000/api/v1
MAPBOX_ACCESS_TOKEN=...
```

## Statut fonctionnel

| Module | Statut |
|---|---|
| Authentification | Connecté au backend |
| Gestion des terrains | Connecté au backend |
| Photos terrain | Upload + affichage via proxy storage |
| Localisation terrain | Mapbox + coordonnées `lat` / `lng` |
| Réservations owner | Liste + détail + refus connectés |
| Profil propriétaire | Profil épuré + photo, édition prénom/nom, téléphone OTP et mot de passe connectés |
| Mot de passe oublié | OTP + réinitialisation depuis l'écran login |
| Disponibilités | Créneaux réels + blocage/déblocage connectés |
| Dashboard | Stats, revenus, graphique et réservations récentes via endpoint dédié |
| Revenus / paiements | Transactions, reversements, totaux, filtres et graphiques connectés |
| Notifications in-app | Liste réelle, compteur non lu, lecture individuelle et tout lire |
| Rapports PDF | Revenus + réservations générés depuis les données réelles, avec aperçu/impression/partage |

## Terrains

Le module terrains utilise `lib/core/services/terrain_service.dart` :

- `GET /terrains/mine`
- `POST /terrains`
- `PATCH /terrains/:id`
- `DELETE /terrains/:id`
- `POST /terrains/:id/images`
- `GET /storage/terrains/*` pour les images locales MinIO/R2

La liste affiche les vrais terrains du propriétaire connecté, le prix réel par heure, les photos, les filtres de statut et la recherche locale.

## Disponibilités

L'écran disponibilités utilise les terrains du propriétaire connecté :

- `GET /terrains/:id/slots?date=YYYY-MM-DD`
- `POST /terrains/:id/slots/block`
- `DELETE /terrains/:id/slots/block`

Les créneaux réservés ne peuvent pas être bloqués/débloqués depuis l'app owner. Les actions de blocage en lot attendent les réponses API et gardent l'interface synchronisée.

## Dashboard

Le dashboard utilise `lib/core/services/dashboard_service.dart` et consomme :

- `GET /owner/dashboard`

L'agrégation est faite côté backend : revenus confirmés, réservations du jour, taux d'occupation du jour, graphiques semaine/mois, stats terrains et réservations récentes.
Le badge notifications du dashboard utilise le compteur non lu renvoyé par `GET /owner/dashboard`.

Le bouton ballon du dashboard ouvre maintenant un scanner QR de check-in. Le backend vérifie que la réservation appartient bien à un terrain du propriétaire, qu'elle est confirmée par paiement, puis enregistre la présence via un check-in séparé du `status` principal.

La liste des réservations ouvre maintenant une page détail dédiée, plus lisible sur mobile, avec statut, client, paiement, terrain, référence et état de check-in.

## Notifications

L'écran notifications utilise `lib/core/services/in_app_notification_service.dart` :

- `GET /notifications`
- `PATCH /notifications/:id/read`
- `PATCH /notifications/read-all`

Les notifications in-app sont créées côté backend quand une réservation owner est confirmée par paiement ou annulée. Les push FCM restent préparés dans `NotificationService`, mais leur validation iOS réelle dépend d'un compte Apple Developer payant.

## Revenus / Paiements

Les écrans revenus et paiements utilisent `lib/core/services/revenue_service.dart`, construit depuis `GET /reservations/owner/mine`.

- Paiements : historique réel, destination de reversement, filtres par statut, période jour/semaine/mois, répartition par méthode.
- Revenus : graphiques journalier/hebdo/mensuel, KPI, taux d'occupation et classement par terrain.

## Rapports PDF

L'écran `ReportScreen` génère deux rapports avec aperçu, impression et partage :

- Rapport revenus : accessible depuis l'écran revenus, basé sur `RevenueService`.
- Rapport réservations : accessible depuis l'écran réservations, basé sur `GET /reservations/owner/mine`.

Les PDF utilisent le vrai propriétaire connecté, les vrais paiements/réservations et des observations calculées sans données fictives.
La génération utilise les polices PDF intégrées pour éviter les erreurs liées aux assets de police locaux, et les erreurs sont journalisées clairement côté Flutter.

## Profil

Le profil propriétaire reste volontairement simple : identité, téléphone en lecture seule, date d'inscription, stats et actions utiles.

- `GET /users/me` pour l'affichage
- `PATCH /users/me` pour modifier prénom/nom
- `POST /users/me/avatar` pour envoyer la photo de profil
- `PATCH /users/me/password` pour changer le mot de passe connecté
- `POST /users/me/phone/request` puis `PATCH /users/me/phone/confirm` pour changer le téléphone avec OTP
- `GET/PATCH /users/me/payout-info` pour les coordonnées Wave, Orange Money et Yas Money

La photo se modifie depuis l'avatar de la carte profil, avec choix caméra ou galerie. Le changement de mot de passe et les coordonnées de reversement sont accessibles depuis la carte informations. Le téléphone se modifie depuis l'écran édition avec un OTP envoyé au nouveau numéro.
Les champs de formulaires sensibles désactivent la sélection interactive pour éviter le crash Flutter `RenderEditable.selectWord` au long appui.

## Mot de passe oublié

L'écran login affiche un lien `Mot de passe oublié ?` :

- `POST /auth/forgot-password` envoie un OTP au numéro existant.
- `POST /auth/reset-password` valide l'OTP et définit le nouveau mot de passe.

## Prochaine tâche

Prochaine amélioration logique :

- Créer une vraie page détail réservation owner.
