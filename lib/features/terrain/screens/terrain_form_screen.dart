import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lottie_success_dialog.dart';
import '../controllers/terrain_controller.dart';

class TerrainFormScreen extends GetView<TerrainController> {
  const TerrainFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.selectedTerrain.value != null;
    final terrain = controller.selectedTerrain.value;

    final nameCtrl = TextEditingController(text: terrain?.name ?? '');
    final addressCtrl = TextEditingController(text: terrain?.address ?? '');
    final priceCtrl = TextEditingController(
        text: terrain != null ? '${terrain.price}' : '');
    final capacityCtrl =
        TextEditingController(text: terrain?.capacity ?? '');
    final openCtrl = TextEditingController(text: '08:00');
    final closeCtrl = TextEditingController(text: '23:00');

    final surfaceObs = (terrain?.surface ?? 'Gazon synthetique').obs;
    final equipments = <String, bool>{
      'Eclairage': true,
      'Vestiaires': true,
      'Parking': false,
      'Tribunes': false,
      'Wi-Fi': false,
      'Buvette': false,
    }.obs;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBgCard,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone),
              color: kTextPrim, size: 20),
        ),
        title: Text(
          isEditing ? 'Modifier le terrain' : 'Nouveau terrain',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kDivider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1 : Photo ──
            _buildSectionTitle(
                    'Photo du terrain',
                    PhosphorIcons.image(PhosphorIconsStyle.duotone))
                .animate()
                .fadeIn(duration: 400.ms, delay: 0.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 12),
            _buildPhotoSection(isEditing, terrain)
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0, duration: 500.ms),
            const SizedBox(height: 28),

            // ── Section 2 : Informations ──
            _buildSectionTitle(
                    'Informations generales',
                    PhosphorIcons.info(PhosphorIconsStyle.duotone))
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: kCardShadow,
              ),
              child: Column(
                children: [
                  _FormField(
                    label: 'Nom du terrain',
                    ctrl: nameCtrl,
                    hint: 'Ex: Terrain Alpha',
                    icon: PhosphorIcons.courtBasketball(
                        PhosphorIconsStyle.duotone),
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Adresse',
                    ctrl: addressCtrl,
                    hint: 'Ex: Cite Keur Gorgui, Dakar',
                    icon:
                        PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Prix / heure',
                          ctrl: priceCtrl,
                          hint: '8000',
                          icon: PhosphorIcons.currencyCircleDollar(
                              PhosphorIconsStyle.duotone),
                          keyboardType: TextInputType.number,
                          suffix: 'F CFA',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FormField(
                          label: 'Capacite',
                          ctrl: capacityCtrl,
                          hint: '5v5',
                          icon: PhosphorIcons.users(
                              PhosphorIconsStyle.duotone),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.05, end: 0, duration: 500.ms),
            const SizedBox(height: 28),

            // ── Section 3 : Surface ──
            _buildSectionTitle(
                    'Type de surface',
                    PhosphorIcons.plant(PhosphorIconsStyle.duotone))
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 12),
            Obx(() => _buildSurfaceChips(surfaceObs))
                .animate()
                .fadeIn(duration: 500.ms, delay: 350.ms)
                .slideY(begin: 0.05, end: 0, duration: 500.ms),
            const SizedBox(height: 28),

            // ── Section 4 : Horaires ──
            _buildSectionTitle(
                    'Horaires d\'ouverture',
                    PhosphorIcons.clock(PhosphorIconsStyle.duotone))
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: kCardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Ouverture',
                      ctrl: openCtrl,
                      hint: '08:00',
                      icon:
                          PhosphorIcons.sun(PhosphorIconsStyle.duotone),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 24,
                      height: 2,
                      color: kTextLight,
                    ),
                  ),
                  Expanded(
                    child: _FormField(
                      label: 'Fermeture',
                      ctrl: closeCtrl,
                      hint: '23:00',
                      icon: PhosphorIcons.moon(
                          PhosphorIconsStyle.duotone),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 450.ms)
                .slideY(begin: 0.05, end: 0, duration: 500.ms),
            const SizedBox(height: 28),

            // ── Section 5 : Equipements ──
            _buildSectionTitle(
                    'Equipements',
                    PhosphorIcons.wrench(PhosphorIconsStyle.duotone))
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 12),
            Obx(() => _buildEquipmentGrid(equipments))
                .animate()
                .fadeIn(duration: 500.ms, delay: 550.ms)
                .slideY(begin: 0.05, end: 0, duration: 500.ms),
            const SizedBox(height: 36),

            // ── Bouton enregistrer ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    LottieSuccessDialog(
                      message: isEditing
                          ? 'Terrain modifie !'
                          : 'Terrain cree !',
                      subtitle: isEditing
                          ? 'Les modifications ont ete enregistrees'
                          : 'Votre nouveau terrain est pret',
                    ),
                    barrierDismissible: false,
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    controller.goBack();
                  });
                },
                icon: Icon(
                  isEditing
                      ? PhosphorIcons.check(PhosphorIconsStyle.duotone)
                      : PhosphorIcons.plus(PhosphorIconsStyle.duotone),
                  color: Colors.white,
                  size: 22,
                ),
                label: Text(
                  isEditing ? 'Enregistrer' : 'Creer le terrain',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: kGreen.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0, duration: 500.ms),
          ],
        ),
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
      ],
    );
  }

  // ── Photo section avec dotted border ──────────────────────────────────────
  Widget _buildPhotoSection(bool isEditing, TerrainModel? terrain) {
    if (isEditing && terrain != null && terrain.isAsset) {
      // Preview de l'image existante
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              terrain.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay avec bouton changer
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        PhosphorIcons.camera(PhosphorIconsStyle.duotone),
                        color: Colors.white,
                        size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Changer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Zone d'upload avec bordure pointillee
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Photo',
          'Fonctionnalite camera a connecter',
          backgroundColor: kBgCard,
          colorText: kTextPrim,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
      },
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(18),
        dashPattern: const [8, 4],
        color: kGreen.withValues(alpha: 0.5),
        strokeWidth: 2,
        child: Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kGreenLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kGreenLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                    PhosphorIcons.cameraPlus(PhosphorIconsStyle.duotone),
                    color: kGreen,
                    size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ajouter une photo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kGreen,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'JPG, PNG ou WEBP (max 5 Mo)',
                style: TextStyle(fontSize: 12, color: kTextSub),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Surface chips selectables ─────────────────────────────────────────────
  Widget _buildSurfaceChips(RxString surfaceObs) {
    final surfaces = [
      {
        'label': 'Gazon synthetique',
        'icon': PhosphorIcons.plant(PhosphorIconsStyle.duotone)
      },
      {
        'label': 'Gazon naturel',
        'icon': PhosphorIcons.tree(PhosphorIconsStyle.duotone)
      },
      {
        'label': 'Terre battue',
        'icon': PhosphorIcons.mountains(PhosphorIconsStyle.duotone)
      },
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: surfaces.map((s) {
        final isSelected = surfaceObs.value == s['label'];
        return GestureDetector(
          onTap: () => surfaceObs.value = s['label'] as String,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? kGreen : kBgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? kGreen : kBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? kCardShadow : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  s['icon'] as IconData,
                  color: isSelected ? Colors.white : kTextSub,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  s['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : kTextPrim,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Equipment grid ────────────────────────────────────────────────────────
  Widget _buildEquipmentGrid(RxMap<String, bool> equipments) {
    final icons = {
      'Eclairage': PhosphorIcons.lightbulb(PhosphorIconsStyle.duotone),
      'Vestiaires': PhosphorIcons.tShirt(PhosphorIconsStyle.duotone),
      'Parking': PhosphorIcons.car(PhosphorIconsStyle.duotone),
      'Tribunes': PhosphorIcons.armchair(PhosphorIconsStyle.duotone),
      'Wi-Fi': PhosphorIcons.wifiHigh(PhosphorIconsStyle.duotone),
      'Buvette': PhosphorIcons.coffee(PhosphorIconsStyle.duotone),
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: equipments.entries.map((e) {
        final isActive = e.value;
        return GestureDetector(
          onTap: () => equipments[e.key] = !isActive,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? kGreenLight : kBgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? kGreen : kBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons[e.key] ??
                      PhosphorIcons.check(PhosphorIconsStyle.duotone),
                  color: isActive ? kGreen : kTextLight,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  e.key,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? kGreen : kTextSub,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 4),
                  Icon(
                      PhosphorIcons.checkCircle(
                          PhosphorIconsStyle.duotone),
                      color: kGreen,
                      size: 14),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Form field reutilisable ────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? suffix;

  const _FormField({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextSub,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: kTextPrim, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kTextLight, fontSize: 14),
            prefixIcon: Icon(icon, color: kTextSub, size: 20),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: kTextSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: kBgSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
