import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../core/providers/repository_providers.dart';

class CustomerState {
  final bool isLoading;
  final String? error;
  final List<Customer> customers;

  CustomerState({this.isLoading = false, this.error, this.customers = const []});

  CustomerState copyWith({bool? isLoading, String? error, List<Customer>? customers}) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      customers: customers ?? this.customers,
    );
  }
}

final customerViewModelProvider = NotifierProvider<CustomerViewModel, CustomerState>(CustomerViewModel.new);

class CustomerViewModel extends Notifier<CustomerState> {
  late final CustomerRepository _repository;
  final _uuid = const Uuid();

  @override
  CustomerState build() {
    _repository = ref.watch(customerRepositoryProvider);
    loadCustomers();
    return CustomerState();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customers = await _repository.getAllCustomers();
      state = state.copyWith(isLoading: false, customers: customers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchCustomers(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customers = await _repository.getAllCustomers();
      if (query.isEmpty) {
        state = state.copyWith(isLoading: false, customers: customers);
      } else {
        final q = query.toLowerCase();
        final filtered = customers.where((c) => 
            c.customerName.toLowerCase().contains(q) ||
            c.contractNumber.toLowerCase().contains(q) ||
            c.mobile.toLowerCase().contains(q)
        ).toList();
        state = state.copyWith(isLoading: false, customers: filtered);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveCustomer({
    String? id,
    required String name,
    required String contractNumber,
    required String mobile,
    required String email,
    required String address,
    required DateTime dob,
    required double contractValue,
    required int contractMonths,
    required double installmentAmount,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customer = Customer(
        id: id ?? _uuid.v4(),
        customerName: name,
        contractNumber: contractNumber,
        mobile: mobile,
        email: email,
        address: address,
        dob: dob,
        contractValue: contractValue,
        contractMonths: contractMonths,
        installmentAmount: installmentAmount,
        status: status,
        createdAt: id == null ? DateTime.now() : state.customers.firstWhere((c) => c.id == id).createdAt,
      );

      if (id == null) {
        await _repository.insertCustomer(customer);
      } else {
        await _repository.updateCustomer(customer);
      }
      await loadCustomers();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
