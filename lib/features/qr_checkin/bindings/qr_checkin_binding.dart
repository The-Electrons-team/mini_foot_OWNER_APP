import 'package:get/get.dart';

import '../controllers/qr_checkin_controller.dart';

class QrCheckInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrCheckInController>(() => QrCheckInController());
  }
}
