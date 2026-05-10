import 'package:flutter_test/flutter_test.dart';
import 'package:mini_foot_owner_flutter/features/terrain/controllers/owner_zone_options.dart';

void main() {
  test('owner zone options only expose backend Zone enum values', () {
    expect(ownerZoneLabels.keys, containsAll(['DAKAR', 'THIES', 'ZIGUINCHOR']));
    expect(ownerZoneLabels.keys, isNot(contains('GUEEDIAWAYE')));
    expect(ownerZoneLabels.keys, isNot(contains('PIKINE')));
    expect(ownerZoneLabels.keys, isNot(contains('RUFISQUE')));
  });
}
