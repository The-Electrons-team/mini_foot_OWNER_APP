import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controllers/terrain_controller.dart';

class TerrainListScreen extends GetView<TerrainController> {
  const TerrainListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBgCard,
        elevation: 0,
        leading: GestureDetector(
          onTap: controller.goBack,
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kBgSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: kTextPrim, size: 16),
          ),
        ),
        title: const Text(
          'Mes Terrains',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kGreen,
          ),
        ),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.activeTerrains}/${controller.totalTerrains} actifs',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kGreen,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.goToForm(null),
        backgroundColor: kGreen,
        elevation: 6,
        child: Icon(PhosphorIcons.plus(PhosphorIconsStyle.duotone),
            color: Colors.white, size: 26),
      ),
      body: Column(
        children: [
          // ── Barre recherche ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: kCardShadow,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.search_rounded,
                        color: kTextLight, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: controller.onSearch,
                      style: const TextStyle(color: kTextPrim, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un terrain...',
                        hintStyle:
                            TextStyle(color: kTextLight, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Liste ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return ShimmerList(
                  itemBuilder: (_, __) => const TerrainCardSkeleton(),
                );
              }
              if (controller.terrains.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.terrains.length,
                itemBuilder: (context, index) {
                  final terrain = controller.terrains[index];
                  return _TerrainRow(
                    terrain: terrain,
                    onToggle: () => controller.toggleStatus(terrain.id),
                    onEdit: () => controller.goToForm(terrain),
                    onDelete: () => controller.deleteConfirm(terrain.id),
                  )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (index * 80).ms)
                      .slideX(
                          begin: 0.08,
                          end: 0,
                          duration: 350.ms,
                          delay: (index * 80).ms,
                          curve: Curves.easeOut);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/football_bounce.json',
                width: 140, height: 140, repeat: true),
            const SizedBox(height: 20),
            const Text('Aucun terrain',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kTextPrim)),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre premier terrain\npour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ─── Terrain Row (inspiré _PopularItem de minifoot_mobile) ───────────────────

class _TerrainRow extends StatelessWidget {
  final TerrainModel terrain;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TerrainRow({
    required this.terrain,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            // ── Image arrondie (style minifoot_mobile _PopularItem) ──────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 90,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    terrain.isAsset
                        ? Image.asset(terrain.imageUrl, fit: BoxFit.cover)
                        : Image.network(
                            terrain.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: kGreen.withValues(alpha: 0.12),
                              child: Icon(
                                PhosphorIcons.courtBasketball(
                                    PhosphorIconsStyle.duotone),
                                color: kGreen, size: 32,
                              ),
                            ),
                          ),
                    // Badge statut en bas de l'image
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: terrain.status
                              ? kGreen.withValues(alpha: 0.88)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(
                                color: terrain.status
                                    ? Colors.white
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              terrain.status ? 'Actif' : 'Off',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Infos ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + prix
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          terrain.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: kTextPrim,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_fmt(terrain.price)} F/h',
                          style: const TextStyle(
                            color: kGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Adresse
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: kTextLight, size: 13),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          terrain.address,
                          style: const TextStyle(
                              fontSize: 12, color: kTextSub),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Note + étoiles
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < terrain.rating.floor()
                              ? Icons.star_rounded
                              : (i < terrain.rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_border_rounded),
                          color: const Color(0xFFFFB300),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        terrain.rating.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kTextSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chips
                  Row(
                    children: [
                      _InfoChip(
                        icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
                        label: terrain.capacity,
                        color: kBlue,
                        bgColor: kBlueLight,
                      ),
                      const SizedBox(width: 6),
                      _InfoChip(
                        icon: PhosphorIcons.calendarBlank(
                            PhosphorIconsStyle.duotone),
                        label: '${terrain.bookingsThisMonth} rés.',
                        color: kGold,
                        bgColor: kGoldLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: kDivider, height: 1),
                  const SizedBox(height: 8),

                  // Actions : toggle + modifier + supprimer
                  Row(
                    children: [
                      // Toggle actif/inactif
                      GestureDetector(
                        onTap: onToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: terrain.status ? kGreenLight : kBgSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: terrain.status ? kGreen : kBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                terrain.status
                                    ? PhosphorIcons.toggleRight(
                                        PhosphorIconsStyle.duotone)
                                    : PhosphorIcons.toggleLeft(
                                        PhosphorIconsStyle.duotone),
                                color: terrain.status ? kGreen : kTextLight,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                terrain.status ? 'Actif' : 'Inactif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: terrain.status ? kGreen : kTextSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Modifier
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: kBlueLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIcons.pencilSimple(
                                PhosphorIconsStyle.duotone),
                            color: kBlue, size: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Supprimer
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: kRedLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIcons.trash(PhosphorIconsStyle.duotone),
                            color: kRed, size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// ─── Info chip ───────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
