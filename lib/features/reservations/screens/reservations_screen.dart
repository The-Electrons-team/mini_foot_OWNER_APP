import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controllers/reservations_controller.dart';

class ReservationsScreen extends GetView<ReservationsController> {
  const ReservationsScreen({super.key});

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
          'Reservations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kDivider),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshReservations,
        color: kGreen,
        backgroundColor: kBgCard,
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(child: _buildReservationList()),
          ],
        ),
      ),
    );
  }

  // ── Filter chips row ────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return Obx(() {
      final filters = [
        {'key': 'all', 'label': 'Toutes', 'count': controller.totalCount},
        {'key': 'confirmed', 'label': 'Confirmees', 'count': controller.confirmedCount},
        {'key': 'pending', 'label': 'En attente', 'count': controller.pendingCount},
        {'key': 'cancelled', 'label': 'Annulees', 'count': controller.cancelledCount},
      ];

      return Container(
        color: kBgCard,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = controller.selectedFilter.value == f['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.setFilter(f['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kGreen : kBgSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? kGreen : kBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          f['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : kTextSub,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : kBgCard,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${f['count']}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : kTextSub,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  // ── Reservation list ────────────────────────────────────────────────────────
  Widget _buildReservationList() {
    return Obx(() {
      // Shimmer loading pendant le chargement
      if (controller.isLoading.value) {
        return ShimmerList(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemBuilder: (context, index) => const ReservationCardSkeleton(),
        );
      }

      final list = controller.filteredReservations;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/football_bounce.json',
                width: 120,
                height: 120,
                repeat: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucune reservation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextSub,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Les reservations apparaitront ici',
                style: TextStyle(fontSize: 13, color: kTextLight),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: list.length,
        itemBuilder: (_, i) => _ReservationCard(reservation: list[i])
            .animate()
            .fadeIn(duration: 400.ms, delay: (i * 80).ms)
            .slideY(begin: 0.1, end: 0),
      );
    });
  }
}

// ── Reservation card ────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  const _ReservationCard({required this.reservation});

  Color get _statusColor {
    switch (reservation.status) {
      case 'confirmed':
        return kGreen;
      case 'pending':
        return kGold;
      case 'cancelled':
        return kRed;
      default:
        return kTextSub;
    }
  }

  Color get _statusBg {
    switch (reservation.status) {
      case 'confirmed':
        return kGreenLight;
      case 'pending':
        return kGoldLight;
      case 'cancelled':
        return kRedLight;
      default:
        return kBgSurface;
    }
  }

  String get _statusLabel {
    switch (reservation.status) {
      case 'confirmed':
        return 'Confirme';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annule';
      default:
        return reservation.status;
    }
  }

  String get _initials {
    final parts = reservation.clientName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return reservation.clientName.substring(0, 2).toUpperCase();
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} F CFA';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          // Top row: avatar + name + status badge
          Row(
            children: [
              // Avatar with initials
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kGreenDim,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.clientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextPrim,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reservation.teamName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextSub,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: kDivider),
          const SizedBox(height: 14),

          // Bottom row: terrain, time, date, amount
          Row(
            children: [
              // Terrain
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kBlueLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(PhosphorIcons.courtBasketball(PhosphorIconsStyle.duotone), color: kBlue, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        reservation.terrain,
                        style: const TextStyle(fontSize: 12, color: kTextSub),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Time
              Row(
                children: [
                  Icon(PhosphorIcons.clock(PhosphorIconsStyle.duotone), color: kTextLight, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    reservation.timeSlot,
                    style: const TextStyle(fontSize: 12, color: kTextSub),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Date
              Row(
                children: [
                  Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone), color: kTextLight, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    reservation.date,
                    style: const TextStyle(fontSize: 12, color: kTextSub),
                  ),
                ],
              ),
              const Spacer(),
              // Amount
              Text(
                _formatAmount(reservation.amount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTextPrim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
