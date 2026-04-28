import 'package:get/get.dart';
import '../controllers/revenues_controller.dart';

class RevenuesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RevenuesController>(() => RevenuesController());
  }
}
