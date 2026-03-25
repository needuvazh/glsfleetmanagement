import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/customer.dart';

final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>((ref) {
  return CustomerViewModel();
});

class CustomerState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final Customer? selectedCustomer;

  CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.selectedCustomer,
  });

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Customer? selectedCustomer,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }
}

class CustomerViewModel extends StateNotifier<CustomerState> {
  CustomerViewModel() : super(CustomerState(isLoading: true)) {
    _loadCustomers();
  }

  static const _cacheKey = 'customer_master_records_v1';

  Future<void> _loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final cachedCustomers = decoded
              .whereType<Map<String, dynamic>>()
              .map(Customer.fromJson)
              .toList();
          state = state.copyWith(
            customers: cachedCustomers,
            isLoading: false,
            clearError: true,
          );
          return;
        }
      }

      final seeded = _mockCustomers();
      state = state.copyWith(
        customers: seeded,
        isLoading: false,
        clearError: true,
      );
      await _persistCustomers(seeded);
    } catch (error) {
      final seeded = _mockCustomers();
      state = state.copyWith(
        customers: seeded,
        isLoading: false,
        error: 'Failed to read local cache. Loaded default customer list.',
      );
      await _persistCustomers(seeded);
      // Keep app functional even if cache fails.
      // ignore: avoid_print
      print('Customer cache load failed: $error');
    }
  }

  List<Customer> _mockCustomers() {
    return [
      Customer(
        id: 'CUST001',
        name: 'Al Ghanim Trading Company',
        address: 'P.O. Box 1234, Muscat 113, Oman',
        email: 'info@alghanim.om',
        phoneNumber: '+968 24 123456',
        crNumber: '1234567',
        vatinNumber: 'OM-VAT-001',
        currency: 'OMR',
        contactPerson: 'Ahmed Al Ghanim',
        category: 'PDO',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Customer(
        id: 'CUST002',
        name: 'Oman Logistics Solutions',
        address: 'Industrial Area, Muscat, Oman',
        email: 'contact@omanlogs.om',
        phoneNumber: '+968 24 234567',
        crNumber: '2345678',
        vatinNumber: 'OM-VAT-002',
        currency: 'OMR',
        contactPerson: 'Fatima Al Balushi',
        category: 'NON-PDO',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Customer(
        id: 'CUST003',
        name: 'Gulf Trading & Distribution',
        address: 'Salalah, Dhofar, Oman',
        email: 'sales@gulftrade.om',
        phoneNumber: '+968 23 345678',
        crNumber: '3456789',
        vatinNumber: 'OM-VAT-003',
        currency: 'OMR',
        contactPerson: 'Mohammed Al Harthi',
        category: 'PDO',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Customer(
        id: 'CUST004',
        name: 'Nizwa Freight Services',
        address: 'Nizwa, Ad Dakhiliyah, Oman',
        email: 'freight@nizwafreight.om',
        phoneNumber: '+968 25 456789',
        crNumber: '4567890',
        vatinNumber: 'OM-VAT-004',
        currency: 'OMR',
        contactPerson: 'Salim Al Rawahi',
        category: 'NON-PDO',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }

  Future<void> _persistCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = customers.map((item) => item.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  void addCustomer(Customer customer) {
    final updatedCustomers = [...state.customers, customer];
    state = state.copyWith(customers: updatedCustomers, clearError: true);
    _persistCustomers(updatedCustomers);
  }

  void updateCustomer(Customer customer) {
    final updatedCustomers = state.customers.map((cust) {
      return cust.id == customer.id ? customer : cust;
    }).toList();
    state = state.copyWith(customers: updatedCustomers, clearError: true);
    _persistCustomers(updatedCustomers);
  }

  void deleteCustomer(String customerId) {
    final updatedCustomers =
        state.customers.where((cust) => cust.id != customerId).toList();
    state = state.copyWith(customers: updatedCustomers, clearError: true);
    _persistCustomers(updatedCustomers);
  }

  void selectCustomer(Customer customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearSelection() {
    state = state.copyWith(selectedCustomer: null);
  }
}
