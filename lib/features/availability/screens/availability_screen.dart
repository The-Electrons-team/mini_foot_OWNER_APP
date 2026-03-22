import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/availability_controller.dart';

class AvailabilityScreen extends GetView<AvailabilityController> {
  const AvailabilityScreen({super.key});

  // Noms des mois en français pour l'affichage du calendrier
  static const _monthNames = [
    'Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Aout', 'Septembre', 'Octobre', 'Novembre', 'Decembre',
  ];

  // Noms courts des jours de la semaine (lundi=1 ... dimanche=7)
  static const _dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBgCard,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone), size: 18),
          color: kTextPrim,
        ),
        title: const Text(
          'Disponibilites',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kGreenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.soccerBall(PhosphorIconsStyle.duotone), size: 14, color: kGreen),
                SizedBox(width: 4),
                Text(
                  'Terrain Alpha',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kDivider),
        ),
      ),
      body: Column(
        children: [
          // Contenu scrollable
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Selecteur de terrain
                SliverToBoxAdapter(child: _buildTerrainSelector()),
                // Calendrier semaine
                SliverToBoxAdapter(child: _buildWeekCalendar()),
                // Legende
                SliverToBoxAdapter(child: _buildLegend()),
                // Grille de creneaux
                SliverToBoxAdapter(child: _buildSlotsGrid()),
                // Espace pour la barre de resume
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          // Barre de resume fixee en bas
          _buildSummaryBar(),
        ],
      ),
    );
  }

  // ── Selecteur de terrain ────────────────────────────────────────────────────
  Widget _buildTerrainSelector() {
    final terrains = ['Terrain A', 'Terrain B', 'Terrain C'];
    return Container(
      color: kBgCard,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: terrains.asMap().entries.map((entry) {
            final isSelected = entry.key == 0;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _TerrainChip(
                label: entry.value,
                isSelected: isSelected,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Calendrier semaine ameliore ─────────────────────────────────────────────
  Widget _buildWeekCalendar() {
    return Obx(() {
      final days = controller.nextSevenDays;
      final selected = controller.selectedDate.value;
      // Titre mois/annee base sur le jour selectionne
      final monthYear =
          '${_monthNames[selected.month - 1]} ${selected.year}';

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: kCardShadow,
          ),
          child: Column(
            children: [
              // Titre mois/annee
              Text(
                monthYear,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kTextPrim,
                ),
              ),
              const SizedBox(height: 16),
              // Row des 7 jours
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((day) {
                  final isSelected =
                      controller.isSameDay(day, selected);
                  final isToday =
                      controller.isSameDay(day, DateTime.now());
                  // weekday: 1=Lun ... 7=Dim
                  final dayLabel = _dayNames[day.weekday - 1];
                  // Simuler un dot si des creneaux sont reserves ce jour
                  // (on affiche le dot pour le jour selectionne car on sait
                  //  qu'il y a des reservations dans les mock)
                  final hasBookings = isSelected &&
                      controller.slots.any((s) => s.isBooked);

                  return GestureDetector(
                    onTap: () => controller.selectDate(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: 42,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? kGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isToday && !isSelected
                            ? Border.all(color: kGreen, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        children: [
                          // Nom du jour
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.white70 : kTextLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Numero du jour
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color:
                                  isSelected ? Colors.white : kTextPrim,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Dot indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasBookings
                                  ? (isSelected
                                      ? Colors.white
                                      : kGold)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Legende amelioree ─────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: kCardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(
                  color: kGreen,
                  label: 'Disponible',
                  count: controller.availableCount,
                ),
                _LegendItem(
                  color: kGold,
                  label: 'Reserve',
                  count: controller.bookedCount,
                ),
                _LegendItem(
                  color: kTextLight,
                  label: 'Bloque',
                  count: controller.blockedCount,
                ),
              ],
            ),
          ),
        ));
  }

  // ── Grille de creneaux redesignee ─────────────────────────────────────────
  Widget _buildSlotsGrid() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre avec icone horloge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kGreenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.clock(PhosphorIconsStyle.duotone),
                    size: 18,
                    color: kGreen,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Creneaux du jour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextPrim,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // GridView 3 colonnes
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.slots.length,
              itemBuilder: (_, i) {
                final slot = controller.slots[i];
                return _SlotCard(
                  slot: slot,
                  onTap: () => controller.toggleBlock(slot.time),
                ).animate().fadeIn(duration: 300.ms, delay: (i * 50).ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
              },
            ),
          ],
        ),
      );
    });
  }

  // ── Barre de resume en bas ────────────────────────────────────────────────
  Widget _buildSummaryBar() {
    return Obx(() {
      final total = controller.slots.length;
      final available =
          controller.slots.where((s) => !s.isBlocked && !s.isBooked).length;
      final progress = total > 0 ? available / total : 0.0;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: kBgCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
                          size: 20, color: kGreen),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14, color: kTextPrim),
                          children: [
                            TextSpan(
                              text: '$available',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: kGreen,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: ' creneaux disponibles sur $total',
                              style: const TextStyle(
                                color: kTextSub,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: kGreen,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Mini barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: kBgSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widgets prives
// ══════════════════════════════════════════════════════════════════════════════

// ── Chip de terrain ─────────────────────────────────────────────────────────

class _TerrainChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TerrainChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? kGreen : kBgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? kGreen : kBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.soccerBall(PhosphorIconsStyle.duotone),
            size: 14,
            color: isSelected ? Colors.white : kTextSub,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : kTextSub,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item de legende ─────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: kTextSub,
          ),
        ),
      ],
    );
  }
}

// ── Carte de creneau ────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onTap;

  const _SlotCard({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determiner le style selon l'etat du creneau
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final String subtitle;
    final IconData icon;

    if (slot.isBooked) {
      bgColor = kGoldLight;
      borderColor = kGold.withValues(alpha: 0.4);
      textColor = kGold;
      subtitle = slot.bookedBy.isNotEmpty ? slot.bookedBy : 'Reserve';
      icon = PhosphorIcons.user(PhosphorIconsStyle.duotone);
    } else if (slot.isBlocked) {
      bgColor = kBgSurface;
      borderColor = kBorder;
      textColor = kTextLight;
      subtitle = 'Bloque';
      icon = PhosphorIcons.lock(PhosphorIconsStyle.duotone);
    } else {
      bgColor = kGreenLight;
      borderColor = kGreen.withValues(alpha: 0.3);
      textColor = kGreen;
      subtitle = 'Disponible';
      icon = PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone);
    }

    return GestureDetector(
      onTap: slot.isBooked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Stack(
          children: [
            // Icone en haut a droite
            Positioned(
              top: 6,
              right: 6,
              child: Icon(icon, size: 14, color: textColor.withValues(alpha: 0.6)),
            ),
            // Contenu central
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
