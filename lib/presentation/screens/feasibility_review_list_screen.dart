import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FeasibilityReviewListScreen extends ConsumerStatefulWidget {
  const FeasibilityReviewListScreen({super.key});

  @override
  ConsumerState<FeasibilityReviewListScreen> createState() =>
      _FeasibilityReviewListScreenState();
}

class _FeasibilityReviewListScreenState
    extends ConsumerState<FeasibilityReviewListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Feasible',
    'Not Feasible',
    'High Risk',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Transactions / Feasibility Review / List',
      currentRoute: RoutePaths.feasibilityReview,
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final filteredList = data.customerRequests.where((e) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = e.enquiryNumber.toLowerCase().contains(q) ||
                e.customerName.toLowerCase().contains(q);

            if (!matchesSearch) return false;

            if (_selectedFilter != 'All') {
              if (_selectedFilter == 'Pending' &&
                  e.feasibilityStatus != 'Pending') return false;
              if (_selectedFilter == 'Feasible' &&
                  e.feasibilityStatus != 'Feasible') return false;
              if (_selectedFilter == 'Not Feasible' &&
                  e.feasibilityStatus != 'Not Feasible') return false;
              if (_selectedFilter == 'High Risk' &&
                  (e.feasibilityRiskLevel != 'High' &&
                      e.feasibilityRiskLevel != 'Critical')) return false;
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
                    title: 'Pending Reviews',
                    subtitle: 'Evaluate operational and commercial feasibility.',
                    icon: Icons.analytics_outlined,
                    accent: const Color(0xFF8B5CF6),
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
                    labelText: 'Search by Enquiry No, Customer',
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
                    labelText: 'Review Status / Risk',
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
              Icon(Icons.check_circle_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No reviews pending.'),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
        columns: const [
          DataColumn(label: Text('Enquiry No')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Cargo')),
          DataColumn(label: Text('Route')),
          DataColumn(label: Text('Risk Level')),
          DataColumn(label: Text('Review Status')),
          DataColumn(label: Text('Reviewed By')),
          DataColumn(label: Text('Action')),
        ],
        rows: [
          for (final enquiry in enquiries)
            DataRow(
              cells: [
                DataCell(Text(enquiry.enquiryNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(enquiry.customerName)),
                DataCell(Text(enquiry.cargoType)),
                DataCell(Text(enquiry.route.isEmpty ? '-' : enquiry.route)),
                DataCell(_riskPill(enquiry.feasibilityRiskLevel)),
                DataCell(_statusPill(enquiry.feasibilityStatus)),
                DataCell(Text(enquiry.reviewedBy.isEmpty
                    ? 'Unassigned'
                    : enquiry.reviewedBy)),
                DataCell(
                  FilledButton.icon(
                    onPressed: () => context.go(RoutePaths.feasibilityReviewById(enquiry.enquiryNumber)),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Review'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
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

  Widget _riskPill(String risk) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade800;
    if (risk == 'High' || risk == 'Critical') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade800;
    } else if (risk == 'Medium') {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade800;
    } else if (risk == 'Low') {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(risk,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _statusPill(String status) {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.grey.shade800;
    if (status == 'Feasible') {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    } else if (status == 'Not Feasible') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade800;
    } else if (status == 'Pending') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
