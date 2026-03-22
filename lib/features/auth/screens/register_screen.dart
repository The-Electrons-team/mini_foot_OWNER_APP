import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import 'otp_screen.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prenomCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cniCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final passwordStrength = 0.0.obs;
    final passwordStrengthColor = kBorder.obs;
    final passwordStrengthLabel = ''.obs;

    void updatePasswordStrength(String value) {
      if (value.isEmpty) {
        passwordStrength.value = 0;
        passwordStrengthColor.value = kBorder;
        passwordStrengthLabel.value = '';
      } else if (value.length < 6) {
        passwordStrength.value = 0.33;
        passwordStrengthColor.value = kRed;
        passwordStrengthLabel.value = 'Faible';
      } else if (value.length <= 8) {
        passwordStrength.value = 0.66;
        passwordStrengthColor.value = kGold;
        passwordStrengthLabel.value = 'Moyen';
      } else {
        passwordStrength.value = 1.0;
        passwordStrengthColor.value = kGreen;
        passwordStrengthLabel.value = 'Fort';
      }
    }

    void submit() {
      final phone = phoneCtrl.text.trim();
      if (prenomCtrl.text.trim().isEmpty ||
          nomCtrl.text.trim().isEmpty ||
          phone.isEmpty ||
          cniCtrl.text.trim().isEmpty ||
          passCtrl.text.isEmpty) {
        Get.snackbar(
          'Champs requis',
          'Veuillez remplir tous les champs',
          backgroundColor: kRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      if (passCtrl.text != confirmCtrl.text) {
        Get.snackbar(
          'Erreur',
          'Les mots de passe ne correspondent pas',
          backgroundColor: kRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      Get.to(
        () => OtpScreen(phone: phone),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Bouton retour
                    GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kBgSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                          color: kTextPrim,
                          size: 20,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 24),

                    // Titre
                    const Text(
                      'Creer votre compte',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: kTextPrim,
                        height: 1.3,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 6),

                    const Text(
                      'Rejoignez des milliers de proprietaires\nde terrains sur MiniFoot',
                      style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
                    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 28),

                    // Section identite
                    _SectionHeader(
                      icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.duotone),
                      label: 'Identite',
                    ).animate().fadeIn(duration: 400.ms, delay: 180.ms),

                    const SizedBox(height: 14),

                    // Prenom + Nom cote a cote
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Prenom',
                            ctrl: prenomCtrl,
                            icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                            hint: 'Mamadou',
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: 'Nom',
                            ctrl: nomCtrl,
                            icon: PhosphorIcons.userCircle(PhosphorIconsStyle.duotone),
                            hint: 'Diallo',
                          ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.15, end: 0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CNI
                    _buildField(
                      label: 'Numero CNI',
                      ctrl: cniCtrl,
                      icon: PhosphorIcons.identificationBadge(PhosphorIconsStyle.duotone),
                      hint: '1 234 567 890 12',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ).animate().fadeIn(duration: 400.ms, delay: 240.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // Section contact
                    _SectionHeader(
                      icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
                      label: 'Contact',
                    ).animate().fadeIn(duration: 400.ms, delay: 260.ms),

                    const SizedBox(height: 14),

                    // Telephone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Numero de telephone'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          style: const TextStyle(color: kTextPrim, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: '77 000 00 00',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('\u{1F1F8}\u{1F1F3}', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 6),
                                  Text(
                                    '+221',
                                    style: TextStyle(
                                      color: kTextPrim,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text('|', style: TextStyle(color: kBorder, fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // Section securite
                    _SectionHeader(
                      icon: PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                      label: 'Securite',
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 14),

                    // Mot de passe
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Mot de passe'),
                        const SizedBox(height: 8),
                        Obx(() => TextField(
                              controller: passCtrl,
                              obscureText: controller.obscurePass.value,
                              onChanged: updatePasswordStrength,
                              style: const TextStyle(color: kTextPrim, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: '........',
                                prefixIcon: Icon(
                                  PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                                  color: kTextLight,
                                  size: 20,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: controller.toggleObscure,
                                  child: Icon(
                                    controller.obscurePass.value
                                        ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.duotone)
                                        : PhosphorIcons.eye(PhosphorIconsStyle.duotone),
                                    color: kTextLight,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(height: 10),
                        Obx(() => passwordStrength.value > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: passwordStrength.value,
                                      backgroundColor: kBorder,
                                      color: passwordStrengthColor.value,
                                      minHeight: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    passwordStrengthLabel.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: passwordStrengthColor.value,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink()),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 320.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // Confirmer mot de passe
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Confirmer le mot de passe'),
                        const SizedBox(height: 8),
                        Obx(() => TextField(
                              controller: confirmCtrl,
                              obscureText: controller.obscureConfirm.value,
                              style: const TextStyle(color: kTextPrim, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: '........',
                                prefixIcon: Icon(
                                  PhosphorIcons.lockKey(PhosphorIconsStyle.duotone),
                                  color: kTextLight,
                                  size: 20,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: controller.toggleObscureConfirm,
                                  child: Icon(
                                    controller.obscureConfirm.value
                                        ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.duotone)
                                        : PhosphorIcons.eye(PhosphorIconsStyle.duotone),
                                    color: kTextLight,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 360.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 28),

                    // Info OTP
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kGreenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
                            color: kGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Un code OTP a 6 chiffres sera envoye sur votre telephone pour valider votre compte.',
                              style: TextStyle(
                                fontSize: 13,
                                color: kGreen,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                    const SizedBox(height: 24),

                    // Bouton creer
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: kGreen.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Recevoir le code OTP',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.duotone),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        )).animate().fadeIn(duration: 400.ms, delay: 440.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Lien connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Deja un compte ? ',
                          style: TextStyle(color: kTextSub, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: controller.goToLogin,
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: kGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 480.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: kTextPrim, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: kTextLight, size: 20),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kGreen, size: 18),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kGreen,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: kBorder),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kTextSub,
        ),
      );
}
