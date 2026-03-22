import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/payments_controller.dart';

class PaymentsScreen extends GetView<PaymentsController> {
  const PaymentsScreen({super.key});

  String _formatAmountFull(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.refreshPayments,
              color: kGreen,
              backgroundColor: kBgCard,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverToBoxAdapter(child: _buildFilterChips()),
                  SliverToBoxAdapter(child: _buildTransactionsHeader()),
                  SliverToBoxAdapter(child: _buildTransactionsList()),
                  // Espace pour le bottom bar
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
            // Bottom summary bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomSummaryBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Green gradient header ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: kGreenGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Top row: back + title
          Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.caretLeft(PhosphorIconsStyle.duotone),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Paiements',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              // Placeholder pour centrer le titre
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 24),

          // Big revenue number
          Obx(() => Column(
                children: [
                  Text(
                    'Revenus totaux',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatAmountFull(controller.totalRevenue.value)} F CFA',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 18),

          // Small stats row
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HeaderStatChip(
                    icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
                    label: 'Ce mois',
                    value: '${_formatAmountFull(controller.monthlyRevenue.value)} F',
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  _HeaderStatChip(
                    icon: PhosphorIcons.hourglass(PhosphorIconsStyle.duotone),
                    label: 'En attente',
                    value: '${_formatAmountFull(controller.pendingAmount.value)} F',
                  ),
                ],
              )),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  // ── Filter chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'Tout'},
      {'key': 'paid', 'label': 'Payé'},
      {'key': 'pending', 'label': 'En attente'},
      {'key': 'failed', 'label': 'Échoué'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 40,
        child: Obx(() => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isActive =
                    controller.selectedFilter.value == filter['key'];
                return GestureDetector(
                  onTap: () => controller.setFilter(filter['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? kGreen : kBgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isActive ? [] : kCardShadow,
                      border: isActive
                          ? null
                          : Border.all(color: kBorder, width: 0.5),
                    ),
                    child: Text(
                      filter['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : kTextSub,
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 350.ms);
  }

  // ── Transactions header ─────────────────────────────────────────────────────
  Widget _buildTransactionsHeader() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.listDashes(PhosphorIconsStyle.duotone),
                size: 20,
                color: kTextPrim,
              ),
              const SizedBox(width: 8),
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kTextPrim,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kGreenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.filteredTransactions.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kGreen,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // ── Transactions list ───────────────────────────────────────────────────────
  Widget _buildTransactionsList() {
    return Obx(() {
      final txns = controller.filteredTransactions;
      if (txns.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: kBgSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone),
                    size: 32,
                    color: kTextLight,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextPrim,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aucune transaction ne correspond\nau filtre sélectionné.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: kTextSub,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 300.ms,
            );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Column(
          children: List.generate(txns.length, (index) {
            return _TransactionCard(
              transaction: txns[index],
              formatAmount: _formatAmountFull,
            )
                .animate()
                .fadeIn(
                  delay: (100 + index * 80).ms,
                  duration: 350.ms,
                )
                .slideX(
                  begin: 0.05,
                  end: 0,
                  delay: (100 + index * 80).ms,
                  duration: 350.ms,
                  curve: Curves.easeOut,
                );
          }),
        ),
      );
    });
  }

  // ── Bottom summary bar ──────────────────────────────────────────────────────
  Widget _buildBottomSummaryBar() {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: kBgCard,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: kElevatedShadow,
                ),
                child: Row(
                  children: [
                    // Paid count
                    _CountCircle(
                      count: controller.paidCount,
                      color: kGreen,
                      bgColor: kGreenLight,
                      label: 'Payés',
                    ),
                    const SizedBox(width: 12),
                    // Pending count
                    _CountCircle(
                      count: controller.pendingCount,
                      color: kGold,
                      bgColor: kGoldLight,
                      label: 'En attente',
                    ),
                    const Spacer(),
                    // Voir rapport button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: kGreenGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.chartBar(PhosphorIconsStyle.duotone),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Voir rapport',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 350.ms).slideY(
          begin: 0.3,
          end: 0,
          delay: 400.ms,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Header stat chip ──────────────────────────────────────────────────────────

class _HeaderStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Count circle for bottom bar ─────────────────────────────────────────────

class _CountCircle extends StatelessWidget {
  final int count;
  final Color color;
  final Color bgColor;
  final String label;

  const _CountCircle({
    required this.count,
    required this.color,
    required this.bgColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: kTextSub,
          ),
        ),
      ],
    );
  }
}

// ── Transaction card widget ─────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(int) formatAmount;

  const _TransactionCard({
    required this.transaction,
    required this.formatAmount,
  });

  Color get _methodColor {
    switch (transaction.method) {
      case 'Wave':
        return kBlue;
      case 'Orange Money':
        return const Color(0xFFFF6D00);
      case 'Free Money':
        return kGreen;
      default:
        return kTextSub;
    }
  }

  Color get _methodBg {
    switch (transaction.method) {
      case 'Wave':
        return kBlueLight;
      case 'Orange Money':
        return const Color(0xFFFFF3E0);
      case 'Free Money':
        return kGreenLight;
      default:
        return kBgSurface;
    }
  }

  IconData get _methodIcon {
    switch (transaction.method) {
      case 'Wave':
        return PhosphorIcons.waves(PhosphorIconsStyle.duotone);
      case 'Orange Money':
        return PhosphorIcons.phone(PhosphorIconsStyle.duotone);
      case 'Free Money':
        return PhosphorIcons.currencyCircleDollar(PhosphorIconsStyle.duotone);
      default:
        return PhosphorIcons.creditCard(PhosphorIconsStyle.duotone);
    }
  }

  Color get _statusColor {
    switch (transaction.status) {
      case 'paid':
        return kGreen;
      case 'pending':
        return kGold;
      case 'failed':
        return kRed;
      default:
        return kTextSub;
    }
  }

  Color get _statusBg {
    switch (transaction.status) {
      case 'paid':
        return kGreenLight;
      case 'pending':
        return kGoldLight;
      case 'failed':
        return kRedLight;
      default:
        return kBgSurface;
    }
  }

  IconData get _statusIcon {
    switch (transaction.status) {
      case 'paid':
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone);
      case 'pending':
        return PhosphorIcons.clock(PhosphorIconsStyle.duotone);
      case 'failed':
        return PhosphorIcons.xCircle(PhosphorIconsStyle.duotone);
      default:
        return PhosphorIcons.question(PhosphorIconsStyle.duotone);
    }
  }

  String get _statusLabel {
    switch (transaction.status) {
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échoué';
      default:
        return transaction.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // Payment method icon - bigger 48x48
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _methodBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_methodIcon, color: _methodColor, size: 24),
          ),
          const SizedBox(width: 14),

          // Client info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.client,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextPrim,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                      size: 13,
                      color: kTextLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        transaction.terrain,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(
                        color: kTextLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      transaction.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kTextLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatAmount(transaction.amount)} F',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kTextPrim,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
