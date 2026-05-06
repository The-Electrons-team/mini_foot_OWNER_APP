# PROGRESSION — Connexion Owner App ↔ Backend

Fichier de suivi pour l'app propriétaires de terrains MiniFoot.
L'UI est **entièrement construite**. L'authentification, la gestion des terrains, les réservations owner, le profil, le changement/réinitialisation de mot de passe, les disponibilités, le dashboard, les revenus/paiements et les rapports PDF sont maintenant connectés au backend NestJS ; les autres modules restent à brancher progressivement.

**Légende :**
- ✅ CONNECTÉ — données réelles depuis le backend
- 🔧 PARTIEL — partiellement connecté, il reste des choses à faire
- ❌ MOCK — données entièrement fausses, hardcodées dans le contrôleur
- ⏳ À FAIRE — planifié mais pas encore commencé

---

## 🚨 BUGS CRITIQUES À CORRIGER EN PRIORITÉ

| # | Bug | Fichiers concernés | Ticket ClickUp | État |
|---|-----|--------------------|----------------|------|
| 1 | **Service layer partiel** — auth + terrains connectés, autres modules encore mock | `core/services/` + controllers métier | [86c9gz7dn](https://app.clickup.com/t/86c9gz7dn) | 🔧 En cours |
| 2 | **RolesGuard manquant** côté backend — endpoints owner sans vérification de rôle | `minifoot_backend/src/modules/auth/guards/` | [86c9gz7e1](https://app.clickup.com/t/86c9gz7e1) | ❌ À faire |
| 3 | ~~`getProfile()` appelait `/auth/profile` au lieu de `/users/me`~~ | `core/services/auth_service.dart` | — | ✅ Corrigé 27/04 |

**Ce qu'il faut créer pour avancer :**
- Services métier restants : `revenue_service.dart`, `payment_service.dart`, etc.
- Endpoints backend owner dédiés aux revenus/transactions si on veut éviter l'agrégation côté Flutter.

---

## 1. AUTHENTIFICATION

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Splash → auto-login | ✅ CONNECTÉ | `auth/screens/splash_screen.dart` + `auth/controllers/auth_controller.dart` | `GET /users/me` |
| Login (téléphone + mot de passe) | ✅ CONNECTÉ | `auth/screens/login_screen.dart` | `POST /auth/login` |
| Inscription étape 1 (numéro) | ✅ CONNECTÉ | `auth/screens/register_screen.dart` | `POST /auth/signup` |
| Vérification OTP | ✅ CONNECTÉ | `auth/screens/otp_screen.dart` | `POST /auth/verify-otp` |
| Inscription étape 2 (nom, prénom, mot de passe) | ✅ CONNECTÉ | `auth/screens/otp_screen.dart` → `auth_controller.verifyAndRegister()` | `POST /auth/register` |
| Mot de passe oublié | ✅ CONNECTÉ | `auth/screens/login_screen.dart` + `auth_controller.resetForgottenPassword()` | `POST /auth/forgot-password` + `POST /auth/reset-password` |
| Déconnexion | ✅ CONNECTÉ | `profile/screens/profile_screen.dart` | (local — supprime token SharedPreferences) |

**Note :** Bug corrigé le 27/04/2026 — `getProfile()` appelait `/auth/profile` (inexistant) au lieu de `/users/me`.
Le backend n'a pas de système de rôles (pas d'enum `UserRole` dans Prisma), donc pas besoin de passer `role: OWNER`.
Le reset de mot de passe réutilise l'OTP Redis existant, valable 5 minutes.

**Ticket ClickUp :** [86c9gz7gj](https://app.clickup.com/t/86c9gz7gj) (Module Owner — endpoints spécifiques propriétaire)

---

## 2. DASHBOARD

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Stats du jour (réservations, revenus) | ✅ CONNECTÉ | `dashboard/screens/dashboard_screen.dart` + `core/services/dashboard_service.dart` | `GET /owner/dashboard` |
| Graphique revenus hebdo/mensuel | ✅ CONNECTÉ | `dashboard/controllers/dashboard_controller.dart` | `GET /owner/dashboard` |
| Réservations récentes | ✅ CONNECTÉ | `dashboard/screens/dashboard_screen.dart` | `GET /owner/dashboard` |
| Badge notifications non lues | ✅ CONNECTÉ | `dashboard/screens/dashboard_screen.dart` | `GET /owner/dashboard` (`unreadNotifications`) |

**Note backend :** `GET /owner/dashboard` renvoie les KPI, séries graphiques et réservations récentes en une seule requête propriétaire.

**Ticket ClickUp :** [86c9gz7c7](https://app.clickup.com/t/86c9gz7c7)

---

## 3. GESTION DES TERRAINS

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Liste de mes terrains | ✅ CONNECTÉ | `terrain/screens/terrain_list_screen.dart` + `core/services/terrain_service.dart` | `GET /terrains/mine` |
| Recherche / filtre statut | ✅ CONNECTÉ | `terrain/controllers/terrain_controller.dart` | Filtrage local après `GET /terrains/mine` |
| Créer un terrain | ✅ CONNECTÉ | `terrain/screens/terrain_form_screen.dart` | `POST /terrains` |
| Modifier un terrain | ✅ CONNECTÉ | `terrain/screens/terrain_form_screen.dart` | `PATCH /terrains/:id` |
| Supprimer un terrain | ✅ CONNECTÉ | `terrain/screens/terrain_list_screen.dart` | `DELETE /terrains/:id` |
| Upload photo du terrain | ✅ CONNECTÉ | `terrain/screens/terrain_form_screen.dart` | `POST /terrains/:id/images` |
| Afficher les photos terrain | ✅ CONNECTÉ | `terrain/screens/terrain_list_screen.dart` + `core/services/terrain_service.dart` | `GET /storage/terrains/*` |
| Localisation terrain formulaire | ✅ CONNECTÉ | `terrain/screens/terrain_form_screen.dart` | Envoi `lat` / `lng` dans `POST/PATCH /terrains` |
| Gérer les disponibilités (créneaux) | ✅ CONNECTÉ | `availability/screens/availability_screen.dart` + `availability/controllers/availability_controller.dart` | `GET /terrains/:id/slots?date=YYYY-MM-DD` |
| Bloquer / débloquer un créneau | ✅ CONNECTÉ | `availability/controllers/availability_controller.dart` + `core/services/terrain_service.dart` | `POST /terrains/:id/slots/block` + `DELETE /terrains/:id/slots/block` |

**Notes :**
- `managerId` est déduit du JWT côté backend à la création.
- Les actions update/delete/upload vérifient que le terrain appartient au propriétaire connecté.
- Les actions de blocage/déblocage de créneaux vérifient aussi que le terrain appartient au propriétaire connecté.
- Le bouton "Notre position" remplit le champ avec `Votre position` et envoie les coordonnées réelles.
- La liste affiche le prix réel par heure, par exemple `10 000 F/h`.
- L'écran disponibilités affiche les créneaux réels du jour, permet le blocage/déblocage individuel ou en lot, et respecte les créneaux déjà réservés.

**Ticket ClickUp :** [86c9gz7c1](https://app.clickup.com/t/86c9gz7c1) + [86c9gz7h7](https://app.clickup.com/t/86c9gz7h7)

---

## 4. GESTION DES RÉSERVATIONS

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Liste de toutes mes réservations owner | ✅ CONNECTÉ | `reservations/screens/reservations_screen.dart` + `core/services/reservation_service.dart` | `GET /reservations/owner/mine` |
| Filtrer par statut (en attente, confirmée, annulée) | ✅ CONNECTÉ | `reservations/controllers/reservations_controller.dart` | Filtrage local après `GET /reservations/owner/mine` |
| Détail d'une réservation owner | ✅ CONNECTÉ | `reservations/screens/reservation_detail_screen.dart` | `GET /reservations/owner/:id` |
| Check-in QR à l'arrivée | ✅ CONNECTÉ | `qr_checkin/` + bouton ballon dashboard | `POST /reservations/owner/check-in/scan`, `PATCH /reservations/owner/:id/check-in` |
| Accepter une réservation | ⏳ À DÉFINIR | — | À définir selon le flux paiement/webhook actuel |
| Refuser une réservation | ✅ CONNECTÉ | `reservations/controllers/reservations_controller.dart` | `PATCH /reservations/owner/:id/cancel` |

**Note backend :** `GET /reservations` retourne les réservations du joueur connecté (`userId`). L'Owner App utilise maintenant `GET /reservations/owner/mine`, filtré par les terrains du propriétaire.

**Ticket ClickUp :** [86c9gz7cc](https://app.clickup.com/t/86c9gz7cc)

---

## 5. REVENUS & PAIEMENTS

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Revenus du jour / semaine / mois | ✅ CONNECTÉ | `revenues/screens/revenues_screen.dart` + `core/services/revenue_service.dart` | Agrégation `GET /reservations/owner/mine` |
| Historique des transactions | ✅ CONNECTÉ | `payments/screens/payments_screen.dart` + `payments/controllers/payments_controller.dart` | Paiements inclus dans `GET /reservations/owner/mine` |
| Répartition par méthode (Wave, Orange, Free) | ✅ CONNECTÉ | `payments/controllers/payments_controller.dart` | Calcul local depuis les paiements réels |
| Détail d'une transaction | ✅ CONNECTÉ | `payments/screens/payments_screen.dart` | Données paiement/réservation owner |
| Destination de reversement | ✅ CONNECTÉ | `payments/screens/payments_screen.dart` | `GET /users/me/payout-info` |

**Ce qu'il faut créer :**
- Un endpoint backend dédié `GET /owner/transactions` plus tard si besoin de pagination serveur.

**Ticket ClickUp :** [86c9gz7cf](https://app.clickup.com/t/86c9gz7cf)

---

## 6. PROFIL PROPRIÉTAIRE

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Afficher mon profil | ✅ CONNECTÉ | `profile/screens/profile_screen.dart` + `profile/controllers/profile_controller.dart` | `GET /users/me` + stats locales terrains/réservations |
| Modifier prénom / nom | ✅ CONNECTÉ | `profile/screens/edit_profile_screen.dart` | `PATCH /users/me` |
| Modifier téléphone | ✅ CONNECTÉ | bottom sheet OTP dans `profile/screens/edit_profile_screen.dart` | `POST /users/me/phone/request` + `PATCH /users/me/phone/confirm` |
| Modifier photo | ✅ CONNECTÉ | avatar dans `profile/screens/profile_screen.dart` | `POST /users/me/avatar` + `GET /storage/avatars/*` |
| Changer mot de passe | ✅ CONNECTÉ | `profile/screens/security_screen.dart` + `profile_controller.changePassword()` | `PATCH /users/me/password` |
| Méthodes de paiement (coordonnées) | ✅ CONNECTÉ | `profile/screens/payment_methods_screen.dart` | `GET/PATCH /users/me/payout-info` |

**Ce qu'il faut créer :**
- Endpoint de reversements dédié plus tard si le modèle devient plus complexe.

**Note UI :** la page profil principale expose uniquement les informations réellement connectées. La photo est modifiable depuis l'avatar, le téléphone via OTP, les reversements et le mot de passe depuis le bloc informations.

**Ticket ClickUp :** [86c9gz7ch](https://app.clickup.com/t/86c9gz7ch)

---

## 7. NOTIFICATIONS

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Liste des notifications | ✅ CONNECTÉ | `notifications/screens/notifications_screen.dart` + `core/services/in_app_notification_service.dart` | `GET /notifications` |
| Compteur non lu dashboard | ✅ CONNECTÉ | `dashboard/controllers/dashboard_controller.dart` | `GET /owner/dashboard` |
| Marquer comme lu | ✅ CONNECTÉ | `notifications/controllers/notifications_controller.dart` | `PATCH /notifications/:id/read` |
| Tout marquer comme lu | ✅ CONNECTÉ | `notifications/controllers/notifications_controller.dart` | `PATCH /notifications/read-all` |
| Création notification paiement confirmé | ✅ CONNECTÉ | backend réservations/webhooks | `NotificationsService.create()` |
| Création notification annulation | ✅ CONNECTÉ | backend réservations | `NotificationsService.create()` |
| Push FCM iOS/Android | 🔧 PARTIEL | `core/services/notification_service.dart` | Token FCM local prêt, enregistrement backend à faire |

**Note :** le niveau 1 est connecté en in-app via REST et fonctionne sans compte Apple Developer payant. Les push FCM restent à finaliser plus tard, surtout pour iOS/APNs.

**Ce qu'il faut compléter :**
- Envoyer le device token à `POST /fcm/register` après connexion

---

## 8. RAPPORTS PDF

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Générer rapport revenus PDF | ✅ CONNECTÉ | `reports/screens/report_screen.dart` + `core/services/revenue_service.dart` | Agrégation `GET /reservations/owner/mine` |
| Générer rapport réservations PDF | ✅ CONNECTÉ | `reports/screens/report_screen.dart` + `core/services/reservation_service.dart` | `GET /reservations/owner/mine` |
| Prévisualiser / imprimer / partager le PDF | ✅ CONNECTÉ | `reports/screens/report_screen.dart` | Local via `pdf`, `printing`, `share_plus` |

**Note :** Le rapport revenus est accessible depuis l'écran revenus. Le rapport réservations est accessible depuis l'icône PDF de l'écran réservations. Les observations du PDF sont calculées depuis les vraies données, sans métriques fictives. La génération PDF utilise les polices intégrées du package `pdf` pour éviter les erreurs d'asset de police, et les erreurs de génération sont journalisées pour faciliter le debug.

**Ticket ClickUp :** [86c9gz7gc](https://app.clickup.com/t/86c9gz7gc)

---

## 9. TOURNOIS

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Créer un tournoi | ⏳ À FAIRE | à créer : `tournaments/` | `POST /tournaments` |
| Liste des tournois de mes terrains | ⏳ À FAIRE | à créer : `tournaments/` | À créer : endpoint owner-scoped |
| Gérer les inscriptions | ⏳ À FAIRE | à créer | `GET /tournaments/:id/teams` |
| Gérer le bracket / les matchs | ⏳ À FAIRE | à créer | `PATCH /tournaments/:id/matches` |

**Note :** Ce module n'existe pas encore dans l'Owner App (ni les fichiers, ni la route). Créer le feature complet `lib/features/tournaments/`.

**Ticket ClickUp :** [86c9gz7hm](https://app.clickup.com/t/86c9gz7hm)

---

## 10. CHAT TEMPS RÉEL

| Écran / Action | État | Fichiers Flutter | Endpoint Backend |
|---|---|---|---|
| Liste des conversations | ❌ MOCK | `chat/screens/chat_list_screen.dart` | `GET /chat/conversations` |
| Ouvrir une conversation | ❌ MOCK | `chat/screens/conversation_screen.dart` | `POST /chat/conversations/direct/:targetId` |
| Envoyer un message | ❌ MOCK | `chat/screens/conversation_screen.dart` | `POST /chat/conversations/:id/messages` |
| Temps réel (Socket.io) | ⏳ À FAIRE | `chat/controllers/chat_controller.dart` | WebSocket event `message.sent` |

**Ce qu'il faut créer :**
- `core/services/chat_service.dart`
- Intégrer `socket_io_client` pour le temps réel

---

## Ordre recommandé de connexion

```
0. 🚨 PRIORITÉ : compléter les endpoints owner manquants côté backend
1. ✅ AUTH           — connexion réelle indispensable pour tout le reste
2. ✅ TERRAINS        — CRUD + images + localisation connectés
2b. ✅ DISPONIBILITÉS — vrais créneaux terrain + blocage/déblocage
3. 🔧 RÉSERVATIONS    — liste + détail + refus connectés, acceptation à clarifier
4. ✅ DASHBOARD       — endpoint dédié `GET /owner/dashboard`
5. ✅ REVENUS         — suit les réservations payées
6. ✅ PROFIL          — affichage, édition prénom/nom, téléphone OTP, avatar, reversements et mot de passe
7. 🔧 NOTIFICATIONS   — in-app connecté, push FCM à finaliser plus tard
8. ✅ RAPPORTS PDF    — revenus + réservations avec aperçu, impression, partage et police PDF stable
9. ⏳ TOURNOIS        — feature à créer from scratch
10. ⏳ CHAT           — le plus complexe (WebSocket)
```

---

## Architecture des services à créer

Chaque service suit ce modèle (GetX + `core/services/`) :

```dart
// lib/core/services/<nom>_service.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TerrainService {
  final String _base = dotenv.get('API_URL');

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, String>> _headers() async => {
    'Authorization': 'Bearer ${await _token()}',
    'Content-Type': 'application/json',
  };

  Future<List<dynamic>> getMesTerrains() async {
    final response = await http.get(
      Uri.parse('$_base/terrains/mine'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erreur ${response.statusCode}: ${response.body}');
  }
}
```

Le token se récupère via `SharedPreferences`, comme dans le flow auth actuel.

---

*Dernière mise à jour : 5 mai 2026 — notifications in-app owner connectées, dashboard migré vers `GET /owner/dashboard`, auth, reset mot de passe, terrains, réservations owner, profil avancé, disponibilités, revenus, paiements et rapports PDF stabilisés*
