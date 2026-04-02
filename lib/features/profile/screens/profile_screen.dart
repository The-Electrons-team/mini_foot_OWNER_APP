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
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildContactCard(),
                const SizedBox(height: 16),
                _buildRevenueCard(),
                const SizedBox(height: 16),
                _buildSubscriptionCard(),
                _buildSection(
                  title: 'Compte',
                  items: [
                    _Item(
                      icon: Icons.person_outline_rounded,
                      iconBg: kGreenLight,
                      iconColor: kGreen,
                      label: 'Informations personnelles',
                      subtitle: 'Nom, email, téléphone',
                      onTap: () => Get.toNamed(Routes.editProfile),
                    ),
                    _Item(
                      icon: Icons.lock_outline_rounded,
                      iconBg: kBlueLight,
                      iconColor: kBlue,
                      label: 'Sécurité',
                      subtitle: 'Mot de passe, 2FA',
                      onTap: () => Get.toNamed(Routes.security),
                    ),
                    _Item(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBg: const Color(0xFFFFF3E0),
                      iconColor: kOrange,
                      label: 'Méthodes de paiement',
                      subtitle: 'Wave, Orange Money, carte',
                      onTap: () => Get.toNamed(Routes.paymentMethods),
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Préférences',
                  items: [
                    _Item(
                      icon: Icons.notifications_none_rounded,
                      iconBg: kGoldLight,
                      iconColor: kGold,
                      label: 'Notifications',
                      subtitle: 'Push, alertes réservations',
                      onTap: () {},
                      trailing: _Switch(value: true),
                    ),
                    _Item(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFFE0F2F1),
                      iconColor: const Color(0xFF00897B),
                      label: 'Langue',
                      subtitle: 'Français',
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.dark_mode_outlined,
                      iconBg: const Color(0xFFEDE7F6),
                      iconColor: const Color(0xFF5E35B1),
                      label: 'Mode sombre',
                      subtitle: 'Désactivé',
                      onTap: () {},
                      trailing: _Switch(value: false),
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Support',
                  items: [
                    _Item(
                      icon: Icons.help_outline_rounded,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9333EA),
                      label: 'Centre d\'aide',
                      subtitle: 'FAQ, tutoriels, guides',
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconBg: kBlueLight,
                      iconColor: kBlue,
                      label: 'Nous contacter',
                      subtitle: 'WhatsApp, email, téléphone',
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.info_outline_rounded,
                      iconBg: kBgSurface,
                      iconColor: kTextSub,
                      label: 'À propos',
                      subtitle: 'Conditions, confidentialité',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLogoutButton(),
                const SizedBox(height: 28),
                _buildVersion(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── SliverAppBar : se rétracte en scrollant ────────────────────────────────
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: kGreen,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: controller.toggleEdit,
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Obx(() => Text(
              controller.ownerName.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )),
        titlePadding: const EdgeInsets.only(bottom: 16),
        background: Container(
          decoration: const BoxDecoration(gradient: kGreenGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60), // espace pour les boutons appbar
              // Avatar
              Obx(() => Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        controller.initials,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 14),

              // Nom
              Obx(() => Text(
                    controller.ownerName.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  )),
              const SizedBox(height: 10),

              // Badge vérifié
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Propriétaire vérifié',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3 stats (terrains, réservations, note) ─────────────────────────────────
  Widget _buildStatsRow() {
    return Obx(() => Row(
          children: [
            _StatCard(
              value: '${controller.totalTerrains.value}',
              label: 'Terrains',
              icon: Icons.stadium_rounded,
              color: kGreen,
              bgColor: kGreenLight,
            ),
            const SizedBox(width: 12),
            _StatCard(
              value: '${controller.totalBookings.value}',
              label: 'Réservations',
              icon: Icons.calendar_month_rounded,
              color: kBlue,
              bgColor: kBlueLight,
            ),
            const SizedBox(width: 12),
            _StatCard(
              value: '${controller.rating.value}',
              label: 'Note',
              icon: Icons.star_rounded,
              color: kGold,
              bgColor: kGoldLight,
            ),
          ],
        ));
  }

  // ── Carte contact (email, téléphone, membre depuis) ────────────────────────
  Widget _buildContactCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: kCardShadow,
          ),
          child: Column(
            children: [
              _ContactRow(
                icon: Icons.email_outlined,
                iconColor: kBlue,
                text: controller.email.value,
              ),
              const _Divider(),
              _ContactRow(
                icon: Icons.phone_outlined,
                iconColor: kGreen,
                text: controller.phone.value,
              ),
              const _Divider(),
              _ContactRow(
                icon: Icons.calendar_today_rounded,
                iconColor: kGold,
                text: 'Membre depuis ${controller.memberSince.value}',
              ),
            ],
          ),
        ));
  }

  // ── Carte revenus ──────────────────────────────────────────────────────────
  Widget _buildRevenueCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: kCardShadow,
          ),
          child: Row(
            children: [
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
                      style: TextStyle(fontSize: 13, color: kTextSub),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kGoldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: kGold, size: 20),
              ),
            ],
          ),
        ));
  }

  // ── Carte abonnement premium ───────────────────────────────────────────────
  Widget _buildSubscriptionCard() {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 8),
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
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Terrains illimités · Stats avancées',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
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
              Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.event_rounded,
                      color: Colors.white.withValues(alpha: 0.7), size: 15),
                  const SizedBox(width: 8),
                  Text(
                    'Expire le ${controller.planExpiry.value}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
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
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  // ── Bloc de paramètres générique ───────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required List<_Item> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
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

  // ── Bouton déconnexion ─────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
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
              'Déconnexion',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/minifoot.png', width: 30, height: 30),
          const SizedBox(height: 8),
          const Text(
            'MiniFoot Owner · v1.2.0',
            style: TextStyle(fontSize: 12, color: kTextLight),
          ),
        ],
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
                child:
                    const Icon(Icons.logout_rounded, color: kRed, size: 32),
              ),
              const SizedBox(height: 22),
              const Text(
                'Déconnexion',
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
                'Êtes-vous sûr de vouloir\nvous déconnecter ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSub,
                  decoration: TextDecoration.none,
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
                          style: TextStyle(fontWeight: FontWeight.w700),
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

// ─────────────────────────────────────────────────────────────────────────────
// Widgets partagés
// ─────────────────────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _ContactRow(
      {required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: kTextPrim,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(height: 1, color: kDivider),
      );
}

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
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: kTextSub),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  const _Switch({required this.value});

  @override
  Widget build(BuildContext context) {
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
}

class _Item extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _Item({
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
                    style: const TextStyle(fontSize: 12, color: kTextLight),
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
