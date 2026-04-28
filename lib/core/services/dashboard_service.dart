import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'auth_service.dart';
import 'reservation_service.dart';
import 'terrain_service.dart';

class OwnerDashboardData {
  final String ownerName;
  final int totalRevenue;
  final int todayRevenue;
  final int totalBookings;
  final int todayBookings;
  final int confirmedBookings;
  final int pendingPayments;
  final int terrainCount;
  final int activeTerrainCount;
  final double rating;
  final double occupancyRate;
  final List<double> weeklyData;
  final List<double> monthlyData;
  final List<Map<String, dynamic>> recentBookings;

  const OwnerDashboardData({
    required this.ownerName,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalBookings,
    required this.todayBookings,
    required this.confirmedBookings,
    required this.pendingPayments,
    required this.terrainCount,
    required this.activeTerrainCount,
    required this.rating,
    required this.occupancyRate,
    required this.weeklyData,
    required this.monthlyData,
    required this.recentBookings,
  });
}

class DashboardService {
  final _terrainService = TerrainService();
  final _reservationService = ReservationService();
  final _authService = AuthService();

  Future<OwnerDashboardData> getOwnerDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final results = await Future.wait<dynamic>([
      _terrainService.getMesTerrains(),
      _reservationService.getOwnerReservations(),
      token.isEmpty ? Future.value(null) : _authService.getProfile(token),
    ]);

    final terrains = results[0] as List<dynamic>;
    final reservations = results[1] as List<dynamic>;
    final profile = results[2] as Map<String, dynamic>?;
    final user = profile == null ? null : UserModel.fromJson(profile);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekly = List<double>.filled(7, 0);
    final monthly = List<double>.filled(12, 0);

    var totalRevenue = 0;
    var todayRevenue = 0;
    var todayBookings = 0;
    var confirmedBookings = 0;
    var pendingPayments = 0;
    var todayBookedIntervals = 0;

    final recent = <Map<String, dynamic>>[];

    for (final item in reservations) {
      final reservation = item as Map<String, dynamic>;
      final status = reservation['status']?.toString() ?? '';
      final date = _parseDate(reservation['date']);
      final dateOnly = date == null
          ? null
          : DateTime(date.year, date.month, date.day);
      final amount = _asInt(
        reservation['finalPrice'] ?? reservation['totalPrice'],
      );
      final paidAmount = _paidAmount(reservation, fallback: amount);
      final isConfirmed = status == 'CONFIRMED' || status == 'COMPLETED';
      final isPending = status == 'PENDING_PAYMENT';

      if (dateOnly != null && _sameDay(dateOnly, today)) {
        todayBookings++;
        if (isConfirmed) {
          todayRevenue += paidAmount;
          todayBookedIntervals += _asInt(reservation['intervals']);
        }
      }

      if (isPending) pendingPayments++;

      if (isConfirmed) {
        confirmedBookings++;
        totalRevenue += paidAmount;

        if (dateOnly != null) {
          if (!dateOnly.isBefore(weekStart) && dateOnly.isBefore(weekEnd)) {
            weekly[dateOnly.weekday - 1] += paidAmount.toDouble();
          }
          if (dateOnly.year == now.year) {
            monthly[dateOnly.month - 1] += paidAmount.toDouble();
          }
        }
      }

      if (status != 'CANCELLED' && recent.length < 5) {
        recent.add(_toRecentBooking(reservation));
      }
    }

    final activeTerrains = terrains.where((item) {
      final terrain = item as Map<String, dynamic>;
      return terrain['isActive'] != false;
    }).length;

    final totalRating = terrains.fold<double>(0, (sum, item) {
      final terrain = item as Map<String, dynamic>;
      return sum + _asDouble(terrain['rating']);
    });

    final averageRating = terrains.isEmpty
        ? 0.0
        : totalRating / terrains.length;
    final todayCapacity = activeTerrains * 36;
    final occupancyRate = todayCapacity == 0
        ? 0.0
        : (todayBookedIntervals / todayCapacity).clamp(0.0, 1.0);

    return OwnerDashboardData(
      ownerName: _ownerName(user),
      totalRevenue: totalRevenue,
      todayRevenue: todayRevenue,
      totalBookings: reservations.length,
      todayBookings: todayBookings,
      confirmedBookings: confirmedBookings,
      pendingPayments: pendingPayments,
      terrainCount: terrains.length,
      activeTerrainCount: activeTerrains,
      rating: averageRating,
      occupancyRate: occupancyRate,
      weeklyData: weekly,
      monthlyData: monthly,
      recentBookings: recent,
    );
  }

  static Map<String, dynamic> _toRecentBooking(
    Map<String, dynamic> reservation,
  ) {
    final user = reservation['user'] as Map<String, dynamic>?;
    final terrain = reservation['terrain'] as Map<String, dynamic>?;
    final firstName = (user?['firstName'] ?? '').toString().trim();
    final lastName = (user?['lastName'] ?? '').toString().trim();
    final name = '$firstName $lastName'.trim();
    final status = reservation['status']?.toString() ?? '';

    return {
      'name': name.isEmpty ? 'Client MiniFoot' : name,
      'time': _formatSlot(reservation['startSlot'], reservation['endSlot']),
      'terrain': (terrain?['name'] ?? 'Terrain').toString(),
      'amount': _asInt(reservation['finalPrice'] ?? reservation['totalPrice']),
      'status': switch (status) {
        'CONFIRMED' || 'COMPLETED' => 'confirmed',
        'CANCELLED' => 'cancelled',
        _ => 'pending',
      },
    };
  }

  static int _paidAmount(
    Map<String, dynamic> reservation, {
    required int fallback,
  }) {
    final payments = reservation['payments'];
    if (payments is! List) return fallback;
    final completed = payments.where((payment) {
      return payment is Map<String, dynamic> &&
          payment['status'] == 'COMPLETED';
    });
    final total = completed.fold<int>(0, (sum, payment) {
      return sum + _asInt((payment as Map<String, dynamic>)['amount']);
    });
    return total == 0 ? fallback : total;
  }

  static String _ownerName(UserModel? user) {
    if (user == null) return 'Propriétaire';
    final name = '${user.firstName} ${user.lastName}'.trim();
    return name.isEmpty ? 'Propriétaire' : name;
  }

  static DateTime? _parseDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toLocal();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _formatSlot(dynamic start, dynamic end) {
    final startText = start?.toString() ?? '';
    final endText = end?.toString() ?? '';
    if (startText.isEmpty && endText.isEmpty) return '';
    return '$startText - $endText';
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
