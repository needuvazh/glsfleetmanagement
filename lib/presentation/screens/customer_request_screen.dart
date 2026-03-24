import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../../domain/entities/logistics_flow.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestScreen extends ConsumerStatefulWidget {
  const CustomerRequestScreen({super.key});

  @override
  ConsumerState<CustomerRequestScreen> createState() =>
      _CustomerRequestScreenState();
}

class _CustomerRequestScreenState extends ConsumerState<CustomerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _distanceController = TextEditingController();
  final _weightVolumeController = TextEditingController();
  final _remarksController = TextEditingController();

  final List<TextEditingController> _pickupControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _dropControllers = [
    TextEditingController(),
  ];

  DateTime _requestDate = DateTime.now();
  DateTime? _requiredDate;
  String? _selectedCustomer;
  String _cargoType = 'General';
  String _loadType = 'NON-PDO';

  int _requestCounter = 1;
  List<_CreatedRequest> _createdRequests = [];

  @override
  void dispose() {
    _contactController.dispose();
    _distanceController.dispose();
    _weightVolumeController.dispose();
    _remarksController.dispose();
    for (final controller in _pickupControllers) {
      controller.dispose();
    }
    for (final controller in _dropControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Customer Request',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.feasibilityQuotation),
          child: const Text('Next'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final customers = {
            for (final item in data.customerRequests) item.customerName,
            'PDO',
            'OQ',
            'Oman LNG',
            'Vale Oman',
          }.toList()
            ..sort();
          _selectedCustomer ??= customers.isEmpty ? null : customers.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 0),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Create Request',
                subtitle:
                    'Capture transport enquiry for feasibility and quotation',
                icon: Icons.request_page_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: _nextRequestNumber,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Request Number'),
                      ),
                      const SizedBox(height: 10),
                      _dateTile(
                        label: 'Request Date',
                        value: _requestDate,
                        onPick: (value) => setState(() => _requestDate = value),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCustomer,
                        decoration:
                            const InputDecoration(labelText: 'Customer Name'),
                        items: [
                          for (final customer in customers)
                            DropdownMenuItem(
                              value: customer,
                              child: Text(customer),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedCustomer = value),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _contactController,
                        decoration:
                            const InputDecoration(labelText: 'Customer Contact'),
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _cargoType,
                        decoration:
                            const InputDecoration(labelText: 'Cargo Type'),
                        items: const [
                          DropdownMenuItem(
                            value: 'General',
                            child: Text('General'),
                          ),
                          DropdownMenuItem(
                            value: 'Equipment',
                            child: Text('Equipment'),
                          ),
                          DropdownMenuItem(
                            value: 'Hazardous',
                            child: Text('Hazardous'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _cargoType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _loadType,
                        decoration: const InputDecoration(labelText: 'Load Type'),
                        items: const [
                          DropdownMenuItem(value: 'PDO', child: Text('PDO')),
                          DropdownMenuItem(
                            value: 'NON-PDO',
                            child: Text('NON-PDO'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _loadType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _locationSection(
                        title: 'Pickup Locations',
                        controllers: _pickupControllers,
                        onAdd: () => setState(
                          () => _pickupControllers.add(TextEditingController()),
                        ),
                        onRemove: (index) => setState(() {
                          final controller = _pickupControllers.removeAt(index);
                          controller.dispose();
                        }),
                      ),
                      const SizedBox(height: 10),
                      _locationSection(
                        title: 'Drop Locations',
                        controllers: _dropControllers,
                        onAdd: () => setState(
                          () => _dropControllers.add(TextEditingController()),
                        ),
                        onRemove: (index) => setState(() {
                          final controller = _dropControllers.removeAt(index);
                          controller.dispose();
                        }),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _distanceController,
                              decoration: const InputDecoration(
                                labelText: 'Total Distance (km)',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: _required,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _autoFillDistance,
                            child: const Text('Auto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _weightVolumeController,
                        decoration:
                            const InputDecoration(labelText: 'Weight / Volume'),
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      _dateTile(
                        label: 'Required Date',
                        value: _requiredDate,
                        onPick: (value) => setState(() => _requiredDate = value),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Remarks'),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => _saveRequest('Draft'),
                              child: const Text('Save Draft'),
                            ),
                            FilledButton(
                              onPressed: () => _saveRequest('Submitted'),
                              child: const Text('Send to Feasibility'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Created Requests',
                subtitle: 'Current session requests and status',
                icon: Icons.list_alt_outlined,
                accent: const Color(0xFF16A34A),
                child: _createdRequests.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('No requests created yet.'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                          columns: const [
                            DataColumn(label: Text('Request No')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Customer')),
                            DataColumn(label: Text('Load Type')),
                            DataColumn(label: Text('Distance')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: [
                            for (final item in _createdRequests)
                              DataRow(
                                cells: [
                                  DataCell(Text(item.requestNo)),
                                  DataCell(Text(item.requestDate)),
                                  DataCell(Text(item.customerName)),
                                  DataCell(Text(item.loadType)),
                                  DataCell(Text(item.distance)),
                                  DataCell(Text(item.status)),
                                ],
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Recent Requests',
                subtitle: 'Loaded from mock customer request JSON',
                icon: Icons.history_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in data.customerRequests)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.customerName),
                        subtitle: Text('${item.pickup} -> ${item.delivery}'),
                        trailing: Text(item.date),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _locationSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required void Function(int index) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (int i = 0; i < controllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[i],
                    decoration: InputDecoration(labelText: '$title ${i + 1}'),
                    validator: _required,
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    onPressed: () => onRemove(i),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
    required DateTime firstDate,
    required DateTime lastDate,
    bool requiredField = false,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDate: value ?? DateTime.now(),
        );
        if (selected != null) {
          onPick(selected);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: requiredField && value == null ? 'Required' : null,
          suffixIcon: const Icon(Icons.date_range_outlined),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  String get _nextRequestNumber => 'REQ-${_requestCounter.toString().padLeft(4, '0')}';

  void _autoFillDistance() {
    final pickupCount = _pickupControllers.length;
    final dropCount = _dropControllers.length;
    final estimated = ((pickupCount + dropCount) * 25).toString();
    setState(() => _distanceController.text = estimated);
  }

  void _saveRequest(String status) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_requiredDate == null) {
      setState(() {});
      return;
    }

    final request = _CreatedRequest(
      requestNo: _nextRequestNumber,
      requestDate: _formatDate(_requestDate),
      customerName: _selectedCustomer ?? '',
      loadType: _loadType,
      distance: _distanceController.text.trim(),
      status: status,
    );

    final pickupJoined =
        _pickupControllers.map((item) => item.text.trim()).join(' -> ');
    final dropJoined =
        _dropControllers.map((item) => item.text.trim()).join(' -> ');

    ref.read(logisticsViewModelProvider.notifier).addCustomerRequest(
          CustomerRequestData(
            customerName: _selectedCustomer ?? '',
            contact: _contactController.text.trim(),
            cargoType: _cargoType,
            weightVolume: _weightVolumeController.text.trim(),
            pickup: pickupJoined,
            delivery: dropJoined,
            date: _formatDate(_requestDate),
          ),
        );

    setState(() {
      _createdRequests = [request, ..._createdRequests];
      _requestCounter += 1;
      _resetForm();
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request ${request.requestNo} saved as $status')),
    );

    if (status == 'Submitted') {
      context.go(RoutePaths.feasibilityQuotation);
    }
  }

  void _resetForm() {
    _contactController.clear();
    _distanceController.clear();
    _weightVolumeController.clear();
    _remarksController.clear();
    _requestDate = DateTime.now();
    _requiredDate = null;
    for (final controller in _pickupControllers) {
      controller.dispose();
    }
    for (final controller in _dropControllers) {
      controller.dispose();
    }
    _pickupControllers
      ..clear()
      ..add(TextEditingController());
    _dropControllers
      ..clear()
      ..add(TextEditingController());
    _cargoType = 'General';
    _loadType = 'NON-PDO';
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _CreatedRequest {
  const _CreatedRequest({
    required this.requestNo,
    required this.requestDate,
    required this.customerName,
    required this.loadType,
    required this.distance,
    required this.status,
  });

  final String requestNo;
  final String requestDate;
  final String customerName;
  final String loadType;
  final String distance;
  final String status;
}
