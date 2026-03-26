import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestScreen extends ConsumerStatefulWidget {
  const CustomerRequestScreen({super.key});

  @override
  ConsumerState<CustomerRequestScreen> createState() => _CustomerRequestScreenState();
}

class _CustomerRequestScreenState extends ConsumerState<CustomerRequestScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'New',
    'Details Pending',
    'Ready for Review',
    'Closed'
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Transactions / Enquiry / List',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            // Placeholder for export functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exporting Enquiries...')),
            );
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('Export'),
        ),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.customerRequestForm),
          icon: const Icon(Icons.add),
          label: const Text('Add Enquiry'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          var filteredList = data.customerRequests.where((e) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = e.enquiryNumber.toLowerCase().contains(q) ||
                e.customerName.toLowerCase().contains(q) ||
                e.requestDate.toLowerCase().contains(q) ||
                e.status.toLowerCase().contains(q);

            if (!matchesSearch) return false;

            if (_selectedFilter != 'All') {
              if (_selectedFilter == 'New' && e.status != 'New Enquiry') {
                return false;
              }
              if (_selectedFilter == 'Details Pending' && e.status != 'Detail Collection') {
                return false;
              }
              if (_selectedFilter == 'Ready for Review' && e.status != 'Ready for Review') {
                return false;
              }
              if (_selectedFilter == 'Closed' &&
                  (e.status != 'Closed' && e.status != 'Cancelled')) {
                return false;
              }
            }
            return true;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilterRow(),
                const SizedBox(height: 16),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Enquiry List',
                    subtitle: 'Manage and track all transport enquiries.',
                    icon: Icons.table_chart_outlined,
                    accent: const Color(0xFF0EA5E9),
                    child: _RegisterTable(enquiries: filteredList),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by Enquiry No, Customer, Date, Status',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter Status',
                    isDense: true,
                  ),
                  items: _filters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedFilter = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _filters.map((f) {
              final isSelected = _selectedFilter == f;
              return ChoiceChip(
                label: Text(f),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedFilter = f);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RegisterTable extends StatelessWidget {
  const _RegisterTable({required this.enquiries});

  final List<CustomerRequestData> enquiries;

  @override
  Widget build(BuildContext context) {
    if (enquiries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No enquiries match your search/filters.'),
            ],
          ),
        ),
      );
    }

    String formatDateTime(DateTime dt) {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF6FF)),
        columns: const [
          DataColumn(label: Text('Enquiry No')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Request Date')),
          DataColumn(label: Text('Cargo Type')),
          DataColumn(label: Text('Pickup')),
          DataColumn(label: Text('Delivery')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Last Updated')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final enquiry in enquiries)
            DataRow(
              cells: [
                DataCell(Text(enquiry.enquiryNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(enquiry.customerName)),
                DataCell(Text(enquiry.requestDate)),
                DataCell(Text(enquiry.cargoType)),
                DataCell(Text(enquiry.pickup)),
                DataCell(Text(enquiry.delivery)),
                DataCell(_statusPill(enquiry.status)),
                DataCell(Text(formatDateTime(enquiry.updatedAt))),
                DataCell(
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconButtonTheme: IconButtonThemeData(
                        style: IconButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      ),
                    ),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        Tooltip(
                          message: 'View',
                          child: IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.blue),
                            onPressed: () => context.go(RoutePaths.customerRequestViewById(enquiry.enquiryNumber)),
                          ),
                        ),
                        if (enquiry.status != 'Closed' && enquiry.status != 'Cancelled')
                          Tooltip(
                            message: 'Edit',
                            child: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.orange),
                              onPressed: () => context.go('${RoutePaths.customerRequestForm}?enquiryNumber=${enquiry.enquiryNumber}'),
                            ),
                          ),
                        if (enquiry.status == 'New Enquiry')
                          Tooltip(
                            message: 'Add Details',
                            child: IconButton(
                              icon: const Icon(Icons.post_add_outlined, size: 20, color: Colors.green),
                              onPressed: () => context.go('${RoutePaths.customerRequestForm}?enquiryNumber=${enquiry.enquiryNumber}'),
                            ),
                          ),
                        if (enquiry.status == 'Detail Collection')
                          Tooltip(
                            message: 'Convert to Review',
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_outlined, size: 20, color: Colors.purple),
                              onPressed: () {
                                // In a real app, this would mutate state and navigate or just mutate
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ], // cells
            ), // DataRow
        ], // rows
      ), // DataTable
    ), // ConstrainedBox
  ); // SingleChildScrollView
}, // builder
); // LayoutBuilder
}

  Widget _statusPill(String status) {
    final s = status.toLowerCase();
    if (s == 'cancelled' || s == 'closed') {
      return OpsPill(label: status, color: const Color(0xFFDC2626));
    }
    if (s == 'detail collection' || s == 'details pending') {
      return OpsPill(label: status, color: const Color(0xFF0284C7));
    }
    if (s == 'ready for review') {
      return OpsPill(label: status, color: const Color(0xFF9333EA));
    }
    return OpsPill(label: status, color: const Color(0xFF16A34A));
  }
}
