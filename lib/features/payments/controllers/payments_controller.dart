import 'package:get/get.dart';

class TransactionModel {
  final String id;
  final String date;
  final String client;
  final String terrain;
  final int amount;
  final String method; // Wave / Orange Money / Yas Money
  final String status; // paid / pending / failed
  final String timeSlot; // ex: "16h00 - 17h00"

  TransactionModel({
    required this.id,
    required this.date,
    required this.client,
    required this.terrain,
    required this.amount,
    required this.method,
    required this.status,
    this.timeSlot = '',
  });
}

class PaymentsController extends GetxController {
  final totalRevenue   = 485000.obs;
  final monthlyRevenue = 145000.obs;
  final pendingAmount  = 24000.obs;

  final transactions   = <TransactionModel>[].obs;
  final selectedFilter = 'all'.obs;
  final selectedPeriod = 'month'.obs; // day / week / month
  final isLoading      = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockTransactions();
  }

  void _loadMockTransactions() {
    transactions.value = [
      TransactionModel(
        id: '1', date: '2 Avr 2026', client: 'Mamadou Diallo',
        terrain: 'Terrain Alpha', amount: 8000, method: 'Wave',
        status: 'paid', timeSlot: '16h00 - 17h00',
      ),
      TransactionModel(
        id: '2', date: '2 Avr 2026', client: 'Ibrahima Ndiaye',
        terrain: 'Terrain Beta', amount: 10000, method: 'Orange Money',
        status: 'pending', timeSlot: '18h00 - 19h00',
      ),
      TransactionModel(
        id: '7', date: '2 Avr 2026', client: 'Awa Sarr',
        terrain: 'Terrain Omega', amount: 15000, method: 'Wave',
        status: 'paid', timeSlot: '20h00 - 21h00',
      ),
      TransactionModel(
        id: '3', date: '1 Avr 2026', client: 'Ousmane Sow',
        terrain: 'Terrain Alpha', amount: 8000, method: 'Yas Money',
        status: 'paid', timeSlot: '10h00 - 11h00',
      ),
      TransactionModel(
        id: '4', date: '1 Avr 2026', client: 'Cheikh Mbaye',
        terrain: 'Terrain Beta', amount: 10000, method: 'Wave',
        status: 'paid', timeSlot: '14h00 - 15h00',
      ),
      TransactionModel(
        id: '5', date: '31 Mar 2026', client: 'Fatou Diop',
        terrain: 'Terrain Omega', amount: 15000, method: 'Orange Money',
        status: 'pending', timeSlot: '19h00 - 20h00',
      ),
      TransactionModel(
        id: '6', date: '30 Mar 2026', client: 'Assane Fall',
        terrain: 'Terrain Alpha', amount: 8000, method: 'Yas Money',
        status: 'paid', timeSlot: '12h00 - 13h00',
      ),
      TransactionModel(
        id: '8', date: '30 Mar 2026', client: 'Moussa Ba',
        terrain: 'Terrain Beta', amount: 10000, method: 'Orange Money',
        status: 'failed', timeSlot: '17h00 - 18h00',
      ),
    ];
  }

  /// Transactions filtrées par statut
  List<TransactionModel> get filteredTransactions {
    if (selectedFilter.value == 'all') return transactions;
    return transactions.where((t) => t.status == selectedFilter.value).toList();
  }

  /// Transactions groupées par date
  Map<String, List<TransactionModel>> get groupedTransactions {
    final filtered = filteredTransactions;
    final map = <String, List<TransactionModel>>{};
    for (final t in filtered) {
      map.putIfAbsent(t.date, () => []).add(t);
    }
    return map;
  }

  /// Répartition par méthode de paiement (uniquement les payés)
  Map<String, int> get methodBreakdown {
    final paid = transactions.where((t) => t.status == 'paid');
    final map = <String, int>{};
    for (final t in paid) {
      map[t.method] = (map[t.method] ?? 0) + t.amount;
    }
    return map;
  }

  int get totalPaidAmount =>
      transactions.where((t) => t.status == 'paid').fold(0, (s, t) => s + t.amount);

  void setFilter(String f) => selectedFilter.value = f;
  void setPeriod(String p) => selectedPeriod.value = p;

  Future<void> refreshPayments() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _loadMockTransactions();
    isLoading.value = false;
  }

  int get paidCount    => transactions.where((t) => t.status == 'paid').length;
  int get pendingCount => transactions.where((t) => t.status == 'pending').length;
  int get failedCount  => transactions.where((t) => t.status == 'failed').length;

  String formatAmount(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toString();
  }
}
