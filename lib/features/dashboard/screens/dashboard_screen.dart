import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/dashboard_controller.dart';

// ─── Constantes de layout ────────────────────────────────────────────────────
const double _kHeaderImageH  = 220.0; // hauteur image expanded
const double _kCardFullH     = 160.0; // hauteur revenue card expanded
const double _kCardCompactH  = 60.0;  // hauteur revenue card collapsed
const double _kOverlapFull   = 60.0;  // overlap expanded
const double _kOverlapMin    = 20.0;  // overlap collapsed (card reste dans le header)
const double _kHeaderMinH    = 72.0;  // hauteur image collapsed (barre verte)

// expanded = image + card visible sous l'image
const double _kExpandedH = _kHeaderImageH + _kCardFullH - _kOverlapFull;
// collapsed = barre verte + card compacte - overlap mini (card chevauche toujours)
const double _kCollapsedH = _kHeaderMinH + _kCardCompactH - _kOverlapMin;

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _DashboardHeader(controller: controller),
          // Espace pour la partie de la card qui dépasse sous le header
          const SliverToBoxAdapter(child: SizedBox(height: _kCardFullH - _kOverlapFull - 48)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsRow(),
                _buildQuickActions(),
                _buildWeeklyChart(),
                _buildRecentBookings(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Stats row ───────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
                  iconBgColor: kBlueLight,
                  iconColor: kBlue,
                  value: '${controller.todayBookings.value}',
                  label: "Rés. aujourd'hui",
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMiniCard(
                  icon: PhosphorIcons.star(PhosphorIconsStyle.duotone),
                  iconBgColor: kGoldLight,
                  iconColor: kGold,
                  value: '${controller.rating.value}',
                  label: 'Note moyenne',
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMiniCard(
                  icon: PhosphorIcons.chartPie(PhosphorIconsStyle.duotone),
                  iconBgColor: kGreenLight,
                  iconColor: kGreen,
                  value: '${(controller.occupancyRate.value * 100).round()}%',
                  label: 'Occupation',
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
            ],
          )),
    );
  }

  // ─── Quick actions ────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _ActionData(
        icon: PhosphorIcons.soccerBall(PhosphorIconsStyle.duotone),
        label: 'Terrains', subtitle: '3 actifs',
        color: kGreen, bgColor: kGreenLight, onTap: controller.goToTerrains,
      ),
      _ActionData(
        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
        label: 'Réservations', subtitle: '${controller.todayBookings.value} nouvelles',
        color: kBlue, bgColor: kBlueLight, onTap: controller.goToReservations,
      ),
      _ActionData(
        icon: PhosphorIcons.clockCountdown(PhosphorIconsStyle.duotone),
        label: 'Disponibilités', subtitle: 'Gérer les créneaux',
        color: kGold, bgColor: kGoldLight, onTap: controller.goToAvailability,
      ),
      _ActionData(
        icon: PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
        label: 'Paiements', subtitle: '2 en attente',
        color: kOrange, bgColor: const Color(0xFFFFF3E0), onTap: controller.goToPayments,
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
                const Text('Actions rapides',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kTextPrim)),
                const SizedBox(width: 8),
                Container(width: 6, height: 6,
                    decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: actions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final a = actions[index];
                return GestureDetector(
                  onTap: a.onTap,
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: a.bgColor, borderRadius: BorderRadius.circular(12)),
                          child: Icon(a.icon, color: a.color, size: 22),
                        ),
                        const Spacer(),
                        Text(a.label,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextPrim)),
                        const SizedBox(height: 2),
                        Text(a.subtitle,
                            style: const TextStyle(fontSize: 11, color: kTextLight, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: (400 + index * 80).ms).slideX(begin: 0.15, end: 0);
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
                      Text(isWeek ? 'Cette semaine' : 'Par mois',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrim)),
                      const SizedBox(height: 2),
                      const Text('Revenus en F CFA',
                          style: TextStyle(fontSize: 12, color: kTextLight)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: kBgSurface, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        _ChartToggle(label: 'Sem.', isActive: isWeek,
                            onTap: () => controller.toggleChartPeriod('week')),
                        _ChartToggle(label: 'Mois', isActive: !isWeek,
                            onTap: () => controller.toggleChartPeriod('month')),
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
                      getDrawingHorizontalLine: (v) => FlLine(color: kDivider, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[idx],
                                  style: TextStyle(
                                      fontSize: isWeek ? 11 : 9,
                                      color: kTextLight,
                                      fontWeight: FontWeight.w500)),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                            gradient: isMax
                                ? kGreenGradient
                                : LinearGradient(
                                    colors: [kGreen.withValues(alpha: 0.18), kGreen.withValues(alpha: 0.08)],
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          ),
                        ],
                      );
                    }).toList(),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIdx, rod, rodIdx) => BarTooltipItem(
                          '${(rod.toY * 1000).toInt()} F',
                          const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
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
                  const Text('Réservations récentes',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kTextPrim)),
                  const SizedBox(width: 8),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(8)),
                        child: Text('${controller.recentBookings.length}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreen)),
                      )),
                ],
              ),
              GestureDetector(
                onTap: controller.goToReservations,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: kBgSurface, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Text('Voir tout',
                          style: TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.duotone), color: kGreen, size: 14),
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
                        .fadeIn(duration: 400.ms, delay: (700 + entry.key * 80).ms)
                        .slideY(begin: 0.1, end: 0))
                    .toList(),
              )),
        ],
      ),
    );
  }

  // ─── Bottom nav ───────────────────────────────────────────────────────────
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
                        icon: PhosphorIcons.squaresFour(PhosphorIconsStyle.duotone),
                        label: 'Accueil',
                        isSelected: controller.selectedTab.value == 0,
                        onTap: () => controller.changeTab(0),
                      ),
                      _NavItem(
                        icon: PhosphorIcons.courtBasketball(PhosphorIconsStyle.duotone),
                        label: 'Terrains',
                        isSelected: controller.selectedTab.value == 1,
                        onTap: () { controller.changeTab(1); controller.goToTerrains(); },
                      ),
                      const SizedBox(width: 72),
                      _NavItem(
                        icon: PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
                        label: 'Paiements',
                        isSelected: controller.selectedTab.value == 3,
                        onTap: () { controller.changeTab(3); controller.goToPayments(); },
                      ),
                      _NavItem(
                        icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                        label: 'Profil',
                        isSelected: controller.selectedTab.value == 4,
                        onTap: () { controller.changeTab(4); controller.goToProfile(); },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () { controller.changeTab(2); controller.goToReservations(); },
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: kBgCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: controller.selectedTab.value == 2 ? kGreen : Colors.black12,
                          width: 2,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset('assets/images/ballon.png', fit: BoxFit.contain),
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

  static String _formatAmountSpaces(int value) {
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
// SLIVER HEADER — image fixe + revenue card chevauchante
// ═══════════════════════════════════════════════════════════════════════════════

class _DashboardHeader extends StatelessWidget {
  final DashboardController controller;
  const _DashboardHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        controller: controller,
        topPad: topPad,
        expandedHeight: _kExpandedH + topPad,
        collapsedHeight: _kCollapsedH + topPad,
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final DashboardController controller;
  final double topPad;
  final double expandedHeight;
  final double collapsedHeight;

  const _HeaderDelegate({
    required this.controller,
    required this.topPad,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => collapsedHeight;
  @override
  bool shouldRebuild(covariant _HeaderDelegate old) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // t = 1 expanded → 0 collapsed
    final t = (1.0 - shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Hauteur image interpolée : de _kHeaderImageH → _kHeaderMinH
    final imageH = _kHeaderMinH + (_kHeaderImageH - _kHeaderMinH) * t + topPad;

    // Hauteur card interpolée : de _kCardFullH → _kCardCompactH
    final cardH = _kCardCompactH + (_kCardFullH - _kCardCompactH) * t;

    // Overlap interpolé : toujours présent, de _kOverlapFull → _kOverlapMin
    final overlap = _kOverlapMin + (_kOverlapFull - _kOverlapMin) * t;

    // Position top de la card : bas de l'image - overlap
    final cardTop = imageH - overlap;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Zone image (se réduit au scroll) ────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: imageH,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF006F39)),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: const Color(0xFF006F39));
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF006F39).withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
                // Avatar + nom + cloche (disparaît progressivement)
                Positioned(
                  top: topPad,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: _buildHeaderContent(context),
                  ),
                ),
                // Barre compacte dans l'image (apparaît quand collapsed)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _kHeaderMinH + topPad,
                  child: Opacity(
                    opacity: (1.0 - t * 3).clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(11)),
                            child: const Center(
                              child: Text('MS',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kGreen)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Tableau de bord',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Revenue card (se réduit au scroll, reste visible) ────────────
        Positioned(
          top: cardTop,
          left: 24,
          right: 24,
          height: cardH,
          child: _RevenueCardAnimated(controller: controller, t: t),
        ),
      ],
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : hour < 18 ? 'Bon après-midi' : 'Bonsoir';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gauche : salutation + titre
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting 👋',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'MINIFOOT',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Espace propriétaire',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          // Droite : notif + toggle thème
          Row(
            children: [
              _NotifBell(controller: controller),
              const SizedBox(width: 8),
              // Toggle thème (cercle blanc, icône verte)
              GestureDetector(
                onTap: () {}, // TODO: connecter au thème
                child: Container(
                  width: 42, height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dark_mode_rounded,
                    color: kGreen,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtAmt(int value) {
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
// WIDGETS EXTRAITS (utilisent Obx — ne peuvent pas être dans _HeaderDelegate)
// ═══════════════════════════════════════════════════════════════════════════════

class _NotifBell extends StatelessWidget {
  final DashboardController controller;
  const _NotifBell({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.goToNotifications,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cercle blanc avec icône verte — même style que minifoot_mobile
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, color: kGreen, size: 22),
          ),
          Obx(() => controller.notificationCount.value > 0
              ? Positioned(
                  top: 4, right: 4,
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        controller.notificationCount.value > 9
                            ? '9+'
                            : '${controller.notificationCount.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _RevenueCardAnimated extends StatelessWidget {
  final DashboardController controller;
  final double t; // 1 = expanded, 0 = collapsed

  const _RevenueCardAnimated({required this.controller, required this.t});

  static String _fmt(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = t > 0.4;
    return Obx(() => ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: kElevatedShadow,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: isExpanded ? 14 : 11),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: isExpanded ? _buildExpanded() : _buildCompact(),
              ),
            ),
          ),
        ));
  }

  Widget _buildExpanded() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: kGoldGradient, borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(PhosphorIcons.wallet(PhosphorIconsStyle.duotone), color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Revenus totaux',
                  style: TextStyle(fontSize: 13, color: kTextSub, fontWeight: FontWeight.w500)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.trendUp(PhosphorIconsStyle.duotone), color: kGreen, size: 13),
                  const SizedBox(width: 3),
                  const Text('+12%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_fmt(controller.totalRevenue.value),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                    color: kTextPrim, letterSpacing: -1, height: 1)),
            const Padding(
              padding: EdgeInsets.only(bottom: 2, left: 5),
              child: Text('F CFA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextSub)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: kDivider),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                color: kGreen, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kGreen.withValues(alpha: 0.4), blurRadius: 5)],
              ),
            ),
            const SizedBox(width: 8),
            Text("${_fmt(controller.todayRevenue.value)} F CFA aujourd'hui",
                style: const TextStyle(fontSize: 12, color: kTextSub, fontWeight: FontWeight.w500)),
            const Spacer(),
            GestureDetector(
              onTap: controller.goToPayments,
              child: Row(
                children: [
                  const Text('Détails', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGreen)),
                  const SizedBox(width: 3),
                  Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.duotone), color: kGreen, size: 14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(gradient: kGoldGradient, borderRadius: BorderRadius.circular(12)),
          child: Icon(PhosphorIcons.wallet(PhosphorIconsStyle.duotone), color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Revenus totaux',
                  style: TextStyle(fontSize: 11, color: kTextSub, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('${_fmt(controller.totalRevenue.value)} F CFA',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                      color: kTextPrim, letterSpacing: -0.5, height: 1)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.trendUp(PhosphorIconsStyle.duotone), color: kGreen, size: 13),
              const SizedBox(width: 3),
              const Text('+12%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
            ],
          ),
        ),
      ],
    );
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
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.bgColor, required this.onTap,
  });
}

