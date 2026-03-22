import 'package:get/get.dart';

class TransactionModel {
  final String id;
  final String date;
  final String client;
  final String terrain;
  final int amount;
  final String method; // Wave / Orange Money / Free Money
  final String status; // paid / pending / failed

  TransactionModel({
    required this.id,
    required this.date,
    required this.client,
    required this.terrain,
    required this.amount,
    required this.method,
    required this.status,
  });
}

class PaymentsController extends GetxController {
  final totalRevenue  = 485000.obs;
  final monthlyRevenue = 145000.obs;
  final pendingAmount  = 24000.obs;

  final transactions = <TransactionModel>[].obs;
  final selectedFilter = 'all'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockTransactions();
  }

  void _loadMockTransactions() {
    transactions.value = [
      TransactionModel(
        id: '1',
        date: '22 Mar 2026',
        client: 'Mamadou Diallo',
        terrain: 'Terrain Alpha',
        amount: 8000,
        method: 'Wave',
        status: 'paid',
      ),
      TransactionModel(
        id: '2',
        date: '22 Mar 2026',
        client: 'Ibrahima Ndiaye',
        terrain: 'Terrain Beta',
        amount: 10000,
        method: 'Orange Money',
        status: 'pending',
      ),
      TransactionModel(
        id: '3',
        date: '21 Mar 2026',
        client: 'Ousmane Sow',
        terrain: 'Terrain Alpha',
        amount: 8000,
        method: 'Free Money',
        status: 'paid',
      ),
      TransactionModel(
        id: '4',
        date: '21 Mar 2026',
        client: 'Cheikh Mbaye',
        terrain: 'Terrain Beta',
        amount: 10000,
        method: 'Wave',
        status: 'paid',
      ),
      TransactionModel(
        id: '5',
        date: '20 Mar 2026',
        client: 'Fatou Diop',
        terrain: 'Terrain Omega',
        amount: 15000,
        method: 'Orange Money',
        status: 'pending',
      ),
      TransactionModel(
        id: '6',
        date: '19 Mar 2026',
        client: 'Assane Fall',
        terrain: 'Terrain Alpha',
        amount: 8000,
        method: 'Free Money',
        status: 'paid',
      ),
    ];
  }

  /// Transactions filtrées selon le filtre actif
  List<TransactionModel> get filteredTransactions {
    if (selectedFilter.value == 'all') return transactions;
    return transactions.where((t) => t.status == selectedFilter.value).toList();
  }

  /// Change le filtre actif
  void setFilter(String f) => selectedFilter.value = f;

  Future<void> refreshPayments() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _loadMockTransactions();
    isLoading.value = false;
  }

  int get paidCount => transactions.where((t) => t.status == 'paid').length;
  int get pendingCount => transactions.where((t) => t.status == 'pending').length;

  String formatAmount(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toString();
  }
}
