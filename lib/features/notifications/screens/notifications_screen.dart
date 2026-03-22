import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: kTextPrim),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.markAllRead(),
            child: const Text(
              'Tout lire',
              style: TextStyle(
                color: kGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(),
          Expanded(
            child: Obx(() {
              final items = controller.filteredNotifications;
              if (items.isEmpty) {
                return _EmptyState();
              }
              return RefreshIndicator(
                color: kGreen,
                onRefresh: controller.refreshNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationTile(item: items[index]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Filtres chips ────────────────────────────────────────────────────────────

class _FilterChips extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBgCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          final selected = controller.selectedFilter.value;
          final unread = controller.unreadCount;
          return Row(
            children: [
              _FilterChip(
                label: 'Toutes ($unread)',
                value: 'all',
                isSelected: selected == 'all',
                onTap: () => controller.setFilter('all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Reservations',
                value: 'booking',
                isSelected: selected == 'booking',
                onTap: () => controller.setFilter('booking'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Paiements',
                value: 'payment',
                isSelected: selected == 'payment',
                onTap: () => controller.setFilter('payment'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Avis',
                value: 'review',
                isSelected: selected == 'review',
                onTap: () => controller.setFilter('review'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Systeme',
                value: 'system',
                isSelected: selected == 'system',
                onTap: () => controller.setFilter('system'),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kGreen : kBgSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kTextSub,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône dans un cercle coloré
          _TypeIcon(type: item.type),
          const SizedBox(width: 12),
          // Contenu texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: kTextPrim,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: kTextSub,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Temps + indicateur non lu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
                style: const TextStyle(
                  color: kTextLight,
                  fontSize: 11,
                ),
              ),
              if (!item.isRead) ...[
                const SizedBox(height: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Icône selon le type ──────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  final String type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color iconColor, Color bgColor) = switch (type) {
      'booking'  => (Icons.calendar_month_rounded, kBlue, kBlueLight),
      'payment'  => (Icons.payments_rounded, kGreen, kGreenLight),
      'review'   => (Icons.star_rounded, kGold, kGoldLight),
      'system'   => (Icons.info_rounded, kTextSub, kBgSurface),
      _          => (Icons.notifications_rounded, kTextSub, kBgSurface),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: kTextLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              color: kTextSub,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
