String addThirtyMinutes(String time) {
  final parts = time.split('h');
  var hour = int.parse(parts[0]);
  var minute = int.parse(parts[1]);
  minute += 30;
  if (minute >= 60) {
    minute -= 60;
    hour += 1;
  }
  return '${hour.toString().padLeft(2, '0')}h${minute.toString().padLeft(2, '0')}';
}

List<String> buildTimeRange(String startTime, int slotCount) {
  if (slotCount <= 0) return const [];

  final times = <String>[];
  var current = startTime;
  for (var i = 0; i < slotCount; i++) {
    times.add(current);
    current = addThirtyMinutes(current);
  }
  return times;
}

String formatSlotDuration(int slotCount) {
  final totalMinutes = slotCount * 30;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (minutes == 0) {
    return '${hours}h';
  }
  return '${hours}h${minutes.toString().padLeft(2, '0')}';
}

String rangeEndTime(String startTime, int slotCount) {
  var current = startTime;
  for (var i = 0; i < slotCount; i++) {
    current = addThirtyMinutes(current);
  }
  return current;
}

bool hasContiguousRange({
  required List<String> availableTimes,
  required String startTime,
  required int slotCount,
}) {
  final allowed = availableTimes.toSet();
  for (final time in buildTimeRange(startTime, slotCount)) {
    if (!allowed.contains(time)) return false;
  }
  return true;
}
