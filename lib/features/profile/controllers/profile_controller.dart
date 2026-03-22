import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final ownerName     = 'Mamadou Sy'.obs;
  final phone         = '+221 77 123 45 67'.obs;
  final email         = 'mamadou.sy@minifoot.sn'.obs;
  final totalTerrains = 3.obs;
  final memberSince   = 'Janvier 2025'.obs;
  final totalBookings = 128.obs;
  final rating        = 4.8.obs;
  final totalRevenue  = 485000.obs;
  final planName      = 'Premium'.obs;
  final planExpiry    = '22 Juin 2026'.obs;

  final isEditing = false.obs;

  // Profile completion
  int get completionPercent {
    int done = 0;
    if (ownerName.value.isNotEmpty) done++;
    if (email.value.isNotEmpty) done++;
    if (phone.value.isNotEmpty) done++;
    if (totalTerrains.value > 0) done++;
    // 4 out of 5 = 80%
    return ((done / 5) * 100).round();
  }

  String get completionLabel {
    final p = completionPercent;
    if (p >= 100) return 'Profil complet';
    return 'Profil complete a $p%';
  }

  void toggleEdit() => isEditing.toggle();

  void logout() {
    Get.offAllNamed(Routes.login);
  }

  String get initials {
    final parts = ownerName.value.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return ownerName.value.substring(0, 2).toUpperCase();
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
