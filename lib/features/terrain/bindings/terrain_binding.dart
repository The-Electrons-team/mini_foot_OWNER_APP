import 'package:get/get.dart';
import '../controllers/terrain_controller.dart';

class TerrainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TerrainController>(() => TerrainController());
  }
}
