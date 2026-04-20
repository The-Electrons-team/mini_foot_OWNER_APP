import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Use computed values from AuthController user
  RxString get ownerName => '${_authController.user.value?.firstName ?? ""} ${_authController.user.value?.lastName ?? ""}'.trim().obs;
  RxString get phone => (_authController.user.value?.phone ?? "Pas de numéro").obs;
  
  // Mock data for other fields (until we have real stats from backend)
  final email         = 'mamadou.sy@minifoot.sn'.obs;
  final totalTerrains = 0.obs;
  final memberSince   = 'Avril 2024'.obs;
  final totalBookings = 0.obs;
  final rating        = 5.0.obs;
  final totalRevenue  = 0.obs;
  final planName      = 'Gratuit'.obs;
  final planExpiry    = 'N/A'.obs;

  final isEditing = false.obs;

  void toggleEdit() => isEditing.toggle();

  void logout() {
    _authController.logout();
  }

  String get initials {
    final name = ownerName.value;
    if (name.isEmpty) return "??";
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  String formatRevenue(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
