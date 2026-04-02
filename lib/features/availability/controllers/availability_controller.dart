import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Modèles
// ══════════════════════════════════════════════════════════════════════════════

enum SlotStatus { available, booked, blocked }

class TimeSlot {
  final String time;       // ex: "08h00"
  final String endTime;    // ex: "09h00"
  final SlotStatus status;
  final String bookedBy;   // nom de l'équipe si réservé

  const TimeSlot({
    required this.time,
    required this.endTime,
    required this.status,
    this.bookedBy = '',
  });

  bool get isAvailable => status == SlotStatus.available;
  bool get isBooked    => status == SlotStatus.booked;
  bool get isBlocked   => status == SlotStatus.blocked;

  TimeSlot copyWith({SlotStatus? status}) => TimeSlot(
        time: time,
        endTime: endTime,
        status: status ?? this.status,
        bookedBy: bookedBy,
      );
}

class TerrainOption {
  final String id;
  final String name;

  const TerrainOption({required this.id, required this.name});
}

// ══════════════════════════════════════════════════════════════════════════════
// Controller principal
// ══════════════════════════════════════════════════════════════════════════════

class AvailabilityController extends GetxController {
  // ── État ────────────────────────────────────────────────────────────────────
  final focusedDay    = DateTime.now().obs;
  final selectedDate  = DateTime.now().obs;
  final selectedTerrain = 0.obs;
  final slots         = <TimeSlot>[].obs;
  final isLoading     = false.obs;

  // Mode calendrier : 'month' ou 'week'
  final calendarFormat = 'month'.obs;

  // Terrains disponibles
  final terrains = <TerrainOption>[
    const TerrainOption(id: 'alpha', name: 'Terrain Alpha'),
    const TerrainOption(id: 'beta',  name: 'Terrain Beta'),
    const TerrainOption(id: 'omega', name: 'Terrain Omega'),
  ].obs;

  // Carte des jours ayant des événements (pour les marqueurs du calendrier)
  final Map<DateTime, List<SlotStatus>> _eventMap = {};

