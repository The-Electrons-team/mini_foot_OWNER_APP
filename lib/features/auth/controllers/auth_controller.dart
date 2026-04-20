import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  final token = RxnString();
  
  // States for obscure text (still used in some screens perhaps, but we might remove them later)
  final obscurePass = true.obs;
  final obscureConfirm = true.obs;

  @override
  void onInit() {
    super.onInit();
    // tryAutoLogin will be called from Splash
  }

  void toggleObscure() => obscurePass.value = !obscurePass.value;
  void toggleObscureConfirm() => obscureConfirm.value = !obscureConfirm.value;

  void goToRegister() => Get.toNamed(Routes.register);
  void goToLogin() => Get.back();

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    
    if (savedToken == null) return false;
    
    try {
      final userData = await _authService.getProfile(savedToken);
      token.value = savedToken;
      user.value = UserModel.fromJson(userData);
      return true;
    } catch (e) {
      prefs.remove('token');
      return false;
    }
  }

  Future<void> startLogin(String phone, String password) async {
    isLoading.value = true;
    try {
      final res = await _authService.login(phone, password);
      if (res['token'] != null) {
        token.value = res['token'];
        user.value = UserModel.fromJson(res['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.value!);
        
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      String message = 'Erreur de connexion';
      if (e.toString().contains('COMPTE_NON_TROUVE')) {
        message = 'Compte non trouvé. Veuillez vous inscrire.';
      } else if (e.toString().contains('ID_INVALIDES')) {
        message = 'Mot de passe incorrect.';
      }
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.TOP);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startSignup(String phone) async {
    isLoading.value = true;
    try {
      await _authService.startSignup(phone);
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceAll('Exception: ', ''));
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAndRegister({
    required String phone,
    required String password,
    required String code,
    required String firstName,
    required String lastName,
    DateTime? birthDate,
  }) async {
    isLoading.value = true;
    try {
      // 1. Verify OTP
      final isVerified = await _authService.verifyOtp(phone, code);
      if (isVerified['verified'] == true) {
        // 2. Register
        final res = await _authService.register(
          phone: phone,
          password: password,
          firstName: firstName,
          lastName: lastName,
          birthDate: birthDate?.toIso8601String(),
        );
        
        token.value = res['token'];
        user.value = UserModel.fromJson(res['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.value!);
        
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    token.value = null;
    user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAllNamed(Routes.login);
  }
}
