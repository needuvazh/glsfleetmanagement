import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cargo_model.dart';
import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/inspection_master_viewmodel.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../widgets/ops_shell.dart';
import 'inspection_template_store.dart';

class InspectionCreateScreen extends ConsumerStatefulWidget {
  const InspectionCreateScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<InspectionCreateScreen> createState() =>
      _InspectionCreateScreenState();
}

class _InspectionCreateScreenState
    extends ConsumerState<InspectionCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _inspectionIdController = TextEditingController();
  final _workOrderController = TextEditingController();
  final _fleetController = TextEditingController(); // Vehicle Code
  final _mulkiyaExpiryController = TextEditingController();
  final _rasExpiryController = TextEditingController();
  final _trailerController = TextEditingController();
  final _trailerMulkiyaExpiryController = TextEditingController();
  final _trailerRasExpiryController = TextEditingController();
  final _driverController = TextEditingController();
  final _driverLicenseExpiryController = TextEditingController();
  final _h2sPermitExpiryController = TextEditingController();
  final _defensiveDrivingController = TextEditingController();
  final _tyrePressureDriverSideController = TextEditingController();
  final _tyrePressurePassengerSideController = TextEditingController();
  final _tyreManufacturingDateController = TextEditingController();
  final _inspectionRemarksController = TextEditingController();

  final _inspectorController = TextEditingController();
  final _notesController = TextEditingController();
  final _correctiveActionController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _reviewerController = TextEditingController();

  String? _selectedCargoCode;
  String? _selectedVendorId;
  String? _selectedSubVendorId;

  InspectionType _type = InspectionType.preDeparture; // Default to new type
  DateTime _inspectionDateTime = DateTime.now();
  InspectionApprovalStatus _selectedApprovalStatus =
      InspectionApprovalStatus.pending;

  List<_ChecklistDraft> _items = [];
  final List<_DocumentDraftRow> _docRows = [_DocumentDraftRow()];

  bool get _isEditing => widget.inspectionId != null;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingInspection();
    } else {
      _inspectionIdController.text =
          'INS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }
  }

  void _loadExistingInspection() {
    final record = ref
        .read(inspectionViewModelProvider.notifier)
        .byId(widget.inspectionId!);
    if (record == null) return;

    _inspectionIdController.text = record.inspectionId;
    _workOrderController.text = record.workOrder;
    _fleetController.text = record.fleet;
    _trailerController.text = record.trailer;
    _driverController.text = record.driver;
    _inspectorController.text = record.inspector;
    _inspectionDateTime = record.inspectedAt;
    _type = record.inspectionType;
    _selectedApprovalStatus = record.approvalStatus;
    _notesController.text = record.notes;
    _correctiveActionController.text = record.correctiveAction;
    _recommendationController.text = record.recommendation;
    _reviewerController.text = record.reviewerName;

    // Read-only if Approved or Rejected
    _isReadOnly = record.approvalStatus == InspectionApprovalStatus.approved ||
        record.approvalStatus == InspectionApprovalStatus.rejected;
  }

  @override
  void dispose() {
    _inspectionIdController.dispose();
    _workOrderController.dispose();
    _fleetController.dispose();
    _mulkiyaExpiryController.dispose();
    _rasExpiryController.dispose();
    _trailerController.dispose();
    _trailerMulkiyaExpiryController.dispose();
    _trailerRasExpiryController.dispose();
    _driverController.dispose();
    _driverLicenseExpiryController.dispose();
    _h2sPermitExpiryController.dispose();
    _defensiveDrivingController.dispose();
    _tyrePressureDriverSideController.dispose();
    _tyrePressurePassengerSideController.dispose();
    _tyreManufacturingDateController.dispose();
    _inspectionRemarksController.dispose();
    _inspectorController.dispose();
    _notesController.dispose();
    _correctiveActionController.dispose();
    _recommendationController.dispose();
    _reviewerController.dispose();
    for (final item in _items) {
      item.remarksController.dispose();
    }
    super.dispose();
  }

  void _rebuildChecklists() {
    final template = InspectionTemplateStore.resolveActiveTemplate(
      type: _type,
      vehicleType: 'Truck',
    );
    if (template != null && template.items.isNotEmpty) {
      setState(() {
        _items = [
          for (var i = 0; i < template.items.length; i++)
            _ChecklistDraft(
              sno: i + 1,
              itemName: template.items[i].name,
              category: template.items[i].category,
              mandatory: template.items[i].mandatory,
              severity: template.items[i].severity,
              requiresPhoto: template.items[i].requiresPhoto,
              requiresVideo: template.items[i].requiresVideo,
            ),
        ];
      });
      return;
    }

    final types = ref.read(inspectionTypesProvider);
    final checklists = ref.read(inspectionChecklistsProvider);

    String? masterTypeId;
    if (_type == InspectionType.preDeparture) masterTypeId = 'T1';
    if (_type == InspectionType.loadSecurity) masterTypeId = 'T2';

    if (masterTypeId == null) {
      setState(() {
        _items = [
          _ChecklistDraft(sno: 1, itemName: 'Tyres', category: 'General'),
          _ChecklistDraft(sno: 2, itemName: 'Brake', category: 'General'),
          _ChecklistDraft(sno: 3, itemName: 'Lights', category: 'General'),
          _ChecklistDraft(
              sno: 4, itemName: 'Fire Extinguisher', category: 'General'),
          _ChecklistDraft(
              sno: 5, itemName: 'Vehicle Documents', category: 'General'),
          _ChecklistDraft(
              sno: 6, itemName: 'Driver Documents', category: 'General'),
        ];
      });
      return;
    }

    final masterType = types.firstWhere((t) => t.id == masterTypeId);
    final categoryIds = masterType.categories.map((c) => c.id).toList();

    final matchingItems =
        checklists.where((c) => categoryIds.contains(c.categoryId)).toList();

    setState(() {
      _items = matchingItems.map((c) {
        final categoryName = masterType.categories
            .firstWhere((cat) => cat.id == c.categoryId)
            .name;
        return _ChecklistDraft(
            sno: c.sno, itemName: c.description, category: categoryName);
      }).toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_items.isEmpty) {
      _rebuildChecklists();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep watching cargoViewModelProvider to ensure correct initialization, though it's now internal
    final selectedCargo = ref
        .read(cargoViewModelProvider.notifier)
        .findByCode(_selectedCargoCode);

    final vendorState = ref.watch(vendorViewModelProvider).valueOrNull;
    final activeVendors =
        vendorState?.vendors.where((v) => v.isActive).toList() ?? [];

    final subVendors = ref.watch(subVendorsProvider(_selectedVendorId ?? ''));

    // Compute description options for Docs panel based on the selected type's categories
    // Fixed master doc_type options for Upload Documents
    final docDescriptions = [
      'Tyre Photos',
      'Vehicle Body Photos',
      'Electrical & Lights Photos',
      'Brake System Photos',
      'Cabin / Interior Photos',
      'Load Securing Photos',
      'Additional Photos',
      'Other Document',
    ];

    final screenTitle = _isReadOnly
        ? 'View Inspection'
        : (_isEditing ? 'Edit Inspection' : 'Create Inspection');

    return OpsShell(
      title: screenTitle,
      currentRoute: RoutePaths.inspections,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _Section(
              title: 'A. Inspection Header',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _field(_inspectionIdController, 'Inspection ID',
                      required: true, width: 260, forceReadOnly: true),
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<InspectionType>(
                      value: _type,
                      decoration:
                          const InputDecoration(labelText: 'Inspection Type'),
                      items: [
                        for (final type in InspectionType.values)
                          DropdownMenuItem(
                              value: type, child: Text(type.label)),
                      ],
                      onChanged: _isReadOnly
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _type = value;
                                  _rebuildChecklists();
                                  _docRows.clear();
                                  _docRows.add(_DocumentDraftRow());
                                });
                              }
                            },
                    ),
                  ),
                  _field(_workOrderController, 'Linked Work Order',
                      required: true),
                  SizedBox(
                    width: 260,
                    child: OutlinedButton.icon(
                      onPressed: _pickInspectionDateTime,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                          'Inspection At: ${_fmtDateTime(_inspectionDateTime)}'),
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Vehicle Details',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _field(_fleetController, 'Vehicle Code', required: true),
                  _field(_mulkiyaExpiryController, 'Mulkiya Expiry Date',
                      isDate: true),
                  _field(_rasExpiryController, 'RAS Expiry Date', isDate: true),
                  _field(_trailerController, 'Trailer Code'),
                  _field(_trailerMulkiyaExpiryController,
                      'Trailer Mulkiya Expiry Date',
                      isDate: true),
                  _field(_trailerRasExpiryController, 'Trailer RAS Expiry Date',
                      isDate: true),
                  _field(_driverController, 'Driver Code', required: true),
                  _field(_driverLicenseExpiryController, 'License Expiry Date',
                      isDate: true),
                  _field(_h2sPermitExpiryController, 'H2S Permit Expiry Date',
                      isDate: true),
                  _field(_defensiveDrivingController, 'Defensive Driving'),
                  _field(_tyrePressureDriverSideController,
                      'Tyre Pressure (Driver Side)'),
                  _field(_tyrePressurePassengerSideController,
                      'Tyre Pressure (Passenger Side)'),
                  _field(_tyreManufacturingDateController,
                      'Tyre Manufacturing Date',
                      isDate: true),
                ],
              ),
            ),
            _Section(
              title: 'Vendor Details',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      value: _selectedVendorId,
                      decoration: const InputDecoration(labelText: 'Vendor'),
                      items: [
                        for (final vendor in activeVendors)
                          DropdownMenuItem(
                            value: vendor.vendorId,
                            child: Text(vendor.vendorName),
                          ),
                      ],
                      onChanged: _isReadOnly
                          ? null
                          : (value) {
                              setState(() {
                                _selectedVendorId = value;
                                _selectedSubVendorId = null;
                              });
                            },
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubVendorId,
                      decoration:
                          const InputDecoration(labelText: 'Sub Vendor Name'),
                      items: [
                        for (final sv in subVendors)
                          DropdownMenuItem(
                            value: sv.id,
                            child: Text(sv.name),
                          ),
                      ],
                      onChanged: (_isReadOnly || _selectedVendorId == null)
                          ? null
                          : (value) {
                              setState(() {
                                _selectedSubVendorId = value;
                              });
                            },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _inspectionRemarksController,
                      readOnly: _isReadOnly,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Inspection Remarks'),
                    ),
                  )
                ],
              ),
            ),
            if (selectedCargo != null)
              _Section(
                title: 'Cargo-driven Inspection Guidance',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedCargo.cargoName} (${selectedCargo.riskLevel.label})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      for (final warning
                          in _cargoInspectionWarnings(selectedCargo))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('- $warning'),
                        ),
                    ],
                  ),
                ),
              ),
            _Section(
              title: 'Checklist Items',
              child: Column(
                children: _buildGroupedChecklistGrid(),
              ),
            ),
            _Section(
              title: 'Upload Documents',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _docRows.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Text('${i + 1}.',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _docRows[i].docType,
                              decoration:
                                  const InputDecoration(labelText: 'Doc Type'),
                              isExpanded: true,
                              items: [
                                for (final desc in docDescriptions)
                                  DropdownMenuItem(
                                    value: desc,
                                    child: Text(desc,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                              onChanged: _isReadOnly
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _docRows[i].docType = val;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: _isReadOnly
                                  ? null
                                  : () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => const AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 20),
                                              Text('Uploading...'),
                                            ],
                                          ),
                                        ),
                                      );
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        _toast('File uploaded successfully');
                                      }
                                    },
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Browse and upload'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.green),
                            onPressed: _isReadOnly
                                ? null
                                : () {
                                    setState(() {
                                      _docRows.insert(
                                          i + 1, _DocumentDraftRow());
                                    });
                                  },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: _isReadOnly
                                ? null
                                : () {
                                    setState(() {
                                      if (_docRows.length > 1) {
                                        _docRows.removeAt(i);
                                      } else {
                                        _docRows[i] = _DocumentDraftRow();
                                      }
                                    });
                                  },
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'General Comments',
              child: Column(
                children: [
                  TextFormField(
                    controller: _notesController,
                    readOnly: _isReadOnly,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _correctiveActionController,
                    readOnly: _isReadOnly,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Corrective Action'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _recommendationController,
                    readOnly: _isReadOnly,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Recommendation'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Sign-off',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _field(_reviewerController, 'Reviewer Name'),
                  OutlinedButton.icon(
                    onPressed: _isReadOnly
                        ? null
                        : () => _toast('Signature placeholder'),
                    icon: const Icon(Icons.draw_outlined),
                    label: const Text('Signature (Placeholder)'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Inspection Status',
              child: SizedBox(
                width: 260,
                child: DropdownButtonFormField<InspectionApprovalStatus>(
                  value: _selectedApprovalStatus,
                  decoration:
                      const InputDecoration(labelText: 'Approval Status'),
                  items: const [
                    DropdownMenuItem(
                        value: InspectionApprovalStatus.pending,
                        child: Text('Pending')),
                    DropdownMenuItem(
                        value: InspectionApprovalStatus.approved,
                        child: Text('Approved')),
                    DropdownMenuItem(
                        value: InspectionApprovalStatus.rejected,
                        child: Text('Rejected')),
                  ],
                  onChanged: _isReadOnly
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() => _selectedApprovalStatus = val);
                          }
                        },
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_isReadOnly)
              Center(
                child: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.inspections),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _submit(
                        InspectionStatus.draft, InspectionResult.passed),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Draft'),
                  ),
                  FilledButton.icon(
                    onPressed: () =>
                        _submit(InspectionStatus.submitted, _computedResult()),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _submit(
                        InspectionStatus.passed, InspectionResult.passed),
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Mark Passed'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _submit(
                        InspectionStatus.failed, InspectionResult.failed),
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Mark Failed'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedChecklistGrid() {
    final Map<String, List<_ChecklistDraft>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final children = <Widget>[];

    for (final entry in grouped.entries) {
      final category = entry.key;
      final items = entry.value;

      children.add(
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.only(top: 16),
          child: Text(
            category,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );

      children.add(
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FixedColumnWidth(30),
            1: FlexColumnWidth(1),
            2: FixedColumnWidth(40),
            3: FixedColumnWidth(30),
            4: FlexColumnWidth(1),
            5: FixedColumnWidth(40),
            6: FixedColumnWidth(30),
            7: FlexColumnWidth(1),
            8: FixedColumnWidth(40),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            for (int i = 0; i < items.length; i += 3)
              TableRow(
                children: [
                  _buildCellSno(items, i),
                  _buildCellDesc(items, i),
                  _buildCellCheck(items, i),
                  _buildCellSno(items, i + 1),
                  _buildCellDesc(items, i + 1),
                  _buildCellCheck(items, i + 1),
                  _buildCellSno(items, i + 2),
                  _buildCellDesc(items, i + 2),
                  _buildCellCheck(items, i + 2),
                ],
              ),
          ],
        ),
      );
    }
    return children;
  }

  Widget _buildCellSno(List<_ChecklistDraft> items, int index) {
    if (index >= items.length) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(child: Text('${items[index].sno}')),
    );
  }

  Widget _buildCellDesc(List<_ChecklistDraft> items, int index) {
    if (index >= items.length) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(items[index].itemName, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCellCheck(List<_ChecklistDraft> items, int index) {
    if (index >= items.length) return const SizedBox();
    final item = items[index];
    return InkWell(
      onTap: _isReadOnly
          ? null
          : () {
              setState(() {
                item.passed = !item.passed;
              });
            },
      child: Container(
        height: 32,
        alignment: Alignment.center,
        child: item.passed
            ? const Icon(Icons.check, color: Colors.green, size: 20)
            : const SizedBox(height: 20, width: 20),
      ),
    );
  }

  SizedBox _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    double width = 260,
    bool isDate = false,
    bool forceReadOnly = false,
  }) {
    final effectiveReadOnly = _isReadOnly || forceReadOnly || isDate;
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        readOnly: effectiveReadOnly,
        onTap: (isDate && !_isReadOnly && !forceReadOnly)
            ? () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null && mounted) {
                  controller.text =
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          suffixIcon:
              isDate ? const Icon(Icons.calendar_today, size: 20) : null,
        ),
      ),
    );
  }

  InspectionResult _computedResult() {
    final hasFailed = _items.any((item) => !item.passed);
    return hasFailed ? InspectionResult.failed : InspectionResult.passed;
  }

  List<String> _cargoInspectionWarnings(CargoModel cargo) {
    final warnings = <String>[];
    if (cargo.hazardous) {
      warnings.add(
          'Hazardous cargo selected. Include chemical/hazmat checkpoints.');
    }
    if (cargo.lashingRequired) {
      warnings.add('Load securement checks should be explicitly verified.');
    }
    if (cargo.photoEvidenceMandatory) {
      warnings.add('Photo evidence is mandatory for completion policy.');
    }
    if (cargo.videoEvidenceMandatory) {
      warnings.add('Video evidence is mandatory for completion policy.');
    }
    if (cargo.preDispatchInspectionRequired) {
      warnings.add('Pre-dispatch checks are expected for this cargo.');
    }
    if (cargo.inTransitCheckRequired) {
      warnings.add('In-transit checkpoints are expected for this cargo.');
    }
    if (cargo.postDeliveryCheckRequired) {
      warnings.add('Post-delivery checks are expected for this cargo.');
    }
    if (warnings.isEmpty) {
      warnings.add('No special cargo rules; proceed with template checks.');
    }
    return warnings;
  }

  Future<void> _pickInspectionDateTime() async {
    if (_isReadOnly) return;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _inspectionDateTime,
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_inspectionDateTime),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _inspectionDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit(InspectionStatus status, InspectionResult result) {
    // Removed form validation and checklist completion checks as requested

    final checklist = _items
        .map(
          (item) => InspectionChecklistItemResult(
            itemName: item.itemName,
            passed: item.passed,
            remarks: item.remarksController.text.trim(),
            mediaCount: item.mediaCount,
            severity:
                item.passed ? InspectionFailureSeverity.none : item.severity,
          ),
        )
        .toList();

    final approvalStatus = _selectedApprovalStatus;

    final record = InspectionRecord(
      inspectionId: _inspectionIdController.text.trim(),
      inspectionType: _type,
      workOrder: _workOrderController.text.trim(),
      fleet: _fleetController.text.trim(),
      trailer: _trailerController.text.trim(),
      driver: _driverController.text.trim(),
      inspector: _inspectorController.text.trim(),
      inspectedAt: _inspectionDateTime,
      overallResult: result,
      status: status,
      approvalStatus: approvalStatus,
      mediaCount: checklist.fold<int>(0, (sum, item) => sum + item.mediaCount),
      lastUpdated: DateTime.now(),
      checklistItems: checklist,
      notes: _notesController.text.trim() +
          (_inspectionRemarksController.text.isNotEmpty
              ? '\nVendor Remarks: ${_inspectionRemarksController.text}'
              : ''),
      correctiveAction: _correctiveActionController.text.trim(),
      recommendation: _recommendationController.text.trim(),
      reviewerName: _reviewerController.text.trim(),
      signaturePlaceholder: true,
    );

    if (_isEditing) {
      ref.read(inspectionViewModelProvider.notifier).updateInspection(record);
      _toast('Inspection ${record.inspectionId} updated as ${status.label}.');
    } else {
      ref.read(inspectionViewModelProvider.notifier).createInspection(record);
      _toast('Inspection ${record.inspectionId} saved as ${status.label}.');
    }
    context.go(RoutePaths.inspections);
  }

  String _fmtDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $hour:$minute';
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChecklistDraft {
  _ChecklistDraft({
    required this.sno,
    required this.itemName,
    required this.category,
    this.mandatory = true,
    this.requiresPhoto = false,
    this.requiresVideo = false,
    this.severity = InspectionFailureSeverity.low,
  }) : remarksController = TextEditingController();

  final int sno;
  final String itemName;
  final String category;
  final bool mandatory;
  final bool requiresPhoto;
  final bool requiresVideo;
  final TextEditingController remarksController;
  bool passed = true;
  int mediaCount = 0;
  InspectionFailureSeverity severity;
}

class _DocumentDraftRow {
  String? docType;
}