  // ── Initialisation ──────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _buildEventMap();
    _loadSlots(selectedDate.value);
  }

  // ── Sélection de date ───────────────────────────────────────────────────────
  void onDaySelected(DateTime day, DateTime focused) {
    selectedDate.value = day;
    focusedDay.value   = focused;
    _loadSlots(day);
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  // ── Sélection de terrain ────────────────────────────────────────────────────
  void selectTerrain(int index) {
    selectedTerrain.value = index;
    _loadSlots(selectedDate.value);
  }

  // ── Basculer entre mois et semaine ──────────────────────────────────────────
  void toggleFormat() {
    calendarFormat.value =
        calendarFormat.value == 'month' ? 'week' : 'month';
  }

  // ── Bloquer / Débloquer un créneau ─────────────────────────────────────────
  void toggleBlock(String time) {
    final idx = slots.indexWhere((s) => s.time == time);
    if (idx == -1 || slots[idx].isBooked) return;

    final current = slots[idx];
    slots[idx] = current.copyWith(
      status: current.isBlocked ? SlotStatus.available : SlotStatus.blocked,
    );
    slots.refresh();
  }

  // ── Marqueurs calendrier ────────────────────────────────────────────────────
  List<SlotStatus> getEventsForDay(DateTime day) {
    final key = _normalizeDate(day);
    return _eventMap[key] ?? [];
  }

  bool hasBookingsOnDay(DateTime day) {
    return getEventsForDay(day).any((s) => s == SlotStatus.booked);
  }

  // ── Statistiques ────────────────────────────────────────────────────────────
  int get availableCount =>
      slots.where((s) => s.isAvailable).length;
  int get bookedCount =>
      slots.where((s) => s.isBooked).length;
  int get blockedCount =>
      slots.where((s) => s.isBlocked).length;

  String get occupancyLabel {
    final total = slots.length;
    if (total == 0) return '0%';
    return '${((bookedCount / total) * 100).round()}%';
  }

  double get occupancyRate {
    final total = slots.length;
    if (total == 0) return 0;
    return bookedCount / total;
  }

  // ── Données mock selon la date et le terrain ─────────────────────────────
  void _loadSlots(DateTime date) {
    isLoading.value = true;

    // Simule un délai réseau court
    Future.delayed(const Duration(milliseconds: 200), () {
      final mockBookings = _getMockBookings(date);
      final mockBlocked  = _getMockBlocked(date);

      slots.value = List.generate(15, (i) {
        final hour    = 8 + i;
        final time    = '${hour.toString().padLeft(2, '0')}h00';
        final endTime = '${(hour + 1).toString().padLeft(2, '0')}h00';

        SlotStatus status;
        String bookedBy = '';

        if (mockBlocked.contains(time)) {
          status = SlotStatus.blocked;
        } else if (mockBookings.containsKey(time)) {
          status = SlotStatus.booked;
          bookedBy = mockBookings[time]!;
        } else {
          status = SlotStatus.available;
        }

        return TimeSlot(
          time: time,
          endTime: endTime,
          status: status,
          bookedBy: bookedBy,
        );
      });

      isLoading.value = false;
    });
  }

  Map<String, String> _getMockBookings(DateTime date) {
    // Varie les réservations selon le jour de la semaine
    final weekday = date.weekday;
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return {
        '08h00': 'Lions FC',
        '10h00': 'AS Médina',
        '12h00': 'Team Almadies',
        '14h00': 'FC Grand Yoff',
        '16h00': 'Star Club',
        '19h00': 'Plateau FC',
      };
    }
    if (weekday == DateTime.friday) {
      return {
        '10h00': 'Lions FC',
        '16h00': 'AS Médina',
        '20h00': 'United Dakar',
      };
    }
    return {
      '10h00': 'Lions FC',
      '12h00': 'AS Médina',
      '16h00': 'FC Grand Yoff',
      '19h00': 'Star Club',
    };
  }

  Set<String> _getMockBlocked(DateTime date) {
    return {'08h00', '22h00'};
  }

  void _buildEventMap() {
    final now = DateTime.now();
    // Simule des événements pour les 30 prochains jours
    for (int i = 0; i < 30; i++) {
      final day = now.add(Duration(days: i));
      final key = _normalizeDate(day);
      if (day.weekday == DateTime.saturday ||
          day.weekday == DateTime.sunday) {
        _eventMap[key] = [
          SlotStatus.booked,
          SlotStatus.booked,
          SlotStatus.booked,
        ];
      } else if (day.weekday == DateTime.friday) {
        _eventMap[key] = [SlotStatus.booked];
      } else if (i % 3 == 0) {
        _eventMap[key] = [SlotStatus.booked, SlotStatus.booked];
      }
    }
  }

  DateTime _normalizeDate(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  // ── Helpers ─────────────────────────────────────────────────────────────────
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isToday(DateTime day) => isSameDay(day, DateTime.now());
  bool isBeforeToday(DateTime day) =>
      day.isBefore(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ));

  // Noms des mois en français
  static const monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  // Noms courts des jours (lundi=1)
  static const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  String get selectedMonthYear {
    final d = focusedDay.value;
    return '${monthNames[d.month - 1]} ${d.year}';
  }

  String get selectedDateLabel {
    final d = selectedDate.value;
    final dayName = dayNames[d.weekday - 1];
    return '$dayName ${d.day} ${monthNames[d.month - 1]}';
  }

  Color slotColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available: return const Color(0xFF006F39);
      case SlotStatus.booked:    return const Color(0xFFF59E0B);
      case SlotStatus.blocked:   return const Color(0xFF9CA3AF);
    }
  }

  Color slotBgColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available: return const Color(0xFFE8F5E9);
      case SlotStatus.booked:    return const Color(0xFFFEF3C7);
      case SlotStatus.blocked:   return const Color(0xFFF3F4F6);
    }
  }

  String slotLabel(SlotStatus status) {
    switch (status) {
      case SlotStatus.available: return 'Libre';
      case SlotStatus.booked:    return 'Réservé';
      case SlotStatus.blocked:   return 'Bloqué';
    }
  }

  IconData slotIcon(SlotStatus status) {
    switch (status) {
      case SlotStatus.available: return Icons.check_circle_outline_rounded;
      case SlotStatus.booked:    return Icons.groups_rounded;
      case SlotStatus.blocked:   return Icons.lock_outline_rounded;
    }
  }
}
