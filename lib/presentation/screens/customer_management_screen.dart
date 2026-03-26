import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/customer.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  bool _highRiskOnly = false;
  bool _creditExceededOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerViewModelProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    var filteredCustomers = customerState.customers.where((cust) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          cust.name.toLowerCase().contains(query) ||
          cust.id.toLowerCase().contains(query) ||
          cust.shortCode.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == 'All' || cust.status == _statusFilter;
      final matchesRisk = !_highRiskOnly || cust.isHighRisk;
      final matchesCredit = !_creditExceededOnly || cust.isCreditExceeded;
      return matchesSearch && matchesStatus && matchesRisk && matchesCredit;
    }).toList();

    filteredCustomers.sort((a, b) => b.riskScore.compareTo(a.riskScore));

    return OpsShell(
      title: 'Customer Management',
      currentRoute: RoutePaths.customerManagement,
      child: customerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _metricChip(
                            label: 'Total ${customerState.customers.length}',
                            color: const Color(0xFF2563EB),
                          ),
                          _metricChip(
                            label:
                                'High Risk ${customerState.customers.where((c) => c.isHighRisk).length}',
                            color: const Color(0xFFDC2626),
                          ),
                          _metricChip(
                            label:
                                'Credit Exceeded ${customerState.customers.where((c) => c.isCreditExceeded).length}',
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => context.go(RoutePaths.customerForm),
                        icon: const Icon(Icons.add),
                        label: const Text('Create New'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OpsSectionCard(
                    title: 'Customer Filters',
                    subtitle:
                        'Search by customer name/code and isolate risk-driven accounts',
                    icon: Icons.filter_alt_outlined,
                    accent: const Color(0xFF0EA5E9),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by name, ID, or short code...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final status in const [
                                'All',
                                'Active',
                                'Inactive',
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(status),
                                    selected: _statusFilter == status,
                                    onSelected: (_) {
                                      setState(() => _statusFilter = status);
                                    },
                                  ),
                                ),
                              FilterChip(
                                label: const Text('High Risk'),
                                selected: _highRiskOnly,
                                onSelected: (selected) {
                                  setState(() => _highRiskOnly = selected);
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Credit Exceeded'),
                                selected: _creditExceededOnly,
                                onSelected: (selected) {
                                  setState(
                                      () => _creditExceededOnly = selected);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? Center(
                          child: Text(
                            'No customers match your filters.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : isDesktop
                          ? _desktopTable(context, filteredCustomers)
                          : ListView.builder(
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return _CustomerCard(customer: customer);
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _desktopTable(BuildContext context, List<Customer> customers) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer ID')),
                  DataColumn(label: Text('Short Code')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Risk')),
                  DataColumn(label: Text('Credit Usage')),
                  DataColumn(label: Text('Indicators')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final customer in customers)
                    DataRow(
                      cells: [
                        DataCell(Text(customer.id)),
                        DataCell(Text(customer.shortCode)),
                        DataCell(Text(customer.name)),
                        DataCell(
                          OpsPill(
                            label: customer.status,
                            color: customer.isActive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        DataCell(
                          OpsPill(
                            label: '${customer.riskScore}',
                            color: customer.riskScore >= 70
                                ? const Color(0xFFDC2626)
                                : customer.riskScore >= 40
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF16A34A),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${customer.outstandingAmount.toStringAsFixed(0)} / ${customer.creditLimit.toStringAsFixed(0)} ${customer.currency}',
                          ),
                        ),
                        DataCell(_indicatorWrap(customer)),
                        DataCell(
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.go(
                                  RoutePaths.customerViewById(customer.id),
                                ),
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('View'),
                              ),
                              TextButton.icon(
                                onPressed: () => context.go(
                                  RoutePaths.editCustomerById(customer.id),
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _metricChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _indicatorWrap(Customer customer) {
    final indicators = <Widget>[];
    if (customer.hasOverduePayments || customer.overdueInvoices > 0) {
      indicators.add(const Tooltip(
        message: 'Overdue payments',
        child: Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
      ));
    }
    if (customer.isNearCreditLimit) {
      indicators.add(const Tooltip(
        message: 'Near credit limit',
        child: Icon(Icons.error_outline, color: Color(0xFFF59E0B)),
      ));
    }
    if (customer.isBlocked) {
      indicators.add(const Tooltip(
        message: 'Blocked customer',
        child: Icon(Icons.block, color: Color(0xFF7F1D1D)),
      ));
    }

    if (indicators.isEmpty) {
      return const Text('-');
    }
    return Row(mainAxisSize: MainAxisSize.min, children: indicators);
  }
}

class _CustomerCard extends ConsumerWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(customerViewModelProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      Text(
                        '${customer.id} - ${customer.shortCode}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                OpsPill(
                  label: customer.status,
                  color: customer.isActive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6B7280),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OpsPill(
                    label: customer.segment, color: const Color(0xFF2563EB)),
                OpsPill(
                  label: 'Risk ${customer.riskScore}',
                  color: customer.riskScore >= 70
                      ? const Color(0xFFDC2626)
                      : customer.riskScore >= 40
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF16A34A),
                ),
                if (customer.hasOverduePayments)
                  const OpsPill(label: 'Overdue', color: Color(0xFFDC2626)),
                if (customer.isNearCreditLimit)
                  const OpsPill(label: 'Near Limit', color: Color(0xFFF59E0B)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Outstanding ${customer.outstandingAmount.toStringAsFixed(0)} / ${customer.creditLimit.toStringAsFixed(0)} ${customer.currency}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      context.go(RoutePaths.customerViewById(customer.id)),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View'),
                ),
                TextButton.icon(
                  onPressed: () =>
                      context.go(RoutePaths.editCustomerById(customer.id)),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    final newStatus =
                        customer.status == 'Active' ? 'Inactive' : 'Active';
                    viewModel.setCustomerStatus(customer.id, newStatus);
                  },
                  icon: const Icon(Icons.toggle_on_outlined),
                  label: Text(
                    customer.status == 'Active' ? 'Deactivate' : 'Activate',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
