import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/entities/work_order.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../widgets/ops_shell.dart';

class WorkOrderDetailScreen extends ConsumerStatefulWidget {
  const WorkOrderDetailScreen({
    super.key,
    required this.workOrderId,
    this.initialTab,
  });

  final String workOrderId;
  final String? initialTab;

  @override
  ConsumerState<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends ConsumerState<WorkOrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabOrder = [
    'summary',
    'assignment',
    'inspection',
    'trip',
    'documents',
    'history',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: _resolveInitialTab(widget.initialTab),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logisticsState = ref.watch(logisticsViewModelProvider);
    
    return OpsShell(
      title: 'Work Order Detail',
      currentRoute: RoutePaths.workOrders,
      child: logisticsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          final order = state.workOrders.where((wo) => wo.woId == widget.workOrderId).firstOrNull;
          if (order == null) {
            return const Center(child: Text('Work Order not found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _headlineChip('WO Number', order.woId),
                          _headlineChip('Customer', order.customer),
                          _headlineChip('Route', order.route),
                          _headlineChip('Status', order.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Quick Actions', style: textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              RoutePaths.editWorkOrderById(widget.workOrderId),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Work Order'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go(RoutePaths.assignments),
                            icon: const Icon(Icons.assignment_ind_outlined),
                            label: const Text('Assign Resources'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.go(RoutePaths.inspectionCreate),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Create Inspection'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.go(RoutePaths.journeyManagement),
                            icon: const Icon(Icons.alt_route_outlined),
                            label: const Text('Create Journey Plan'),
                          ),
                          FilledButton.icon(
                            onPressed: () => context.go(RoutePaths.tripExecution),
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Dispatch'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Summary'),
                  Tab(text: 'Assignment'),
                  Tab(text: 'Inspection'),
                  Tab(text: 'Trip'),
                  Tab(text: 'Documents'),
                  Tab(text: 'History'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SummaryTab(order: order, state: state),
                    _PlaceholderTab(title: 'Assignment Details', id: widget.workOrderId),
                    _PlaceholderTab(title: 'Inspection Status', id: widget.workOrderId),
                    _PlaceholderTab(title: 'Trip Tracking', id: widget.workOrderId),
                    _PlaceholderTab(title: 'Documents and Media', id: widget.workOrderId),
                    _PlaceholderTab(title: 'Full Audit Timeline', id: widget.workOrderId),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headlineChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  int _resolveInitialTab(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }
    final normalized = value.trim().toLowerCase();
    final index = _tabOrder.indexOf(normalized);
    return index < 0 ? 0 : index;
  }
}

class _SummaryTab extends ConsumerWidget {
  const _SummaryTab({required this.order, required this.state});

  final WorkOrderFlowItem order;
  final LogisticsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerViewModelProvider).customers;
    final routes = ref.watch(routeViewModelProvider).valueOrNull?.routes ?? [];
    final quote = state.quotations.where((q) => q.quoteRef == order.linkedQuotationRef).firstOrNull;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildQuotationContext(context, quote, state, customers, routes),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Planning Details',
          rows: [
            _Pair('Requested Date', _formatDate(order.serviceStartDate)),
            _Pair('Planned Dispatch', _formatDateTime(order.serviceStartDate)),
            _Pair('Planned Delivery', _formatDateTime(order.serviceEndDate)),
            _Pair('Priority', order.routeRiskLevel), // Reusing for now
            _Pair('Internal Notes', order.internalNotes),
          ],
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatDateTime(String iso) {
    if (iso.isEmpty) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildQuotationContext(
    BuildContext context,
    QuotationData? quote,
    LogisticsUiState? state,
    List<Customer> customers,
    List<RouteLocationModel> routes,
  ) {
    if (quote == null || state == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No quotation reference found for this work order.'),
      );
    }

    final enquiry = state.customerRequests.where((e) => e.enquiryNumber == quote.enquiryRef).firstOrNull;
    final customer = customers.where((c) => c.name.toLowerCase() == (enquiry?.customerName ?? quote.customer).toLowerCase()).firstOrNull;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Quotation & Context Reference',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text('QUOTATION DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _twoColumnRow(
            _contextItem(context, 'Quote Ref', quote.quoteRef),
            _contextItem(context, 'Enquiry Ref', quote.enquiryRef),
          ),
          _twoColumnRow(
            _contextItem(context, 'Rate', '${quote.rate.toStringAsFixed(2)} OMR'),
            _contextItem(context, 'Validity', quote.validityDate.isEmpty ? '-' : quote.validityDate),
          ),
          
          const Divider(height: 32),
          
          Text('CUSTOMER DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _twoColumnRow(
            _contextItem(context, 'Customer Name', customer?.name ?? quote.customer),
            _contextItem(context, 'Contact Number', customer?.phoneNumber.isNotEmpty == true ? customer!.phoneNumber : '-'),
          ),

          if (enquiry != null) ...[
            const Divider(height: 32),
            Text('CARGO DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _twoColumnRow(
              _contextItem(context, 'Cargo Type', enquiry.cargoType),
              _contextItem(context, 'Weight/Volume', enquiry.weightVolume),
            ),
            
            const Divider(height: 32),
            Text('ROUTE DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _twoColumnRow(
              _contextItem(context, 'Origin', enquiry.pickup),
              _contextItem(context, 'Destination', enquiry.delivery),
            ),
          ],
        ],
      ),
    );
  }

  Widget _twoColumnRow(Widget a, Widget b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 16),
          Expanded(child: b),
        ],
      ),
    );
  }

  Widget _contextItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.id});
  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Detailed view for $id will be integrated in the next sprint.'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows, this.footer});

  final String title;
  final List<_Pair> rows;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 210,
                      child: Text(
                        row.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
            if (footer != null) ...[
              const SizedBox(height: 8),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Pair {
  const _Pair(this.label, this.value);

  final String label;
  final String value;
}
