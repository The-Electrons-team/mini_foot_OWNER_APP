import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/availability_controller.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Screen principal
// ══════════════════════════════════════════════════════════════════════════════

class AvailabilityScreen extends GetView<AvailabilityController> {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // AppBar + Calendrier dans un bloc scrollable fixe en haut
          _buildStickyHeader(context),
          // Contenu scrollable en bas (créneeaux)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _SlotsShimmer();
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildDayStats()),
                  SliverToBoxAdapter(child: _buildSlotsSection(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            }),
          ),
        ],
      ),
      // FAB pour bloquer/débloquer en lot (bonne pratique : action principale accessible)
      floatingActionButton: _buildFab(),
    );
  }

  // ── AppBar + Terrain selector + Calendrier ──────────────────────────────────
  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      color: kBgCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAppBar(context),
          _buildTerrainSelector(),
          _buildCalendar(),
          Container(height: 1, color: kDivider),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, topPad + 4, 16, 0),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            onPressed: Get.back,
            icon: Icon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone),
              color: kTextPrim,
              size: 22,
            ),
          ),
          // Titre
          Expanded(
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disponibilités',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrim,
                  ),
                ),
                Text(
                  controller.selectedDateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )),
          ),
          // Toggle mois / semaine
          Obx(() => GestureDetector(
            onTap: controller.toggleFormat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kGreenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.calendarFormat.value == 'month'
                        ? Icons.calendar_view_week_rounded
                        : Icons.calendar_month_rounded,
                    size: 16,
                    color: kGreen,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    controller.calendarFormat.value == 'month'
                        ? 'Semaine'
                        : 'Mois',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kGreen,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ── Sélecteur de terrain ─────────────────────────────────────────────────────
  Widget _buildTerrainSelector() {
    return SizedBox(
      height: 52,
      child: Obx(() => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.terrains.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final terrain = controller.terrains[i];
          final selected = controller.selectedTerrain.value == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectTerrain(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? kGreen : kBgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? kGreen : kBorder,
                  width: selected ? 0 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer_rounded,
                    size: 14,
                    color: selected ? Colors.white : kTextSub,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    terrain.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : kTextSub,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )),
    );
  }

  // ── Calendrier table_calendar ────────────────────────────────────────────────
  Widget _buildCalendar() {
    return Obx(() {
      final isMonth = controller.calendarFormat.value == 'month';
      return TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) =>
            controller.isSameDay(day, controller.selectedDate.value),
        calendarFormat: isMonth ? CalendarFormat.month : CalendarFormat.week,
        onDaySelected: controller.onDaySelected,
        onPageChanged: controller.onPageChanged,
        eventLoader: controller.getEventsForDay,

        // ── Style ─────────────────────────────────────────────────────────────
        calendarStyle: CalendarStyle(
          // Jours normaux
          defaultTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextPrim,
          ),
          weekendTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kGold,
          ),
          // Jour sélectionné
          selectedDecoration: const BoxDecoration(
            color: kGreen,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          // Aujourd'hui
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: kGreen, width: 2),
          ),
          todayTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kGreen,
          ),
          // Jours hors du mois courant
          outsideDaysVisible: false,
          // Marqueurs d'événements
          markerDecoration: const BoxDecoration(
            color: kGold,
            shape: BoxShape.circle,
          ),
          markerSize: 5,
          markersMaxCount: 3,
          markerMargin: const EdgeInsets.only(top: 2),
          cellMargin: const EdgeInsets.all(4),
        ),

        // ── Header du calendrier ──────────────────────────────────────────────
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: kTextSub,
              size: 20,
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: kTextSub,
              size: 20,
            ),
          ),
          headerPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // ── Noms des jours de la semaine ──────────────────────────────────────
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kTextSub,
          ),
          weekendStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kGold,
          ),
        ),

        locale: 'fr_FR',
      );
    });
  }

  // ── Stats du jour ────────────────────────────────────────────────────────────
  Widget _buildDayStats() {
    return Obx(() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatBadge(
            count: controller.availableCount,
            label: 'Libres',
            color: kGreen,
            bgColor: kGreenLight,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 10),
          _StatBadge(
            count: controller.bookedCount,
            label: 'Réservés',
            color: kGold,
            bgColor: kGoldLight,
            icon: Icons.groups_rounded,
          ),
          const SizedBox(width: 10),
          _StatBadge(
            count: controller.blockedCount,
            label: 'Bloqués',
            color: kTextLight,
            bgColor: kBgSurface,
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(width: 10),
          // Taux d'occupation
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: kCardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    controller.occupancyLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kTextPrim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: controller.occupancyRate,
                      backgroundColor: kBgSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Taux',
                    style: TextStyle(fontSize: 10, color: kTextLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // ── Section créneaux ────────────────────────────────────────────────────────
  Widget _buildSlotsSection(BuildContext context) {
    return Obx(() {
      final slots = controller.slots;
      if (slots.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: kGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: kGreen,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Créneaux du jour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextPrim,
                    ),
                  ),
                ),
                // Légende compacte
                _buildLegendDot(kGreen, 'Libre'),
                const SizedBox(width: 10),
                _buildLegendDot(kGold, 'Réservé'),
                const SizedBox(width: 10),
                _buildLegendDot(kTextLight, 'Bloqué'),
              ],
            ),
            const SizedBox(height: 14),

            // Grille 3 colonnes
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: slots.length,
              itemBuilder: (_, i) {
                return _SlotCard(
                  slot: slots[i],
                  onTap: () => _onSlotTap(context, slots[i]),
                )
                    .animate()
                    .fadeIn(duration: 250.ms, delay: (i * 30).ms)
                    .scale(begin: const Offset(0.92, 0.92));
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 10, color: kTextSub)),
      ],
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => _showBulkActionSheet(),
      backgroundColor: kGreen,
      elevation: 3,
      icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
      label: const Text(
        'Gérer',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Tap sur un créneau → bottom sheet de détail ─────────────────────────────
  void _onSlotTap(BuildContext context, TimeSlot slot) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SlotDetailSheet(slot: slot, controller: controller),
    );
  }

  // ── Bottom sheet d'actions en lot ──────────────────────────────────────────
  void _showBulkActionSheet() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      _BulkActionSheet(controller: controller),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget : Carte créneau
