import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../reports/screens/report_screen.dart';
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
          icon: Icon(
            PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone),
            size: 18,
          ),
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
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => const ReportScreen(),
              arguments: {'reportType': 'reservations'},
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded, color: kGreen),
            tooltip: 'Rapport PDF',
          ),
        ],
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
        {
          'key': 'confirmed',
          'label': 'Confirmees',
          'count': controller.confirmedCount,
        },
        {
          'key': 'pending',
          'label': 'En attente',
          'count': controller.pendingCount,
        },
        {
          'key': 'cancelled',
          'label': 'Annulees',
          'count': controller.cancelledCount,
        },
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kGreen : kBgSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isSelected ? kGreen : kBorder),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
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
        itemBuilder: (_, i) =>
            _ReservationCard(
                  reservation: list[i],
                  onTap: () => _showReservationDetails(list[i]),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: (i * 80).ms)
                .slideY(begin: 0.1, end: 0),
      );
    });
  }

  void _showReservationDetails(ReservationModel reservation) {
    Get.bottomSheet(
      _ReservationDetailSheet(
        reservation: reservation,
        onCancel: reservation.canCancel
            ? () {
                Get.back();
                controller.cancelReservation(reservation.id);
              }
            : null,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ── Reservation card ────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onTap;

  const _ReservationCard({required this.reservation, required this.onTap});

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
    final name = reservation.clientName.trim();
    if (name.isEmpty) return 'MF';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first.length >= 2
        ? parts.first.substring(0, 2).toUpperCase()
        : parts.first[0].toUpperCase();
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: kCardShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
                Row(
                  children: [
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
                            child: Icon(
                              PhosphorIcons.courtBasketball(
                                PhosphorIconsStyle.duotone,
                              ),
                              color: kBlue,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              reservation.terrain,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextSub,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.clock(PhosphorIconsStyle.duotone),
                          color: kTextLight,
                          size: 14,
                        ),
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
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendarBlank(
                            PhosphorIconsStyle.duotone,
                          ),
                          color: kTextLight,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reservation.date,
                          style: const TextStyle(fontSize: 12, color: kTextSub),
                        ),
                      ],
                    ),
                    const Spacer(),
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
          ),
        ),
      ),
    );
  }
}

class _ReservationDetailSheet extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback? onCancel;

  const _ReservationDetailSheet({required this.reservation, this.onCancel});

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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: kElevatedShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: kGreenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
                    color: kGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détail réservation',
                        style: TextStyle(
                          color: kTextPrim,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        reservation.reference.isNotEmpty
                            ? reservation.reference
                            : reservation.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kTextLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
              label: 'Client',
              value: reservation.clientName,
            ),
            _DetailRow(
              icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
              label: 'Téléphone',
              value: reservation.phone.isEmpty
                  ? 'Non renseigné'
                  : reservation.phone,
            ),
            _DetailRow(
              icon: PhosphorIcons.courtBasketball(PhosphorIconsStyle.duotone),
              label: 'Terrain',
              value: reservation.terrain,
            ),
            _DetailRow(
              icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
              label: 'Date',
              value: reservation.date,
            ),
            _DetailRow(
              icon: PhosphorIcons.clock(PhosphorIconsStyle.duotone),
              label: 'Créneau',
              value: reservation.timeSlot,
            ),
            _DetailRow(
              icon: PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
              label: 'Paiement',
              value:
                  '${reservation.paymentMethod} · ${reservation.paymentStatus}',
            ),
            _DetailRow(
              icon: PhosphorIcons.money(PhosphorIconsStyle.duotone),
              label: 'Montant',
              value: _formatAmount(reservation.amount),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(
                    PhosphorIcons.xCircle(PhosphorIconsStyle.duotone),
                    size: 18,
                  ),
                  label: const Text('Refuser la réservation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: const BorderSide(color: kRed),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kTextSub, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: kTextLight, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: kTextPrim,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
