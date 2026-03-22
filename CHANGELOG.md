# Changelog - MiniFoot Owner

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
