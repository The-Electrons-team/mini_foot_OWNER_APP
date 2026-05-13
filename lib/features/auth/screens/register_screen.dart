import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
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
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final birthDate = Rxn<DateTime>();

    void selectDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime(now.year - 18, 1, 1),
        firstDate: DateTime(1930),
        lastDate: DateTime(now.year - 5),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: kGreen,
                onPrimary: Colors.white,
                onSurface: kTextPrim,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) birthDate.value = picked;
    }

    void submit() async {
      final phone = '+221${phoneCtrl.text.trim()}';
      if (prenomCtrl.text.trim().isEmpty ||
          nomCtrl.text.trim().isEmpty ||
          phoneCtrl.text.trim().isEmpty ||
          passCtrl.text.trim().isEmpty ||
          birthDate.value == null) {
        Get.snackbar(
          'Champs requis',
          'Veuillez remplir tous les champs personnels et le mot de passe',
          backgroundColor: kRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      if (passCtrl.text != confirmPassCtrl.text) {
        Get.snackbar(
          'Erreur',
          'Les mots de passe ne correspondent pas',
          backgroundColor: kRed,
          colorText: Colors.white,
        );
        return;
      }
      
      if (passCtrl.text.length < 6) {
        Get.snackbar(
          'Erreur',
          'Le mot de passe doit faire au moins 6 caractères',
          backgroundColor: kRed,
          colorText: Colors.white,
        );
        return;
      }

      await controller.startSignup(
        phone: phone,
        firstName: prenomCtrl.text.trim(),
        lastName: nomCtrl.text.trim(),
        password: passCtrl.text.trim(),
        birthDate: birthDate.value?.toIso8601String(),
      );

      Get.to(
        () => OtpScreen(phone: phone, isNewUser: true),
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
                      'Créer votre compte',
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
                      'Rejoignez des milliers de propriétaires\nde terrains sur MiniFoot',
                      style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
                    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 28),

                    // Section identité
                    _SectionHeader(
                      icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.duotone),
                      label: 'Identité',
                    ).animate().fadeIn(duration: 400.ms, delay: 180.ms),

                    const SizedBox(height: 14),

                    // Prénom + Nom côte à côte
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Prénom',
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

                    // Date de naissance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Date de naissance'),
                        const SizedBox(height: 8),
                        Obx(() => GestureDetector(
                              onTap: selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: kBgSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kBorder),
                                ),
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.calendar(PhosphorIconsStyle.duotone),
                                        color: kTextLight, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      birthDate.value == null
                                          ? 'Sélectionner une date'
                                          : DateFormat('dd/MM/yyyy').format(birthDate.value!),
                                      style: TextStyle(
                                        color: birthDate.value == null ? kTextLight : kTextPrim,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 240.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // Section contact
                    _SectionHeader(
                      icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
                      label: 'Contact',
                    ).animate().fadeIn(duration: 400.ms, delay: 260.ms),

                    const SizedBox(height: 14),

                    // Téléphone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Numéro de téléphone'),
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

                    // Section Sécurité
                    _SectionHeader(
                      icon: PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                      label: 'Sécurité',
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 14),

                    _buildField(
                      label: 'Mot de passe',
                      ctrl: passCtrl,
                      icon: PhosphorIcons.lockSimple(PhosphorIconsStyle.duotone),
                      hint: '••••••••',
                      isPassword: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 320.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    _buildField(
                      label: 'Confirmer le mot de passe',
                      ctrl: confirmPassCtrl,
                      icon: PhosphorIcons.lockKey(PhosphorIconsStyle.duotone),
                      hint: '••••••••',
                      isPassword: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 340.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 32),

                    // Info OTP
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kGreen.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kGreen.withValues(alpha: 0.2)),
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
                              'Un code de vérification sera envoyé sur votre téléphone pour valider votre identité.',
                              style: TextStyle(
                                fontSize: 13,
                                color: kGreen,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 32),

                    // Bouton créer
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
                                        'Recevoir le code de vérification',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
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
                        )).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Lien connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
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
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

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
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final obscure = true.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 8),
        isPassword 
          ? Obx(() => TextField(
              controller: ctrl,
              keyboardType: keyboardType,
              obscureText: obscure.value,
              inputFormatters: inputFormatters,
              style: const TextStyle(color: kTextPrim, fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: kTextLight, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure.value ? PhosphorIcons.eyeClosed() : PhosphorIcons.eye(),
                    color: kTextLight,
                  ),
                  onPressed: () => obscure.toggle(),
                ),
              ),
            ))
          : TextField(
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
