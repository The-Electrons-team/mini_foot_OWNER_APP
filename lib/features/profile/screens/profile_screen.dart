import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader(context)),
          SliverToBoxAdapter(child: _buildProfileCard()),
          SliverToBoxAdapter(child: _buildCompletionBar()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildRevenueCard()),
          SliverToBoxAdapter(child: _buildSubscriptionCard()),
          SliverToBoxAdapter(child: _buildAccountSection()),
          SliverToBoxAdapter(child: _buildPreferencesSection()),
          SliverToBoxAdapter(child: _buildSupportSection()),
          SliverToBoxAdapter(child: _buildLogoutButton()),
          SliverToBoxAdapter(child: _buildVersion()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── Hero header avec image terrain + overlay vert ──────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image terrain en fond
          Image.asset('assets/images/terrain.webp', fit: BoxFit.cover),
          // Gradient overlay vert
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  kGreen.withValues(alpha: 0.65),
                  kGreen.withValues(alpha: 0.85),
                  kGreen.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
          // Pattern decoratif subtil
          Positioned.fill(
            child: CustomPaint(painter: _HexPatternPainter()),
          ),
          // Bouton retour
          Positioned(
            top: topPad + 8,
            left: 16,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          // Titre "Mon Profil"
          Positioned(
            top: topPad + 14,
            left: 0,
            right: 0,
            child: const Text(
              'Mon Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Bouton modifier
          Positioned(
            top: topPad + 8,
            right: 16,
            child: GestureDetector(
              onTap: controller.toggleEdit,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          // Deco: mini terrain icon en bas a droite
          Positioned(
            bottom: 30,
            right: 24,
            child: Icon(
              Icons.sports_soccer_rounded,
              color: Colors.white.withValues(alpha: 0.08),
              size: 80,
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte profil chevauchante ──────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Obx(() => Transform.translate(
          offset: const Offset(0, -40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: kElevatedShadow,
              ),
              child: Column(
                children: [
                  // Avatar cercle avec gradient et ombre
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kGreenGradient,
                      border: Border.all(color: kBgCard, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: kGreen.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        controller.initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nom
                  Text(
                    controller.ownerName.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kTextPrim,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: kGreen, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'Proprietaire verifie',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Infos contact
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kBgSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.email_outlined,
                          text: controller.email.value,
                          color: kBlue,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(height: 1, color: kDivider),
                        ),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          text: controller.phone.value,
                          color: kGreen,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(height: 1, color: kDivider),
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          text:
                              'Membre depuis ${controller.memberSince.value}',
                          color: kGold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // ── Barre de completion profil ─────────────────────────────────────────────
  Widget _buildCompletionBar() {
    return Obx(() {
      final percent = controller.completionPercent;
      final rate = percent / 100.0;
      final barColor = rate >= 1.0
          ? kGreen
          : rate > 0.6
              ? kGold
              : kRed;
      return Transform.translate(
        offset: const Offset(0, -24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
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
                    Icon(
                      rate >= 1.0
                          ? Icons.check_circle_rounded
                          : Icons.pie_chart_rounded,
                      color: barColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.completionLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: barColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: kBgSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 6,
                  ),
                ),
                if (rate < 1.0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez une photo de profil pour completer',
                    style: TextStyle(fontSize: 11, color: kTextLight),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Obx(() => Transform.translate(
          offset: const Offset(0, -8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatCard(
                  value: '${controller.totalTerrains.value}',
                  label: 'Terrains',
                  icon: Icons.stadium_rounded,
                  color: kGreen,
                  bgColor: kGreenLight,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  value: '${controller.totalBookings.value}',
                  label: 'Reservations',
                  icon: Icons.calendar_month_rounded,
                  color: kBlue,
                  bgColor: kBlueLight,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  value: '${controller.rating.value}',
                  label: 'Note',
                  icon: Icons.star_rounded,
                  color: kGold,
                  bgColor: kGoldLight,
                ),
              ],
            ),
          ),
        ));
  }

  // ── Carte revenus rapide ───────────────────────────────────────────────────
  Widget _buildRevenueCard() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: kCardShadow,
            ),
            child: Row(
              children: [
                // Icone revenus
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: kGoldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kGold.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenus totaux',
                        style: TextStyle(
                          fontSize: 13,
                          color: kTextSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.formatRevenue(controller.totalRevenue.value)} F CFA',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kTextPrim,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Fleche voir details
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.trending_up_rounded, color: kGold, size: 20),
                ),
              ],
            ),
          ),
        ));
  }

  // ── Carte abonnement premium ───────────────────────────────────────────────
  Widget _buildSubscriptionCard() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kGreenGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: kGreen.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icone premium
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan ${controller.planName.value}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Terrains illimites, stats avancees',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge actif
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Separateur
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 14),
                // Date expiration
                Row(
                  children: [
                    Icon(Icons.event_rounded,
                        color: Colors.white.withValues(alpha: 0.7), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Expire le ${controller.planExpiry.value}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Renouveler',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  // ── Section Compte ─────────────────────────────────────────────────────────
  Widget _buildAccountSection() {
    return _SettingsSection(
      title: 'Compte',
      items: [
        _SettingsItem(
          icon: Icons.person_outline_rounded,
          iconBg: kGreenLight,
          iconColor: kGreen,
          label: 'Informations personnelles',
          subtitle: 'Nom, email, telephone',
          onTap: () => Get.toNamed(Routes.editProfile),
        ),
        _SettingsItem(
          icon: Icons.lock_outline_rounded,
          iconBg: kBlueLight,
          iconColor: kBlue,
          label: 'Securite',
          subtitle: 'Mot de passe, authentification 2FA',
          onTap: () => Get.toNamed(Routes.security),
        ),
        _SettingsItem(
          icon: Icons.account_balance_wallet_outlined,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: kOrange,
          label: 'Methodes de paiement',
          subtitle: 'Wave, Orange Money, carte',
          onTap: () => Get.toNamed(Routes.paymentMethods),
        ),
      ],
    );
  }

  // ── Section Preferences ────────────────────────────────────────────────────
  Widget _buildPreferencesSection() {
    return _SettingsSection(
      title: 'Preferences',
      items: [
        _SettingsItem(
          icon: Icons.notifications_none_rounded,
          iconBg: kGoldLight,
          iconColor: kGold,
          label: 'Notifications',
          subtitle: 'Push, email, alertes reservations',
          onTap: () {},
          trailing: _buildSwitch(true),
        ),
        _SettingsItem(
          icon: Icons.language_rounded,
          iconBg: const Color(0xFFE0F2F1),
          iconColor: const Color(0xFF00897B),
          label: 'Langue',
          subtitle: 'Francais',
          onTap: () {},
        ),
        _SettingsItem(
          icon: Icons.dark_mode_outlined,
          iconBg: const Color(0xFFEDE7F6),
          iconColor: const Color(0xFF5E35B1),
          label: 'Mode sombre',
          subtitle: 'Desactive',
          onTap: () {},
          trailing: _buildSwitch(false),
        ),
      ],
    );
  }

  // ── Section Support ────────────────────────────────────────────────────────
  Widget _buildSupportSection() {
    return _SettingsSection(
      title: 'Support',
      items: [
        _SettingsItem(
          icon: Icons.help_outline_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          label: 'Centre d\'aide',
          subtitle: 'FAQ, tutoriels, guides',
          onTap: () {},
        ),
        _SettingsItem(
          icon: Icons.chat_bubble_outline_rounded,
          iconBg: kBlueLight,
          iconColor: kBlue,
          label: 'Nous contacter',
          subtitle: 'WhatsApp, email, telephone',
          onTap: () {},
        ),
        _SettingsItem(
          icon: Icons.info_outline_rounded,
          iconBg: kBgSurface,
          iconColor: kTextSub,
          label: 'A propos',
          subtitle: 'Conditions, confidentialite, licences',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSwitch(bool value) {
    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: value,
        onChanged: (_) {},
        activeThumbColor: kGreen,
        activeTrackColor: kGreenLight,
        inactiveTrackColor: kBgSurface,
        inactiveThumbColor: kTextLight,
      ),
    );
  }

  // ── Logout button ──────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: _showLogoutDialog,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kRed.withValues(alpha: 0.3)),
            boxShadow: kCardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kRedLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: kRed, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Deconnexion',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Center(
        child: Column(
          children: [
            Image.asset('assets/images/minifoot.png', width: 32, height: 32),
            const SizedBox(height: 8),
            const Text(
              'MiniFoot Owner',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextLight,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Version 1.2.0',
              style: TextStyle(fontSize: 11, color: kTextLight),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: kElevatedShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon avec pulsation visuelle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kRedLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kRed.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.logout_rounded, color: kRed, size: 32),
              ),
              const SizedBox(height: 22),
              const Text(
                'Deconnexion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextPrim,
                  decoration: TextDecoration.none,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Etes-vous sur de vouloir\nvous deconnecter ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSub,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: Get.back,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorder, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            color: kTextSub,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

// ── Pattern hexagonal pour le header ─────────────────────────────────────────

class _HexPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final offset = (y ~/ spacing).isOdd ? spacing / 2 : 0.0;
        canvas.drawCircle(Offset(x + offset, y), 12, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Info row (email, phone, date) ────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: kTextPrim,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: kCardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: kTextSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings section groupee ─────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kTextLight,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: kCardShadow,
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    const Divider(
                        height: 1, indent: 68, endIndent: 16, color: kDivider),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings item ────────────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextPrim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextLight,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: kBgSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: kTextLight, size: 20),
                ),
          ],
        ),
      ),
    );
  }
}
