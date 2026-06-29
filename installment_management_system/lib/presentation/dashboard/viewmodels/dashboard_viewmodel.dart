import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../core/providers/repository_providers.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final int totalCustomers;
  final int activeContracts;
  final int pendingContracts;
  final double totalInstallmentAmount;
  final List<Customer> recentEntries;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.totalCustomers = 0,
    this.activeContracts = 0,
    this.pendingContracts = 0,
    this.totalInstallmentAmount = 0.0,
    this.recentEntries = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    int? totalCustomers,
    int? activeContracts,
    int? pendingContracts,
    double? totalInstallmentAmount,
    List<Customer>? recentEntries,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      activeContracts: activeContracts ?? this.activeContracts,
      pendingContracts: pendingContracts ?? this.pendingContracts,
      totalInstallmentAmount: totalInstallmentAmount ?? this.totalInstallmentAmount,
      recentEntries: recentEntries ?? this.recentEntries,
    );
  }
}

final dashboardViewModelProvider = NotifierProvider<DashboardViewModel, DashboardState>(DashboardViewModel.new);

class DashboardViewModel extends Notifier<DashboardState> {
  late final CustomerRepository _customerRepository;

  @override
  DashboardState build() {
    _customerRepository = ref.watch(customerRepositoryProvider);
    loadDashboardData();
    return DashboardState();
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customers = await _customerRepository.getAllCustomers();
      
      final activeCustomers = customers.where((c) => c.status == 'Active').toList();
      final pendingCustomers = customers.where((c) => c.status == 'Pending').toList();
      final totalInstallmentExpected = customers.fold(0.0, (sum, c) => sum + c.installmentAmount);

      customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recent = customers.take(10).toList();

      state = state.copyWith(
        isLoading: false,
        totalCustomers: customers.length,
        activeContracts: activeCustomers.length,
        pendingContracts: pendingCustomers.length,
        totalInstallmentAmount: totalInstallmentExpected,
        recentEntries: recent,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
