import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/oman_fleet_master.dart';
import '../../domain/route_model.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
<<<<<<< Updated upstream
import '../viewmodels/module_document_viewmodel.dart';
=======
>>>>>>> Stashed changes
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
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _employeeCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _licenseCtrl;
  late final TextEditingController _licenseIssueCtrl;
  late final TextEditingController _expiryCtrl;
<<<<<<< Updated upstream
  late final TextEditingController _nationalityCtrl;
=======
  late final TextEditingController _residentCardNumberCtrl;
  late final TextEditingController _allowedVehicleCtrl;
>>>>>>> Stashed changes
  late final TextEditingController _certCtrl;
  late final TextEditingController _notesCtrl;
  final ScrollController _docsHorizontalController = ScrollController();
  final List<_DriverUploadRow> _uploadRows = [];

  bool _initialized = false;
  bool _saving = false;

  String _nationality = 'Oman';
  String _availability = 'Available';
  String _baseLocation = OmanFleetMaster.omanLocations.first;
  String _licenseType = 'Light Vehicle';
  List<String> _selectedAllowedVehicleTypes = <String>[];
  bool _heavyAllowed = false;
  bool _active = true;
<<<<<<< Updated upstream
  List<String> _selectedAllowedVehicleTypes = [];
  List<String> _selectedPreferredRoutes = [];
  List<String> _selectedPreferredVehicleTypes = [];
=======
  DateTime? _residentCardExpiryDate;
