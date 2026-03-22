import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends GetView<ProfileController> {
  const EditProfileScreen({super.key});

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
          'Informations personnelles',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Sauvegarde',
                'Vos informations ont ete mises a jour',
                backgroundColor: kGreen,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 14,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Sauvegarder',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          children: [
            // Avatar section
            _buildAvatarSection()
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),

            // Editable fields
            _buildEditableField(
              icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
              label: 'Nom complet',
              value: controller.ownerName.value,
              color: kGreen,
              bgColor: kGreenLight,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 14),

            _buildEditableField(
              icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
              label: 'Telephone',
              value: controller.phone.value,
              color: kBlue,
              bgColor: kBlueLight,
              keyboardType: TextInputType.phone,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 14),

            _buildEditableField(
              icon: PhosphorIcons.envelope(PhosphorIconsStyle.duotone),
              label: 'Email',
              value: controller.email.value,
              color: kGold,
              bgColor: kGoldLight,
              keyboardType: TextInputType.emailAddress,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 14),

            _buildEditableField(
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
              label: 'Ville',
              value: 'Dakar',
              color: kOrange,
              bgColor: const Color(0xFFFFF3E0),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 14),

            _buildEditableField(
              icon: PhosphorIcons.buildings(PhosphorIconsStyle.duotone),
              label: 'Adresse terrain',
              value: 'Parcelles Assainies, Unite 14',
              color: kBlue,
              bgColor: kBlueLight,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Sauvegarde',
                    'Vos informations ont ete mises a jour',
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 700.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Obx(() => Column(
          children: [
            Stack(
              children: [
                // Avatar circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGreenGradient,
                    border: Border.all(color: kBgCard, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: kGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      controller.initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                // Camera overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Pick image
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: kBgCard, width: 3),
                        boxShadow: kCardShadow,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              controller.ownerName.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kTextPrim,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Changer votre photo de profil',
              style: TextStyle(
                fontSize: 13,
                color: kTextLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ));
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kTextLight,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  initialValue: value,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextPrim,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          // Edit icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_outlined, color: kTextLight, size: 16),
          ),
        ],
      ),
    );
  }
}
