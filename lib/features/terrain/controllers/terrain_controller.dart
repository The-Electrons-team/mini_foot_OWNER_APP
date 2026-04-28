import 'dart:io';
import 'package:get/get.dart';
import '../../../core/services/terrain_service.dart';
import '../../../routes/app_routes.dart';

class TerrainModel {
  final String id;
  final String name;
  final String address;
  final String? description;
  final int pricePerHour;
  final String zone;
  final List<String> features;
  final String? imageUrl;
  final List<String> imageUrls;
  final double rating;
  bool isActive;
  final double? lat;
  final double? lng;
  final String? managerId;

  TerrainModel({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    required this.pricePerHour,
    required this.zone,
    this.features = const [],
    this.imageUrl,
    this.imageUrls = const [],
    this.rating = 0,
    required this.isActive,
    this.lat,
    this.lng,
    this.managerId,
  });

  factory TerrainModel.fromJson(Map<String, dynamic> json) {
    return TerrainModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      pricePerHour: (json['pricePerHour'] ?? 0) as int,
      zone: json['zone'] ?? 'DAKAR',
      features: (json['features'] as List<dynamic>? ?? []).cast<String>(),
      imageUrl: json['imageUrl'],
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? []).cast<String>(),
      rating: (json['rating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      managerId: json['managerId'],
    );
  }

  String get displayCapacity {
    const caps = ['5v5', '7v7', '11v11'];
    final found = features.where((f) => caps.contains(f)).toList();
    return found.isNotEmpty ? found.join(', ') : '—';
  }

  String get displaySurface {
    const surfaces = ['Gazon synthétique', 'Gazon naturel', 'Terre battue'];
    return features.firstWhere((f) => surfaces.contains(f), orElse: () => '—');
  }

  String get displayImage =>
      imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : '');
}

class TerrainController extends GetxController {
  final _service = TerrainService();

  final terrains = <TerrainModel>[].obs;
  final allTerrains = <TerrainModel>[].obs;
  final isLoading = false.obs;
  final selectedTerrain = Rxn<TerrainModel>();
  final searchQuery = ''.obs;
  final statusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTerrains();
  }

  Future<void> loadTerrains() async {
    isLoading.value = true;
    try {
      final data = await _service.getMesTerrains();
      final list = data
          .map((e) => TerrainModel.fromJson(e as Map<String, dynamic>))
          .toList();
      allTerrains.value = list;
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les terrains',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTerrains() => loadTerrains();

  void onSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void selectStatusFilter(String filter) {
    statusFilter.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    Iterable<TerrainModel> filtered = allTerrains;

    if (statusFilter.value == 'active') {
      filtered = filtered.where((t) => t.isActive);
    } else if (statusFilter.value == 'inactive') {
      filtered = filtered.where((t) => !t.isActive);
    }

    if (query.isNotEmpty) {
      filtered = filtered.where(
        (t) =>
            t.name.toLowerCase().contains(query) ||
            t.address.toLowerCase().contains(query) ||
            t.zone.toLowerCase().contains(query),
      );
    }

    terrains.value = filtered.toList();
  }

  int get totalTerrains => allTerrains.length;
  int get activeTerrains => allTerrains.where((t) => t.isActive).length;
  int get inactiveTerrains => allTerrains.where((t) => !t.isActive).length;

  Future<void> toggleStatus(String id) async {
    final idx = terrains.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final terrain = terrains[idx];
    final newStatus = !terrain.isActive;
    try {
      await _service.modifierTerrain(id, {'isActive': newStatus});
      terrain.isActive = newStatus;
      terrains.refresh();
      final allIdx = allTerrains.indexWhere((t) => t.id == id);
      if (allIdx != -1) allTerrains[allIdx].isActive = newStatus;
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le statut',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void deleteConfirm(String id) {
    Get.defaultDialog(
      title: 'Supprimer le terrain',
      middleText: 'Cette action est irréversible. Confirmer ?',
      textConfirm: 'Supprimer',
      textCancel: 'Annuler',
      onConfirm: () async {
        Get.back();
        try {
          await _service.supprimerTerrain(id);
          terrains.removeWhere((t) => t.id == id);
          allTerrains.removeWhere((t) => t.id == id);
          Get.snackbar(
            'Succès',
            'Terrain supprimé',
            snackPosition: SnackPosition.TOP,
          );
        } catch (e) {
          Get.snackbar(
            'Erreur',
            'Impossible de supprimer le terrain',
            snackPosition: SnackPosition.TOP,
          );
        }
      },
    );
  }

  void goToForm(TerrainModel? terrain) {
    selectedTerrain.value = terrain;
    Get.toNamed(Routes.terrainForm);
  }

  Future<void> saveTerrain({
    required String name,
    required String address,
    required String zone,
    required int pricePerHour,
    required double lat,
    required double lng,
    String? description,
    required List<String> features,
    List<File> images = const [],
    String? managerId,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'address': address,
      'zone': zone,
      'pricePerHour': pricePerHour,
      'lat': lat,
      'lng': lng,
      if (description != null && description.isNotEmpty)
        'description': description,
      'features': features,
    };

    final terrain = selectedTerrain.value;
    final String terrainId;

    if (terrain == null) {
      final createData = <String, dynamic>{...data};
      if (managerId != null) createData['managerId'] = managerId;
      final result = await _service.creerTerrain(createData);
      terrainId = result['id'] as String;
    } else {
      await _service.modifierTerrain(terrain.id, data);
      terrainId = terrain.id;
    }

    if (images.isNotEmpty) {
      await _service.uploadImages(terrainId, images);
    }

    await loadTerrains();
  }

  void goBack() => Get.back();
}
