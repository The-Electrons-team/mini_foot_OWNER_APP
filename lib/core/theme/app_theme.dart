import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Palette harmonisée avec l'app client ───────────────────────────────────
const Color kBg        = Color(0xFFF5F0E8);   // fond beige chaud (identique client)
const Color kBgCard    = Color(0xFFFFFFFF);   // cartes blanches
const Color kBgSurface = Color(0xFFF0EBE3);   // surface inputs (beige plus clair)
const Color kGreen     = Color(0xFF006F39);   // vert principal (identique client)
const Color kGreenDark = Color(0xFF00C264);   // vert clair pour dark mode/accents
const Color kGreenDim  = Color(0xFF005A2E);   // vert foncé
const Color kGreenLight= Color(0xFFE8F5E9);   // vert très clair (badges, fonds)
const Color kGold      = Color(0xFFF59E0B);   // or/revenus
const Color kGoldLight = Color(0xFFFEF3C7);   // or clair (badge fond)
const Color kRed       = Color(0xFFEF4444);   // danger
const Color kRedLight  = Color(0xFFFEE2E2);   // danger clair (badge fond)
const Color kBlue      = Color(0xFF1565C0);   // info (identique client)
const Color kBlueLight = Color(0xFFDBEAFE);   // info clair
const Color kOrange    = Color(0xFFE65100);   // orange accent
const Color kTextPrim  = Color(0xFF1A1A1A);   // texte principal (identique client)
const Color kTextSub   = Color(0xFF6B7280);   // texte secondaire
const Color kTextLight = Color(0xFF9CA3AF);   // texte léger (placeholders)
const Color kBorder    = Color(0xFFE5E0D8);   // bordures beige
const Color kDivider   = Color(0xFFF0EBE3);   // séparateurs

// ─── Ombres (style client) ──────────────────────────────────────────────────
List<BoxShadow> get kCardShadow => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

List<BoxShadow> get kElevatedShadow => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
];

List<BoxShadow> get kNavShadow => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.10),
    blurRadius: 20,
    offset: const Offset(0, 4),
  ),
];

// ─── Gradients ──────────────────────────────────────────────────────────────
const LinearGradient kGreenGradient = LinearGradient(
  colors: [Color(0xFF006F39), Color(0xFF00C264)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kGoldGradient = LinearGradient(
  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── ThemeData ──────────────────────────────────────────────────────────────
ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: kBg,
  cardColor: kBgCard,
  colorScheme: const ColorScheme.light(
    primary: kGreen,
    secondary: kGold,
    surface: kBgCard,
    onSurface: kTextPrim,
    error: kRed,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    iconTheme: IconThemeData(color: kTextPrim),
    titleTextStyle: TextStyle(
      fontFamily: 'Orbitron',
      color: kTextPrim,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  ),
  fontFamily: 'DMSans',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Orbitron', color: kTextPrim, fontWeight: FontWeight.w900),
    displayMedium: TextStyle(fontFamily: 'Orbitron', color: kTextPrim, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(fontFamily: 'Orbitron', color: kTextPrim, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontFamily: 'DMSans', color: kTextPrim, fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontFamily: 'DMSans', color: kTextSub, fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontFamily: 'DMSans', color: kTextLight, fontSize: 12, height: 1.5),
    labelLarge: TextStyle(fontFamily: 'DMSans', color: kTextPrim, fontSize: 14, fontWeight: FontWeight.w600),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kBgCard,
    hintStyle: const TextStyle(color: kTextLight, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kGreen, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kRed),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: 0.3,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kTextPrim,
      padding: const EdgeInsets.symmetric(vertical: 14),
      side: const BorderSide(color: kBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  dividerColor: kDivider,
  dividerTheme: const DividerThemeData(color: kDivider, thickness: 1),
);
