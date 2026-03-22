import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final obscurePass = true.obs;
  final obscureConfirm = true.obs;

  void toggleObscure() => obscurePass.value = !obscurePass.value;
  void toggleObscureConfirm() => obscureConfirm.value = !obscureConfirm.value;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.offAllNamed(Routes.dashboard);
  }

  Future<void> register(String name, String phone, String email, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.offAllNamed(Routes.dashboard);
  }

  void goToLogin() => Get.toNamed(Routes.login);
  void goToRegister() => Get.toNamed(Routes.register);
}
