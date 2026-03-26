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

  static const _cacheKey = 'customer_master_records_v3';

  Future<void> _loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final cachedCustomers = decoded
              .whereType<Map>()
              .map((item) => item.map(
                    (key, value) => MapEntry(key.toString(), value),
                  ))
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
        name: 'Shell Oman',
        shortCode: 'SHO',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'PDO',
        billingAddress: 'Mina Al Fahal, Muscat, Oman',
        city: 'Muscat',
        country: 'Oman',
        email: 'ops@shelloman.com',
        phoneNumber: '+968 2470 1234',
        primaryContactPerson: 'John Smith',
        paymentTerms: 'Net 30',
        paymentMode: 'Credit',
        invoiceCycle: 'Monthly',
        crNumber: 'CR12345',
        vatinNumber: 'VAT12345',
        currency: 'OMR',
        createdBy: 'system',
        createdAt: DateTime.now(),
      ),
      Customer(
        id: 'CUST002',
        name: 'PDO (Petroleum Development Oman)',
        shortCode: 'PDO',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'PDO',
        billingAddress: 'Sohar St, Muscat, Oman',
        city: 'Muscat',
        country: 'Oman',
        email: 'logistics@pdo.co.om',
        phoneNumber: '+968 2478 5600',
        primaryContactPerson: 'Ali Al Balushi',
        paymentTerms: 'Net 30',
        paymentMode: 'Credit',
        invoiceCycle: 'Monthly',
        crNumber: 'CR67890',
        vatinNumber: 'VAT67890',
        currency: 'OMR',
        createdBy: 'system',
        createdAt: DateTime.now(),
      ),
      Customer(
        id: 'CUST003',
        name: 'OQ Logistics',
        shortCode: 'OQL',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'NON-PDO',
        billingAddress: 'Sohar Port, Sohar, Oman',
        city: 'Sohar',
        country: 'Oman',
        email: 'ref-oq-9321@oq.com',
        phoneNumber: '+968 2450 3800',
        primaryContactPerson: 'Said Al Kindi',
        paymentTerms: 'Net 15',
        paymentMode: 'Credit',
        invoiceCycle: 'Monthly',
        crNumber: 'CR11223',
        vatinNumber: 'VAT11223',
        currency: 'OMR',
        createdBy: 'system',
        createdAt: DateTime.now(),
      ),
      Customer(
        id: 'CUST004',
        name: 'DHL Supply Chain',
        shortCode: 'DHL',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'NON-PDO',
        billingAddress: 'Logistics Hub, Muscat, Oman',
        city: 'Muscat',
        country: 'Oman',
        email: 'om-ops@dhl.com',
        phoneNumber: '+968 2440 7700',
        primaryContactPerson: 'Sarah Jones',
        paymentTerms: 'Net 30',
        paymentMode: 'Credit',
        invoiceCycle: 'Weekly',
        crNumber: 'CR44556',
        vatinNumber: 'VAT44556',
        currency: 'OMR',
        createdBy: 'system',
        createdAt: DateTime.now(),
      ),
      Customer(
        id: 'CUST005',
        name: 'BSC (Bahwan Cybertek)',
        shortCode: 'BSC',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'NON-PDO',
        billingAddress: 'CBD, Muscat, Oman',
        city: 'Muscat',
        country: 'Oman',
        email: 'ref-bsc-5120@bsc.om',
        phoneNumber: '+968 2472 4700',
        primaryContactPerson: 'Mohammed Al Riyami',
        paymentTerms: 'Advance 50%',
        paymentMode: 'Credit',
        invoiceCycle: 'Monthly',
        crNumber: 'CR77889',
        vatinNumber: 'VAT77889',
        currency: 'OMR',
        createdBy: 'system',
        createdAt: DateTime.now(),
      ),
      Customer(
        id: 'CUST006',
        name: 'Al Madina Transport',
        shortCode: 'AMT',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'NON-PDO',
        billingAddress: 'Ibri, Ad Dhahirah, Oman',
        city: 'Ibri',
        country: 'Oman',
        email: 'dispatch@almadina.om',
        phoneNumber: '+968 2461 2211',
        primaryContactPerson: 'Nasser Al Balushi',
        paymentTerms: 'Net 30',
        paymentMode: 'Credit',
        invoiceCycle: 'Weekly',
        crNumber: 'CR99001',
        vatinNumber: 'VAT99001',
        currency: 'OMR',
        createdBy: 'system',
        createdAt: DateTime.now(),
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
    final updatedCustomers = state.customers.map((cust) {
      if (cust.id != customerId) {
        return cust;
      }
      return cust.copyWith(
        status: 'Inactive',
        updatedAt: DateTime.now(),
        updatedBy: 'system',
      );
    }).toList();
    state = state.copyWith(customers: updatedCustomers, clearError: true);
    _persistCustomers(updatedCustomers);
  }

  void setCustomerStatus(String customerId, String status) {
    final updatedCustomers = state.customers.map((cust) {
      if (cust.id != customerId) {
        return cust;
      }
      return cust.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        updatedBy: 'system',
      );
    }).toList();
    state = state.copyWith(customers: updatedCustomers, clearError: true);
    _persistCustomers(updatedCustomers);
  }

  void toggleBlockCustomer({
    required String customerId,
    required bool blocked,
    String reason = '',
    bool hardBlock = true,
  }) {
    final updatedCustomers = state.customers.map((cust) {
      if (cust.id != customerId) {
        return cust;
      }
      return cust.copyWith(
        isBlocked: blocked,
        hardBlock: hardBlock,
        blockReason: blocked ? reason : '',
        updatedAt: DateTime.now(),
        updatedBy: 'system',
      );
    }).toList();
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
