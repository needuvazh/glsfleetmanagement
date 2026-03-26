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
        name: 'Al Ghanim Trading Company',
        shortCode: 'AGT',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'PDO',
        billingAddress: 'P.O. Box 1234, Muscat 113, Oman',
        city: 'Muscat',
        country: 'Oman',
        email: 'info@alghanim.om',
        phoneNumber: '+968 24 123456',
        alternateContact: '+968 99 123456',
        crNumber: '1234567',
        vatinNumber: 'OM-VAT-001',
        currency: 'OMR',
        primaryContactPerson: 'Ahmed Al Ghanim',
        paymentTerms: 'Net 30',
        creditLimit: 500000,
        outstandingAmount: 352000,
        hasOverduePayments: true,
        paymentMode: 'Credit',
        invoiceCycle: 'Monthly',
        averagePaymentDelayDays: 12,
        complaintsCount: 1,
        riskScore: 76,
        podRequired: true,
        dnRequired: true,
        specialDocumentsRequired: const ['POD', 'DN', 'Seal Checklist'],
        slaHours: 24,
        preferredVehicleType: 'Flatbed Trailer',
        preferredRoute: 'Muscat - Fahud',
        priorityLevel: 'High',
        specialCertificationsRequired: const ['PDO Passport', 'H2S'],
        restrictedRoutes: const ['Marmul Night Route'],
        safetyRules: const ['No idling beyond 10 min'],
        mandatoryInspectionType: 'Pre-dispatch L3',
        activeWorkOrders: 6,
        pendingInvoices: 3,
        overdueInvoices: 1,
        isBlocked: false,
        hardBlock: true,
        blockReason: '',
        createdBy: 'ops.admin',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedBy: 'credit.controller',
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Customer(
        id: 'CUST002',
        name: 'Oman Logistics Solutions',
        shortCode: 'OLS',
        customerType: 'Corporate',
        status: 'Active',
        segment: 'NON-PDO',
        billingAddress: 'Industrial Area, Muscat, Oman',
        city: 'Muscat',
        country: 'Oman',
        email: 'contact@omanlogs.om',
        phoneNumber: '+968 24 234567',
        alternateContact: '+968 92 234567',
        crNumber: '2345678',
        vatinNumber: 'OM-VAT-002',
        currency: 'OMR',
        primaryContactPerson: 'Fatima Al Balushi',
        paymentTerms: 'Advance',
        creditLimit: 250000,
        outstandingAmount: 32000,
        hasOverduePayments: false,
        paymentMode: 'Bank Transfer',
        invoiceCycle: 'Per Trip',
        averagePaymentDelayDays: 0,
        complaintsCount: 0,
        riskScore: 18,
        podRequired: false,
        dnRequired: false,
        specialDocumentsRequired: const [],
        slaHours: 36,
        preferredVehicleType: 'Curtain Side',
        preferredRoute: 'Muscat - Sohar',
        priorityLevel: 'Normal',
        specialCertificationsRequired: const [],
        restrictedRoutes: const [],
        safetyRules: const ['Reflective PPE mandatory'],
        mandatoryInspectionType: 'Standard',
        activeWorkOrders: 3,
        pendingInvoices: 1,
        overdueInvoices: 0,
        isBlocked: false,
        hardBlock: false,
        blockReason: '',
        createdBy: 'ops.admin',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedBy: 'ops.admin',
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Customer(
        id: 'CUST003',
        name: 'Gulf Trading & Distribution',
        shortCode: 'GTD',
        customerType: 'Corporate',
        status: 'Inactive',
        segment: 'PDO',
        billingAddress: 'Salalah, Dhofar, Oman',
        city: 'Salalah',
        country: 'Oman',
        email: 'sales@gulftrade.om',
        phoneNumber: '+968 23 345678',
        alternateContact: '+968 94 345678',
        crNumber: '3456789',
        vatinNumber: 'OM-VAT-003',
        currency: 'OMR',
        primaryContactPerson: 'Mohammed Al Harthi',
        paymentTerms: 'Net 60',
        creditLimit: 300000,
        outstandingAmount: 312500,
        hasOverduePayments: true,
        paymentMode: 'Credit',
        invoiceCycle: 'Monthly',
        averagePaymentDelayDays: 28,
        complaintsCount: 3,
        riskScore: 92,
        podRequired: true,
        dnRequired: true,
        specialDocumentsRequired: const ['POD', 'Site Gate Pass'],
        slaHours: 18,
        preferredVehicleType: 'Lowbed',
        preferredRoute: 'Duqm Port Corridor',
        priorityLevel: 'Critical',
        specialCertificationsRequired: const ['H2S', 'Defensive Driving'],
        restrictedRoutes: const ['Batinah Coastal Road'],
        safetyRules: const ['Escort mandatory for heavy haul'],
        mandatoryInspectionType: 'Pre-trip Special',
        activeWorkOrders: 0,
        pendingInvoices: 4,
        overdueInvoices: 2,
        isBlocked: true,
        hardBlock: true,
        blockReason: 'Credit exceeded with 2 overdue invoices.',
        createdBy: 'ops.admin',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedBy: 'finance.manager',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Customer(
        id: 'CUST004',
        name: 'Nizwa Freight Services',
        shortCode: 'NFS',
        customerType: 'Individual',
        status: 'Active',
        segment: 'NON-PDO',
        billingAddress: 'Nizwa, Ad Dakhiliyah, Oman',
        city: 'Nizwa',
        country: 'Oman',
        email: 'freight@nizwafreight.om',
        phoneNumber: '+968 25 456789',
        alternateContact: '+968 96 456789',
        crNumber: '4567890',
        vatinNumber: 'OM-VAT-004',
        currency: 'OMR',
        primaryContactPerson: 'Salim Al Rawahi',
        paymentTerms: 'Net 15',
        creditLimit: 120000,
        outstandingAmount: 98000,
        hasOverduePayments: false,
        paymentMode: 'Credit',
        invoiceCycle: 'Weekly',
        averagePaymentDelayDays: 4,
        complaintsCount: 0,
        riskScore: 44,
        podRequired: true,
        dnRequired: false,
        specialDocumentsRequired: const ['POD'],
        slaHours: 48,
        preferredVehicleType: 'Box Truck',
        preferredRoute: 'Nizwa Local Route',
        priorityLevel: 'Normal',
        specialCertificationsRequired: const [],
        restrictedRoutes: const [],
        safetyRules: const ['Load lashing photo required'],
        mandatoryInspectionType: 'Standard',
        activeWorkOrders: 2,
        pendingInvoices: 2,
        overdueInvoices: 0,
        isBlocked: false,
        hardBlock: false,
        blockReason: '',
        createdBy: 'ops.supervisor',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedBy: 'ops.supervisor',
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
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
