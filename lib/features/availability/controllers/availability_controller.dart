import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/terrain_service.dart';
import 'availability_range_helper.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Modèles
// ══════════════════════════════════════════════════════════════════════════════

enum SlotStatus { available, booked, blocked }

class TimeSlot {
  final String time;
  final String endTime;
  final SlotStatus status;
  final String bookedBy;

  const TimeSlot({
    required this.time,
    required this.endTime,
    required this.status,
    this.bookedBy = '',
  });

  bool get isAvailable => status == SlotStatus.available;
  bool get isBooked => status == SlotStatus.booked;
  bool get isBlocked => status == SlotStatus.blocked;

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
  static const List<int> durationOptions = [2, 3];

  final _service = TerrainService();

  final focusedDay = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;
  final selectedTerrain = 0.obs;
  final slots = <TimeSlot>[].obs;
  final isLoading = false.obs;
  final isLoadingTerrains = false.obs;
  final isBulkUpdating = false.obs;
  final errorMessage = ''.obs;

  final calendarFormat = 'week'.obs;

  final terrains = <TerrainOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTerrains();
  }

  // ── Chargement des terrains ─────────────────────────────────────────────────
  Future<void> _loadTerrains() async {
    isLoadingTerrains.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.getMesTerrains();
      terrains.value = data
          .map((e) {
            final m = e as Map<String, dynamic>;
            return TerrainOption(
              id: m['id'] as String? ?? '',
              name: m['name'] as String? ?? '',
            );
          })
          .where((t) => t.id.isNotEmpty)
          .toList();
      if (selectedTerrain.value >= terrains.length) {
        selectedTerrain.value = 0;
      }
      if (terrains.isNotEmpty) {
        await _loadSlots(selectedDate.value);
      } else {
        slots.clear();
      }
    } catch (e) {
      errorMessage.value = 'Impossible de charger les terrains';
      Get.snackbar(
        'Erreur',
        'Impossible de charger les terrains',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingTerrains.value = false;
    }
  }

  // ── Sélection de date ───────────────────────────────────────────────────────
  void onDaySelected(DateTime day, DateTime focused) {
    selectedDate.value = day;
    focusedDay.value = focused;
    _loadSlots(day);
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  // ── Sélection de terrain ────────────────────────────────────────────────────
  void selectTerrain(int index) {
    if (index < 0 || index >= terrains.length) return;
    selectedTerrain.value = index;
    _loadSlots(selectedDate.value);
  }

  void toggleFormat() {
    calendarFormat.value = calendarFormat.value == 'month' ? 'week' : 'month';
  }

  // ── Chargement des créneaux depuis l'API ─────────────────────────────────────
  Future<void> _loadSlots(DateTime date) async {
    if (terrains.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final terrainId = terrains[selectedTerrain.value].id;
      final dateStr = _formatDate(date);
      final data = await _service.getCreneaux(terrainId, dateStr);

      slots.value = data.map((item) {
        final m = item as Map<String, dynamic>;
        final time = m['slot'] as String;
        final rawStatus =
            m['status'] as String? ??
            ((m['available'] == true) ? 'available' : 'blocked');

        final status = switch (rawStatus) {
          'booked' => SlotStatus.booked,
          'blocked' => SlotStatus.blocked,
          _ => SlotStatus.available,
        };

        return TimeSlot(
          time: time,
          endTime: _addThirtyMin(time),
          status: status,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = 'Impossible de charger les créneaux';
      Get.snackbar(
        'Erreur',
        'Impossible de charger les créneaux',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAvailability() async {
    await _loadTerrains();
  }

  // ── Bloquer / Débloquer un créneau ─────────────────────────────────────────
  Future<bool> toggleBlock(String time, {bool silent = false}) async {
    final idx = slots.indexWhere((s) => s.time == time);
    if (idx == -1 || slots[idx].isBooked || terrains.isEmpty) return false;

    final terrainId = terrains[selectedTerrain.value].id;
    final dateStr = _formatDate(selectedDate.value);
    final isCurrentlyBlocked = slots[idx].isBlocked;

    // Mise à jour optimiste
    slots[idx] = slots[idx].copyWith(
      status: isCurrentlyBlocked ? SlotStatus.available : SlotStatus.blocked,
    );
    slots.refresh();

    try {
      if (isCurrentlyBlocked) {
        await _service.debloquerCreneau(terrainId, dateStr, time);
      } else {
        await _service.bloquerCreneau(terrainId, dateStr, time);
      }
      return true;
    } catch (_) {
      // Annulation en cas d'erreur
      slots[idx] = slots[idx].copyWith(
        status: isCurrentlyBlocked ? SlotStatus.blocked : SlotStatus.available,
      );
      slots.refresh();
      if (!silent) {
        Get.snackbar(
          'Erreur',
          'Impossible de modifier le créneau',
          snackPosition: SnackPosition.TOP,
        );
      }
      return false;
    }
  }

  bool canToggleRange(String time, int slotCount) {
    final idx = slots.indexWhere((slot) => slot.time == time);
    if (idx == -1 || terrains.isEmpty) return false;

    final startSlot = slots[idx];
    if (startSlot.isBooked) return false;

    final expectedTimes = buildTimeRange(time, slotCount);
    final rangeSlots = <TimeSlot>[];

    for (final expectedTime in expectedTimes) {
      final slotIndex = slots.indexWhere((slot) => slot.time == expectedTime);
      if (slotIndex == -1) return false;
      rangeSlots.add(slots[slotIndex]);
    }

    if (startSlot.isBlocked) {
      return rangeSlots.every((slot) => slot.isBlocked);
    }

    return rangeSlots.every((slot) => slot.isAvailable);
  }

  Future<bool> toggleBlockRange(
    String time,
    int slotCount, {
    bool silent = false,
  }) async {
    if (!canToggleRange(time, slotCount)) {
      if (!silent) {
        Get.snackbar(
          'Durée indisponible',
          'Sélectionne une plage continue de ${formatSlotDuration(slotCount)}.',
          snackPosition: SnackPosition.TOP,
        );
      }
      return false;
    }

    final rangeTimes = buildTimeRange(time, slotCount);
    final startIdx = slots.indexWhere((slot) => slot.time == time);
    if (startIdx == -1) return false;

    final shouldUnblock = slots[startIdx].isBlocked;
    final originalStatuses = <String, SlotStatus>{
      for (final rangeTime in rangeTimes)
        rangeTime: slots.firstWhere((slot) => slot.time == rangeTime).status,
    };

    for (final rangeTime in rangeTimes) {
      final idx = slots.indexWhere((slot) => slot.time == rangeTime);
      slots[idx] = slots[idx].copyWith(
        status: shouldUnblock ? SlotStatus.available : SlotStatus.blocked,
      );
    }
    slots.refresh();

    try {
      for (final rangeTime in rangeTimes) {
        if (shouldUnblock) {
          await _service.debloquerCreneau(
            terrains[selectedTerrain.value].id,
            _formatDate(selectedDate.value),
            rangeTime,
          );
        } else {
          await _service.bloquerCreneau(
            terrains[selectedTerrain.value].id,
            _formatDate(selectedDate.value),
            rangeTime,
          );
        }
      }
      return true;
    } catch (_) {
      for (final rangeTime in rangeTimes) {
        final idx = slots.indexWhere((slot) => slot.time == rangeTime);
        slots[idx] = slots[idx].copyWith(status: originalStatuses[rangeTime]);
      }
      slots.refresh();
      if (!silent) {
        Get.snackbar(
          'Erreur',
          'Impossible de modifier la plage sélectionnée',
          snackPosition: SnackPosition.TOP,
        );
      }
      return false;
    }
  }

  Future<int> blockAllAvailable() async {
    return _bulkToggle(
      slots.where((slot) => slot.isAvailable).map((slot) => slot.time).toList(),
    );
  }

  Future<int> unblockAllBlocked() async {
    return _bulkToggle(
      slots.where((slot) => slot.isBlocked).map((slot) => slot.time).toList(),
    );
  }

  Future<int> _bulkToggle(List<String> times) async {
    if (times.isEmpty || isBulkUpdating.value) return 0;
    isBulkUpdating.value = true;
    var successCount = 0;
    try {
      for (final time in times) {
        final ok = await toggleBlock(time, silent: true);
        if (ok) successCount++;
      }
      return successCount;
    } finally {
      isBulkUpdating.value = false;
    }
  }

  // ── Marqueurs calendrier ────────────────────────────────────────────────────
  List<SlotStatus> getEventsForDay(DateTime day) {
    if (!isSameDay(day, selectedDate.value)) return [];
    return slots
        .where((slot) => slot.isBooked || slot.isBlocked)
        .map((slot) => slot.status)
        .toList();
  }

  bool hasBookingsOnDay(DateTime day) =>
      getEventsForDay(day).any((status) => status == SlotStatus.booked);

  // ── Statistiques ────────────────────────────────────────────────────────────
  int get availableCount => slots.where((s) => s.isAvailable).length;
  int get bookedCount => slots.where((s) => s.isBooked).length;
  int get blockedCount => slots.where((s) => s.isBlocked).length;

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

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _addThirtyMin(String time) {
    final parts = time.split('h');
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    m += 30;
    if (m >= 60) {
      m -= 60;
      h += 1;
    }
    return '${h.toString().padLeft(2, '0')}h${m.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isToday(DateTime day) => isSameDay(day, DateTime.now());
  bool isBeforeToday(DateTime day) => day.isBefore(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  );

  static const monthNames = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

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
      case SlotStatus.available:
        return const Color(0xFF006F39);
      case SlotStatus.booked:
        return const Color(0xFFF59E0B);
      case SlotStatus.blocked:
        return const Color(0xFF9CA3AF);
    }
  }

  Color slotBgColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return const Color(0xFFE8F5E9);
      case SlotStatus.booked:
        return const Color(0xFFFEF3C7);
      case SlotStatus.blocked:
        return const Color(0xFFF3F4F6);
    }
  }

  String slotLabel(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return 'Libre';
      case SlotStatus.booked:
        return 'Réservé';
      case SlotStatus.blocked:
        return 'Bloqué';
    }
  }

  IconData slotIcon(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Icons.check_circle_outline_rounded;
      case SlotStatus.booked:
        return Icons.groups_rounded;
      case SlotStatus.blocked:
        return Icons.lock_outline_rounded;
    }
  }
}