>>>>>>> Stashed changes

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
    final nameParts = _splitName(existing?.name ?? '');
    _firstNameCtrl = TextEditingController(text: nameParts.$1);
    _lastNameCtrl = TextEditingController(text: nameParts.$2);
    _employeeCtrl = TextEditingController(text: existing?.employeeRef ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _licenseCtrl = TextEditingController(text: existing?.licenseNo ?? '');
    _licenseIssueCtrl =
        TextEditingController(text: existing?.licenseIssueDate ?? '');
    _expiryCtrl = TextEditingController(text: existing?.expiryDate ?? '');
<<<<<<< Updated upstream
    _nationalityCtrl =
        TextEditingController(text: existing?.nationality ?? 'Omani');
=======
    _residentCardNumberCtrl = TextEditingController();
    _allowedVehicleCtrl = TextEditingController(
      text: existing?.allowedVehicleTypes.join(', ') ?? '',
    );
>>>>>>> Stashed changes
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
    _nationality = existing?.nationality.isNotEmpty == true
        ? existing!.nationality
        : 'Oman';
    _licenseType = existing?.licenseType ?? 'Light Vehicle';
    _selectedAllowedVehicleTypes =
        List<String>.from(existing?.allowedVehicleTypes ?? const <String>[]);
    _heavyAllowed = existing?.heavyVehicleAllowed ?? false;
    _active = existing?.active ?? true;
    _initialized = true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _employeeCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    _licenseIssueCtrl.dispose();
    _expiryCtrl.dispose();
<<<<<<< Updated upstream
    _nationalityCtrl.dispose();
=======
    _residentCardNumberCtrl.dispose();
    _allowedVehicleCtrl.dispose();
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    final complianceState = ref.watch(moduleDocumentViewModelProvider).valueOrNull;
    final authState = ref.watch(authViewModelProvider).valueOrNull;
=======
>>>>>>> Stashed changes
    final isEdit = widget.editDriverId != null;
    final existing = _existingDriver(state);
    final fileTypeOptions = List<String>.from(_driverDocumentTypes);
    const mandatoryByType = <String, bool>{
      'Resident Card': true,
      'Driver ID / Passport': false,
      'License Copy': false,
      'Other Documents': false,
    };
<<<<<<< Updated upstream
    final routeOptions = _withSelections(
      _routeOptions(routeState?.routes ?? const []),
      _selectedPreferredRoutes,
    );
    final vehicleTypeOptions = _withSelections(
      _vehicleTypeOptions(vehicleTypeState?.items ?? const []),
      [..._selectedAllowedVehicleTypes, ..._selectedPreferredVehicleTypes],
=======
    final vehicleTypeOptions = _vehicleTypeOptions(
      vehicleTypeState?.items ?? const [],
      currentSelections: _selectedAllowedVehicleTypes,
      singleSelection: _preferredVehicleTypeCtrl.text.trim(),
    );
    final routeOptions = _routeOptions(
      routeState?.routes ?? const [],
      _preferredRouteTypeCtrl.text.trim(),
>>>>>>> Stashed changes
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
                    _buildResponsiveGrid(
                      children: [
                        _field(
                          _codeCtrl,
                          label: 'Driver Code',
                          enabled: !isEdit,
                        ),
                        _field(
                          _firstNameCtrl,
                          label: 'First Name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'First name is required'
                              : null,
                        ),
                        _field(
                          _lastNameCtrl,
                          label: 'Last Name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Last name is required'
                              : null,
                        ),
                        _field(_employeeCtrl, label: 'Employee ID / Ref'),
                        _field(_phoneCtrl, label: 'Mobile Number'),
                        _SearchableSelectionField<String>(
                          label: 'Nationality',
                          value: _nationality,
                          items: _countries,
                          itemLabel: (item) => item,
                          onSelected: (value) =>
                              setState(() => _nationality = value),
                        ),
                        _SearchableSelectionField<String>(
                          label: 'Base Location',
                          value: _baseLocation,
                          items: OmanFleetMaster.omanLocations,
                          itemLabel: (item) => item,
                          onSelected: (value) =>
                              setState(() => _baseLocation = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Resident Card Details'),
                    _buildResponsiveGrid(
                      children: [
                        _field(
                          _residentCardNumberCtrl,
                          label: 'Resident Card Number',
                        ),
                        _DateInputField(
                          label: 'Expiry Date',
                          value: _residentCardExpiryDate,
                          onTap: () => _pickDate(
                            initialDate: _residentCardExpiryDate,
                            onSelected: (value) => setState(
                              () => _residentCardExpiryDate = value,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('License'),
                    _buildResponsiveGrid(
                      children: [
                        _field(
                          _licenseCtrl,
                          label: 'License Number',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'License number is required'
                              : null,
                        ),
                        _SearchableSelectionField<String>(
                          label: 'License Type',
                          value: _licenseType,
                          items: _licenseTypes,
                          itemLabel: (item) => item,
                          onSelected: (value) =>
                              setState(() => _licenseType = value),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'License class is required'
                              : null,
                        ),
                        _DateTextControllerField(
                          label: 'Expiry Date',
                          controller: _expiryCtrl,
                          onTap: () => _pickDateForController(_expiryCtrl),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'License expiry is required';
                            }
                            return DateTime.tryParse(v.trim()) == null
                                ? 'Use YYYY-MM-DD format'
                                : null;
                          },
                        ),
                        _DateTextControllerField(
                          label: 'Issue Date',
                          controller: _licenseIssueCtrl,
                          onTap: () => _pickDateForController(_licenseIssueCtrl),
                        ),
                        _SearchableSelectionField<String>(
                          label: 'Availability',
                          value: _availability,
                          items: _availabilityOptions,
                          itemLabel: (item) => item,
                          onSelected: (value) =>
                              setState(() => _availability = value),
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Preferences'),
<<<<<<< Updated upstream
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
=======
                    _buildResponsiveGrid(
                      children: [
                        _VehicleTypeMultiSelectField(
                          label: 'Allowed Vehicle Types (comma separated)',
                          options: vehicleTypeOptions,
                          selectedValues: _selectedAllowedVehicleTypes,
                          onChanged: (values) {
                            setState(() {
                              _selectedAllowedVehicleTypes = values;
                              _allowedVehicleCtrl.text = values.join(', ');
                            });
                          },
                        ),
                        _SearchableSelectionField<String>(
                          label: 'Preferred Route Type',
                          value: _preferredRouteTypeCtrl.text.trim().isEmpty
                              ? null
                              : _preferredRouteTypeCtrl.text.trim(),
                          items: routeOptions,
                          itemLabel: (item) => item,
                          onSelected: (value) {
                            setState(() {
                              _preferredRouteTypeCtrl.text = value;
                            });
                          },
                        ),
                        _SearchableSelectionField<String>(
                          label: 'Preferred Vehicle Type',
                          value: _preferredVehicleTypeCtrl.text.trim().isEmpty
                              ? null
                              : _preferredVehicleTypeCtrl.text.trim(),
                          items: vehicleTypeOptions,
                          itemLabel: (item) => item,
                          onSelected: (value) {
                            setState(() {
                              _preferredVehicleTypeCtrl.text = value;
                            });
                          },
                        ),
                        _field(
                          _certCtrl,
                          label: 'Certifications (comma separated)',
                        ),
                        _field(
                          _notesCtrl,
                          label: 'Notes',
                          maxLines: 2,
                        ),
                      ],
>>>>>>> Stashed changes
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Driver Documents Upload'),
                    _buildDocumentsUploader(
                      context: context,
                      fileTypeOptions: fileTypeOptions,
                      mandatoryByType: mandatoryByType,
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

  Widget _buildResponsiveGrid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = constraints.maxWidth >= 1120
            ? 3
            : (constraints.maxWidth >= 720 ? 2 : 1);
        final baseWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              _buildField(
                width: baseWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }

  Widget _buildField({required double width, required Widget child}) {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  (String, String) _splitName(String fullName) {
    final normalized = fullName.trim();
    if (normalized.isEmpty) {
      return ('', '');
    }
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }

  Future<void> _pickDate({
    required DateTime? initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickDateForController(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text.trim());
    await _pickDate(
      initialDate: initial,
      onSelected: (value) {
        final month = value.month.toString().padLeft(2, '0');
        final day = value.day.toString().padLeft(2, '0');
        controller.text = '${value.year}-$month-$day';
        setState(() {});
      },
    );
  }

  Widget _buildDocumentsUploader({
    required BuildContext context,
    required List<String> fileTypeOptions,
    required Map<String, bool> mandatoryByType,
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
                  'Supported file types: Resident Card, Driver ID / Passport, License Copy, and Other Documents.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              FilledButton.icon(
                onPressed: canAddRows
                    ? () => setState(() {
                          _uploadRows.add(
                            _DriverUploadRow(
                              fileType: _defaultDriverDocumentType,
                              mandatory: mandatoryByType[_defaultDriverDocumentType] ??
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
              initialValue: dropdownValue,
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
                          if (row.fileNameController.text.trim().isNotEmpty) {
                            row.uploadedAt ??= DateTime.now();
                          }
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
              validator: (value) {
                if (row.mandatory && (value == null || value.trim().isEmpty)) {
                  return 'File is required';
                }
                return null;
              },
              decoration: InputDecoration(
                isDense: true,
                labelText: row.mandatory ? 'File name *' : 'File name',
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
          row.fileType = _defaultDriverDocumentType;
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
      _uploadRows.add(
        _DriverUploadRow(
          fileType: _defaultDriverDocumentType,
          mandatory: mandatoryByType[_defaultDriverDocumentType] ?? false,
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
            name:
                '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim(),
            employeeRef: _employeeCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            licenseNo: _licenseCtrl.text.trim(),
            licenseType: _licenseType.trim(),
            licenseIssueDate: _licenseIssueCtrl.text.trim(),
            licenseExpiry: _expiryCtrl.text.trim(),
            availability: _availability,
            nationality: _nationality.trim(),
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
            name:
                '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim(),
            employeeRef: _employeeCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            licenseNo: _licenseCtrl.text.trim(),
            licenseType: _licenseType.trim(),
            licenseIssueDate: _licenseIssueCtrl.text.trim(),
            licenseExpiry: _expiryCtrl.text.trim(),
            availability: _availability,
            nationality: _nationality.trim(),
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

<<<<<<< Updated upstream
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
=======
  List<String> _vehicleTypeOptions(
    List<dynamic> items, {
    required List<String> currentSelections,
    required String singleSelection,
  }) {
    final names = <String>{
      for (final item in items)
        if (item.vehicleTypeName.trim().isNotEmpty) item.vehicleTypeName.trim(),
      ...currentSelections.where((item) => item.trim().isNotEmpty),
      if (singleSelection.trim().isNotEmpty) singleSelection.trim(),
    };
    final result = names.toList()..sort();
    return result;
  }

  List<String> _routeOptions(List<dynamic> items, String currentSelection) {
    final names = <String>{
      for (final item in items)
        if (item.routeName.trim().isNotEmpty) item.routeName.trim(),
      if (currentSelection.trim().isNotEmpty) currentSelection.trim(),
    };
    final result = names.toList()..sort();
    return result;
>>>>>>> Stashed changes
  }
}

class _DriverUploadRow {
  _DriverUploadRow({
    required this.fileType,
    required this.mandatory,
    String fileName = '',
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

class _SearchableSelectionField<T> extends StatefulWidget {
  const _SearchableSelectionField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.validator,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onSelected;
  final String? Function(T? value)? validator;

  @override
  State<_SearchableSelectionField<T>> createState() =>
      _SearchableSelectionFieldState<T>();
}

class _SearchableSelectionFieldState<T>
    extends State<_SearchableSelectionField<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == null ? '' : widget.itemLabel(widget.value as T),
    );
  }

  @override
  void didUpdateWidget(covariant _SearchableSelectionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText =
        widget.value == null ? '' : widget.itemLabel(widget.value as T);
    if (_controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      validator: (_) => widget.validator?.call(widget.value),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.search),
      ),
      onTap: () async {
        final selected = await showDialog<T>(
          context: context,
          builder: (context) => _SearchSelectionDialog<T>(
            title: widget.label,
            items: widget.items,
            itemLabel: widget.itemLabel,
          ),
        );
        if (selected != null) {
          widget.onSelected(selected);
        }
      },
    );
  }
}

class _SearchSelectionDialog<T> extends StatefulWidget {
  const _SearchSelectionDialog({
    required this.title,
    required this.items,
    required this.itemLabel,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;

  @override
  State<_SearchSelectionDialog<T>> createState() =>
      _SearchSelectionDialogState<T>();
}

class _SearchSelectionDialogState<T> extends State<_SearchSelectionDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      final label = widget.itemLabel(item).toLowerCase();
      return label.contains(_query.trim().toLowerCase());
    }).toList();

    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: filteredItems.isEmpty
                  ? const Center(child: Text('No matching options found.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text(widget.itemLabel(item)),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DateInputField extends StatelessWidget {
  const _DateInputField({
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
        ? ''
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: onTap,
    );
  }
}

class _DateTextControllerField extends StatelessWidget {
  const _DateTextControllerField({
    required this.label,
    required this.controller,
    required this.onTap,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: onTap,
    );
  }
}

class _VehicleTypeMultiSelectField extends StatelessWidget {
  const _VehicleTypeMultiSelectField({
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
      ),
      child: options.isEmpty
          ? const Text('No vehicle types available.')
          : Column(
              children: [
                for (final option in options)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(option),
                    value: selectedValues.contains(option),
                    onChanged: (checked) {
                      final next = List<String>.from(selectedValues);
                      if (checked == true) {
                        if (!next.contains(option)) {
                          next.add(option);
                        }
                      } else {
                        next.remove(option);
                      }
                      onChanged(next);
                    },
                  ),
              ],
            ),
    );
  }
}

const List<String> _availabilityOptions = <String>[
  'Available',
  'Assigned',
  'On Leave',
  'Resting / Off Duty',
  'Suspended',
  'Inactive',
];

const List<String> _licenseTypes = <String>[
  'Light Vehicle',
  'Medium Vehicle',
  'Heavy Vehicle',
  'Trailer',
];

const String _defaultDriverDocumentType = 'Resident Card';

const List<String> _driverDocumentTypes = <String>[
  'Resident Card',
  'Driver ID / Passport',
  'License Copy',
  'Other Documents',
];

const List<String> _countries = <String>[
  'Afghanistan',
  'Albania',
  'Algeria',
  'Andorra',
  'Angola',
  'Antigua and Barbuda',
  'Argentina',
  'Armenia',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bahamas',
  'Bahrain',
  'Bangladesh',
  'Barbados',
  'Belarus',
  'Belgium',
  'Belize',
  'Benin',
  'Bhutan',
  'Bolivia',
  'Bosnia and Herzegovina',
  'Botswana',
  'Brazil',
  'Brunei',
  'Bulgaria',
  'Burkina Faso',
  'Burundi',
  'Cambodia',
  'Cameroon',
  'Canada',
  'Cape Verde',
  'Central African Republic',
  'Chad',
  'Chile',
  'China',
  'Colombia',
  'Comoros',
  'Congo',
  'Costa Rica',
  'Croatia',
  'Cuba',
  'Cyprus',
  'Czech Republic',
  'Denmark',
  'Djibouti',
  'Dominica',
  'Dominican Republic',
  'Ecuador',
  'Egypt',
  'El Salvador',
  'Equatorial Guinea',
  'Eritrea',
  'Estonia',
  'Eswatini',
  'Ethiopia',
  'Fiji',
  'Finland',
  'France',
  'Gabon',
  'Gambia',
  'Georgia',
  'Germany',
  'Ghana',
  'Greece',
  'Grenada',
  'Guatemala',
  'Guinea',
  'Guinea-Bissau',
  'Guyana',
  'Haiti',
  'Honduras',
  'Hungary',
  'Iceland',
  'India',
  'Indonesia',
  'Iran',
  'Iraq',
  'Ireland',
  'Israel',
  'Italy',
  'Ivory Coast',
  'Jamaica',
  'Japan',
  'Jordan',
  'Kazakhstan',
  'Kenya',
  'Kiribati',
  'Kuwait',
  'Kyrgyzstan',
  'Laos',
  'Latvia',
  'Lebanon',
  'Lesotho',
  'Liberia',
  'Libya',
  'Liechtenstein',
  'Lithuania',
  'Luxembourg',
  'Madagascar',
  'Malawi',
  'Malaysia',
  'Maldives',
  'Mali',
  'Malta',
  'Marshall Islands',
  'Mauritania',
  'Mauritius',
  'Mexico',
  'Micronesia',
  'Moldova',
  'Monaco',
  'Mongolia',
  'Montenegro',
  'Morocco',
  'Mozambique',
  'Myanmar',
  'Namibia',
  'Nauru',
  'Nepal',
  'Netherlands',
  'New Zealand',
  'Nicaragua',
  'Niger',
  'Nigeria',
  'North Korea',
  'North Macedonia',
  'Norway',
  'Oman',
  'Pakistan',
  'Palau',
  'Panama',
  'Papua New Guinea',
  'Paraguay',
  'Peru',
  'Philippines',
  'Poland',
  'Portugal',
  'Qatar',
  'Romania',
  'Russia',
  'Rwanda',
  'Saint Kitts and Nevis',
  'Saint Lucia',
  'Saint Vincent and the Grenadines',
  'Samoa',
  'San Marino',
  'Sao Tome and Principe',
  'Saudi Arabia',
  'Senegal',
  'Serbia',
  'Seychelles',
  'Sierra Leone',
  'Singapore',
  'Slovakia',
  'Slovenia',
  'Solomon Islands',
  'Somalia',
  'South Africa',
  'South Korea',
  'South Sudan',
  'Spain',
  'Sri Lanka',
  'Sudan',
  'Suriname',
  'Sweden',
  'Switzerland',
  'Syria',
  'Taiwan',
  'Tajikistan',
  'Tanzania',
  'Thailand',
  'Timor-Leste',
  'Togo',
  'Tonga',
  'Trinidad and Tobago',
  'Tunisia',
  'Turkey',
  'Turkmenistan',
  'Tuvalu',
  'Uganda',
  'Ukraine',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Uruguay',
  'Uzbekistan',
  'Vanuatu',
  'Vatican City',
  'Venezuela',
  'Vietnam',
  'Yemen',
  'Zambia',
  'Zimbabwe',
];
