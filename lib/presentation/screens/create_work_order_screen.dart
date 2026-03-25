import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/entities/work_order.dart';
import '../../domain/vendor_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/journey_plan_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../viewmodels/work_order_draft_viewmodel.dart';
import '../viewmodels/work_orders_viewmodel.dart';
import '../widgets/ops_shell.dart';

class CreateWorkOrderScreen extends ConsumerStatefulWidget {
  const CreateWorkOrderScreen({
    super.key,
    this.editWorkOrderId,
  });

  final String? editWorkOrderId;

  @override
  ConsumerState<CreateWorkOrderScreen> createState() =>
      _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends ConsumerState<CreateWorkOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _workOrderNumberController = TextEditingController();
  final _enquiryNumberController = TextEditingController();
  final _customerController = TextEditingController();
  final _remarksController = TextEditingController();
  final _cargoTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _weightController = TextEditingController();
  final _loadTypeController = TextEditingController();
  final _specialHandlingController = TextEditingController();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _stopPointsController = TextEditingController();
  final _routeNotesController = TextEditingController();
  final _specialDocumentsController = TextEditingController();
  VendorServiceType _vendorServiceType = VendorServiceType.nonPdo;
  String? _vendorId;

  WorkOrderPriority _priority = WorkOrderPriority.medium;
  DateTime? _requestedDate;
  DateTime? _plannedDispatchDate;
  DateTime? _plannedDeliveryDate;
  bool _podRequired = true;
  bool _dnRequired = true;
  String? _journeyPlanId;
  bool _didPopulateEditValues = false;

