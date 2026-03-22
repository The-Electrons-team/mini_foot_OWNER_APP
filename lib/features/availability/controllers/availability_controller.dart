import 'package:get/get.dart';

class TimeSlot {
  final String time;
  bool isBlocked;
  final bool isBooked;
  final String bookedBy;

  TimeSlot({
    required this.time,
    required this.isBlocked,
    required this.isBooked,
    required this.bookedBy,
  });
}

class AvailabilityController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final slots = <TimeSlot>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateSlots();
  }

  void _generateSlots() {
    // Créneaux mockés : 08h à 22h par pas de 1h
    final bookedTimes = {
      '10h00': 'Lions FC',
      '12h00': 'AS Médina',
      '16h00': 'FC Grand Yoff',
      '19h00': 'Star Club',
    };
    final blockedTimes = {'08h00', '22h00'};

    slots.value = List.generate(15, (i) {
      final hour = 8 + i;
      final time = '${hour.toString().padLeft(2, '0')}h00';
      return TimeSlot(
        time: time,
        isBlocked: blockedTimes.contains(time),
        isBooked: bookedTimes.containsKey(time),
        bookedBy: bookedTimes[time] ?? '',
      );
    });
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    // Régénérer avec d'autres mock selon la date
    _generateSlots();
  }

  void toggleBlock(String time) {
    final idx = slots.indexWhere((s) => s.time == time);
    if (idx != -1 && !slots[idx].isBooked) {
      slots[idx].isBlocked = !slots[idx].isBlocked;
      slots.refresh();
    }
  }

  // Retourne les 7 prochains jours
  List<DateTime> get nextSevenDays {
    final now = DateTime.now();
    return List.generate(7, (i) => now.add(Duration(days: i)));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get availableCount {
    final count = slots.where((s) => !s.isBlocked && !s.isBooked).length;
    return count.toString();
  }

  String get bookedCount {
    return slots.where((s) => s.isBooked).length.toString();
  }

  String get blockedCount {
    return slots.where((s) => s.isBlocked).length.toString();
  }
}