class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;

  const _StatMiniCard({
    required this.icon, required this.iconBgColor, required this.iconColor,
    required this.value, required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBgCard, borderRadius: BorderRadius.circular(18), boxShadow: kCardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextPrim)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: kTextSub, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

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
    final raw = amount.toString();
    final amountStr = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) amountStr.write(' ');
      amountStr.write(raw[i]);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard, borderRadius: BorderRadius.circular(18), boxShadow: kCardShadow),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(
              isConfirmed
                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone)
                  : PhosphorIcons.clock(PhosphorIconsStyle.duotone),
              color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextPrim)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.duotone), size: 13, color: kTextLight),
                    const SizedBox(width: 4),
                    Text(booking['terrain'] as String,
                        style: const TextStyle(fontSize: 12, color: kTextSub)),
                    Container(
                      width: 3, height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(color: kTextLight, shape: BoxShape.circle),
                    ),
                    Icon(PhosphorIcons.clock(PhosphorIconsStyle.duotone), size: 13, color: kTextLight),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(booking['time'] as String,
                          style: const TextStyle(fontSize: 12, color: kTextSub),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$amountStr F',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kTextPrim)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(10)),
                child: Text(statusText,
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartToggle({required this.label, required this.isActive, required this.onTap});

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
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : kTextSub)),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

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
              child: Icon(icon, color: isSelected ? Colors.white : kTextLight, size: 22),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? kGreen : kTextLight,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                maxLines: 1),
          ],
        ),
      ),
    );
  }
}
