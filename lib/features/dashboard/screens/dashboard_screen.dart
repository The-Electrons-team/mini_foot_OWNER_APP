import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // ── Green curved header background ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF008C47),
                    Color(0xFF006F39),
                    Color(0xFF005A2E),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),
          // ── Subtle pattern on green ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),
          // ── Main scrollable content ──
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildRevenueCard()),
                SliverToBoxAdapter(child: _buildStatsRow()),
                SliverToBoxAdapter(child: _buildQuickActions()),
                SliverToBoxAdapter(child: _buildWeeklyChart()),
                SliverToBoxAdapter(child: _buildRecentBookings()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Header (on green background) ─────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
            ? 'Bon après-midi'
            : 'Bonsoir';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Profile avatar
          GestureDetector(
            onTap: () {
              controller.changeTab(4);
              controller.goToProfile();
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'MS',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kGreen,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mamadou Sy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: controller.goToNotifications,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    PhosphorIcons.bell(PhosphorIconsStyle.regular),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Obx(() => controller.notificationCount.value > 0
                    ? Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          constraints:
                              const BoxConstraints(minWidth: 22, minHeight: 22),
                          decoration: BoxDecoration(
                            color: kRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF008C47), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${controller.notificationCount.value}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms);
  }

  // ─── Revenue hero card ────────────────────────────────────────────────────
  Widget _buildRevenueCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Obx(() => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: kElevatedShadow,
            ),
            child: Column(
              children: [
                // Top row: revenus label + trend badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: kGoldGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kGold.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Revenus totaux',
                        style: TextStyle(
                          fontSize: 14,
                          color: kTextSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kGreenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.trendUp(PhosphorIconsStyle.duotone),
                            color: kGreen,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '+12%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: kGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Big amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmountSpaces(controller.totalRevenue.value),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: kTextPrim,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3, left: 6),
                      child: Text(
                        'F CFA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextSub,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider
                Container(height: 1, color: kDivider),
                const SizedBox(height: 16),
                // Today revenue + see details
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kGreen.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${_formatAmountSpaces(controller.todayRevenue.value)} F CFA aujourd'hui",
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.goToPayments,
                      child: Row(
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            PhosphorIcons.caretRight(
                                PhosphorIconsStyle.duotone),
                            color: kGreen,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 200.ms);
  }

  // ─── Stats row (3 mini cards) ─────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  icon:
                      PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
                  iconBgColor: kBlueLight,
                  iconColor: kBlue,
                  value: '${controller.todayBookings.value}',
                  label: "Rés. aujourd'hui",
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMiniCard(
                  icon: PhosphorIcons.star(PhosphorIconsStyle.duotone),
                  iconBgColor: kGoldLight,
                  iconColor: kGold,
                  value: '${controller.rating.value}',
                  label: 'Note moyenne',
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMiniCard(
                  icon: PhosphorIcons.chartPie(PhosphorIconsStyle.duotone),
                  iconBgColor: kGreenLight,
                  iconColor: kGreen,
                  value:
                      '${(controller.occupancyRate.value * 100).round()}%',
                  label: 'Occupation',
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          )),
    );
  }

  // ─── Quick actions (horizontal scroll cards) ──────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _ActionData(
        icon: PhosphorIcons.soccerBall(PhosphorIconsStyle.duotone),
        label: 'Terrains',
        subtitle: '3 actifs',
        color: kGreen,
        bgColor: kGreenLight,
        onTap: controller.goToTerrains,
      ),
      _ActionData(
        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
        label: 'Réservations',
        subtitle: '${controller.todayBookings.value} nouvelles',
        color: kBlue,
        bgColor: kBlueLight,
        onTap: controller.goToReservations,
      ),
      _ActionData(
        icon: PhosphorIcons.clockCountdown(PhosphorIconsStyle.duotone),
        label: 'Disponibilités',
        subtitle: 'Gérer les créneaux',
        color: kGold,
        bgColor: kGoldLight,
        onTap: controller.goToAvailability,
      ),
      _ActionData(
        icon: PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
        label: 'Paiements',
        subtitle: '2 en attente',
        color: kOrange,
        bgColor: const Color(0xFFFFF3E0),
        onTap: controller.goToPayments,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrim,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: actions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final a = actions[index];
                return GestureDetector(
                  onTap: a.onTap,
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: a.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(a.icon, color: a.color, size: 22),
                        ),
                        const Spacer(),
                        Text(
                          a.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kTextPrim,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kTextLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (400 + index * 80).ms)
                    .slideX(begin: 0.15, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Weekly chart ─────────────────────────────────────────────────────────
  Widget _buildWeeklyChart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(22),
          boxShadow: kCardShadow,
        ),
        child: Obx(() {
          final isWeek = controller.chartPeriod.value == 'week';
          final data = controller.activeChartData;
          final labels = controller.activeChartLabels;
          final maxVal = data.reduce((a, b) => a > b ? a : b);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWeek ? 'Cette semaine' : 'Par mois',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kTextPrim,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Revenus en F CFA',
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextLight,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kBgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        _ChartToggle(
                          label: 'Sem.',
                          isActive: isWeek,
                          onTap: () =>
                              controller.toggleChartPeriod('week'),
                        ),
                        _ChartToggle(
                          label: 'Mois',
                          isActive: !isWeek,
                          onTap: () =>
                              controller.toggleChartPeriod('month'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (maxVal / 1000) * 1.2,
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: isWeek ? 20 : 50,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: kDivider,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= labels.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  fontSize: isWeek ? 11 : 9,
                                  color: kTextLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: data.asMap().entries.map((e) {
                      final isMax = e.value == maxVal;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value / 1000,
                            width: isWeek ? 28 : 16,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            gradient: isMax
                                ? kGreenGradient
                                : LinearGradient(
                                    colors: [
                                      kGreen.withValues(alpha: 0.18),
                                      kGreen.withValues(alpha: 0.08),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIdx, rod, rodIdx) {
                          return BarTooltipItem(
                            '${(rod.toY * 1000).toInt()} F',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
            ],
          );
        }),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms);
  }

  // ─── Recent bookings ──────────────────────────────────────────────────────
  Widget _buildRecentBookings() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Réservations récentes',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kTextPrim,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${controller.recentBookings.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kGreen,
                          ),
                        ),
                      )),
                ],
              ),
              GestureDetector(
                onTap: controller.goToReservations,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: kBgSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Voir tout',
                        style: TextStyle(
                          fontSize: 12,
                          color: kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIcons.caretRight(PhosphorIconsStyle.duotone),
                        color: kGreen,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: controller.recentBookings
                    .asMap()
                    .entries
                    .map((entry) => _BookingTile(booking: entry.value)
                        .animate()
                        .fadeIn(
                            duration: 400.ms,
                            delay: (700 + entry.key * 80).ms)
                        .slideY(begin: 0.1, end: 0))
                    .toList(),
              )),
        ],
      ),
    );
  }

  // ─── Bottom navigation ────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Obx(() => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: kBgCard,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: kNavShadow,
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: PhosphorIcons.squaresFour(
                            PhosphorIconsStyle.duotone),
                        label: 'Accueil',
                        isSelected: controller.selectedTab.value == 0,
                        onTap: () => controller.changeTab(0),
                      ),
                      _NavItem(
                        icon: PhosphorIcons.courtBasketball(
                            PhosphorIconsStyle.duotone),
                        label: 'Terrains',
                        isSelected: controller.selectedTab.value == 1,
                        onTap: () {
                          controller.changeTab(1);
                          controller.goToTerrains();
                        },
                      ),
                      const SizedBox(width: 72),
                      _NavItem(
                        icon: PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
                        label: 'Paiements',
                        isSelected: controller.selectedTab.value == 3,
                        onTap: () {
                          controller.changeTab(3);
                          controller.goToPayments();
                        },
                      ),
                      _NavItem(
                        icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                        label: 'Profil',
                        isSelected: controller.selectedTab.value == 4,
                        onTap: () {
                          controller.changeTab(4);
                          controller.goToProfile();
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () {
                      controller.changeTab(2);
                      controller.goToReservations();
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: kBgCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: controller.selectedTab.value == 2
                              ? kGreen
                              : Colors.black12,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            'assets/images/ballon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  String _formatAmountSpaces(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

// ─── Stat mini card ─────────────────────────────────────────────────────────
class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;

  const _StatMiniCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTextPrim,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: kTextSub,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Booking tile ───────────────────────────────────────────────────────────
class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = booking['status'] == 'confirmed';
    final statusColor = isConfirmed ? kGreen : kGold;
    final statusBgColor = isConfirmed ? kGreenLight : kGoldLight;
    final statusText = isConfirmed ? 'Confirmé' : 'En attente';
    final amount = booking['amount'] as int;

    final amountStr = StringBuffer();
    final raw = amount.toString();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) amountStr.write(' ');
      amountStr.write(raw[i]);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isConfirmed
                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone)
                  : PhosphorIcons.clock(PhosphorIconsStyle.duotone),
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
                    Text(
                      booking['terrain'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextSub,
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
                    Icon(
                      PhosphorIcons.clock(PhosphorIconsStyle.duotone),
                      size: 13,
                      color: kTextLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        booking['time'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextSub,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountStr F',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kTextPrim,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Chart toggle button ────────────────────────────────────────────────────
class _ChartToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? kGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : kTextSub,
          ),
        ),
      ),
    );
  }
}

// ─── Nav item ───────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? kGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : kTextLight,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? kGreen : kTextLight,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dot pattern painter ────────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
