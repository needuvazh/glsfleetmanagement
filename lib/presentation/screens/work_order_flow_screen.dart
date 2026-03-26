import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _workOrderNoController = TextEditingController();
  final _customerPoController = TextEditingController();
  final _jobFileRefController = TextEditingController();
  final _internalNotesController = TextEditingController();

  String? _selectedQuoteRef;
  String? _selectedEnquiryNo;
  String? _selectedOrderId;
  String? _selectedVehicleNo;
  String? _selectedDriverId;
  String? _selectedRouteMasterId;
  DateTime? _serviceStartDate;
  DateTime? _serviceEndDate;
  String _initialWoStatus = 'Open';
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    final suffix = DateTime.now().millisecondsSinceEpoch % 100000;
    _workOrderNoController.text = 'WO-$suffix';
    _jobFileRefController.text = 'JOB-$suffix';
  }

  @override
  void dispose() {
    _workOrderNoController.dispose();
    _customerPoController.dispose();
    _jobFileRefController.dispose();
    _internalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final routeState = ref.watch(routeViewModelProvider).valueOrNull;

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
              .where((q) =>
                  (data.quoteStatusByRef[q.quoteRef] ?? 'Pending') ==
                  'Approved')
              .toList();
          final validEnquiries = data.customerRequests
              .where((e) => e.status != 'Cancelled')
              .toList();

          if (_selectedQuoteRef != null &&
              !approvedQuotations.any((q) => q.quoteRef == _selectedQuoteRef)) {
            _selectedQuoteRef = null;
          }
          if (_selectedEnquiryNo != null &&
              !validEnquiries
                  .any((e) => e.enquiryNumber == _selectedEnquiryNo)) {
            _selectedEnquiryNo = null;
          }
          if (_selectedRouteMasterId != null &&
              !(routeState?.routes
                      .any((r) => r.routeId == _selectedRouteMasterId) ??
                  false)) {
            _selectedRouteMasterId = null;
          }

          QuotationData? selectedQuotation;
          for (final item in approvedQuotations) {
            if (item.quoteRef == _selectedQuoteRef) {
              selectedQuotation = item;
              break;
            }
          }

          CustomerRequestData? selectedEnquiry;
          if (_selectedEnquiryNo != null) {
            for (final enquiry in validEnquiries) {
              if (enquiry.enquiryNumber == _selectedEnquiryNo) {
                selectedEnquiry = enquiry;
                break;
              }
            }
          }
          RouteLocationModel? selectedRouteMaster;
          if (_selectedRouteMasterId != null) {
            for (final route
                in (routeState?.routes ?? const <RouteLocationModel>[])) {
              if (route.routeId == _selectedRouteMasterId) {
                selectedRouteMaster = route;
                break;
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 4),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Generate Work Order / Job File',
                subtitle:
                    'Create operational WO from accepted quotation and approved request flow.',
                icon: Icons.playlist_add_check_circle_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _attemptedSubmit
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _workOrderNoController,
                        decoration: const InputDecoration(
                            labelText: 'Work Order Number'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Work order number is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedQuoteRef,
                        decoration: const InputDecoration(
                          labelText: 'Linked Accepted Quotation *',
                        ),
                        items: [
                          for (final item in approvedQuotations)
                            DropdownMenuItem(
                              value: item.quoteRef,
                              child:
                                  Text('${item.quoteRef} - ${item.customer}'),
                            ),
                        ],
                        onChanged: approvedQuotations.isEmpty
                            ? null
                            : (value) {
                                setState(() => _selectedQuoteRef = value);
                              },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Quotation number is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedEnquiryNo,
                        decoration: const InputDecoration(
                          labelText: 'Linked Enquiry *',
                        ),
                        items: [
                          for (final item in validEnquiries)
                            DropdownMenuItem(
                              value: item.enquiryNumber,
                              child: Text(
                                '${item.enquiryNumber} - ${item.customerName} (${item.status})',
                              ),
                            ),
                        ],
                        onChanged: validEnquiries.isEmpty
                            ? null
                            : (value) {
                                setState(() => _selectedEnquiryNo = value);
                              },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enquiry number is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String?>(
                        value: _selectedRouteMasterId,
                        decoration: const InputDecoration(
                          labelText: 'Route Master Override (Optional)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Use Enquiry Route'),
                          ),
                          for (final route in (routeState?.routes ??
                              const <RouteLocationModel>[]))
                            DropdownMenuItem<String?>(
                              value: route.routeId,
                              child: Text(
                                  '${route.routeCode} • ${route.routeName}'),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRouteMasterId = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _customerPoController,
                        decoration: const InputDecoration(
                          labelText: 'Customer PO / CWO Reference',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Customer PO / CWO reference is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _jobFileRefController,
                        decoration: const InputDecoration(
                            labelText: 'Job File Reference'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Job file reference is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'Service Start Date',
                              value: _serviceStartDate,
                              onTap: () => _pickDate(
                                current: _serviceStartDate,
                                onSelected: (value) =>
                                    setState(() => _serviceStartDate = value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateField(
                              label: 'Service End Date',
                              value: _serviceEndDate,
                              onTap: () => _pickDate(
                                current: _serviceEndDate,
                                onSelected: (value) =>
                                    setState(() => _serviceEndDate = value),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_attemptedSubmit &&
                          _serviceDateValidationError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _serviceDateValidationError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _initialWoStatus,
                        decoration: const InputDecoration(
                            labelText: 'Initial WO Status'),
                        items: const [
                          DropdownMenuItem(value: 'Open', child: Text('Open')),
                          DropdownMenuItem(
                            value: 'Ready for Allocation',
                            child: Text('Ready for Allocation'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _initialWoStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _internalNotesController,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(labelText: 'Internal Notes'),
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
                            'Enquiry Ref: ${selectedQuotation.enquiryRef}\n'
                            'Rate: ${selectedQuotation.rate.toStringAsFixed(2)} | ${selectedQuotation.costSummary}',
                          ),
                        ),
                      ],
                      if (selectedEnquiry != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedEnquiry.routeRestricted
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFEAF7EF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedEnquiry.routeRestricted
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Text(
                            'Route: ${selectedEnquiry.routeName.isEmpty ? selectedEnquiry.route : selectedEnquiry.routeName}\n'
                            'Risk: ${selectedEnquiry.routeRiskLevel} | Status: ${selectedEnquiry.routeOperationalStatus}'
                            '${selectedEnquiry.routeRestricted ? '\nRestriction: ${selectedEnquiry.routeRestrictionReason}' : ''}',
                          ),
                        ),
                      ],
                      if (selectedRouteMaster != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                selectedRouteMaster.isSelectableForNewOperations
                                    ? const Color(0xFFE0F2FE)
                                    : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedRouteMaster
                                      .isSelectableForNewOperations
                                  ? const Color(0xFF7DD3FC)
                                  : const Color(0xFFFCA5A5),
                            ),
                          ),
                          child: Text(
                            'Override Route: ${selectedRouteMaster.routeCode} • ${selectedRouteMaster.routeName}\n'
                            'Risk: ${selectedRouteMaster.riskLevel.label} | Status: ${selectedRouteMaster.status.label}'
                            '${selectedRouteMaster.isSelectableForNewOperations ? '' : '\nRestriction: ${selectedRouteMaster.restrictionReason}'}',
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _selectedQuoteRef == null ||
                                  _selectedEnquiryNo == null
                              ? null
                              : () {
                                  setState(() => _attemptedSubmit = true);
                                  final isValid =
                                      _formKey.currentState?.validate() ??
                                          false;
                                  if (!isValid ||
                                      _serviceDateValidationError != null) {
                                    return;
                                  }
                                  final start = _serviceStartDate;
                                  final end = _serviceEndDate;
                                  final override = selectedRouteMaster;
                                  final message = ref
                                      .read(logisticsViewModelProvider.notifier)
                                      .createWorkOrderJobFile(
                                        workOrderNumber:
                                            _workOrderNoController.text.trim(),
                                        linkedQuotationRef: _selectedQuoteRef!,
                                        linkedEnquiryNumber:
                                            _selectedEnquiryNo!,
                                        customerPoReference:
                                            _customerPoController.text.trim(),
                                        jobFileReference:
                                            _jobFileRefController.text.trim(),
                                        serviceStartDate: start == null
                                            ? ''
                                            : _formatDate(start),
                                        serviceEndDate:
                                            end == null ? '' : _formatDate(end),
                                        internalNotes: _internalNotesController
                                            .text
                                            .trim(),
                                        initialStatus: _initialWoStatus,
                                        overrideRouteMasterId:
                                            override?.routeId ?? '',
                                        overrideRouteCode:
                                            override?.routeCode ?? '',
                                        overrideRouteName:
                                            override?.routeName ?? '',
                                        overrideRouteRiskLevel:
                                            override?.riskLevel.label ?? 'Low',
                                        overrideRouteOperationalStatus:
                                            override?.status.label ?? 'Active',
                                        overrideRouteRestricted: override !=
                                                null
                                            ? !override
                                                .isSelectableForNewOperations
                                            : false,
                                        overrideRouteRestrictionReason:
                                            override?.restrictionReason ?? '',
                                        overrideRouteDisplay: override == null
                                            ? ''
                                            : '${override.routeCode} • ${override.routeName}',
                                      );
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
                      decoration:
                          const InputDecoration(labelText: 'Order Number'),
                      items: [
                        for (final item in data.workOrders)
                          DropdownMenuItem(
                            value: item.woId,
                            child: Text('${item.woId} (${item.status})'),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedOrderId = value),
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
                      onChanged: (value) =>
                          setState(() => _selectedDriverId = value),
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
                      DataColumn(label: Text('Linked Quote')),
                      DataColumn(label: Text('Linked Enquiry')),
                      DataColumn(label: Text('PO/CWO Ref')),
                      DataColumn(label: Text('Job File Ref')),
                      DataColumn(label: Text('Service Dates')),
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
                            DataCell(Text(item.linkedQuotationRef)),
                            DataCell(Text(item.linkedEnquiryNumber)),
                            DataCell(Text(item.customerPoReference)),
                            DataCell(Text(item.jobFileReference)),
                            DataCell(Text(
                              '${item.serviceStartDate} -> ${item.serviceEndDate}',
                            )),
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

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: current ?? DateTime.now(),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  String? get _serviceDateValidationError {
    if (_serviceStartDate == null || _serviceEndDate == null) {
      return 'Service start and end dates are required.';
    }
    if (_serviceEndDate!.isBefore(_serviceStartDate!)) {
      return 'Service end date cannot be before start date.';
    }
    return null;
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select date'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.date_range_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}
