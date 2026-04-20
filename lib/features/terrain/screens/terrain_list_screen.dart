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
      backgroundColor: const Color(0xFFE5E0D8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF0EBE3)),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Center(
              child: GestureDetector(
                onTap: controller.goBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EBE3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1A1A1A),
                    size: 16,
                  ),
                ),
              ),
            ),
            centerTitle: true,
            title: const Text(
              'Mes Terrains',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF006F39),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.goToForm(null),
        backgroundColor: const Color(0xFF006F39),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          PhosphorIconsLight.plusCircle,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F0E8),
        child: Column(
          children: [
            // ── En-tête : Badge & Recherche ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vos infrastructures',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${controller.activeTerrains}/${controller.totalTerrains} actifs',
                              style: const TextStyle(
                                color: Color(0xFF006F39),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E0D8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          PhosphorIconsLight.magnifyingGlass,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: controller.onSearch,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Rechercher un terrain...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste de terrains ─────────────────────────────────────────
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

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E0D8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: List.generate(
                          controller.terrains.length,
                          (index) {
                            final terrain = controller.terrains[index];
                            final isLast =
                                index == controller.terrains.length - 1;
                            return Column(
                              children: [
                                _TerrainRow(
                                  terrain: terrain,
                                  onToggle: () =>
                                      controller.toggleStatus(terrain.id),
                                  onEdit: () => controller.goToForm(terrain),
                                  onDelete: () =>
                                      controller.deleteConfirm(terrain.id),
                                ).animate().fadeIn(
                                    duration: 350.ms, delay: (index * 80).ms),
                                if (!isLast)
                                  const Divider(
                                    color: Color(0xFFF0EBE3),
                                    height: 1,
                                    indent: 14,
                                    endIndent: 14,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
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
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre premier terrain\npour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

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
    return Opacity(
      opacity: terrain.status ? 1.0 : 0.8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          splashColor: const Color(0xFFF5F0E8),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Vignette ───────────────────────────────────────
                Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E0D8)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: ColorFiltered(
                          colorFilter: terrain.status
                              ? const ColorFilter.mode(
                                  Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(
                                  Colors.grey, BlendMode.saturation),
                          child: terrain.isAsset
                              ? Image.asset(terrain.imageUrl, fit: BoxFit.cover)
                              : Image.network(
                                  terrain.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color:
                                        const Color(0xFF006F39).withAlpha(30),
                                    child: const Icon(PhosphorIconsLight.soccerBall),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Point Statut Superposé
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: terrain.status
                              ? const Color(0xFF006F39)
                              : const Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // ── Informations ───────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        terrain.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Localisation
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(
                              PhosphorIconsLight.mapPin,
                              size: 12,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                terrain.address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badges
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _InfoBadge(
                              label: '${_fmt(terrain.price)}k/h',
                              isBold: true,
                            ),
                            _InfoBadge(label: terrain.capacity),
                            _InfoBadge(
                              label: terrain.rating.toString(),
                              icon: PhosphorIconsFill.star,
                              iconColor: const Color(0xFFF59E0B),
                              backgroundColor: const Color(0xFFFEF3C7),
                              borderColor: const Color(0xFFFDE68A),
                              textColor: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),

                      // Actions bas
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Switch Toggle
                            GestureDetector(
                              onTap: onToggle,
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 16,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: terrain.status
                                          ? const Color(0xFF006F39)
                                          : const Color(0xFFE5E0D8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: AnimatedAlign(
                                      duration: 200.ms,
                                      alignment: terrain.status
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    terrain.status ? 'Actif' : 'Inactif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: terrain.status
                                          ? const Color(0xFF006F39)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Boutons Edit/Delete
                            Row(
                              children: [
                                _ActionButton(
                                  icon: PhosphorIconsLight.pencil,
                                  onTap: onEdit,
                                ),
                                _ActionButton(
                                  icon: PhosphorIconsLight.trash,
                                  onTap: onDelete,
                                  hoverColor:
                                      const Color(0xFFEF4444).withAlpha(20),
                                  iconColor: const Color(0xFF9CA3AF),
                                  hoverIconColor: const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(int price) {
    if (price >= 1000) {
      return (price / 1000).toStringAsFixed(0);
    }
    return price.toString();
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isBold;

  const _InfoBadge({
    required this.label,
    this.icon,
    this.iconColor,
    this.backgroundColor = const Color(0xFFF5F0E8),
    this.borderColor = const Color(0xFFE5E0D8),
    this.textColor = const Color(0xFF1A1A1A),
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: iconColor ?? textColor),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? hoverColor;
  final Color? iconColor;
  final Color? hoverIconColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.hoverColor,
    this.iconColor,
    this.hoverIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: iconColor ?? const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

