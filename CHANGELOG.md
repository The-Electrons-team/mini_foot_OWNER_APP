# Changelog - MiniFoot Owner

## [1.3.1] - 2026-05-05

### Backend
- **Dashboard owner dédié** : l'écran dashboard consomme maintenant `GET /owner/dashboard` au lieu d'agréger `GET /users/me`, `GET /terrains/mine` et `GET /reservations/owner/mine` côté Flutter.

### Technique
- **Service dashboard simplifié** : `DashboardService` parse directement la réponse backend et conserve le même contrat UI (`ownerName`, revenus, réservations, graphiques semaine/mois, terrains, taux d'occupation et réservations récentes).

## [1.3.0] - 2026-04-28

### Connexion backend
- **Terrains connectés** : liste propriétaire via `GET /terrains/mine`, création, modification, suppression et upload images branchés sur le backend.
- **Sécurité owner** : création avec propriétaire déduit du JWT ; modification, suppression et upload limités aux terrains du propriétaire connecté.
- **Images terrain** : normalisation des URLs MinIO locales vers le proxy backend `GET /storage/terrains/*` pour l'affichage mobile.
- **Localisation** : le bouton "Notre position" remplit le champ avec `Votre position` et envoie les coordonnées `lat` / `lng`.
- **Réservations owner** : liste branchée sur `GET /reservations/owner/mine`, détail en bottom sheet, refus des réservations en attente via `PATCH /reservations/owner/:id/cancel`.
- **Profil owner** : affichage connecté à `GET /users/me`, stats calculées depuis terrains/réservations, modification prénom/nom via `PATCH /users/me`, photo via `POST /users/me/avatar`, formulaire édition épuré.
- **Profil avancé owner** : coordonnées Wave/Orange Money/Yas Money via `GET/PATCH /users/me/payout-info` et changement téléphone par OTP via `POST /users/me/phone/request` + `PATCH /users/me/phone/confirm`.
- **Mots de passe** : réinitialisation depuis le login via OTP (`POST /auth/forgot-password`, `POST /auth/reset-password`) et changement connecté depuis le profil (`PATCH /users/me/password`).
- **Disponibilités owner** : créneaux réels via `GET /terrains/:id/slots`, blocage/déblocage individuel et en lot via les endpoints backend sécurisés.
- **Dashboard owner** : stats, revenus, graphique semaine/mois et réservations récentes agrégés depuis les terrains/réservations/profil réels.
- **Revenus / paiements owner** : historique transactions, totaux, répartition par méthode, graphiques revenus et classement terrain calculés depuis les paiements réels.
- **Rapports PDF** : rapports revenus et réservations générés depuis les données réelles, avec aperçu, impression et partage.

### Design & UX
- **Liste terrains modernisée** : stats total/actifs/pause, recherche, filtres statut, cartes avec grande photo, actions rapides et prix réel par heure (`10 000 F/h`).
- **Formulaire terrain amélioré** : aperçu photo plus moderne, thumbnails, Mapbox, géolocalisation et retour automatique à la liste après création/modification réussie.
- **Profil propriétaire simplifié** : carte identité compacte, stats clés, revenu confirmé, raccourcis Terrains/Réservations/Créneaux et bloc informations réelles.
- **Avatar propriétaire** : photo ronde dans le profil, choix caméra/galerie, chargement visuel et affichage via proxy storage.
- **Modification profil épurée** : formulaire réduit aux champs supportés par le backend, téléphone en lecture seule et sauvegarde claire.
- **Reversements owner** : écran dédié aux numéros de réception, méthode préférée et accès rapide depuis le profil/paiements.
- **Sécurité profil épurée** : écran réduit au changement de mot de passe réel, avec validations et feedback.
- **Disponibilités stabilisées** : état vide si aucun terrain, pull-to-refresh, action en lot avec chargement et feedback clair.
- **Dashboard assaini** : image locale, pull-to-refresh, états vides, sous-titres dynamiques et suppression des données visuelles fictives.
- **Paiements et revenus stabilisés** : pull-to-refresh, destination de reversement, états vides, feedback chargement/erreur et périodes jour/semaine/mois.
- **PDF assainis** : propriétaire réel, police PDF intégrée stable, observations calculées, aucun indicateur inventé et erreurs de génération journalisées.
- **Formulaires stabilisés** : désactivation de la sélection interactive sur les champs sensibles pour éviter le crash Flutter `RenderEditable.selectWord` au long appui.

### Données de dev
- **Seed dashboard owner** : script `npm run prisma:seed:owner-dashboard` pour générer des réservations utiles au dashboard du propriétaire `771234569`.

### Prochaine tâche
- **Notifications owner** : connecter la liste, les statuts lus et l'enregistrement FCM.

## [1.2.0] - 2026-03-22

### Design & UI (Phase 3 - Experience premium)
- **Ecran Disponibilites redesigne** : Selecteur de terrain en chips, calendrier semaine avec dots de reservation, grille de creneaux coloree avec icones (check/person/lock), barre resume en bas avec taux de disponibilite
- **Ecran Notifications (nouveau)** : Filtres par type (Reservations, Paiements, Avis, Systeme), cartes avec icones colorees, indicateur non lu, bouton "Tout lire"
- **Shimmer Loading** : Squelettes de chargement animes natifs (sans package) sur listes Terrains et Reservations
- **Profil premium redesigne** : Header avec pattern hexagonal decoratif, carte profil avec infos contact groupees, badge "Proprietaire verifie", barre completion profil, carte revenus totaux, carte abonnement avec expiration, parametres groupes (Compte/Preferences/Support), switches notifications et mode sombre, logo minifoot footer

### Fonctionnalites (Phase 3)
- **Navigation notifications** : Bouton cloche du dashboard connecte a l'ecran notifications
- **Shimmer natif** : Widget ShimmerBox reutilisable + skeletons (TerrainCard, ReservationCard, NotificationCard)
- **Revenus dans profil** : Affichage du total des revenus avec formatage CFA
- **Completion profil** : Barre de progression avec pourcentage

### Technique (Phase 3)
- **Nouvelle feature** : notifications (controller, binding, screen)
- **Widget reutilisable** : `lib/core/widgets/shimmer_loading.dart` avec AnimationController natif
- **Route** : `/notifications` avec transition downToUp
- **Profil controller** : Ajout totalRevenue, planExpiry, completionPercent, formatRevenue()
- **Reservations controller** : Ajout isLoading pour shimmer

## [1.1.0] - 2026-03-22

### Design & UI (Phase 2 - Ameliorations avancees)
- **Cartes terrain redesignees** : Image hero plein ecran avec overlay gradient, badges statut/note superposes, nom + prix sur l'image, barre d'occupation mensuelle, mini stats (capacite/surface/reservations), toggle actif/inactif anime
- **Formulaire terrain pro** : Sections avec icones (Photo, Infos, Surface, Horaires, Equipements), zone upload photo en bordure pointillee (dotted_border), chips de surface selectables animes, grille d'equipements toggleable, dialog succes Lottie
- **Page profil premium** : Header avec image terrain.webp + gradient vert, carte profil chevauchante avec avatar gradient, stats en row (terrains/reservations/note), carte abonnement premium en gradient vert, menu parametres avec sous-titres, dialog deconnexion personnalise
- **Animations Lottie** : football_bounce.json (ballon rebondissant), success_check.json (coche animee), loading_dots.json (3 points verts)
- **Etats vides enrichis** : Animations Lottie + textes encourageants sur ecrans terrains et reservations

### Design & UI (Phase 1)
- **Theme clair harmonise** : Refonte complete du theme en mode clair (beige chaud #F5F0E8) harmonise avec l'app client MiniFoot
- **Palette de couleurs** : kGreen (#006F39), kGold (#F59E0B), kBlue (#1565C0), kRed (#EF4444)
- **Splash screen** : Nouveau splash avec logo minifoot.png, animations elastiques, texte Orbitron, 3 points rebondissants
- **Onboarding** : 3 slides riches avec images reelles (terrain.webp, minifoot.png, ballon.png) et animations flutter_animate
- **Login screen** : Logo reel minifoot.png, design clair, formulaire beige
- **Register screen** : Refonte theme clair
- **Dashboard** : Carte revenus avec image terrain en fond + overlay vert, stats mini-cards, graphique interactif
- **Navbar flottante** : Barre en pilule (borderRadius 36) avec bouton central ballon.png, style identique a l'app client
- **Terrains** : Cartes avec image + overlay couleur (vert/bleu/orange), badges note + surface + prix
- **Reservations** : Design clair, filtres en chips colores, cartes avec avatars initiales
- **Paiements** : Design clair, cartes resume en haut, liste transactions
- **Disponibilites** : Refonte theme clair
- **Profil** : Refonte theme clair

### Fonctionnalites
- **Badge notifications** : Compteur rouge sur l'icone cloche du dashboard (notificationCount reactif)
- **Graphique ameliore** : Selecteur Semaine/Mois avec animation de transition, tooltips au toucher
- **Pull-to-refresh** : RefreshIndicator sur les ecrans Reservations, Terrains et Paiements
- **Images reelles** : Utilisation des assets (minifoot.png, terrain.webp, ballon.png, ballon.png) au lieu d'icones placeholder
- **Animations de transition** : Transitions personnalisees par page (fadeIn, cupertino, zoom, rightToLeftWithFade, downToUp)
- **Animations d'entree** : flutter_animate sur l'onboarding (fadeIn, scale, slideY)

### Technique (Phase 2)
- **Widgets prives** : _TerrainCard, _MiniStat, _OccupancyBar, _ActionButton (terrain list), _FormField (terrain form), _StatCard, _SettingsItem (profil)
- **Lottie integration** : 3 animations JSON custom, LottieSuccessDialog widget reutilisable
- **Packages** : Ajout lottie (^3.1.0), dotted_border pour zone upload

### Technique (Phase 1)
- **Terrains** : Ajout champs `surface`, `isAsset`, `overlayColor` au TerrainModel
- **Dashboard controller** : Ajout `notificationCount`, `chartPeriod`, `monthlyData`, `activeChartData`, `refreshDashboard()`
- **Controllers** : Ajout methodes `refreshReservations()`, `refreshTerrains()`, `refreshPayments()`
- **Routes** : Transitions personnalisees dans app_routes.dart avec durees et courbes specifiques
- **Test widget** : Corrige pour utiliser `OwnerApp` au lieu de `MyApp`

### Assets
- Copie des images depuis l'app client : ballon.png, minifoot.png, terrain.webp, free.png, om.png, wave.png

## [1.0.0] - Initial

- Structure initiale de l'app owner avec GetX
- Ecrans : splash, login, register, dashboard, terrains, reservations, paiements, disponibilites, profil
- Architecture feature-based avec controllers, screens, bindings