// ══════════════════════════════════════════════════════════════════════════════

class _SlotCard extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onTap;

  const _SlotCard({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // On utilise le controller pour les couleurs
    final ctrl = Get.find<AvailabilityController>();
    final bgColor     = ctrl.slotBgColor(slot.status);
    final accentColor = ctrl.slotColor(slot.status);
    final icon        = ctrl.slotIcon(slot.status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // Icône en haut à droite
            Positioned(
              top: 6,
              right: 7,
              child: Icon(icon, size: 13, color: accentColor.withValues(alpha: 0.55)),
            ),
            // Contenu central
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot.isBooked
                          ? _truncate(slot.bookedBy, 10)
                          : ctrl.slotLabel(slot.status),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: accentColor.withValues(alpha: 0.75),
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

  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max - 1)}…' : s;
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget : Badge stat du jour
// ══════════════════════════════════════════════════════════════════════════════

class _StatBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatBadge({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: kTextSub),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget : Bottom sheet détail créneau
// ══════════════════════════════════════════════════════════════════════════════

class _SlotDetailSheet extends StatelessWidget {
  final TimeSlot slot;
  final AvailabilityController controller;

  const _SlotDetailSheet({required this.slot, required this.controller});

  @override
  Widget build(BuildContext context) {
    final accentColor = controller.slotColor(slot.status);
    final bgColor     = controller.slotBgColor(slot.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: kElevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icône du statut
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.slotIcon(slot.status),
              color: accentColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),

          // Heure
          Text(
            '${slot.time} → ${slot.endTime}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kTextPrim,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Statut badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.slotLabel(slot.status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info équipe si réservé
          if (slot.isBooked) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kGoldLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: kGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Équipe réservante',
                            style: TextStyle(fontSize: 11, color: kTextSub),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slot.bookedBy,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kTextPrim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 8),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SafeArea(
              top: false,
              child: slot.isBooked
                  // Réservé → juste fermer
                  ? SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: Navigator.of(context).pop,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Fermer',
                          style: TextStyle(
                              color: kTextSub, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  // Libre ou Bloqué → action de toggle
                  : Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: Navigator.of(context).pop,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: kBorder),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                    color: kTextSub,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                controller.toggleBlock(slot.time);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: slot.isBlocked
                                    ? kGreen
                                    : kRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: Icon(
                                slot.isBlocked
                                    ? Icons.lock_open_rounded
                                    : Icons.lock_rounded,
                                size: 18,
                              ),
                              label: Text(
                                slot.isBlocked ? 'Débloquer' : 'Bloquer',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget : Bottom sheet actions en lot
// ══════════════════════════════════════════════════════════════════════════════

class _BulkActionSheet extends StatelessWidget {
  final AvailabilityController controller;

  const _BulkActionSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Text(
              'Gérer les créneaux',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextPrim,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Appliquer une action sur tous les créneaux libres du jour',
              style: TextStyle(fontSize: 13, color: kTextSub, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Action : Bloquer tous les créneaux libres
          _BulkActionTile(
            icon: Icons.lock_rounded,
            iconColor: kRed,
            iconBg: kRedLight,
            title: 'Bloquer tous les créneaux libres',
            subtitle: 'Personne ne pourra réserver aujourd\'hui',
            onTap: () {
              HapticFeedback.mediumImpact();
              for (final slot in controller.slots) {
                if (slot.isAvailable) {
                  controller.toggleBlock(slot.time);
                }
              }
              Get.back();
              Get.snackbar(
                'Créneaux bloqués',
                'Tous les créneaux libres ont été bloqués',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: kBgCard,
                colorText: kTextPrim,
                margin: const EdgeInsets.all(16),
                borderRadius: 16,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.lock_rounded, color: kRed),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: kDivider, height: 1),
          ),

          // Action : Débloquer tous les créneaux bloqués
          _BulkActionTile(
            icon: Icons.lock_open_rounded,
            iconColor: kGreen,
            iconBg: kGreenLight,
            title: 'Débloquer tous les créneaux',
            subtitle: 'Rendre disponibles les créneaux bloqués',
            onTap: () {
              HapticFeedback.mediumImpact();
              for (final slot in controller.slots) {
                if (slot.isBlocked) {
                  controller.toggleBlock(slot.time);
                }
              }
              Get.back();
              Get.snackbar(
                'Créneaux débloqués',
                'Tous les créneaux bloqués sont maintenant libres',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: kBgCard,
                colorText: kTextPrim,
                margin: const EdgeInsets.all(16),
                borderRadius: 16,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.lock_open_rounded, color: kGreen),
              );
            },
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: Get.back,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                        color: kTextSub, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BulkActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextSub,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kTextLight, size: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget : Shimmer de chargement
// ══════════════════════════════════════════════════════════════════════════════

class _SlotsShimmer extends StatelessWidget {
  const _SlotsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 15,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: kBgSurface,
            borderRadius: BorderRadius.circular(14),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: kBgCard),
      ),
    );
  }
}
