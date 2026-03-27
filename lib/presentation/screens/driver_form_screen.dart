import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/oman_fleet_master.dart';
import '../../domain/route_model.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../viewmodels/vehicle_type_master_viewmodel.dart';
import '../widgets/ops_shell.dart';

class DriverFormScreen extends ConsumerStatefulWidget {
  const DriverFormScreen({super.key, this.editDriverId});

  final String? editDriverId;

  @override
  ConsumerState<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends ConsumerState<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _employeeCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _licenseCtrl;
  late final TextEditingController _licenseTypeCtrl;
  late final TextEditingController _licenseIssueCtrl;
  late final TextEditingController _expiryCtrl;
  late final TextEditingController _nationalityCtrl;
  late final TextEditingController _certCtrl;
  late final TextEditingController _notesCtrl;
  final ScrollController _docsHorizontalController = ScrollController();
  final List<_DriverUploadRow> _uploadRows = [];

  bool _initialized = false;
  bool _saving = false;

  String _availability = 'Available';
  String _baseLocation = OmanFleetMaster.omanLocations.first;
  bool _heavyAllowed = false;
  bool _active = true;
  List<String> _selectedAllowedVehicleTypes = [];
  List<String> _selectedPreferredRoutes = [];
  List<String> _selectedPreferredVehicleTypes = [];

