import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Handler des notifs en arrière-plan (top-level function obligatoire)
// ══════════════════════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé par main.dart
  debugPrint('Notif en arrière-plan : ${message.messageId}');
}

// ══════════════════════════════════════════════════════════════════════════════
// Service de notifications push
// ══════════════════════════════════════════════════════════════════════════════

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  // ── Initialisation ──────────────────────────────────────────────────────────
  static Future<void> init() async {
    // 1. Handler arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Demande de permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permission notifs : ${settings.authorizationStatus}');

    // 3. Récupérer le token FCM (en arrière-plan pour ne pas bloquer l'app)
    _messaging.getToken().then((token) {
      if (token != null) debugPrint('FCM Token : $token');
    }).catchError((e) {
      debugPrint('Note : Token FCM non disponible (normal sur compte Apple gratuit ou simulateur).');
    });

    // 4. Écouter les notifs en premier plan
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 5. Tap sur notif quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 6. Vérifier si l'app a été ouverte via une notif (app fermée)
    //    On attend que GetMaterialApp soit monté avant de naviguer
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _handleNavigation(initialMessage);
      });
    }

    // 7. Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token rafraîchi : $newToken');
      // TODO: envoyer le nouveau token à ton backend
    });
  }

  // ── Notif reçue en premier plan ─────────────────────────────────────────────
  static void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Notif reçue (foreground) : ${message.notification?.title}');
    _showInAppBanner(message);
  }

  // ── Tap sur notif (app en arrière-plan) ─────────────────────────────────────
  static void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('App ouverte via notif : ${message.notification?.title}');
    _handleNavigation(message);
  }

  // ── Afficher une bannière in-app (premier plan) ─────────────────────────────
  static void _showInAppBanner(RemoteMessage message) {
    final title = message.notification?.title ?? 'Nouvelle notification';
    final body  = message.notification?.body ?? '';
    final type  = message.data['type'] as String? ?? 'general';

    final (Color iconColor, Color iconBg, IconData icon) = switch (type) {
      'booking'  => (kBlue,    kBlueLight,  Icons.calendar_month_rounded),
      'payment'  => (kGreen,   kGreenLight, Icons.payments_rounded),
      'review'   => (kGold,    kGoldLight,  Icons.star_rounded),
      _          => (kTextSub, kBgSurface,  Icons.notifications_rounded),
    };

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: kBgCard,
      colorText: kTextPrim,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 4),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      onTap: (_) => _handleNavigation(message),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ── Navigation selon le type de notif ───────────────────────────────────────
  static void _handleNavigation(RemoteMessage message) {
    final type = message.data['type'] as String? ?? '';
    switch (type) {
      case 'booking':
        Get.toNamed(Routes.reservations);
      case 'payment':
        Get.toNamed(Routes.payments);
      case 'chat':
        Get.toNamed(Routes.chat);
      default:
        Get.toNamed(Routes.notifications);
    }
  }

  // ── Récupérer le token (pour ton backend) ───────────────────────────────────
  static Future<String?> getToken() => _messaging.getToken();
}
