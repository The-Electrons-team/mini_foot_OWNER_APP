import 'package:get/get.dart';
import '../controllers/availability_controller.dart';

class AvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AvailabilityController>(() => AvailabilityController());
  }
}
