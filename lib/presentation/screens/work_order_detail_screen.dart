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
                            onPressed: () => context.push(
                              RoutePaths.assignSupervisorById(widget.workOrderId),
                            ),
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Assign Supervisor'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go(
                              RoutePaths.resourceAssignmentById(widget.workOrderId),
                            ),
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
                            onPressed: () {
                              if (order.assignedVehicleNo.isEmpty || order.assignedDriverId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot Dispatch: Please assign a vehicle and driver first.')),
                                );
                                return;
                              }

                              final vehicle = state.vehicles.where((v) => v.vehicleNo == order.assignedVehicleNo).firstOrNull;
                              final driver = state.drivers.where((d) => d.driverId == order.assignedDriverId).firstOrNull;
                              final jmp = state.journeyPlans.where((p) => p.woId == widget.workOrderId).firstOrNull;

                              if (jmp == null || jmp.status != 'Approved') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.warning_amber, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Journey Plan Required'),
                                      ],
                                    ),
                                    content: const Text('An Approved Journey Management Plan (JMP) is mandatory before dispatch.\n\nPlease create or approve the JMP for this Work Order.'),
                                    actions: [
                                      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                                      FilledButton(
                                        onPressed: () {
                                          context.pop();
                                          if (jmp == null) {
                                            context.go('${RoutePaths.journeyManagement}/new');
                                          } else {
                                            context.go('${RoutePaths.journeyManagement}/${jmp.jmpId}');
                                          }
                                        },
                                        child: Text(jmp == null ? 'Create JMP' : 'View JMP'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              bool isBlocked = false;
                              if (vehicle != null && vehicle.status.toLowerCase() == 'maintenance') isBlocked = true;
                              if (driver != null && (!driver.licenseValid || driver.pdoPassportStatus.toLowerCase() == 'expired' || driver.h2sStatus.toLowerCase() == 'expired')) isBlocked = true;

                              if (isBlocked) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.block, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Dispatch Blocked'),
                                      ],
                                    ),
                                    content: const Text('Mandatory compliance documents are missing or expired (Hard-block).\n\nPlease review the readiness tracker and ensure all resources are compliant before dispatching.'),
                                    actions: [
                                      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                                      FilledButton(
                                        onPressed: () {
                                          context.pop();
                                          context.go('${RoutePaths.complianceReadiness}?workOrderId=${widget.workOrderId}');
                                        },
                                        child: const Text('View Readiness'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              context.go(RoutePaths.tripExecution);
                            },
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
                    _AssignmentTab(order: order, state: state),
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
          icon: Icons.calendar_today_outlined,
          children: [
            Text('PLANNING DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _GridRow(
              label1: 'Requested Date', 
              value1: _formatDate(order.serviceStartDate),
              label2: 'Priority',
              value2: order.routeRiskLevel,
            ),
            const SizedBox(height: 16),
            _GridRow(
              label1: 'Planned Dispatch',
              value1: _formatDateTime(order.serviceStartDate),
              label2: 'Planned Delivery',
              value2: _formatDateTime(order.serviceEndDate),
            ),
            const SizedBox(height: 16),
            _GridRow(
              label1: 'Internal Notes',
              value1: order.internalNotes,
            ),
          ],
        ),
        if (order.assignedSupervisor.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Supervisor Assignment',
            icon: Icons.assignment_ind_outlined,
            children: [
              Text('ASSIGNMENT DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _GridRow(
                label1: 'Assigned Supervisor',
                value1: order.assignedSupervisor,
                label2: 'Region / Responsibility',
                value2: order.supervisorRegion.isNotEmpty ? order.supervisorRegion : 'N/A',
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'Assignment Date',
                value1: order.assignmentDate,
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'Remarks',
                value1: order.assignmentRemarks.isNotEmpty ? order.assignmentRemarks : 'N/A',
              ),
            ],
          ),
        ],
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
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.15),
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

class _AssignmentTab extends ConsumerWidget {
  const _AssignmentTab({required this.order, required this.state});
  final WorkOrderFlowItem order;
  final LogisticsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (order.assignedVehicleNo.isEmpty && order.assignedDriverId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text('No Resources Assigned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Assign resources from the quick actions bar to see details here.'),
          ],
        ),
      );
    }

    final vehicle = state.vehicles.where((v) => v.vehicleNo == order.assignedVehicleNo).firstOrNull;
    final driver = state.drivers.where((d) => d.driverId == order.assignedDriverId).firstOrNull;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (vehicle != null)
          _InfoCard(
            title: 'Assigned Fleet (Truck)',
            icon: Icons.local_shipping_outlined,
            children: [
              Text('FLEET SPECIFICATIONS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _GridRow(
                label1: 'Vehicle No',
                value1: vehicle.vehicleNo,
                label2: 'Type / Model',
                value2: vehicle.type,
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'Capacity',
                value1: vehicle.capacity,
                label2: 'Fuel Type',
                value2: vehicle.fuelType,
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'IVMS Device ID',
                value1: vehicle.ivmsDeviceId.isNotEmpty ? vehicle.ivmsDeviceId : 'N/A',
                label2: 'Operational Status',
                value2: vehicle.status,
              ),
            ],
          ),
        
        if (order.assignedTrailerId.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Assigned Trailer',
            icon: Icons.rv_hookup_outlined,
            children: [
              Text('TRAILER DETAILS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _GridRow(
                label1: 'Trailer ID',
                value1: order.assignedTrailerId,
                label2: 'Connection Status',
                value2: 'Linked',
              ),
            ],
          ),
        ],

        if (driver != null) ...[
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Assigned Driver',
            icon: Icons.person_outline,
            children: [
              Text('DRIVER PROFILE', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _GridRow(
                label1: 'Full Name',
                value1: driver.name,
                label2: 'Driver ID',
                value2: driver.driverId,
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'Phone Number',
                value1: driver.phone,
                label2: 'Nationality',
                value2: driver.nationality,
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'License No',
                value1: driver.licenseNo,
                label2: 'Employee Ref',
                value2: driver.employeeRef,
              ),
              const SizedBox(height: 16),
              _GridRow(
                label1: 'Status',
                value1: driver.status,
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
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

class _PairRow extends StatelessWidget {
  const _PairRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 210,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
    this.footer,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.label1,
    required this.value1,
    this.label2,
    this.value2,
  });

  final String label1;
  final String value1;
  final String? label2;
  final String? value2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _label(context, label1)),
            if (label2 != null) ...[
              const SizedBox(width: 16),
              Expanded(child: _label(context, label2!)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _value(context, value1)),
            if (value2 != null) ...[
              const SizedBox(width: 16),
              Expanded(child: _value(context, value2!)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _value(BuildContext context, String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}