  DriverData? _existingDriver(AsyncValue<LogisticsUiState> state) {
    final editId = widget.editDriverId;
    if (editId == null || editId.trim().isEmpty) {
      return null;
    }
    final drivers = state.valueOrNull?.drivers ?? const <DriverData>[];
    for (final d in drivers) {
      if (d.driverId == editId) {
        return d;
      }
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final state = ref.read(logisticsViewModelProvider);
    final existing = _existingDriver(state);
    _codeCtrl = TextEditingController(text: existing?.driverId ?? '');
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _employeeCtrl = TextEditingController(text: existing?.employeeRef ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _licenseCtrl = TextEditingController(text: existing?.licenseNo ?? '');
    _licenseTypeCtrl =
        TextEditingController(text: existing?.licenseType ?? 'Light Vehicle');
    _licenseIssueCtrl =
        TextEditingController(text: existing?.licenseIssueDate ?? '');
    _expiryCtrl = TextEditingController(text: existing?.expiryDate ?? '');
    _nationalityCtrl =
        TextEditingController(text: existing?.nationality ?? 'Omani');
    _certCtrl = TextEditingController(
      text: existing?.certifications.join(', ') ?? '',
    );
    _notesCtrl = TextEditingController(text: existing?.specialSkillsNotes ?? '');
    _selectedAllowedVehicleTypes = [...(existing?.allowedVehicleTypes ?? const [])];
    _selectedPreferredRoutes = _csv(existing?.preferredRouteType ?? '');
    _selectedPreferredVehicleTypes = _csv(existing?.preferredVehicleType ?? '');

    _availability = existing?.status ?? 'Available';
    _baseLocation =
        existing?.baseLocation ?? OmanFleetMaster.omanLocations.first;
    _heavyAllowed = existing?.heavyVehicleAllowed ?? false;
    _active = existing?.active ?? true;
    _initialized = true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _employeeCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    _licenseTypeCtrl.dispose();
    _licenseIssueCtrl.dispose();
    _expiryCtrl.dispose();
    _nationalityCtrl.dispose();
    _certCtrl.dispose();
    _notesCtrl.dispose();
    _docsHorizontalController.dispose();
    for (final row in _uploadRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final routeState = ref.watch(routeViewModelProvider).valueOrNull;
    final vehicleTypeState =
        ref.watch(vehicleTypeMasterViewModelProvider).valueOrNull;
    final complianceState = ref.watch(moduleDocumentViewModelProvider).valueOrNull;
    final authState = ref.watch(authViewModelProvider).valueOrNull;
    final isEdit = widget.editDriverId != null;
    final existing = _existingDriver(state);
    final roleName = (authState?.userRole ?? '').toLowerCase();
    final isComplianceRole =
        roleName.contains('admin') || roleName.contains('compliance');

    final driverRules = (complianceState?.items ?? const [])
        .where(
          (item) =>
              item.applicableTo.toLowerCase() == 'driver' &&
              item.status.toLowerCase() == 'active',
        )
        .toList();
    final visibleRules = isComplianceRole
        ? driverRules
        : driverRules.where((item) => item.mandatory).toList();
    final fileTypeOptions = visibleRules
        .map((item) => item.documentName.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final mandatoryByType = <String, bool>{
      for (final item in driverRules) item.documentName.trim(): item.mandatory,
    };
    final routeOptions = _withSelections(
      _routeOptions(routeState?.routes ?? const []),
      _selectedPreferredRoutes,
    );
    final vehicleTypeOptions = _withSelections(
      _vehicleTypeOptions(vehicleTypeState?.items ?? const []),
      [..._selectedAllowedVehicleTypes, ..._selectedPreferredVehicleTypes],
    );

    _syncUploadRowsWithOptions(
      fileTypeOptions: fileTypeOptions,
      existing: existing,
      mandatoryByType: mandatoryByType,
    );

    if (isEdit && existing == null && state.valueOrNull != null) {
      return const OpsShell(
        title: 'Edit Driver',
        currentRoute: RoutePaths.driverManagement,
        child: Center(child: Text('Driver not found.')),
      );
    }

    return OpsShell(
      title: isEdit ? 'Edit Driver' : 'Create Driver',
      currentRoute: RoutePaths.driverManagement,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Driver Identity'),
                    _field(
                      _codeCtrl,
                      label: 'Driver Code',
                      enabled: !isEdit,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _nameCtrl,
                      label: 'Full Name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Driver name is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _field(_employeeCtrl, label: 'Employee ID / Ref'),
                    const SizedBox(height: 10),
                    _field(_phoneCtrl, label: 'Mobile Number'),
                    const SizedBox(height: 10),
                    _field(_nationalityCtrl, label: 'Nationality'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _baseLocation,
                      decoration:
                          const InputDecoration(labelText: 'Base Location'),
                      items: [
                        for (final location in OmanFleetMaster.omanLocations)
                          DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _baseLocation = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('License'),
                    _field(
                      _licenseCtrl,
                      label: 'License Number',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'License number is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _licenseTypeCtrl,
                      label: 'License Type / Class',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'License class is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _licenseIssueCtrl,
                      label: 'License Issue Date (YYYY-MM-DD)',
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _expiryCtrl,
                      label: 'License Expiry Date (YYYY-MM-DD)',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'License expiry is required';
                        }
                        return DateTime.tryParse(v.trim()) == null
                            ? 'Use YYYY-MM-DD format'
                            : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _availability,
                      decoration:
                          const InputDecoration(labelText: 'Availability'),
                      items: const [
                        'Available',
                        'Assigned',
                        'On Leave',
                        'Resting / Off Duty',
                        'Suspended',
                        'Inactive',
                      ]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _availability = value);
                        }
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Heavy Vehicle Allowed'),
                      value: _heavyAllowed,
                      onChanged: (value) =>
                          setState(() => _heavyAllowed = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: _active,
                      onChanged: (value) => setState(() => _active = value),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Preferences'),
                    _multiSelectField(
                      label: 'Allowed Vehicle Types',
                      selectedValues: _selectedAllowedVehicleTypes,
                      options: vehicleTypeOptions,
                      onChanged: (values) {
                        setState(() => _selectedAllowedVehicleTypes = values);
                      },
                    ),
                    const SizedBox(height: 10),
                    _multiSelectField(
                      label: 'Preferred Route',
                      selectedValues: _selectedPreferredRoutes,
                      options: routeOptions,
                      onChanged: (values) {
                        setState(() => _selectedPreferredRoutes = values);
                      },
                    ),
                    const SizedBox(height: 10),
                    _multiSelectField(
                      label: 'Preferred Vehicle Type',
                      selectedValues: _selectedPreferredVehicleTypes,
                      options: vehicleTypeOptions,
                      onChanged: (values) {
                        setState(() => _selectedPreferredVehicleTypes = values);
                      },
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _certCtrl,
                      label: 'Certifications (comma separated)',
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _notesCtrl,
                      label: 'Notes',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Driver Documents Upload'),
                    _buildDocumentsUploader(
                      context: context,
                      fileTypeOptions: fileTypeOptions,
                      mandatoryByType: mandatoryByType,
                      isComplianceRole: isComplianceRole,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => context.go(RoutePaths.driverManagement),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _save(existing),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(isEdit ? 'Save Driver' : 'Create Driver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _field(
    TextEditingController controller, {
    required String label,
    bool enabled = true,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDocumentsUploader({
    required BuildContext context,
    required List<String> fileTypeOptions,
    required Map<String, bool> mandatoryByType,
    required bool isComplianceRole,
  }) {
    final canAddRows = fileTypeOptions.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2F0)),
        color: const Color(0xFFFAFCFF),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isComplianceRole
                      ? 'File types from Compliance Master (Driver - Active)'
                      : 'Role-based view: mandatory Driver documents from Compliance Master',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              FilledButton.icon(
                onPressed: canAddRows
                    ? () => setState(() {
                          _uploadRows.add(
                            _DriverUploadRow(
                              fileType: fileTypeOptions.first,
                              mandatory: mandatoryByType[fileTypeOptions.first] ??
                                  false,
                            ),
                          );
                        })
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Add File'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_uploadRows.isEmpty)
            const Text('No document rows yet. Click "Add File".')
          else
            Scrollbar(
              thumbVisibility: true,
              controller: _docsHorizontalController,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _docsHorizontalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  horizontalMargin: 10,
                  columnSpacing: 18,
                  headingRowHeight: 46,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('File Type')),
                    DataColumn(label: Text('Required')),
                    DataColumn(label: Text('File Name')),
                    DataColumn(label: Text('Uploaded At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (var i = 0; i < _uploadRows.length; i++)
                      _buildUploadRow(
                        index: i,
                        row: _uploadRows[i],
                        fileTypeOptions: fileTypeOptions,
                        mandatoryByType: mandatoryByType,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildUploadRow({
    required int index,
    required _DriverUploadRow row,
    required List<String> fileTypeOptions,
    required Map<String, bool> mandatoryByType,
  }) {
    final dropdownValue = fileTypeOptions.contains(row.fileType)
        ? row.fileType
        : (fileTypeOptions.isEmpty ? null : fileTypeOptions.first);

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              value: dropdownValue,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Type',
              ),
              items: [
                for (final item in fileTypeOptions)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: fileTypeOptions.isEmpty
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          row.fileType = value;
                          row.mandatory = mandatoryByType[value] ?? false;
                        });
                      }
                    },
            ),
          ),
        ),
        DataCell(Text(row.mandatory ? 'Yes' : 'No')),
        DataCell(
          SizedBox(
            width: 270,
            child: TextFormField(
              controller: row.fileNameController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'File name',
              ),
            ),
          ),
        ),
        DataCell(Text(row.uploadedAtLabel)),
        DataCell(
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Mock upload',
                  onPressed: () {
                    final now = DateTime.now();
                    final stamp =
                        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
                    setState(() {
                      final type = row.fileType.isEmpty ? 'document' : row.fileType;
                      row.fileNameController.text =
                          '${type.replaceAll(' ', '_').toLowerCase()}_$stamp.pdf';
                      row.uploadedAt = now;
                    });
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                ),
                IconButton(
                  tooltip: 'Remove row',
                  onPressed: () {
                    setState(() {
                      _uploadRows.removeAt(index).dispose();
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _syncUploadRowsWithOptions({
    required List<String> fileTypeOptions,
    required DriverData? existing,
    required Map<String, bool> mandatoryByType,
  }) {
    if (_uploadRows.isNotEmpty) {
      for (final row in _uploadRows) {
        if (row.fileType.isEmpty && fileTypeOptions.isNotEmpty) {
          row.fileType = fileTypeOptions.first;
        }
        row.mandatory = mandatoryByType[row.fileType] ?? false;
      }
      return;
    }

    if (_initialized && existing != null && existing.certifications.isNotEmpty) {
      for (final cert in existing.certifications) {
        final type = cert.trim();
        if (type.isEmpty) {
          continue;
        }
        _uploadRows.add(
          _DriverUploadRow(
            fileType: type,
            mandatory: mandatoryByType[type] ?? false,
            fileName: '',
          ),
        );
      }
    } else if (fileTypeOptions.isNotEmpty) {
      final first = fileTypeOptions.first;
      _uploadRows.add(
        _DriverUploadRow(
          fileType: first,
          mandatory: mandatoryByType[first] ?? false,
        ),
      );
    }
  }

  Future<void> _save(DriverData? existing) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final vm = ref.read(logisticsViewModelProvider.notifier);
    final isEdit = widget.editDriverId != null;
    final uploadedTypes = _uploadRows
        .where((row) =>
            row.fileType.trim().isNotEmpty &&
            row.fileNameController.text.trim().isNotEmpty)
        .map((row) => row.fileType.trim())
        .toSet()
        .toList();
    if (uploadedTypes.isNotEmpty) {
      _certCtrl.text = uploadedTypes.join(', ');
    }

    final message = isEdit
        ? vm.updateDriver(
            driverCode: existing!.driverId,
            name: _nameCtrl.text.trim(),
            employeeRef: _employeeCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            licenseNo: _licenseCtrl.text.trim(),
            licenseType: _licenseTypeCtrl.text.trim(),
            licenseIssueDate: _licenseIssueCtrl.text.trim(),
            licenseExpiry: _expiryCtrl.text.trim(),
            availability: _availability,
            nationality: _nationalityCtrl.text.trim(),
            baseLocation: _baseLocation,
            heavyVehicleAllowed: _heavyAllowed,
            allowedVehicleTypes: _selectedAllowedVehicleTypes,
            preferredRouteType: _selectedPreferredRoutes.join(', '),
            preferredVehicleType: _selectedPreferredVehicleTypes.join(', '),
            specialSkillsNotes: _notesCtrl.text.trim(),
            certifications: _certCtrl.text.trim(),
            active: _active,
          )
        : vm.addDriver(
            driverCode: _codeCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            employeeRef: _employeeCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            licenseNo: _licenseCtrl.text.trim(),
            licenseType: _licenseTypeCtrl.text.trim(),
            licenseIssueDate: _licenseIssueCtrl.text.trim(),
            licenseExpiry: _expiryCtrl.text.trim(),
            availability: _availability,
            nationality: _nationalityCtrl.text.trim(),
            baseLocation: _baseLocation,
            heavyVehicleAllowed: _heavyAllowed,
            allowedVehicleTypes: _selectedAllowedVehicleTypes,
            preferredRouteType: _selectedPreferredRoutes.join(', '),
            preferredVehicleType: _selectedPreferredVehicleTypes.join(', '),
            specialSkillsNotes: _notesCtrl.text.trim(),
            certifications: _certCtrl.text.trim(),
            active: _active,
          );

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (message.toLowerCase().contains('added') ||
        message.toLowerCase().contains('updated')) {
      context.go(RoutePaths.driverManagement);
    }
  }

  List<String> _csv(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _withSelections(List<String> options, List<String> selected) {
    final merged = <String>{...options, ...selected};
    final items = merged.toList()..sort();
    return items;
  }

  List<String> _routeOptions(List<RouteLocationModel> routes) {
    final items = <String>{};
    for (final route in routes) {
      final code = route.routeCode.trim();
      final name = route.routeName.trim();
      final label = code.isEmpty ? name : '$code - $name';
      if (label.trim().isNotEmpty) {
        items.add(label);
      }
    }
    final list = items.toList()..sort();
    return list;
  }

  List<String> _vehicleTypeOptions(List<VehicleTypeMasterModel> items) {
    final names = <String>{};
    for (final item in items) {
      final name = item.vehicleTypeName.trim();
      if (name.isNotEmpty) {
        names.add(name);
      }
    }
    final list = names.toList()..sort();
    return list;
  }

  Widget _multiSelectField({
    required String label,
    required List<String> selectedValues,
    required List<String> options,
    required ValueChanged<List<String>> onChanged,
  }) {
    final summary = selectedValues.isEmpty
        ? 'No selection'
        : selectedValues.join(', ');
    return InkWell(
      onTap: options.isEmpty
          ? null
          : () async {
              final selected = await _showMultiSelectDialog(
                title: label,
                options: options,
                initialSelected: selectedValues,
              );
              if (selected != null) {
                onChanged(selected);
              }
            },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          options.isEmpty ? 'No master data available' : summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<List<String>?> _showMultiSelectDialog({
    required String title,
    required List<String> options,
    required List<String> initialSelected,
  }) async {
    final selected = <String>{...initialSelected};
    return showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 420,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      CheckboxListTile(
                        value: selected.contains(option),
                        title: Text(option),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (checked) {
                          setInnerState(() {
                            if (checked ?? false) {
                              selected.add(option);
                            } else {
                              selected.remove(option);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(selected.toList()..sort()),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DriverUploadRow {
  _DriverUploadRow({
    required this.fileType,
    required this.mandatory,
    String fileName = '',
    this.uploadedAt,
  }) : fileNameController = TextEditingController(text: fileName);

  final TextEditingController fileNameController;
  String fileType;
  bool mandatory;
  DateTime? uploadedAt;

  String get uploadedAtLabel {
    final value = uploadedAt;
    if (value == null) {
      return '-';
    }
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    return '$d/$m/$y';
  }

  void dispose() {
    fileNameController.dispose();
  }
}
