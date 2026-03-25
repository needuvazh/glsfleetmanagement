import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class WorkOrderFlowScreen extends ConsumerStatefulWidget {
  const WorkOrderFlowScreen({super.key});

  @override
  ConsumerState<WorkOrderFlowScreen> createState() =>
      _WorkOrderFlowScreenState();
}

class _WorkOrderFlowScreenState extends ConsumerState<WorkOrderFlowScreen> {
  String? _selectedQuoteRef;
  String? _selectedOrderId;
  String? _selectedVehicleNo;
  String? _selectedDriverId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Work Order',
      currentRoute: RoutePaths.workOrderFlow,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.complianceInspection),
          child: const Text('Next'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final approvedQuotations = data.quotations
              .where((q) => (data.quoteStatusByRef[q.quoteRef] ?? 'Pending') == 'Approved')
              .toList();

          if (_selectedQuoteRef != null &&
              !approvedQuotations.any((q) => q.quoteRef == _selectedQuoteRef)) {
            _selectedQuoteRef = null;
          }

          QuotationData? selectedQuotation;
          for (final item in approvedQuotations) {
            if (item.quoteRef == _selectedQuoteRef) {
              selectedQuotation = item;
              break;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 4),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Create Work Order from Approved Quotation',
                subtitle:
                    'Select approved quotation ID to auto-fill work order context',
                icon: Icons.playlist_add_check_circle_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedQuoteRef,
                      decoration: const InputDecoration(
                        labelText: 'Approved Quotation ID',
                      ),
                      items: [
                        for (final item in approvedQuotations)
                          DropdownMenuItem(
                            value: item.quoteRef,
                            child: Text('${item.quoteRef} - ${item.customer}'),
                          ),
                      ],
                      onChanged: approvedQuotations.isEmpty
                          ? null
                          : (value) {
                              setState(() => _selectedQuoteRef = value);
                            },
                    ),
                    if (approvedQuotations.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'No approved quotations available. Approve one in Feasibility & Quotation first.',
                      ),
                    ],
                    if (selectedQuotation != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD8E5FB)),
                        ),
                        child: Text(
                          'Customer: ${selectedQuotation.customer}\n'
                          'Contact: ${selectedQuotation.customerContact}\n'
                          'Work: ${selectedQuotation.workDescription}\n'
                          'Amount: ${selectedQuotation.amount.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _selectedQuoteRef == null
                            ? null
                            : () {
                                final message = ref
                                    .read(logisticsViewModelProvider.notifier)
                                    .createOrderFromQuotation(
                                        _selectedQuoteRef!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)));
                              },
                        icon: const Icon(Icons.post_add_outlined),
                        label: const Text('Create Work Order'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Fleet + Driver Assignment',
                subtitle: 'Assign vehicle and driver after order creation',
                icon: Icons.assignment_ind_outlined,
                accent: const Color(0xFF16A34A),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedOrderId,
                      decoration: const InputDecoration(labelText: 'Order Number'),
                      items: [
                        for (final item in data.workOrders)
                          DropdownMenuItem(
                            value: item.woId,
                            child: Text('${item.woId} (${item.status})'),
                          ),
                      ],
                      onChanged: (value) => setState(() => _selectedOrderId = value),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleNo,
                      decoration: const InputDecoration(labelText: 'Vehicle'),
                      items: [
                        for (final item in data.vehicles)
                          DropdownMenuItem(
                            value: item.vehicleNo,
                            child: Text('${item.vehicleNo} - ${item.status}'),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedVehicleNo = value),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDriverId,
                      decoration: const InputDecoration(labelText: 'Driver'),
                      items: [
                        for (final item in data.drivers)
                          DropdownMenuItem(
                            value: item.driverId,
                            child: Text('${item.name} - ${item.status}'),
                          ),
                      ],
                      onChanged: (value) => setState(() => _selectedDriverId = value),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: (_selectedOrderId == null ||
                                _selectedVehicleNo == null ||
                                _selectedDriverId == null)
                            ? null
                            : () {
                                final message = ref
                                    .read(logisticsViewModelProvider.notifier)
                                    .assignFleetDriver(
                                      orderId: _selectedOrderId!,
                                      vehicleNo: _selectedVehicleNo!,
                                      driverId: _selectedDriverId!,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                        child: const Text('Assign Fleet + Driver'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Work Orders',
                subtitle: 'WO ID, customer, route, cargo and status',
                icon: Icons.assignment_outlined,
                accent: const Color(0xFF0EA5E9),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                    columns: const [
                      DataColumn(label: Text('WO ID')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Route')),
                      DataColumn(label: Text('Cargo')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: [
                      for (final item in data.workOrders)
                        DataRow(
                          cells: [
                            DataCell(Text(item.woId)),
                            DataCell(Text(item.customer)),
                            DataCell(Text(item.route)),
                            DataCell(Text(item.cargo)),
                            DataCell(Text(item.status)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
