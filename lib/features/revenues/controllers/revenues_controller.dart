import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Modèles
// ══════════════════════════════════════════════════════════════════════════════

class RevenueEntry {
  final String label;   // ex: "Lun", "Sem 1", "Janv"
  final int amount;     // en FCFA
  final int bookings;   // nombre de réservations
  final double occupancy; // taux d'occupation 0.0 → 1.0

  const RevenueEntry({
    required this.label,
    required this.amount,
    required this.bookings,
    required this.occupancy,
  });
}

enum RevenuePeriod { daily, weekly, monthly }

// ══════════════════════════════════════════════════════════════════════════════
// Controller
// ══════════════════════════════════════════════════════════════════════════════

class RevenuesController extends GetxController {
  final period       = RevenuePeriod.weekly.obs;
  final selectedBar  = (-1).obs;  // index de la barre sélectionnée
  final isLoading    = false.obs;

  // Période pour le rapport PDF
  final reportPeriod = 'Ce mois'.obs;

  // ── Données mock ────────────────────────────────────────────────────────────
  static const _dailyData = [
    RevenueEntry(label: 'Lun', amount: 24000, bookings: 3, occupancy: 0.43),
    RevenueEntry(label: 'Mar', amount: 16000, bookings: 2, occupancy: 0.29),
    RevenueEntry(label: 'Mer', amount: 32000, bookings: 4, occupancy: 0.57),
    RevenueEntry(label: 'Jeu', amount: 8000,  bookings: 1, occupancy: 0.14),
    RevenueEntry(label: 'Ven', amount: 48000, bookings: 6, occupancy: 0.86),
    RevenueEntry(label: 'Sam', amount: 72000, bookings: 9, occupancy: 1.0),
    RevenueEntry(label: 'Dim', amount: 56000, bookings: 7, occupancy: 0.86),
  ];

  static const _weeklyData = [
    RevenueEntry(label: 'Sem 1', amount: 185000, bookings: 23, occupancy: 0.52),
    RevenueEntry(label: 'Sem 2', amount: 210000, bookings: 27, occupancy: 0.61),
    RevenueEntry(label: 'Sem 3', amount: 175000, bookings: 21, occupancy: 0.48),
    RevenueEntry(label: 'Sem 4', amount: 245000, bookings: 31, occupancy: 0.74),
  ];

  static const _monthlyData = [
    RevenueEntry(label: 'Oct',  amount: 480000, bookings: 62, occupancy: 0.55),
    RevenueEntry(label: 'Nov',  amount: 520000, bookings: 68, occupancy: 0.61),
    RevenueEntry(label: 'Déc',  amount: 610000, bookings: 79, occupancy: 0.72),
    RevenueEntry(label: 'Jan',  amount: 390000, bookings: 51, occupancy: 0.46),
    RevenueEntry(label: 'Fév',  amount: 445000, bookings: 58, occupancy: 0.52),
    RevenueEntry(label: 'Mars', amount: 815000, bookings: 106, occupancy: 0.83),
  ];

  // ── Getters des données selon la période ─────────────────────────────────
  List<RevenueEntry> get entries {
    switch (period.value) {
      case RevenuePeriod.daily:   return _dailyData;
      case RevenuePeriod.weekly:  return _weeklyData;
      case RevenuePeriod.monthly: return _monthlyData;
    }
  }

  int get totalRevenue =>
      entries.fold(0, (sum, e) => sum + e.amount);

  int get totalBookings =>
      entries.fold(0, (sum, e) => sum + e.bookings);

  double get avgOccupancy {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, e) => sum + e.occupancy) / entries.length;
  }

  int get bestAmount =>
      entries.fold(0, (max, e) => e.amount > max ? e.amount : max);

  String get periodLabel {
    switch (period.value) {
      case RevenuePeriod.daily:   return 'Cette semaine';
      case RevenuePeriod.weekly:  return 'Ce mois';
      case RevenuePeriod.monthly: return 'Ces 6 mois';
    }
  }

  RevenueEntry? get selectedEntry {
    final i = selectedBar.value;
    if (i < 0 || i >= entries.length) return null;
    return entries[i];
  }

  // ── Changer la période ───────────────────────────────────────────────────
  void setPeriod(RevenuePeriod p) {
    if (period.value == p) return;
    period.value = p;
    selectedBar.value = -1;
  }

  void selectBar(int index) {
    selectedBar.value = selectedBar.value == index ? -1 : index;
  }

  // ── Données pour fl_chart ─────────────────────────────────────────────────
  List<BarChartGroupData> get barGroups {
    return List.generate(entries.length, (i) {
      final entry     = entries[i];
      final isSelected = selectedBar.value == i;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: entry.amount.toDouble(),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: LinearGradient(
              colors: isSelected
                  ? [const Color(0xFF00C264), const Color(0xFF006F39)]
                  : [kGreen.withValues(alpha: 0.4), kGreen.withValues(alpha: 0.7)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
        showingTooltipIndicators: isSelected ? [0] : [],
      );
    });
  }

  List<LineChartBarData> get occupancyLine {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.occupancy * 100);
    }).toList();

    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.35,
        color: kGold,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              kGold.withValues(alpha: 0.18),
              kGold.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
  }

  // ── Format ────────────────────────────────────────────────────────────────
  String formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '$amount';
  }

  String formatAmountFull(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String get occupancyPercent => '${(avgOccupancy * 100).round()}%';
}
