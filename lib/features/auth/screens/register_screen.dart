import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    // Pour l'indicateur de force du mot de passe
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
        passwordStrengthColor.value = Colors.red;
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

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Green accent bar ──────────────────────────────────────
              Container(
                width: double.infinity,
                height: 4,
                decoration: const BoxDecoration(gradient: kGreenGradient),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Back Button ──
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
                          PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone),
                          color: kTextPrim,
                          size: 20,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 24),

                    // ── Title ──
                    const Text(
                      'Cr\u00e9er votre compte',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: kTextPrim,
                        height: 1.3,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    const Text(
                      'Rejoignez des milliers de propri\u00e9taires\nde terrains sur MiniFoot',
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextSub,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 28),

                    // ── Form Card ───────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kBgCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: kCardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Nom complet ──
                          _buildField(
                            label: 'Nom complet',
                            ctrl: nameCtrl,
                            icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                            hint: 'Mamadou Sy',
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),

                          const SizedBox(height: 18),

                          // ── Telephone ──
                          _buildField(
                            label: 'T\u00e9l\u00e9phone',
                            ctrl: phoneCtrl,
                            icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
                            hint: '+221 77 000 00 00',
                            keyboardType: TextInputType.phone,
                          ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.15, end: 0),

                          const SizedBox(height: 18),

                          // ── Email ──
                          _buildField(
                            label: 'Email',
                            ctrl: emailCtrl,
                            icon: PhosphorIcons.envelope(PhosphorIconsStyle.duotone),
                            hint: 'votre@email.com',
                            keyboardType: TextInputType.emailAddress,
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.15, end: 0),

                          const SizedBox(height: 18),

                          // ── Mot de passe ──
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
                                      hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
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

                              // ── Password Strength Indicator ──
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
                                        const SizedBox(height: 6),
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
                          ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.15, end: 0),

                          const SizedBox(height: 18),

                          // ── Confirmer mot de passe ──
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
                                      hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                                      prefixIcon: Icon(
                                        PhosphorIcons.lock(PhosphorIconsStyle.duotone),
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
                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.15, end: 0),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── CGU Checkbox ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: kGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            PhosphorIcons.check(PhosphorIconsStyle.duotone),
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
                              children: [
                                TextSpan(text: "J'accepte les "),
                                TextSpan(
                                  text: "Conditions d'utilisation",
                                  style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: " et la "),
                                TextSpan(
                                  text: "Politique de confidentialit\u00e9",
                                  style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

                    const SizedBox(height: 24),

                    // ── Register Button ──
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.register(
                                      nameCtrl.text,
                                      phoneCtrl.text,
                                      emailCtrl.text,
                                      passCtrl.text,
                                    ),
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
                                        'Cr\u00e9er mon compte',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        PhosphorIcons.userPlus(PhosphorIconsStyle.duotone),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        )).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // ── Login Link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'D\u00e9j\u00e0 un compte ? ',
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
                    ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

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

  /// Construit un champ texte standard avec label et ic\u00f4ne Phosphor
  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
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

// ─── Label Widget ───────────────────────────────────────────────────────────

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
