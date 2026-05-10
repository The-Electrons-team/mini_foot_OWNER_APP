import 'package:flutter_test/flutter_test.dart';
import 'package:mini_foot_owner_flutter/features/availability/controllers/availability_range_helper.dart';

void main() {
  group('buildTimeRange', () {
    test('construit une plage de 1h en demi-heures', () {
      expect(buildTimeRange('08h00', 2), ['08h00', '08h30']);
    });

    test('construit une plage de 1h30 en demi-heures', () {
      expect(buildTimeRange('08h30', 3), ['08h30', '09h00', '09h30']);
    });
  });

  group('formatSlotDuration', () {
    test('formate 2 slots en 1h', () {
      expect(formatSlotDuration(2), '1h');
    });

    test('formate 3 slots en 1h30', () {
      expect(formatSlotDuration(3), '1h30');
    });
  });

  group('rangeEndTime', () {
    test('calcule la fin pour 1h', () {
      expect(rangeEndTime('08h00', 2), '09h00');
    });

    test('calcule la fin pour 1h30', () {
      expect(rangeEndTime('08h30', 3), '10h00');
    });
  });

  group('hasContiguousRange', () {
    test('retourne true si la plage complete existe', () {
      expect(
        hasContiguousRange(
          availableTimes: const ['08h00', '08h30', '09h00', '09h30'],
          startTime: '08h30',
          slotCount: 3,
        ),
        isTrue,
      );
    });

    test('retourne false si un slot manque dans la plage', () {
      expect(
        hasContiguousRange(
          availableTimes: const ['08h00', '08h30', '09h30'],
          startTime: '08h30',
          slotCount: 3,
        ),
        isFalse,
      );
    });
  });
}
