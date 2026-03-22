import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final selectedTab = 0.obs;

  // Stats mock
  final totalRevenue  = 485000.obs;
  final todayRevenue  = 45000.obs;
  final totalBookings = 128.obs;
  final todayBookings = 7.obs;
  final rating        = 4.8.obs;
  final occupancyRate = 0.72.obs;
  final notificationCount = 3.obs;
  final chartPeriod = 'week'.obs; // 'week' ou 'month'

  final monthlyData = <double>[
    120000, 145000, 98000, 170000, 162000, 185000,
    145000, 195000, 130000, 210000, 178000, 155000,
  ].obs;

  void toggleChartPeriod(String period) => chartPeriod.value = period;

  List<double> get activeChartData =>
      chartPeriod.value == 'week' ? weeklyData : monthlyData;

  List<String> get activeChartLabels =>
      chartPeriod.value == 'week'
          ? ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
          : ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];

  Future<void> refreshDashboard() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simule un refresh des données
    todayBookings.value = todayBookings.value;
    notificationCount.value = 0;
  }

  final recentBookings = <Map<String, dynamic>>[
    {'name': 'Équipe Lions FC',      'time': '10h00 – 11h00', 'terrain': 'Terrain A', 'amount': 8000,  'status': 'confirmed'},
    {'name': 'Mamadou Diallo',       'time': '12h00 – 13h00', 'terrain': 'Terrain B', 'amount': 6000,  'status': 'pending'},
    {'name': 'AS Médina',            'time': '14h00 – 15h00', 'terrain': 'Terrain A', 'amount': 8000,  'status': 'confirmed'},
    {'name': 'Ibrahima Ndiaye',      'time': '16h00 – 17h00', 'terrain': 'Terrain C', 'amount': 5000,  'status': 'confirmed'},
    {'name': 'FC Grand Yoff',        'time': '18h00 – 19h00', 'terrain': 'Terrain B', 'amount': 6000,  'status': 'pending'},
  ].obs;

  final weeklyData = <double>[42000, 55000, 38000, 70000, 62000, 85000, 45000].obs;

  void changeTab(int i) => selectedTab.value = i;

  void goToTerrains()      => Get.toNamed(Routes.terrainList);
  void goToReservations()  => Get.toNamed(Routes.reservations);
  void goToAvailability()  => Get.toNamed(Routes.availability);
  void goToPayments()      => Get.toNamed(Routes.payments);
  void goToProfile()        => Get.toNamed(Routes.profile);
  void goToNotifications()  => Get.toNamed(Routes.notifications);
}
