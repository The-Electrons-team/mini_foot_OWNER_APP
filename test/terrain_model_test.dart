import 'package:flutter_test/flutter_test.dart';
import 'package:mini_foot_owner_flutter/features/terrain/controllers/terrain_controller.dart';

void main() {
  test('TerrainModel parses sub-terrains from backend payload', () {
    final terrain = TerrainModel.fromJson({
      'id': 'terrain-1',
      'name': 'Parcelle Sacre-Coeur',
      'address': 'Dakar',
      'pricePerHour': 15000,
      'zone': 'DAKAR',
      'features': ['Eclairage'],
      'imageUrls': <String>[],
      'rating': 4.5,
      'isActive': true,
      'subTerrains': [
        {
          'id': 'sub-1',
          'name': 'Terrain A',
          'capacity': 10,
          'type': '5v5',
          'surface': 'Gazon synthetique',
          'pricePerHour': 18000,
          'isActive': true,
        },
      ],
    });

    expect(terrain.miniTerrainCount, 1);
    expect(terrain.miniTerrainLabel, '1 mini-terrain');
    expect(terrain.subTerrains.first.name, 'Terrain A');
    expect(terrain.subTerrains.first.toJson(), {
      'id': 'sub-1',
      'name': 'Terrain A',
      'capacity': 10,
      'type': '5v5',
      'surface': 'Gazon synthetique',
      'pricePerHour': 18000,
      'isActive': true,
    });
  });
}