  bool get _isEditMode =>
      widget.editWorkOrderId != null &&
      widget.editWorkOrderId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(workOrderDraftProvider);
      setState(() {
        _workOrderNumberController.text = draft.workOrderNumber;
        _enquiryNumberController.text = draft.enquiryNumber;
        _customerController.text = draft.customer;
        _remarksController.text = draft.remarks;
        _cargoTypeController.text = draft.cargoType;
        _quantityController.text = draft.quantity;
        _weightController.text = draft.weight;
        _loadTypeController.text = draft.loadType;
        _specialHandlingController.text = draft.specialHandlingNotes;
        _pickupController.text = draft.pickupLocation;
        _deliveryController.text = draft.deliveryLocation;
        _stopPointsController.text = draft.stopPoints;
        _routeNotesController.text = draft.routeNotes;
        _specialDocumentsController.text = draft.specialCustomerDocuments;
        _priority = draft.priority;
        _requestedDate = draft.requestedDate;
        _plannedDispatchDate = draft.plannedDispatchDate;
        _plannedDeliveryDate = draft.plannedDeliveryDate;
        _podRequired = draft.podRequired;
        _dnRequired = draft.dnRequired;
        _journeyPlanId = draft.journeyPlanId;
        if (_isEditMode && _workOrderNumberController.text.trim().isEmpty) {
          _workOrderNumberController.text = widget.editWorkOrderId!.trim();
        }
      });
    });
  }

  @override
  void dispose() {
    _workOrderNumberController.dispose();
    _enquiryNumberController.dispose();
    _customerController.dispose();
    _remarksController.dispose();
    _cargoTypeController.dispose();
    _quantityController.dispose();
    _weightController.dispose();
    _loadTypeController.dispose();
    _specialHandlingController.dispose();
    _pickupController.dispose();
    _deliveryController.dispose();
    _stopPointsController.dispose();
    _routeNotesController.dispose();
    _specialDocumentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journeyState = ref.watch(journeyPlanViewModelProvider);
    final logisticsState = ref.watch(logisticsViewModelProvider);
    final vendorState = ref.watch(vendorViewModelProvider);

    _tryPopulateEditValues(logisticsState);

    return OpsShell(
      title: _isEditMode ? 'Edit Work Order' : 'Create Work Order',
      currentRoute: RoutePaths.workOrders,
      child: journeyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load route plans: $error')),
        data: (planState) {
          final plans = planState.items;
          final selectedPlan = _findPlan(plans, _journeyPlanId);
          final activeVendors = vendorState.valueOrNull?.vendors
                  .where(
                    (vendor) =>
                        vendor.status == VendorStatus.active &&
                        vendor.serviceType == _vendorServiceType,
                  )
                  .toList() ??
              const [];
          if (_vendorId != null &&
              !activeVendors.any((vendor) => vendor.vendorId == _vendorId)) {
            _vendorId = null;
          }

          return Form(
            key: _formKey,
            child: ListView(
              children: [
                _SectionCard(
                  title: 'A. Basic Details',
                  child: Column(
                    children: [
                      _threeColumnFields(
                        context,
                        _requiredField(
                          controller: _workOrderNumberController,
                          label: 'Work Order Number',
                          readOnly: _isEditMode,
                        ),
                        _requiredField(
                          controller: _enquiryNumberController,
                          label: 'Enquiry Number',
                        ),
                        _requiredField(
                          controller: _customerController,
                          label: 'Customer',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _threeColumnFields(
                        context,
                        DropdownButtonFormField<WorkOrderPriority>(
                          value: _priority,
                          decoration:
                              const InputDecoration(labelText: 'Priority'),
                          items: [
                            for (final value in WorkOrderPriority.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: _journeyPlanId,
                          decoration: const InputDecoration(
                            labelText: 'Route Template (Optional)',
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('None')),
                            for (final plan in plans)
                              DropdownMenuItem(
                                value: plan.id,
                                child: Text(
                                  '${plan.planName} (${plan.origin} -> ${plan.destination})',
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _journeyPlanId = value),
                        ),
                        const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Remarks'),
                      ),
                      if (selectedPlan != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.35),
                          ),
                          child: Text(
                            'Template Estimate: ${selectedPlan.distance.toStringAsFixed(1)} km, '
                            '${selectedPlan.estimatedTime.toStringAsFixed(1)} hrs\n'
                            'Stops: ${selectedPlan.stops.isEmpty ? 'None' : selectedPlan.stops.join(', ')}',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'B. Cargo Details',
                  child: Column(
                    children: [
                      _threeColumnFields(
                        context,
                        _requiredField(
                            controller: _cargoTypeController,
                            label: 'Cargo Type'),
                        TextFormField(
                          controller: _quantityController,
                          decoration:
                              const InputDecoration(labelText: 'Quantity'),
                        ),
                        TextFormField(
                          controller: _weightController,
                          decoration:
                              const InputDecoration(labelText: 'Weight'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _threeColumnFields(
                        context,
                        TextFormField(
                          controller: _loadTypeController,
                          decoration:
                              const InputDecoration(labelText: 'Load Type'),
                          onChanged: (value) {
                            setState(() {
                              _vendorServiceType = _inferServiceType(value);
                              _vendorId = null;
                            });
                          },
                        ),
                        TextFormField(
                          controller: _specialHandlingController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Special Handling Notes',
                          ),
                        ),
                        const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'C. Route Details',
                  child: Column(
                    children: [
                      _threeColumnFields(
                        context,
                        _requiredField(
                          controller: _pickupController,
                          label: 'Pickup Location',
                        ),
                        _requiredField(
                          controller: _deliveryController,
                          label: 'Delivery Location',
                        ),
                        TextFormField(
                          controller: _stopPointsController,
                          decoration: const InputDecoration(
                            labelText: 'Intermediate Stop Points',
                            hintText: 'Comma-separated',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _routeNotesController,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(labelText: 'Route Notes'),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'D. Schedule',
                  child: _threeColumnFields(
                    context,
                    _DateField(
                      label: 'Requested Date',
                      value: _requestedDate,
                      onTap: () =>
                          _pickDate((v) => setState(() => _requestedDate = v)),
                    ),
                    _DateField(
                      label: 'Planned Dispatch Date',
                      value: _plannedDispatchDate,
                      onTap: () => _pickDate(
                          (v) => setState(() => _plannedDispatchDate = v)),
                    ),
                    _DateField(
                      label: 'Planned Delivery Date',
                      value: _plannedDeliveryDate,
                      onTap: () => _pickDate(
                          (v) => setState(() => _plannedDeliveryDate = v)),
                    ),
                  ),
                ),
                _SectionCard(
                  title: 'E. Required Documents',
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: [
                          FilterChip(
                            selected: _podRequired,
                            label: const Text('POD Required'),
                            onSelected: (value) =>
                                setState(() => _podRequired = value),
                          ),
                          FilterChip(
                            selected: _dnRequired,
                            label: const Text('DN Required'),
                            onSelected: (value) =>
                                setState(() => _dnRequired = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _specialDocumentsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Special Customer Documents',
                        ),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'G. Vendor Assignment',
                  child: Column(
                    children: [
                      _threeColumnFields(
                        context,
                        DropdownButtonFormField<VendorServiceType>(
                          value: _vendorServiceType,
                          decoration:
                              const InputDecoration(labelText: 'Service Type'),
                          items: [
                            for (final item in VendorServiceType.values)
                              DropdownMenuItem(
                                value: item,
                                child: Text(item.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _vendorServiceType = value;
                              _vendorId = null;
                            });
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: _vendorId,
                          decoration: const InputDecoration(
                            labelText: 'Vendor (Active only)',
                          ),
                          items: [
                            for (final vendor in activeVendors)
                              DropdownMenuItem(
                                value: vendor.vendorId,
                                child: Text(vendor.vendorName),
                              ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          onChanged: activeVendors.isEmpty
                              ? null
                              : (value) => setState(() => _vendorId = value),
                        ),
                        TextFormField(
                          initialValue:
                              'Vehicle & Driver mapping in next module',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Mapping Status',
                          ),
                        ),
                      ),
                      if (activeVendors.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No active vendors for selected service type.',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'F. Attachments',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _placeholder(
                            'File upload will be integrated with DMS.'),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Upload File (Placeholder)'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _placeholder(
                            'Image attachment pipeline pending API hookup.'),
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Attach Image'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _placeholder(
                            'Video upload will be enabled in media service.'),
                        icon: const Icon(Icons.videocam_outlined),
                        label: const Text('Attach Video (Placeholder)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saveDraft,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Draft'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () => _submit(plans),
                      icon: Icon(
                        _isEditMode ? Icons.save_outlined : Icons.send_outlined,
                      ),
                      label: Text(_isEditMode ? 'Update' : 'Submit'),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _tryPopulateEditValues(AsyncValue<LogisticsUiState> logisticsState) {
    if (!_isEditMode || _didPopulateEditValues) {
      return;
    }

    final data = logisticsState.valueOrNull;
    if (data == null) {
      return;
    }

    final editId = widget.editWorkOrderId!.trim();
    WorkOrderFlowItem? source;
    for (final item in data.workOrders) {
      if (item.woId.trim().toLowerCase() == editId.toLowerCase()) {
        source = item;
        break;
      }
    }

    _didPopulateEditValues = true;

    if (source == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _placeholder('Work order $editId was not found for edit auto-fill.');
      });
      return;
    }

    final order = source;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _workOrderNumberController.text = order.woId;
        _enquiryNumberController.text = order.linkedEnquiryNumber.isNotEmpty
            ? order.linkedEnquiryNumber
            : order.linkedQuotationRef;
        _customerController.text = order.customer;
        _cargoTypeController.text = order.cargo;
        _remarksController.text = order.internalNotes;
        _routeNotesController.text = order.route;
        _pickupController.text = _routeOrigin(order.route);
        _deliveryController.text = _routeDestination(order.route);
        _requestedDate = _parseIsoDate(order.serviceStartDate);
        _plannedDispatchDate = _parseIsoDate(order.serviceStartDate);
        _plannedDeliveryDate = _parseIsoDate(order.serviceEndDate);
      });
    });
  }

  DateTime? _parseIsoDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  String _routeOrigin(String route) {
    final parts = route.split('->');
    if (parts.isEmpty) {
      return route.trim();
    }
    return parts.first.trim();
  }

  String _routeDestination(String route) {
    final parts = route.split('->');
    if (parts.length < 2) {
      return route.trim();
    }
    return parts.last.trim();
  }

  Widget _threeColumnFields(
      BuildContext context, Widget a, Widget b, Widget c) {
    final isSmall = MediaQuery.of(context).size.width < 1100;
    if (isSmall) {
      return Column(
        children: [
          a,
          const SizedBox(height: 12),
          b,
          const SizedBox(height: 12),
          c,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
        const SizedBox(width: 12),
        Expanded(child: c),
      ],
    );
  }

  TextFormField _requiredField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  JourneyPlan? _findPlan(List<JourneyPlan> plans, String? planId) {
    if (planId == null) {
      return null;
    }
    for (final plan in plans) {
      if (plan.id == planId) {
        return plan;
      }
    }
    return null;
  }

  Future<void> _pickDate(ValueChanged<DateTime> onSelect) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
      initialDate: now,
    );
    if (date != null) {
      onSelect(date);
    }
  }

  Future<void> _saveDraft() async {
    final draft = WorkOrderDraft(
      workOrderNumber: _workOrderNumberController.text.trim(),
      enquiryNumber: _enquiryNumberController.text.trim(),
      customer: _customerController.text.trim(),
      remarks: _remarksController.text.trim(),
      cargoType: _cargoTypeController.text.trim(),
      quantity: _quantityController.text.trim(),
      weight: _weightController.text.trim(),
      loadType: _loadTypeController.text.trim(),
      specialHandlingNotes: _specialHandlingController.text.trim(),
      pickupLocation: _pickupController.text.trim(),
      deliveryLocation: _deliveryController.text.trim(),
      stopPoints: _stopPointsController.text.trim(),
      routeNotes: _routeNotesController.text.trim(),
      requestedDate: _requestedDate,
      plannedDispatchDate: _plannedDispatchDate,
      plannedDeliveryDate: _plannedDeliveryDate,
      podRequired: _podRequired,
      dnRequired: _dnRequired,
      specialCustomerDocuments: _specialDocumentsController.text.trim(),
      title:
          '${_workOrderNumberController.text.trim()} ${_customerController.text.trim()}'
              .trim(),
      vehicleId: '',
      journeyPlanId: _journeyPlanId,
      priority: _priority,
    );

    await ref.read(workOrderDraftProvider.notifier).saveDraft(draft);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved successfully.')),
    );
  }

  Future<void> _submit(List<JourneyPlan> plans) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_plannedDispatchDate != null &&
        _plannedDeliveryDate != null &&
        _plannedDeliveryDate!.isBefore(_plannedDispatchDate!)) {
      _placeholder('Planned delivery date cannot be before dispatch date.');
      return;
    }

    final selectedPlan = _findPlan(plans, _journeyPlanId);
    if (selectedPlan != null) {
      ref.read(workOrdersViewModelProvider.notifier).createOrderFromJourneyPlan(
            plan: selectedPlan,
            vehicleId: 'TBD',
            title:
                '${_workOrderNumberController.text.trim()} • ${_customerController.text.trim()}',
            priority: _priority,
          );
    }

    await ref.read(workOrderDraftProvider.notifier).clearDraft();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Work order updated successfully.'
              : selectedPlan == null
                  ? 'Work order submitted. Route template can be mapped later.'
                  : 'Work order submitted from template ${selectedPlan.planName}.',
        ),
      ),
    );
    context.go(RoutePaths.workOrders);
  }

  void _placeholder(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  VendorServiceType _inferServiceType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'pdo') {
      return VendorServiceType.pdo;
    }
    return VendorServiceType.nonPdo;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
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
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
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
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}
