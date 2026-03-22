import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class TerrainModel {
  final String id;
  final String name;
  final String address;
  final String? description;
  final int price;
  final String capacity;
  final String surface; // Gazon synthétique, Gazon naturel, Terre battue
  final String dimensions;
  final String imageUrl;
  final bool isAsset;
  final int overlayColor;
  final double rating;
  bool status;
  final int bookingsThisMonth;

  TerrainModel({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    required this.price,
    required this.capacity,
    this.surface = 'Gazon synthétique',
    this.dimensions = '40 x 25 m',
    required this.imageUrl,
    this.isAsset = false,
    this.overlayColor = 0xFF006F39,
    required this.rating,
    required this.status,
    required this.bookingsThisMonth,
  });
}

class TerrainController extends GetxController {
  final terrains = <TerrainModel>[].obs;
  final isLoading = false.obs;
  final selectedTerrain = Rxn<TerrainModel>();

  @override
  void onInit() {
    super.onInit();
    _loadMockTerrains();
  }

  void _loadMockTerrains() {
    terrains.value = [
      TerrainModel(
        id: '1',
        name: 'Terrain Alpha',
        address: 'Cité Keur Gorgui, Dakar',
        description: 'Terrain moderne avec gazon synthétique de haute qualité et éclairage LED. Idéal pour les matchs en soirée.',
        price: 8000,
        capacity: '5v5',
        surface: 'Gazon synthétique',
        dimensions: '40 x 25 m',
        imageUrl: 'assets/images/terrain.webp',
        isAsset: true,
        overlayColor: 0xFF006F39,
        rating: 4.8,
        status: true,
        bookingsThisMonth: 24,
      ),
      TerrainModel(
        id: '2',
        name: 'Terrain Beta',
        address: 'Almadies, Dakar',
        description: 'Terrain en gazon naturel avec vue sur mer. Parking gratuit et vestiaires disponibles.',
        price: 10000,
        capacity: '7v7',
        surface: 'Gazon naturel',
        dimensions: '60 x 40 m',
        imageUrl: 'assets/images/terrain.webp',
        isAsset: true,
        overlayColor: 0xFF1565C0,
        rating: 4.5,
        status: true,
        bookingsThisMonth: 18,
      ),
      TerrainModel(
        id: '3',
        name: 'Terrain Omega',
        address: 'Plateau, Dakar',
        description: 'Grand terrain officiel au cœur du Plateau. Idéal pour les compétitions et tournois.',
        price: 15000,
        capacity: '11v11',
        surface: 'Gazon synthétique',
        dimensions: '105 x 68 m',
        imageUrl: 'assets/images/terrain.webp',
        isAsset: true,
        overlayColor: 0xFFE65100,
        rating: 4.2,
        status: false,
        bookingsThisMonth: 8,
      ),
    ];
  }

  Future<void> refreshTerrains() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _loadMockTerrains();
    isLoading.value = false;
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      _loadMockTerrains();
    } else {
      terrains.value = terrains
          .where((t) =>
              t.name.toLowerCase().contains(query.toLowerCase()) ||
              t.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  int get totalTerrains => terrains.length;
  int get activeTerrains => terrains.where((t) => t.status).length;

  void toggleStatus(String id) {
    final idx = terrains.indexWhere((t) => t.id == id);
    if (idx != -1) {
      terrains[idx].status = !terrains[idx].status;
      terrains.refresh();
    }
  }

  void deleteConfirm(String id) {
    Get.defaultDialog(
      title: 'Supprimer le terrain',
      middleText: 'Confirmer la suppression de ce terrain ?',
      textConfirm: 'Supprimer',
      textCancel: 'Annuler',
      onConfirm: () {
        terrains.removeWhere((t) => t.id == id);
        Get.back();
      },
    );
  }

  void goToForm(TerrainModel? terrain) {
    selectedTerrain.value = terrain;
    Get.toNamed(Routes.terrainForm);
  }

  void goBack() => Get.back();
}
