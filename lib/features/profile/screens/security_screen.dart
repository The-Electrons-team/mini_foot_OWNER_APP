import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class SecurityScreen extends GetView<ProfileController> {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBgCard,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kTextPrim, size: 18),
          ),
        ),
        title: const Text(
          'Securite',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password section
            _buildSectionTitle('Mot de passe'),
            const SizedBox(height: 12),
            _buildPasswordSection()
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 28),

            // 2FA section
            _buildSectionTitle('Authentification 2FA'),
            const SizedBox(height: 12),
            _build2FASection()
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 28),

            // Active sessions
            _buildSectionTitle('Sessions actives'),
            const SizedBox(height: 12),
            _buildSessionCard(
              deviceName: 'Samsung Galaxy A12',
              lastLogin: 'Aujourd\'hui, 14:32',
              ipAddress: '192.168.1.45',
              icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.duotone),
              isCurrent: true,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideX(begin: -0.05, end: 0),
            const SizedBox(height: 12),
            _buildSessionCard(
              deviceName: 'iPhone 14',
              lastLogin: 'Hier, 09:15',
              ipAddress: '10.0.0.22',
              icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.duotone),
              isCurrent: false,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideX(begin: -0.05, end: 0),
            const SizedBox(height: 12),
            _buildSessionCard(
              deviceName: 'Chrome Desktop',
              lastLogin: '18 Mars, 20:45',
              ipAddress: '197.149.65.120',
              icon: PhosphorIcons.desktop(PhosphorIconsStyle.duotone),
              isCurrent: false,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideX(begin: -0.05, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kTextLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    final obscureCurrent = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;
    final strengthValue = 0.0.obs;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          // Current password
          Obx(() => _buildPasswordField(
                label: 'Mot de passe actuel',
                hint: 'Entrez votre mot de passe',
                icon: PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                obscure: obscureCurrent.value,
                onToggle: () => obscureCurrent.toggle(),
              )),
          const SizedBox(height: 16),

          // New password
          Obx(() => _buildPasswordField(
                label: 'Nouveau mot de passe',
                hint: 'Minimum 8 caracteres',
                icon: PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                obscure: obscureNew.value,
                onToggle: () => obscureNew.toggle(),
                onChanged: (val) {
                  // Simple strength calculation
                  double s = 0;
                  if (val.length >= 8) s += 0.25;
                  if (val.contains(RegExp(r'[A-Z]'))) s += 0.25;
                  if (val.contains(RegExp(r'[0-9]'))) s += 0.25;
                  if (val.contains(RegExp(r'[!@#\$%^&*]'))) s += 0.25;
                  strengthValue.value = s;
                },
              )),

          // Strength indicator
          const SizedBox(height: 12),
          Obx(() {
            final s = strengthValue.value;
            final color = s <= 0.25
                ? kRed
                : s <= 0.5
                    ? kOrange
                    : s <= 0.75
                        ? kGold
                        : kGreen;
            final label = s <= 0.25
                ? 'Faible'
                : s <= 0.5
                    ? 'Moyen'
                    : s <= 0.75
                        ? 'Bon'
                        : 'Excellent';
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Force du mot de passe',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (s > 0)
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s,
                    backgroundColor: kBgSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 16),

          // Confirm password
          Obx(() => _buildPasswordField(
                label: 'Confirmer le mot de passe',
                hint: 'Retapez le mot de passe',
                icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
                obscure: obscureConfirm.value,
                onToggle: () => obscureConfirm.toggle(),
              )),

          const SizedBox(height: 20),

          // Update button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Mot de passe',
                  'Votre mot de passe a ete mis a jour',
                  backgroundColor: kGreen,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 14,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Mettre a jour',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextSub,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscure,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: kTextPrim,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: kTextLight, size: 22),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 46, minHeight: 46),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: kTextLight,
                  size: 20,
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            filled: true,
            fillColor: kBgSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build2FASection() {
    final is2FAEnabled = false.obs;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kBlueLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
              color: kBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification en deux etapes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextPrim,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Un code SMS sera envoye a chaque connexion pour renforcer la securite de votre compte.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSub.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: is2FAEnabled.value,
                  onChanged: (val) => is2FAEnabled.value = val,
                  activeThumbColor: kGreen,
                  activeTrackColor: kGreenLight,
                  inactiveTrackColor: kBgSurface,
                  inactiveThumbColor: kTextLight,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required String deviceName,
    required String lastLogin,
    required String ipAddress,
    required IconData icon,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
        border: isCurrent
            ? Border.all(color: kGreen.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Device icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCurrent ? kGreenLight : kBgSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isCurrent ? kGreen : kTextSub,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrim,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Actuel',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: kGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$lastLogin  ·  $ipAddress',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Disconnect button
          if (!isCurrent)
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Session terminee',
                  '$deviceName a ete deconnecte',
                  backgroundColor: kRed,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 14,
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kRedLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  PhosphorIcons.signOut(PhosphorIconsStyle.duotone),
                  color: kRed,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
