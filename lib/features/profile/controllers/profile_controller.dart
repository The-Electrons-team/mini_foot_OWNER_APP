import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/reservation_service.dart';
import '../../../core/services/terrain_service.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final AuthService _authService = AuthService();
  final TerrainService _terrainService = TerrainService();
  final ReservationService _reservationService = ReservationService();

  final ownerName = 'Propriétaire'.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;
  final phone = 'Pas de numéro'.obs;
  final avatarUrl = RxnString();
  final payoutWavePhone = RxnString();
  final payoutOrangePhone = RxnString();
  final payoutFreePhone = RxnString();
  final preferredPayoutMethod = RxnString();
  final memberSince = '—'.obs;
  final profileStatus = 'Compte actif'.obs;
  final totalTerrains = 0.obs;
  final totalBookings = 0.obs;
  final rating = 0.0.obs;
  final totalRevenue = 0.obs;
  final planName = 'Owner'.obs;
  final planExpiry = 'Sans expiration'.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;
  final isSavingPayout = false.obs;
  final isChangingPhone = false.obs;
  final phoneOtpSent = false.obs;
  final isChangingPassword = false.obs;
  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final wavePhoneCtrl = TextEditingController();
  final orangePhoneCtrl = TextEditingController();
  final freePhoneCtrl = TextEditingController();
  final nextPhoneCtrl = TextEditingController();
  final phoneOtpCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _syncUser(_authController.user.value);
    loadProfile();
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    wavePhoneCtrl.dispose();
    orangePhoneCtrl.dispose();
    freePhoneCtrl.dispose();
    nextPhoneCtrl.dispose();
    phoneOtpCtrl.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final token = _authController.token.value;
      if (token != null && token.isNotEmpty) {
        final userData = await _authService.getProfile(token);
        final user = UserModel.fromJson(userData);
        _authController.user.value = user;
        _syncUser(user);
      }

      final terrains = await _terrainService.getMesTerrains();
      final reservations = await _reservationService.getOwnerReservations();

      totalTerrains.value = terrains.length;
      totalBookings.value = reservations.length;
      rating.value = _averageRating(terrains);
      totalRevenue.value = _confirmedRevenue(reservations);
    } catch (_) {
      Get.snackbar(
        'Profil',
        'Impossible de rafraîchir toutes les informations',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    final token = _authController.token.value;
    if (token == null || token.isEmpty) return;

    final nextFirstName = firstNameCtrl.text.trim();
    final nextLastName = lastNameCtrl.text.trim();
    if (nextFirstName.isEmpty || nextLastName.isEmpty) {
      Get.snackbar(
        'Profil',
        'Le prénom et le nom sont obligatoires',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSaving.value = true;
    try {
      final updated = await _authService.updateProfile(token, {
        'firstName': nextFirstName,
        'lastName': nextLastName,
      });
      final user = UserModel.fromJson(updated);
      _authController.user.value = user;
      _syncUser(user);
      Get.snackbar(
        'Profil mis à jour',
        'Vos informations ont été enregistrées',
        snackPosition: SnackPosition.TOP,
      );
      Get.back();
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le profil',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAndUploadAvatar(ImageSource source) async {
    final token = _authController.token.value;
    if (token == null || token.isEmpty) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image == null) return;

      isUploadingAvatar.value = true;
      final updated = await _authService.uploadAvatar(
        token: token,
        image: File(image.path),
      );
      final user = UserModel.fromJson(updated);
      _authController.user.value = user;
      _syncUser(user);
      Get.snackbar(
        'Photo mise à jour',
        'Votre photo de profil a été enregistrée',
        snackPosition: SnackPosition.TOP,
      );
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la photo',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void resetForm() {
    firstNameCtrl.text = firstName.value;
    lastNameCtrl.text = lastName.value;
  }

  void resetPasswordForm() {
    currentPasswordCtrl.clear();
    newPasswordCtrl.clear();
    confirmPasswordCtrl.clear();
    obscureCurrentPassword.value = true;
    obscureNewPassword.value = true;
    obscureConfirmPassword.value = true;
  }

  void resetPayoutForm() {
    wavePhoneCtrl.text = _localPhone(payoutWavePhone.value);
    orangePhoneCtrl.text = _localPhone(payoutOrangePhone.value);
    freePhoneCtrl.text = _localPhone(payoutFreePhone.value);
  }

  void selectPreferredPayoutMethod(String method) {
    preferredPayoutMethod.value = method;
  }

  Future<void> savePayoutInfo() async {
    final token = _authController.token.value;
    if (token == null || token.isEmpty) return;

    final wave = _fullPhoneOrNull(wavePhoneCtrl.text);
    final orange = _fullPhoneOrNull(orangePhoneCtrl.text);
    final free = _fullPhoneOrNull(freePhoneCtrl.text);
    final preferred =
        preferredPayoutMethod.value ??
        (wave != null
            ? 'WAVE'
            : orange != null
            ? 'ORANGE_MONEY'
            : free != null
            ? 'FREE_MONEY'
            : null);

    if ([wave, orange, free].whereType<String>().isEmpty) {
      Get.snackbar(
        'Coordonnées',
        'Ajoutez au moins un numéro de reversement',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (preferred != null &&
        _phoneForMethod(preferred, wave, orange, free) == null) {
      Get.snackbar(
        'Coordonnées',
        'Ajoutez le numéro de la méthode préférée',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSavingPayout.value = true;
    try {
      final updated = await _authService.updatePayoutInfo(token, {
        'payoutWavePhone': wave,
        'payoutOrangePhone': orange,
        'payoutFreePhone': free,
        'preferredPayoutMethod': preferred,
      });
      payoutWavePhone.value = updated['payoutWavePhone'];
      payoutOrangePhone.value = updated['payoutOrangePhone'];
      payoutFreePhone.value = updated['payoutFreePhone'];
      preferredPayoutMethod.value = updated['preferredPayoutMethod'];
      resetPayoutForm();
      Get.snackbar(
        'Coordonnées enregistrées',
        'Vos numéros de reversement sont à jour',
        snackPosition: SnackPosition.TOP,
      );
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer les coordonnées',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSavingPayout.value = false;
    }
  }

  void resetPhoneChangeForm() {
    nextPhoneCtrl.clear();
    phoneOtpCtrl.clear();
    phoneOtpSent.value = false;
  }

  Future<void> requestPhoneChange() async {
    final token = _authController.token.value;
    if (token == null || token.isEmpty) return;

    final nextPhone = _fullPhoneOrNull(nextPhoneCtrl.text);
    if (nextPhone == null) {
      Get.snackbar(
        'Téléphone',
        'Entrez un numéro sénégalais valide',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isChangingPhone.value = true;
    try {
      await _authService.requestPhoneChange(token: token, phone: nextPhone);
      phoneOtpSent.value = true;
      Get.snackbar(
        'Code envoyé',
        'Un code OTP a été envoyé au nouveau numéro',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      final message = e.toString().contains('PHONE_ALREADY_USED')
          ? 'Ce numéro est déjà utilisé'
          : 'Impossible d\'envoyer le code';
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.TOP);
    } finally {
      isChangingPhone.value = false;
    }
  }

  Future<void> confirmPhoneChange() async {
    final token = _authController.token.value;
    if (token == null || token.isEmpty) return;

    final nextPhone = _fullPhoneOrNull(nextPhoneCtrl.text);
    final code = phoneOtpCtrl.text.trim();
    if (nextPhone == null || code.length != 6) {
      Get.snackbar(
        'Téléphone',
        'Vérifiez le numéro et le code OTP',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isChangingPhone.value = true;
    try {
      final updated = await _authService.confirmPhoneChange(
        token: token,
        phone: nextPhone,
        code: code,
      );
      final user = UserModel.fromJson(updated);
      _authController.user.value = user;
      _syncUser(user);
      resetPhoneChangeForm();
      Get.back();
      Get.snackbar(
        'Téléphone mis à jour',
        'Votre nouveau numéro est actif',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      final message = e.toString().contains('CODE_INVALIDE')
          ? 'Code invalide ou expiré'
          : e.toString().contains('PHONE_ALREADY_USED')
          ? 'Ce numéro est déjà utilisé'
          : 'Impossible de changer le téléphone';
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.TOP);
    } finally {
      isChangingPhone.value = false;
    }
  }

  Future<void> changePassword() async {
    final token = _authController.token.value;
    if (token == null || token.isEmpty) return;

    final currentPassword = currentPasswordCtrl.text.trim();
    final newPassword = newPasswordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Mot de passe',
        'Tous les champs sont obligatoires',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Mot de passe',
        'Le nouveau mot de passe doit contenir au moins 6 caractères',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Mot de passe',
        'Les deux nouveaux mots de passe ne correspondent pas',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isChangingPassword.value = true;
    try {
      await _authService.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      resetPasswordForm();
      Get.snackbar(
        'Mot de passe mis à jour',
        'Votre nouveau mot de passe est actif',
        snackPosition: SnackPosition.TOP,
      );
      Get.back();
    } catch (e) {
      final message = e.toString().contains('MOT_DE_PASSE_ACTUEL_INCORRECT')
          ? 'Le mot de passe actuel est incorrect'
          : 'Impossible de modifier le mot de passe';
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.TOP);
    } finally {
      isChangingPassword.value = false;
    }
  }

  void logout() {
    _authController.logout();
  }

  String get initials {
    final name = ownerName.value.trim();
    if (name.isEmpty) return '??';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first.length >= 2
        ? parts.first.substring(0, 2).toUpperCase()
        : parts.first[0].toUpperCase();
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

  void _syncUser(UserModel? user) {
    if (user == null) return;
    final userJson = user.toJson();
    firstName.value = user.firstName;
    lastName.value = user.lastName;
    ownerName.value = '${user.firstName} ${user.lastName}'.trim();
    phone.value = user.phone.isEmpty ? 'Pas de numéro' : user.phone;
    avatarUrl.value = user.avatarUrl;
    payoutWavePhone.value = userJson['payoutWavePhone']?.toString();
    payoutOrangePhone.value = userJson['payoutOrangePhone']?.toString();
    payoutFreePhone.value = userJson['payoutFreePhone']?.toString();
    preferredPayoutMethod.value = userJson['preferredPayoutMethod']?.toString();
    memberSince.value = _formatMemberSince(user.createdAt);
    firstNameCtrl.text = user.firstName;
    lastNameCtrl.text = user.lastName;
    resetPayoutForm();
  }

  String _localPhone(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.startsWith('+221') ? value.substring(4) : value;
  }

  String? _fullPhoneOrNull(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length != 9) return null;
    return '+221$digits';
  }

  String? _phoneForMethod(
    String method,
    String? wave,
    String? orange,
    String? free,
  ) {
    switch (method) {
      case 'WAVE':
        return wave;
      case 'ORANGE_MONEY':
        return orange;
      case 'FREE_MONEY':
        return free;
      default:
        return null;
    }
  }

  double _averageRating(List<dynamic> terrains) {
    final ratings = terrains
        .map(
          (terrain) => terrain is Map<String, dynamic> ? terrain['rating'] : 0,
        )
        .whereType<num>()
        .map((rating) => rating.toDouble())
        .toList();
    if (ratings.isEmpty) return 0;
    final sum = ratings.fold<double>(0, (acc, rating) => acc + rating);
    return double.parse((sum / ratings.length).toStringAsFixed(1));
  }

  int _confirmedRevenue(List<dynamic> reservations) {
    return reservations.fold<int>(0, (sum, item) {
      if (item is! Map<String, dynamic>) return sum;
      final status = item['status']?.toString();
      if (status != 'CONFIRMED' && status != 'COMPLETED') return sum;
      final price = item['finalPrice'] ?? item['totalPrice'] ?? 0;
      if (price is num) return sum + price.toInt();
      return sum + (int.tryParse(price.toString()) ?? 0);
    });
  }

  String _formatMemberSince(String? createdAt) {
    final date = DateTime.tryParse(createdAt ?? '')?.toLocal();
    if (date == null) return '—';
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }
}
