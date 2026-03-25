import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/vehicle_type.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/access_control_viewmodel.dart';
import '../viewmodels/vehicle_type_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class TransportManagementScreen extends ConsumerStatefulWidget {
  const TransportManagementScreen({super.key});

  @override
  ConsumerState<TransportManagementScreen> createState() =>
      _TransportManagementScreenState();
}

class _TransportManagementScreenState
    extends ConsumerState<TransportManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  static const _ownershipTypes = ['Company Owned', 'Vendor Owned'];
  static const _fuelTypes = ['Diesel'];
  static const _statusOptions = ['Active', 'Inactive'];
  static const _availabilityOptions = ['Available', 'In Use', 'Maintenance'];

  String? _selectedVehicleType;
  String? _selectedOwnershipType;
  String? _selectedFuelType;
  String? _selectedStatus;
  String? _selectedAvailability;
  String _autoVehicleCategory = '';
  String _autoVehicleClass = '';
  String _autoCapacityUnit = 'KG';
  List<_VehicleDocumentFormRow> _documentRows = [];
  String _selectedVehicleLoadType = 'NON-PDO';

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _vehicleNameController.dispose();
    _vendorNameController.dispose();
    _capacityController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _disposeDocumentRows();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessControlProvider);
    final vehicleTypeState = ref.watch(vehicleTypeViewModelProvider);
    final vehicleTypeItems = vehicleTypeState.valueOrNull?.items ?? const [];

    if (_selectedVehicleType != null) {
      final exists =
          vehicleTypeItems.any((item) => item.name == _selectedVehicleType);
      if (!exists) {
        _selectedVehicleType = null;
      }
    }
    if (_selectedVehicleType == null && vehicleTypeItems.isNotEmpty) {
      _selectVehicleType(vehicleTypeItems.first);
    }

    _selectedOwnershipType ??= _ownershipTypes.first;
    _selectedFuelType ??= _fuelTypes.first;
    _selectedStatus ??= _statusOptions.first;
    _selectedAvailability ??= _availabilityOptions.first;

    VehicleType? selectedType;
    for (final item in vehicleTypeItems) {
      if (item.name == _selectedVehicleType) {
        selectedType = item;
        break;
      }
    }
    final hasPdoWarning = _selectedVehicleLoadType == 'PDO' &&
        _documentRows.any((row) => row.mandatory && _computeStatus(row) != 'Valid');

    return OpsShell(
      title: 'Vehicle Master Module',
      currentRoute: RoutePaths.transportManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.vehicleTypes),
          child: const Text('Vehicle Types'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OpsSectionCard(
            title: 'Create Vehicle',
            subtitle: 'Maintain real vehicle details and dynamic documents',
            icon: Icons.local_shipping_outlined,
            accent: const Color(0xFF2563EB),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Basic Details'),
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Number',
                      hintText: 'e.g. 8603 BK',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _vehicleNameController,
                    decoration: const InputDecoration(labelText: 'Vehicle Name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    decoration: const InputDecoration(labelText: 'Vehicle Type'),
                    items: [
                      for (final type in vehicleTypeItems)
                        DropdownMenuItem(
                          value: type.name,
                          child: Text('${type.name} (${type.code})'),
                        ),
                    ],
                    onChanged: vehicleTypeItems.isEmpty
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            final selected = vehicleTypeItems.firstWhere(
                              (item) => item.name == value,
                            );
                            setState(() => _selectVehicleType(selected));
                          },
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey('cat-$_autoVehicleCategory'),
                    initialValue: _autoVehicleCategory,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Vehicle Category'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey('class-$_autoVehicleClass'),
                    initialValue: _autoVehicleClass,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Vehicle Class'),
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle(context, 'Ownership'),
                  DropdownButtonFormField<String>(
                    value: _selectedOwnershipType,
                    decoration: const InputDecoration(labelText: 'Ownership Type'),
                    items: [
                      for (final item in _ownershipTypes)
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedOwnershipType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _vendorNameController,
                    decoration: const InputDecoration(labelText: 'Vendor Name'),
                    validator: (value) {
                      if (_selectedOwnershipType == 'Vendor Owned' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Vendor name required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle(context, 'Technical Details'),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _capacityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Capacity'),
                          validator: _positiveDecimal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: ValueKey('unit-$_autoCapacityUnit'),
                          initialValue: _autoCapacityUnit,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Unit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedFuelType,
                    decoration: const InputDecoration(labelText: 'Fuel Type'),
                    items: [
                      for (final item in _fuelTypes)
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedFuelType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(labelText: 'Manufacturer'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year'),
                    validator: _yearValidator,
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle(context, 'Status'),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final item in _statusOptions)
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedAvailability,
                    decoration:
                        const InputDecoration(labelText: 'Availability Status'),
                    items: [
                      for (final item in _availabilityOptions)
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedAvailability = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle(context, 'Vehicle Documents'),
                  if (_documentRows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Select a Vehicle Type to auto-load required documents.',
                      ),
                    ),
                  for (int i = 0; i < _documentRows.length; i++)
                    _documentRowCard(_documentRows[i], i),
                  if (hasPdoWarning)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4F4),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Vehicle not compliant for PDO'),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: selectedType == null
                          ? null
                          : () => _submit(context, selectedType!),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Vehicle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Vehicle List',
            subtitle: 'Vehicles with compliance and document status',
            icon: Icons.table_chart_outlined,
            accent: const Color(0xFF16A34A),
            child: state.transports.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('No vehicles created yet.'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                      columns: const [
                        DataColumn(label: Text('Vehicle Number')),
                        DataColumn(label: Text('Vehicle Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Ownership')),
                        DataColumn(label: Text('Vendor')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Availability')),
                        DataColumn(label: Text('PDO Compliant')),
                        DataColumn(label: Text('Documents')),
                      ],
                      rows: [
                        for (final item in state.transports)
                          DataRow(
                            cells: [
                              DataCell(Text(item.vehicleNumber)),
                              DataCell(Text(item.vehicleName)),
                              DataCell(Text(item.vehicleType)),
                              DataCell(Text(item.vehicleCategory)),
                              DataCell(Text(item.vehicleClass)),
                              DataCell(Text(item.ownershipType)),
                              DataCell(Text(item.vendorName.isEmpty
                                  ? '-'
                                  : item.vendorName)),
                              DataCell(Text(item.status)),
                              DataCell(Text(item.availabilityStatus)),
                              DataCell(Text(item.pdoCompliant ? 'Yes' : 'No')),
                              DataCell(Text('${item.documents.length}')),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _documentRowCard(_VehicleDocumentFormRow row, int index) {
    final status = _computeStatus(row);
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE6F7)),
        color: const Color(0xFFF8FAFC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${row.documentName}${row.mandatory ? ' *' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row.documentNumberController,
            decoration: const InputDecoration(labelText: 'Document Number'),
            validator: (value) {
              if (row.mandatory && (value == null || value.trim().isEmpty)) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _dateField(
                  controller: row.issueDateController,
                  label: 'Issue Date',
                  requiredField: row.mandatory,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dateField(
                  controller: row.expiryDateController,
                  label: 'Expiry Date',
                  requiredField: row.mandatory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row.uploadFileController,
            decoration: const InputDecoration(labelText: 'Upload File (Mock)'),
          ),
        ],
      ),
    );
  }

  void _selectVehicleType(VehicleType selected) {
    _selectedVehicleType = selected.name;
    _selectedVehicleLoadType = selected.loadType;
    _autoVehicleCategory = selected.category;
    _autoVehicleClass = selected.vehicleClass;
    _autoCapacityUnit = selected.capacityUnit;
    _capacityController.text = selected.defaultCapacity.toStringAsFixed(0);
    _buildDocumentRowsFromTemplate(selected.documentRequirements);
  }

  void _buildDocumentRowsFromTemplate(
    List<VehicleTypeDocumentRequirement> template,
  ) {
    _disposeDocumentRows();
    _documentRows = [
      for (final doc in template)
        _VehicleDocumentFormRow(
          documentName: doc.documentName,
          mandatory: doc.mandatory,
        ),
    ];
  }

  void _disposeDocumentRows() {
    for (final row in _documentRows) {
      row.dispose();
    }
    _documentRows = [];
  }

  String _computeStatus(_VehicleDocumentFormRow row) {
    final expiry = DateTime.tryParse(row.expiryDateController.text.trim());
    if (expiry == null) {
      return row.mandatory ? 'Expired' : 'Valid';
    }
    final today = DateTime.now();
    final diff = expiry.difference(today).inDays;
    if (diff < 0) {
      return 'Expired';
    }
    if (diff <= 30) {
      return 'Expiring Soon';
    }
    return 'Valid';
  }

  Color _statusColor(String status) {
    if (status == 'Expired') {
      return const Color(0xFFDC2626);
    }
    if (status == 'Expiring Soon') {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF16A34A);
  }

  Future<void> _submit(BuildContext context, VehicleType selectedType) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final documents = [
      for (final row in _documentRows)
        VehicleDocumentItem(
          documentName: row.documentName,
          mandatory: row.mandatory,
          documentNumber: row.documentNumberController.text,
          issueDate: row.issueDateController.text,
          expiryDate: row.expiryDateController.text,
          uploadFile: row.uploadFileController.text,
          status: _computeStatus(row) == 'Valid' ? 'Valid' : 'Expired',
        ),
    ];

    final message = ref.read(accessControlProvider.notifier).addTransport(
          vehicleNumber: _vehicleNumberController.text,
          vehicleName: _vehicleNameController.text,
          vehicleClass: _autoVehicleClass,
          vehicleCategory: _autoVehicleCategory,
          vehicleType: _selectedVehicleType ?? '',
          ownershipType: _selectedOwnershipType ?? '',
          vendorName: _vendorNameController.text,
          capacity: double.parse(_capacityController.text.trim()),
          capacityUnit: _autoCapacityUnit,
          fuelType: _selectedFuelType ?? 'Diesel',
          manufacturer: _manufacturerController.text,
          model: _modelController.text,
          yearOfManufacture: int.parse(_yearController.text.trim()),
          status: _selectedStatus ?? '',
          availabilityStatus: _selectedAvailability ?? '',
          isPdoVehicleType: selectedType.loadType == 'PDO',
          documents: documents,
        );

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (message.startsWith('Vehicle created')) {
      _vehicleNumberController.clear();
      _vehicleNameController.clear();
      _vendorNameController.clear();
      _manufacturerController.clear();
      _modelController.clear();
      _yearController.clear();
      if (_selectedVehicleType != null) {
        _selectVehicleType(selectedType);
      } else {
        _capacityController.clear();
      }
      setState(() {});
    }
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveDecimal(String? value) {
    final raw = value?.trim() ?? '';
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      return 'Enter valid number';
    }
    return null;
  }

  String? _yearValidator(String? value) {
    final raw = value?.trim() ?? '';
    final parsed = int.tryParse(raw);
    final currentYear = DateTime.now().year;
    if (parsed == null || parsed < 1980 || parsed > currentYear + 1) {
      return 'Enter valid year';
    }
    return null;
  }

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required bool requiredField,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (!requiredField && (value == null || value.trim().isEmpty)) {
          return null;
        }
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) {
          return 'YYYY-MM-DD';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }
}

class _VehicleDocumentFormRow {
  _VehicleDocumentFormRow({
    required this.documentName,
    required this.mandatory,
  })  : documentNumberController = TextEditingController(),
        issueDateController = TextEditingController(),
        expiryDateController = TextEditingController(),
        uploadFileController = TextEditingController();

  final String documentName;
  final bool mandatory;
  final TextEditingController documentNumberController;
  final TextEditingController issueDateController;
  final TextEditingController expiryDateController;
  final TextEditingController uploadFileController;

  void dispose() {
    documentNumberController.dispose();
    issueDateController.dispose();
    expiryDateController.dispose();
    uploadFileController.dispose();
  }
}
