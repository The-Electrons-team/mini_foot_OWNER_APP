import 'package:get/get.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'booking', 'payment', 'system', 'review'
  final String time;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsController extends GetxController {
  final notifications = <NotificationItem>[].obs;
  final selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    notifications.value = [
      NotificationItem(id: '1', title: 'Nouvelle reservation', message: 'Lions FC a reserve le Terrain A pour demain 10h-11h', type: 'booking', time: 'Il y a 5 min'),
      NotificationItem(id: '2', title: 'Paiement recu', message: 'Paiement de 8 000 F CFA confirme pour la reservation #1042', type: 'payment', time: 'Il y a 30 min'),
      NotificationItem(id: '3', title: 'Nouvel avis', message: 'AS Medina a laisse un avis 5 etoiles sur le Terrain B', type: 'review', time: 'Il y a 1h'),
      NotificationItem(id: '4', title: 'Reservation annulee', message: 'FC Grand Yoff a annule sa reservation du 24 Mars', type: 'booking', time: 'Il y a 2h', isRead: true),
      NotificationItem(id: '5', title: 'Mise a jour systeme', message: 'Nouvelle version de MiniFoot disponible. Mettez a jour pour les dernières fonctionnalites', type: 'system', time: 'Il y a 5h', isRead: true),
      NotificationItem(id: '6', title: 'Paiement en attente', message: 'Le paiement de Mamadou Diallo pour le 25 Mars est en attente', type: 'payment', time: 'Hier'),
      NotificationItem(id: '7', title: 'Nouvelle reservation', message: 'Star Club a reserve le Terrain C pour samedi 16h-18h', type: 'booking', time: 'Hier'),
      NotificationItem(id: '8', title: 'Rapport mensuel', message: 'Votre rapport de revenus de Mars est disponible', type: 'system', time: 'Il y a 2 jours', isRead: true),
    ];
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  List<NotificationItem> get filteredNotifications {
    if (selectedFilter.value == 'all') return notifications;
    return notifications.where((n) => n.type == selectedFilter.value).toList();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void markAllRead() {
    // Mock: just refresh
    notifications.refresh();
  }

  Future<void> refreshNotifications() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}
