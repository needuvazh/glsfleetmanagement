import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class QuotationListScreen extends ConsumerStatefulWidget {
  const QuotationListScreen({super.key});

  @override
  ConsumerState<QuotationListScreen> createState() =>
      _QuotationListScreenState();
}

class _QuotationListScreenState extends ConsumerState<QuotationListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Draft',
    'Sent',
    'Accepted',
    'Rejected',
    'Expired',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Transactions / Quotation / List',
      currentRoute: RoutePaths.quotation,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.quotationForm),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Quotation'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          final filtered = data.quotations.where((q) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch = q.quoteRef.toLowerCase().contains(query) ||
                q.customer.toLowerCase().contains(query) ||
                q.enquiryRef.toLowerCase().contains(query);
            if (!matchesSearch) return false;
            if (_selectedFilter != 'All' && q.status != _selectedFilter) {
              return false;
            }
            return true;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilter(),
                const SizedBox(height: 16),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Quotations',
                    subtitle: 'Manage and track all quotations.',
                    icon: Icons.request_quote_outlined,
                    accent: const Color(0xFF0284C7),
                    child: _QuotationTable(quotations: filtered),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
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
                    labelText: 'Search by Quote No, Enquiry, Customer',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration:
                      const InputDecoration(labelText: 'Status', isDense: true),
                  items: _filters
                      .map((f) =>
                          DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedFilter = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _filters.map((f) {
              return ChoiceChip(
                label: Text(f),
                selected: _selectedFilter == f,
                onSelected: (sel) {
                  if (sel) setState(() => _selectedFilter = f);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuotationTable extends StatelessWidget {
  const _QuotationTable({required this.quotations});
  final List<QuotationData> quotations;

  @override
  Widget build(BuildContext context) {
    if (quotations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.request_quote_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No quotations found.'),
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
              headingRowColor:
                  WidgetStateProperty.all(const Color(0xFFF3F4F6)),
              columns: const [
                DataColumn(label: Text('Quotation No')),
                DataColumn(label: Text('Enquiry Ref')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Validity')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final q in quotations)
                  DataRow(
                    cells: [
                      DataCell(Text(q.quoteRef,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(q.enquiryRef.isEmpty ? '-' : q.enquiryRef)),
                      DataCell(Text(q.customer)),
                      DataCell(Text(q.rate.toStringAsFixed(2))),
                      DataCell(Text(q.validityDate.isEmpty ? '-' : q.validityDate)),
                      DataCell(_statusPill(q.status)),
                      DataCell(
                        Wrap(
                          spacing: 4,
                          children: [
                            TextButton(
                              onPressed: () => context.go(
                                  RoutePaths.quotationEditByRef(q.quoteRef)),
                              child: const Text('Edit'),
                            ),
                            if (q.status == 'Draft')
                              Consumer(builder: (ctx, ref, _) {
                                return TextButton(
                                  onPressed: () {
                                    final msg = ref
                                        .read(logisticsViewModelProvider
                                            .notifier)
                                        .sendQuotation(q.quoteRef);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text(msg)));
                                  },
                                  child: const Text('Send'),
                                );
                              }),
                            if (q.status == 'Sent')
                              TextButton(
                                onPressed: () => context.go(
                                    RoutePaths.quotationDecisionByRef(
                                        q.quoteRef)),
                                child: const Text('Record Decision'),
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
    );
  }

  Widget _statusPill(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Accepted':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      case 'Rejected':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      case 'Sent':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        break;
      case 'Expired':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
