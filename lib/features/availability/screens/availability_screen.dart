import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
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
          // Contenu scrollable en bas (créneaux) — swipe gauche/droite pour changer de jour
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                final current = controller.selectedDate.value;
                if (details.primaryVelocity! < -200) {
                  // Swipe gauche → jour suivant
                  HapticFeedback.selectionClick();
                  final next = current.add(const Duration(days: 1));
                  controller.onDaySelected(next, next);
                } else if (details.primaryVelocity! > 200) {
                  // Swipe droite → jour précédent
                  HapticFeedback.selectionClick();
                  final prev = current.subtract(const Duration(days: 1));
                  controller.onDaySelected(prev, prev);
                }
              },
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _SlotsShimmer();
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: RefreshIndicator(
                    key: ValueKey(controller.selectedDate.value),
                    color: kGreen,
                    onRefresh: controller.refreshAvailability,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(child: _buildSlotsSection(context)),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      // FAB pour bloquer/débloquer en lot (bonne pratique : action principale accessible)
      floatingActionButton: _buildFab(),
    );
  }

  // ── AppBar + Terrain selector + Stats + Calendrier ───────────────────────────
  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      color: kBgCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAppBar(context),
          _buildTerrainSelector(),
          _buildCompactStats(),
          _buildCalendar(),
          Container(height: 1, color: kDivider),
        ],
      ),
    );
  }

  // ── Stats compactes dans le header ────────────────────────────────────────
  Widget _buildCompactStats() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            _CompactStat(
              count: controller.availableCount,
              label: 'Libres',
              color: kGreen,
              bgColor: kGreenLight,
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(width: 8),
            _CompactStat(
              count: controller.bookedCount,
              label: 'Réservés',
              color: kGold,
              bgColor: kGoldLight,
              icon: Icons.groups_rounded,
            ),
            const SizedBox(width: 8),
            _CompactStat(
              count: controller.blockedCount,
              label: 'Bloqués',
              color: kTextLight,
              bgColor: kBgSurface,
              icon: Icons.lock_outline_rounded,
            ),
            const SizedBox(width: 8),
            // Taux d'occupation compact
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.occupancyLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrim,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: controller.occupancyRate,
                            backgroundColor: kBgCard,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              kGreen,
                            ),
                            minHeight: 5,
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
            child: Obx(
              () => Column(
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
              ),
            ),
          ),
          // Toggle mois / semaine
          Obx(
            () => GestureDetector(
              onTap: controller.toggleFormat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
            ),
          ),
        ],
      ),
    );
  }

  // ── Sélecteur de terrain ─────────────────────────────────────────────────────
  Widget _buildTerrainSelector() {
    return SizedBox(
      height: 52,
      child: Obx(() {
        if (controller.isLoadingTerrains.value) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (_, i) =>
                Container(
                      width: 118,
                      decoration: BoxDecoration(
                        color: kBgSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: kBgCard),
          );
        }

        if (controller.terrains.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _NoTerrainChip(),
          );
        }

        return ListView.separated(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
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
        );
      }),
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

        // ── Marqueurs personnalisés ───────────────────────────────────────────
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final count = events.length;
            // Plus il y a de réservations, plus la barre est pleine et foncée
            final intensity = (count / 3).clamp(0.0, 1.0);
            final barColor = Color.lerp(
              const Color(0xFFFCD34D), // or clair
              const Color(0xFFD97706), // or foncé
              intensity,
            )!;
            return Positioned(
              bottom: 4,
              left: 6,
              right: 6,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        ),

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

  // ── Section créneaux organisée par période ──────────────────────────────────
  Widget _buildSlotsSection(BuildContext context) {
    return Obx(() {
      final slots = controller.slots;
      if (controller.isLoadingTerrains.value) {
        return const SizedBox.shrink();
      }
      if (controller.terrains.isEmpty) {
        return const _AvailabilityEmptyState(
          icon: Icons.sports_soccer_rounded,
          title: 'Aucun terrain',
          message:
              'Crée d’abord un terrain pour gérer ses créneaux de réservation.',
          showCreateButton: true,
        );
      }
      if (slots.isEmpty) {
        return const _AvailabilityEmptyState(
          icon: Icons.event_busy_rounded,
          title: 'Aucun créneau',
          message:
              'Tire vers le bas pour recharger les disponibilités du jour.',
        );
      }

      // Séparer par périodes
      final morning = slots.where((s) => _hourOf(s.time) < 12).toList();
      final afternoon = slots
          .where((s) => _hourOf(s.time) >= 12 && _hourOf(s.time) < 17)
          .toList();
      final evening = slots.where((s) => _hourOf(s.time) >= 17).toList();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Légende compacte
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendDot(kGreen, 'Libre'),
                const SizedBox(width: 14),
                _buildLegendDot(kGold, 'Réservé'),
                const SizedBox(width: 14),
                _buildLegendDot(kTextLight, 'Bloqué'),
              ],
            ),
            const SizedBox(height: 14),

            // ── Matin ────────────────────────────────────────────────────
            if (morning.isNotEmpty) ...[
              _PeriodHeader(
                label: 'Matin',
                icon: Icons.wb_sunny_rounded,
                color: kGold,
                count: morning.where((s) => s.isBooked).length,
                total: morning.length,
              ),
              const SizedBox(height: 8),
              _buildSlotGrid(morning, context, 0),
              const SizedBox(height: 18),
            ],

            // ── Après-midi ───────────────────────────────────────────────
            if (afternoon.isNotEmpty) ...[
              _PeriodHeader(
                label: 'Après-midi',
                icon: Icons.wb_cloudy_rounded,
                color: kBlue,
                count: afternoon.where((s) => s.isBooked).length,
                total: afternoon.length,
              ),
              const SizedBox(height: 8),
              _buildSlotGrid(afternoon, context, morning.length),
              const SizedBox(height: 18),
            ],

            // ── Soirée ───────────────────────────────────────────────────
            if (evening.isNotEmpty) ...[
              _PeriodHeader(
                label: 'Soirée',
                icon: Icons.nightlight_rounded,
                color: const Color(0xFF7C3AED),
                count: evening.where((s) => s.isBooked).length,
                total: evening.length,
              ),
              const SizedBox(height: 8),
              _buildSlotGrid(
                evening,
                context,
                morning.length + afternoon.length,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSlotGrid(
    List<TimeSlot> slots,
    BuildContext context,
    int animOffset,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final slot = slots[i];
        final isNow = _isCurrentHourSlot(slot.time);
        return _SlotCard(
              slot: slot,
              isNow: isNow,
              onTap: () => _onSlotTap(context, slot),
              onLongPress: () async {
                if (slot.isBooked) {
                  return; // on ne peut pas bloquer un slot réservé
                }
                HapticFeedback.heavyImpact();
                final wasBlocked = slot.isBlocked;
                final ok = await controller.toggleBlock(slot.time);
                if (!ok) return;
                Get.snackbar(
                  wasBlocked ? 'Débloqué' : 'Bloqué',
                  '${slot.time} → ${slot.endTime}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: kBgCard,
                  colorText: kTextPrim,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 16,
                  duration: const Duration(seconds: 1),
                  icon: Icon(
                    wasBlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: wasBlocked ? kGreen : kTextLight,
                  ),
                );
              },
            )
            .animate()
            .fadeIn(duration: 200.ms, delay: ((animOffset + i) * 25).ms)
            .scale(begin: const Offset(0.94, 0.94));
      },
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: kTextSub,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Vérifie si un créneau correspond à l'heure actuelle
  bool _isCurrentHourSlot(String time) {
    final now = DateTime.now();
    final hour = _hourOf(time);
    final selectedDay = controller.selectedDate.value;
    return controller.isSameDay(selectedDay, now) && hour == now.hour;
  }

  /// Extrait l'heure depuis "08h00"
  int _hourOf(String time) => int.tryParse(time.substring(0, 2)) ?? 0;

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return Obx(() {
      if (controller.terrains.isEmpty ||
          controller.slots.isEmpty ||
          controller.isLoading.value ||
          controller.isLoadingTerrains.value) {
        return const SizedBox.shrink();
      }

      final isBusy = controller.isBulkUpdating.value;
      return FloatingActionButton.extended(
        onPressed: isBusy ? null : () => _showBulkActionSheet(),
        backgroundColor: isBusy ? kTextLight : kGreen,
        elevation: 3,
        icon: isBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
        label: Text(
          isBusy ? 'Mise à jour' : 'Gérer',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    });
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
  final bool isNow;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SlotCard({
    required this.slot,
    this.isNow = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AvailabilityController>();
    final bgColor = ctrl.slotBgColor(slot.status);
    final accentColor = ctrl.slotColor(slot.status);
    final icon = ctrl.slotIcon(slot.status);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isNow ? kGreen : accentColor.withValues(alpha: 0.35),
            width: isNow ? 2.2 : 1.2,
          ),
          boxShadow: isNow
              ? [
                  BoxShadow(
                    color: kGreen.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Icône en haut à droite
            Positioned(
              top: 5,
              right: 6,
              child: Icon(
                icon,
                size: 12,
                color: accentColor.withValues(alpha: 0.55),
              ),
            ),
            // Badge "Maintenant" en haut à gauche
            if (isNow)
              Positioned(
                top: 3,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: kGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NOW',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isNow ? kGreen : accentColor,
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
                        color: (isNow ? kGreen : accentColor).withValues(
                          alpha: 0.75,
                        ),
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
// Widget : En-tête de période (Matin / Après-midi / Soirée)
// ══════════════════════════════════════════════════════════════════════════════

class _PeriodHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final int total;

  const _PeriodHeader({
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count réservé${count > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kGold,
              ),
            ),
          ),
        const Spacer(),
        Text(
          '$total créneaux',
          style: const TextStyle(fontSize: 10, color: kTextLight),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget : Stat compacte dans le header
// ══════════════════════════════════════════════════════════════════════════════

class _CompactStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _CompactStat({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTerrainChip extends StatelessWidget {
  const _NoTerrainChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: kTextSub),
          SizedBox(width: 6),
          Text(
            'Aucun terrain disponible',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool showCreateButton;

  const _AvailabilityEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.showCreateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: kGreenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kGreen, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kTextPrim,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.4, color: kTextSub),
          ),
          if (showCreateButton) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.terrainForm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Créer un terrain',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
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
    final bgColor = controller.slotBgColor(slot.status);

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
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Fermer',
                          style: TextStyle(
                            color: kTextSub,
                            fontWeight: FontWeight.w600,
                          ),
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
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                  color: kTextSub,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                backgroundColor: slot.isBlocked ? kGreen : kRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
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
                                  fontWeight: FontWeight.w700,
                                ),
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
            onTap: () async {
              HapticFeedback.mediumImpact();
              final count = await controller.blockAllAvailable();
              Get.back();
              Get.snackbar(
                'Créneaux bloqués',
                count == 0
                    ? 'Aucun créneau libre à bloquer'
                    : '$count créneau${count > 1 ? 'x' : ''} bloqué${count > 1 ? 's' : ''}',
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
            onTap: () async {
              HapticFeedback.mediumImpact();
              final count = await controller.unblockAllBlocked();
              Get.back();
              Get.snackbar(
                'Créneaux débloqués',
                count == 0
                    ? 'Aucun créneau bloqué à débloquer'
                    : '$count créneau${count > 1 ? 'x' : ''} débloqué${count > 1 ? 's' : ''}',
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      color: kTextSub,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: const TextStyle(fontSize: 12, color: kTextSub),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: kTextLight,
              size: 20,
            ),
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
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 15,
      itemBuilder: (_, i) =>
          Container(
                decoration: BoxDecoration(
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: kBgCard),
    );
  }
}
