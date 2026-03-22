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
        centerTitle: false,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone),
              color: kTextPrim, size: 20),
        ),
        title: const Text(
          'Mes Terrains',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.activeTerrains}/${controller.totalTerrains} actifs',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kGreen,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.goToForm(null),
        backgroundColor: kGreen,
        elevation: 6,
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.duotone),
            color: Colors.white, size: 22),
        label: const Text(
          'Ajouter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshTerrains,
        color: kGreen,
        backgroundColor: kBgCard,
        child: Obx(() {
          // Shimmer loading pendant le chargement
          if (controller.isLoading.value) {
            return ShimmerList(
              itemBuilder: (context, index) => const TerrainCardSkeleton(),
            );
          }
          if (controller.terrains.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: controller.terrains.length,
            itemBuilder: (context, index) {
              final terrain = controller.terrains[index];
              return _TerrainCard(
                terrain: terrain,
                onToggle: () => controller.toggleStatus(terrain.id),
                onEdit: () => controller.goToForm(terrain),
                onDelete: () => controller.deleteConfirm(terrain.id),
              )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: (index * 100).ms,
                  )
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 400.ms,
                    delay: (index * 100).ms,
                    curve: Curves.easeOut,
                  );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/football_bounce.json',
                width: 150,
                height: 150,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucun terrain',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextPrim,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Commencez par ajouter votre\npremier terrain de foot !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSub,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => controller.goToForm(null),
                icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.duotone),
                    color: Colors.white, size: 20),
                label: const Text('Ajouter un terrain'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ─── Terrain Card amelioree ─────────────────────────────────────────────────

class _TerrainCard extends StatelessWidget {
  final TerrainModel terrain;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TerrainCard({
    required this.terrain,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image hero avec badges ──
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  terrain.isAsset
                      ? Image.asset(terrain.imageUrl, fit: BoxFit.cover)
                      : Image.network(
                          terrain.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: kBgSurface,
                            child: Center(
                              child: Icon(
                                  PhosphorIcons.courtBasketball(
                                      PhosphorIconsStyle.duotone),
                                  color: kTextLight,
                                  size: 48),
                            ),
                          ),
                        ),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(terrain.overlayColor).withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  // Badge statut (haut-gauche)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: terrain.status
                            ? kGreen.withValues(alpha: 0.9)
                            : kRed.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            terrain.status ? 'Actif' : 'Inactif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Badge note (haut-droit)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              PhosphorIcons.star(PhosphorIconsStyle.duotone),
                              color: const Color(0xFFFFD700),
                              size: 14),
                          const SizedBox(width: 3),
                          Text(
                            terrain.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Infos en bas (nom + prix)
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                terrain.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                      PhosphorIcons.mapPin(
                                          PhosphorIconsStyle.duotone),
                                      color: Colors.white70,
                                      size: 13),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      terrain.address,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_formatPrice(terrain.price)} F/h',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenu sous l'image ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              children: [
                // Stats row
                Row(
                  children: [
                    _MiniStat(
                      icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
                      label: terrain.capacity,
                      color: kBlue,
                      bgColor: kBlueLight,
                    ),
                    const SizedBox(width: 8),
                    _MiniStat(
                      icon: PhosphorIcons.plant(PhosphorIconsStyle.duotone),
                      label: terrain.surface,
                      color: kGreen,
                      bgColor: kGreenLight,
                    ),
                    const SizedBox(width: 8),
                    _MiniStat(
                      icon: PhosphorIcons.calendarBlank(
                          PhosphorIconsStyle.duotone),
                      label: '${terrain.bookingsThisMonth} res.',
                      color: kGold,
                      bgColor: kGoldLight,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Barre de progression "taux d'occupation"
                _OccupancyBar(
                  bookings: terrain.bookingsThisMonth,
                  maxBookings: 30,
                ),
                const SizedBox(height: 12),

                // Divider
                const Divider(color: kDivider, height: 1),
                const SizedBox(height: 8),

                // Actions row
                Row(
                  children: [
                    // Toggle switch
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              terrain.status ? 'Actif' : 'Inactif',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: terrain.status ? kGreen : kTextSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Edit
                    _ActionButton(
                      icon: PhosphorIcons.pencilSimple(
                          PhosphorIconsStyle.duotone),
                      color: kBlue,
                      bgColor: kBlueLight,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    // Delete
                    _ActionButton(
                      icon: PhosphorIcons.trash(PhosphorIconsStyle.duotone),
                      color: kRed,
                      bgColor: kRedLight,
                      onTap: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ─── Mini stat chip ──────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barre d'occupation ──────────────────────────────────────────────────────

class _OccupancyBar extends StatelessWidget {
  final int bookings;
  final int maxBookings;

  const _OccupancyBar({required this.bookings, required this.maxBookings});

  @override
  Widget build(BuildContext context) {
    final rate = (bookings / maxBookings).clamp(0.0, 1.0);
    final percent = (rate * 100).round();
    final barColor = rate > 0.7
        ? kGreen
        : rate > 0.4
            ? kGold
            : kRed;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Taux d\'occupation ce mois',
              style: TextStyle(fontSize: 11, color: kTextSub),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: kBgSurface,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Action button ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
