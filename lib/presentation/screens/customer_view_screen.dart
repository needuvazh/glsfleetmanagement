import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/customer.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../widgets/ops_shell.dart';

class CustomerViewScreen extends ConsumerWidget {
  const CustomerViewScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewModelProvider);

    if (state.isLoading) {
      return OpsShell(
        title: 'Customer Details',
        currentRoute: RoutePaths.customerManagement,
        actions: [
          TextButton(
            onPressed: () => context.go(RoutePaths.customerManagement),
            child: const Text('Back to List'),
          ),
        ],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Customer? customer;
    for (final item in state.customers) {
      if (item.id == customerId) {
        customer = item;
        break;
      }
    }

    if (customer == null) {
      return OpsShell(
        title: 'Customer Details',
        currentRoute: RoutePaths.customerManagement,
        actions: [
          TextButton(
            onPressed: () => context.go(RoutePaths.customerManagement),
            child: const Text('Back to List'),
          ),
        ],
        child: const Center(child: Text('Customer not found.')),
      );
    }

    final currentCustomer = customer;

    return OpsShell(
      title: 'Customer Details',
      currentRoute: RoutePaths.customerManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentCustomer.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _row('Customer ID', currentCustomer.id),
                  _row('Category', currentCustomer.category),
                  _row('Contact Person', currentCustomer.contactPerson),
                  _row('Email', currentCustomer.email),
                  _row('Phone', currentCustomer.phoneNumber),
                  _row('Address', currentCustomer.address),
                  _row('CR Number', currentCustomer.crNumber),
                  _row('VATIN Number', currentCustomer.vatinNumber),
                  _row('Currency', currentCustomer.currency),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.go(
                            RoutePaths.editCustomerById(currentCustomer.id)),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Customer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
