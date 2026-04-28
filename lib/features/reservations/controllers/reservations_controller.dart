import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../core/services/reservation_service.dart';

class ReservationModel {
  final String id;
  final String clientName;
  final String teamName;
  final String terrain;
  final String date;
  final String timeSlot;
  final int amount;
  final String status; // confirmed / pending / cancelled
  final String phone;
  final String reference;
  final String paymentMethod;
  final String paymentStatus;

  ReservationModel({
    required this.id,
    required this.clientName,
    required this.teamName,
    required this.terrain,
    required this.date,
    required this.timeSlot,
    required this.amount,
    required this.status,
    required this.phone,
    required this.reference,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final terrain = json['terrain'] as Map<String, dynamic>?;
    final firstName = (user?['firstName'] ?? '').toString().trim();
    final lastName = (user?['lastName'] ?? '').toString().trim();
    final clientName = '$firstName $lastName'.trim();

    return ReservationModel(
      id: (json['id'] ?? '').toString(),
      clientName: clientName.isNotEmpty ? clientName : 'Client MiniFoot',
      teamName: (user?['phone'] ?? json['reference'] ?? 'Client').toString(),
      terrain: (terrain?['name'] ?? 'Terrain').toString(),
      date: _formatDate(json['date']),
      timeSlot: _formatSlot(json['startSlot'], json['endSlot']),
      amount: _asInt(json['finalPrice'] ?? json['totalPrice']),
      status: _mapStatus(json['status']),
      phone: (user?['phone'] ?? '').toString(),
      reference: (json['reference'] ?? '').toString(),
      paymentMethod: _formatPaymentMethod(json['paymentMethod']),
      paymentStatus: _formatPaymentStatus(json['payments']),
    );
  }

  bool get canCancel => status == 'pending';

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return value?.toString() ?? '';
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  static String _formatSlot(dynamic start, dynamic end) {
    final startText = start?.toString() ?? '';
    final endText = end?.toString() ?? '';
    if (startText.isEmpty && endText.isEmpty) return '';
    return '$startText – $endText';
  }

  static String _mapStatus(dynamic value) {
    switch (value?.toString()) {
      case 'CONFIRMED':
      case 'COMPLETED':
        return 'confirmed';
      case 'CANCELLED':
        return 'cancelled';
      case 'PENDING_PAYMENT':
      default:
        return 'pending';
    }
  }

  static String _formatPaymentMethod(dynamic value) {
    switch (value?.toString()) {
      case 'WAVE':
        return 'Wave';
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'FREE_MONEY':
        return 'Free Money';
      default:
        return value?.toString() ?? 'Non défini';
    }
  }

  static String _formatPaymentStatus(dynamic value) {
    if (value is! List || value.isEmpty) return 'Aucun paiement';
    final lastPayment = value.last;
    final status = lastPayment is Map<String, dynamic>
        ? lastPayment['status']?.toString()
        : null;
    switch (status) {
      case 'COMPLETED':
        return 'Payé';
      case 'FAILED':
        return 'Échoué';
      case 'REFUNDED':
        return 'Remboursé';
      case 'PENDING':
      default:
        return 'En attente';
    }
  }
}

class ReservationsController extends GetxController {
  final _service = ReservationService();
  final _allReservations = <ReservationModel>[].obs;
  final selectedFilter = 'all'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReservations();
  }

  Future<void> loadReservations() async {
    isLoading.value = true;
    try {
      final data = await _service.getOwnerReservations();
      _allReservations.value = data
          .map(
            (item) => ReservationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les réservations',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<ReservationModel> get filteredReservations {
    if (selectedFilter.value == 'all') return _allReservations;
    return _allReservations
        .where((r) => r.status == selectedFilter.value)
        .toList();
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  Future<void> refreshReservations() async {
    await loadReservations();
  }

  Future<void> cancelReservation(String id) async {
    Get.defaultDialog(
      title: 'Refuser la réservation',
      middleText: 'Cette réservation passera en statut annulé.',
      textCancel: 'Garder',
      textConfirm: 'Refuser',
      onConfirm: () async {
        Get.back();
        try {
          await _service.cancelOwnerReservation(id);
          await loadReservations();
          Get.snackbar(
            'Réservation refusée',
            'Le créneau est à nouveau disponible.',
            snackPosition: SnackPosition.TOP,
          );
        } catch (e) {
          Get.snackbar(
            'Erreur',
            'Impossible de refuser cette réservation',
            snackPosition: SnackPosition.TOP,
          );
        }
      },
    );
  }

  int get totalCount => _allReservations.length;
  int get confirmedCount =>
      _allReservations.where((r) => r.status == 'confirmed').length;
  int get pendingCount =>
      _allReservations.where((r) => r.status == 'pending').length;
  int get cancelledCount =>
      _allReservations.where((r) => r.status == 'cancelled').length;
}
