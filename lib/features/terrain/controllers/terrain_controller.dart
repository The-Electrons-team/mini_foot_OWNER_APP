import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class TerrainModel {
  final String id;
  final String name;
  final String address;
  final int price;
  final String capacity;
  final String surface; // Gazon synthétique, Gazon naturel, Terre battue
  final String imageUrl;
  final bool isAsset;
  final int overlayColor; // couleur overlay pour différencier visuellement
  final double rating;
  bool status;
  final int bookingsThisMonth;

  TerrainModel({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.capacity,
    this.surface = 'Gazon synthétique',
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
        price: 8000,
        capacity: '5v5',
        surface: 'Gazon synthétique',
        imageUrl: 'assets/images/terrain.webp',
        isAsset: true,
        overlayColor: 0xFF006F39, // vert
        rating: 4.8,
        status: true,
        bookingsThisMonth: 24,
      ),
      TerrainModel(
        id: '2',
        name: 'Terrain Beta',
        address: 'Almadies, Dakar',
        price: 10000,
        capacity: '7v7',
        surface: 'Gazon naturel',
        imageUrl: 'assets/images/terrain.webp',
        isAsset: true,
        overlayColor: 0xFF1565C0, // bleu
        rating: 4.5,
        status: true,
        bookingsThisMonth: 18,
      ),
      TerrainModel(
        id: '3',
        name: 'Terrain Omega',
        address: 'Plateau, Dakar',
        price: 15000,
        capacity: '11v11',
        surface: 'Gazon synthétique',
        imageUrl: 'assets/images/terrain.webp',
        isAsset: true,
        overlayColor: 0xFFE65100, // orange
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
