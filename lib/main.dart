import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/auth/bindings/auth_binding.dart';
import 'routes/app_routes.dart';

String? _envValue(String key) {
  final value = dotenv.env[key]?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

Future<bool> _initializeFirebase() async {
  try {
    if (kIsWeb) {
      final apiKey = _envValue('FIREBASE_API_KEY');
      final authDomain = _envValue('FIREBASE_AUTH_DOMAIN');
      final projectId = _envValue('FIREBASE_PROJECT_ID');
      final storageBucket = _envValue('FIREBASE_STORAGE_BUCKET');
      final messagingSenderId = _envValue('FIREBASE_MESSAGING_SENDER_ID');
      final appId = _envValue('FIREBASE_APP_ID');

      final hasWebConfig = [
        apiKey,
        authDomain,
        projectId,
        storageBucket,
        messagingSenderId,
        appId,
      ].every((value) => value != null);

      if (!hasWebConfig) {
        debugPrint('Firebase Web non configure: notifications desactivees.');
        return false;
      }

      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey!,
          authDomain: authDomain,
          projectId: projectId!,
          storageBucket: storageBucket!,
          messagingSenderId: messagingSenderId!,
          appId: appId!,
          measurementId: _envValue('FIREBASE_MEASUREMENT_ID'),
        ),
      );
      return true;
    }

    await Firebase.initializeApp();
    return true;
  } catch (e) {
    debugPrint('Firebase non initialise: $e');
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final firebaseReady = await _initializeFirebase();
  await initializeDateFormatting('fr_FR', null); // pour le calendrier en français
  if (firebaseReady) {
    try {
      await NotificationService.init();
    } catch (e) {
      debugPrint('Notifications push desactivees: $e');
    }
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const OwnerApp());
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MiniFoot Owner',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialBinding: AuthBinding(),
      initialRoute: Routes.splash,
      getPages: appPages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
