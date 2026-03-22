import 'package:get/get.dart';

class ReservationModel {
  final String id;
  final String clientName;
  final String teamName;
  final String terrain;
  final String date;
  final String timeSlot;
  final int amount;
  final String status; // confirmed / pending / cancelled

  ReservationModel({
    required this.id,
    required this.clientName,
    required this.teamName,
    required this.terrain,
    required this.date,
    required this.timeSlot,
    required this.amount,
    required this.status,
  });
}

class ReservationsController extends GetxController {
  final _allReservations = <ReservationModel>[].obs;
  final selectedFilter = 'all'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockReservations();
  }

  void _loadMockReservations() {
    _allReservations.value = [
      ReservationModel(
        id: '1',
        clientName: 'Mamadou Diallo',
        teamName: 'Lions FC',
        terrain: 'Terrain Alpha',
        date: '22 Mar 2026',
        timeSlot: '10h00 – 11h00',
        amount: 8000,
        status: 'confirmed',
      ),
      ReservationModel(
        id: '2',
        clientName: 'Ibrahima Ndiaye',
        teamName: 'AS Médina',
        terrain: 'Terrain Beta',
        date: '22 Mar 2026',
        timeSlot: '12h00 – 13h00',
        amount: 10000,
        status: 'pending',
      ),
      ReservationModel(
        id: '3',
        clientName: 'Ousmane Sow',
        teamName: 'FC Grand Yoff',
        terrain: 'Terrain Alpha',
        date: '23 Mar 2026',
        timeSlot: '09h00 – 10h00',
        amount: 8000,
        status: 'confirmed',
      ),
      ReservationModel(
        id: '4',
        clientName: 'Abdou Sy',
        teamName: 'Team Almadies',
        terrain: 'Terrain Omega',
        date: '23 Mar 2026',
        timeSlot: '15h00 – 16h00',
        amount: 15000,
        status: 'cancelled',
      ),
      ReservationModel(
        id: '5',
        clientName: 'Cheikh Mbaye',
        teamName: 'Star Club',
        terrain: 'Terrain Beta',
        date: '24 Mar 2026',
        timeSlot: '17h00 – 18h00',
        amount: 10000,
        status: 'confirmed',
      ),
      ReservationModel(
        id: '6',
        clientName: 'Fatou Diop',
        teamName: 'Ladies FC',
        terrain: 'Terrain Alpha',
        date: '24 Mar 2026',
        timeSlot: '19h00 – 20h00',
        amount: 8000,
        status: 'pending',
      ),
      ReservationModel(
        id: '7',
        clientName: 'Moussa Thiam',
        teamName: 'United Dakar',
        terrain: 'Terrain Omega',
        date: '25 Mar 2026',
        timeSlot: '08h00 – 09h00',
        amount: 15000,
        status: 'cancelled',
      ),
      ReservationModel(
        id: '8',
        clientName: 'Assane Fall',
        teamName: 'Plateau FC',
        terrain: 'Terrain Beta',
        date: '25 Mar 2026',
        timeSlot: '20h00 – 21h00',
        amount: 10000,
        status: 'confirmed',
      ),
    ];
  }

  List<ReservationModel> get filteredReservations {
    if (selectedFilter.value == 'all') return _allReservations;
    return _allReservations
        .where((r) => r.status == selectedFilter.value)
        .toList();
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  Future<void> refreshReservations() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _loadMockReservations();
    isLoading.value = false;
  }

  int get totalCount => _allReservations.length;
  int get confirmedCount =>
      _allReservations.where((r) => r.status == 'confirmed').length;
  int get pendingCount =>
      _allReservations.where((r) => r.status == 'pending').length;
  int get cancelledCount =>
      _allReservations.where((r) => r.status == 'cancelled').length;
}
