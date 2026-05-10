import 'package:get/get.dart';
import '../controllers/controllers_controller.dart';

class ControllersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ControllersController>(() => ControllersController());
  }
}
