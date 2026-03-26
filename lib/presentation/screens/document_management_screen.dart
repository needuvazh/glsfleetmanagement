import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/module_document.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/module_document_upload_section.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class DocumentManagementScreen extends ConsumerStatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  ConsumerState<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState
    extends ConsumerState<DocumentManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentCodeController = TextEditingController();
  final _documentNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _alertDaysController = TextEditingController(text: '30');

  String? _editingRuleId;
  bool _showEditor = false;

  String _selectedApplicableTo =
      ModuleDocumentViewModel.applicableToOptions.first;
  String _selectedStatus = 'Active';
  String _selectedMissingAction = ModuleDocumentViewModel.actionTypes[1];
  String _selectedExpiredAction = ModuleDocumentViewModel.actionTypes[3];

  bool _mandatory = true;
  bool _hasExpiry = true;
  bool _checkAtAssignment = true;
  bool _checkAtInspection = false;
  bool _checkAtDispatch = true;
  bool _checkAtTripStart = false;
  bool _checkAtDeliveryClosure = false;
  bool _uploadRequired = true;
  bool _overrideAllowed = false;

  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final ScrollController _tableHorizontalScrollController =
      ScrollController();
  final ScrollController _tableVerticalScrollController = ScrollController();

  bool get _isEditMode => _editingRuleId != null;

  @override
  void dispose() {
    _documentCodeController.dispose();
    _documentNameController.dispose();
    _descriptionController.dispose();
    _alertDaysController.dispose();
    _tableHorizontalScrollController.dispose();
    _tableVerticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moduleDocumentViewModelProvider);

    return OpsShell(
      title: 'Compliance Document Master',
      currentRoute: RoutePaths.documentManagement,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: _showEditor
                ? SingleChildScrollView(
                    child: _buildEditorCard(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildListCard(data),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildListCard(ModuleDocumentUiState data) {
    return OpsSectionCard(
      title: 'Compliance Rule List',
      subtitle:
          'View all existing rules first, then create, edit, or view rule details from the header actions',
      icon: Icons.rule_folder_outlined,
      accent: const Color(0xFF16A34A),
      expandChild: true,
      child: Column(
        children: [
          _buildContentHeader(data),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: data.query,
            decoration: const InputDecoration(
              labelText: 'Search by code/name/applicable/stage',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged:
                ref.read(moduleDocumentViewModelProvider.notifier).setQuery,
          ),
          const SizedBox(height: 10),
          _buildFilters(data),
          const SizedBox(height: 10),
          if (data.filteredItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text('No compliance rules found for selected filters.'),
            ),
          else
            Expanded(
              child: _buildPaginatedTable(data.filteredItems),
            ),
        ],
      ),
    );
  }

  Widget _buildEditorCard() {
    return OpsSectionCard(
      title: _isEditMode ? 'Edit Compliance Rule' : 'Create New Compliance Rule',
      subtitle:
          'Define applicability, stage checks, severity, and evidence requirements',
      icon: _isEditMode ? Icons.edit_document : Icons.policy_outlined,
      accent: const Color(0xFF2563EB),
      trailing: TextButton.icon(
        onPressed: _closeEditor,
        icon: const Icon(Icons.close),
        label: const Text('Close'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildBasicsRow(),
            const SizedBox(height: 10),
            _buildRequirementRow(),
            const SizedBox(height: 10),
            _buildStageRow(),
            const SizedBox(height: 10),
            _buildBlockingRow(),
            const SizedBox(height: 10),
            _buildEvidenceRow(),
            const ModuleDocumentUploadSection(
              moduleName: 'Compliance Master',
              title: 'Policy Attachment Uploads',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _submitRule,
                icon: Icon(
                    _isEditMode ? Icons.save_outlined : Icons.add_task_outlined),
                label: Text(
                    _isEditMode ? 'Save Changes' : 'Create Compliance Rule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader(ModuleDocumentUiState data) {
    final total = data.items.length;
    final hardBlocks =
        data.items.where((item) => item.blockingType == 'Hard Block').length;
    final active = data.items.where((item) => item.status == 'Active').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            OpsPill(label: 'Total $total', color: const Color(0xFF2563EB)),
            OpsPill(label: 'Active $active', color: const Color(0xFF16A34A)),
            OpsPill(
              label: 'Hard Block $hardBlocks',
              color: const Color(0xFFB91C1C),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _openEditorForCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create New Compliance'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginatedTable(List<ModuleDocument> items) {
    final sortedItems = _sortedItems(items);
    final source = _ComplianceRuleTableSource(
      items: sortedItems,
      onView: _showRuleDetails,
      onEdit: _openEditorForEdit,
      onDelete: _deleteRule,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final tableWidth = viewportWidth < 1650 ? 1650.0 : viewportWidth;

        return Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: _tableVerticalScrollController,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.vertical,
          child: SingleChildScrollView(
            controller: _tableVerticalScrollController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              controller: _tableHorizontalScrollController,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _tableHorizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: PaginatedDataTable(
                  header: const Text('Compliance Rules'),
                  showCheckboxColumn: false,
                  showEmptyRows: false,
                  rowsPerPage: _rowsPerPage,
                  availableRowsPerPage: const [5, 10, 20, 50],
                  onRowsPerPageChanged: (value) {
                    if (value != null) {
                      setState(() => _rowsPerPage = value);
                    }
                  },
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn(
                      label: const Text('Code'),
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Rule Name'),
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Applicable To'),
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Mandatory'),
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Required Stage'),
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Blocking Type'),
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Alert Days'),
                      numeric: true,
                      onSort: _setSort,
                    ),
                    DataColumn(
                      label: const Text('Status'),
                      onSort: _setSort,
                    ),
                    const DataColumn(label: Text('Actions')),
                  ],
                  source: source,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<ModuleDocument> _sortedItems(List<ModuleDocument> items) {
    final sorted = [...items];
    final column = _sortColumnIndex;
    if (column == null) {
      return sorted;
    }

    int compareString(String left, String right) =>
        left.toLowerCase().compareTo(right.toLowerCase());

    sorted.sort((left, right) {
      int result;
      switch (column) {
        case 0:
          result = compareString(left.documentCode, right.documentCode);
          break;
        case 1:
          result = compareString(left.documentName, right.documentName);
          break;
        case 2:
          result = compareString(left.applicableTo, right.applicableTo);
          break;
        case 3:
          result = (left.mandatory ? 1 : 0).compareTo(right.mandatory ? 1 : 0);
          break;
        case 4:
          result =
              compareString(left.requiredStageLabel, right.requiredStageLabel);
          break;
        case 5:
          result = compareString(left.blockingType, right.blockingType);
          break;
        case 6:
          result = left.alertBeforeDays.compareTo(right.alertBeforeDays);
          break;
        case 7:
          result = compareString(left.status, right.status);
          break;
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });

    return sorted;
  }

  void _setSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Widget _buildBasicsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        if (compact) {
          return Column(
            children: [
              TextFormField(
                controller: _documentCodeController,
                decoration: const InputDecoration(
                  labelText: 'Document Code',
                  hintText: 'Auto if empty',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _documentNameController,
                decoration: const InputDecoration(labelText: 'Document Name *'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedApplicableTo,
                decoration: const InputDecoration(labelText: 'Applicable To *'),
                items: [
                  for (final value in ModuleDocumentViewModel.applicableToOptions)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedApplicableTo = value);
                  }
                },
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _documentCodeController,
                decoration: const InputDecoration(
                  labelText: 'Document Code',
                  hintText: 'Auto if empty',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _documentNameController,
                decoration: const InputDecoration(labelText: 'Document Name *'),
                validator: _required,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedApplicableTo,
                decoration: const InputDecoration(labelText: 'Applicable To *'),
                items: [
                  for (final value in ModuleDocumentViewModel.applicableToOptions)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedApplicableTo = value);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequirementRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        if (compact) {
          return Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Business meaning and usage guidance',
                ),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _mandatory,
                onChanged: (value) => setState(() => _mandatory = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Mandatory'),
              ),
              SwitchListTile(
                value: _hasExpiry,
                onChanged: (value) => setState(() => _hasExpiry = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Has Expiry'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _alertDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Alert Before Days',
                ),
                enabled: _hasExpiry,
                validator: _validateAlertDays,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Business meaning and usage guidance',
                ),
                minLines: 2,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _mandatory,
                    onChanged: (value) => setState(() => _mandatory = value),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mandatory'),
                  ),
                  SwitchListTile(
                    value: _hasExpiry,
                    onChanged: (value) => setState(() => _hasExpiry = value),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Has Expiry'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _alertDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Alert Before Days',
                    ),
                    enabled: _hasExpiry,
                    validator: _validateAlertDays,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStageRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: [
        _stageToggle('Check at Assignment', _checkAtAssignment,
            (v) => _checkAtAssignment = v),
        _stageToggle('Check at Inspection', _checkAtInspection,
            (v) => _checkAtInspection = v),
        _stageToggle(
            'Check at Dispatch', _checkAtDispatch, (v) => _checkAtDispatch = v),
        _stageToggle('Check at Trip Start', _checkAtTripStart,
            (v) => _checkAtTripStart = v),
        _stageToggle('Check at Delivery Closure', _checkAtDeliveryClosure,
            (v) => _checkAtDeliveryClosure = v),
      ],
    );
  }

  Widget _stageToggle(String label, bool value, ValueSetter<bool> onChanged) {
    return SizedBox(
      width: 230,
      child: CheckboxListTile(
        value: value,
        onChanged: (next) => setState(() => onChanged(next ?? false)),
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(label),
      ),
    );
  }

  Widget _buildBlockingRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMissingAction,
                decoration: const InputDecoration(labelText: 'Missing Action'),
                items: [
                  for (final action in ModuleDocumentViewModel.actionTypes)
                    DropdownMenuItem(value: action, child: Text(action)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMissingAction = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedExpiredAction,
                decoration: const InputDecoration(labelText: 'Expired Action'),
                items: [
                  for (final action in ModuleDocumentViewModel.actionTypes)
                    DropdownMenuItem(value: action, child: Text(action)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedExpiredAction = value);
                  }
                },
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedMissingAction,
                decoration: const InputDecoration(labelText: 'Missing Action'),
                items: [
                  for (final action in ModuleDocumentViewModel.actionTypes)
                    DropdownMenuItem(value: action, child: Text(action)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMissingAction = value);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedExpiredAction,
                decoration: const InputDecoration(labelText: 'Expired Action'),
                items: [
                  for (final action in ModuleDocumentViewModel.actionTypes)
                    DropdownMenuItem(value: action, child: Text(action)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedExpiredAction = value);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEvidenceRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        if (compact) {
          return Column(
            children: [
              SwitchListTile(
                value: _uploadRequired,
                onChanged: (value) => setState(() => _uploadRequired = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Upload Required'),
              ),
              SwitchListTile(
                value: _overrideAllowed,
                onChanged: (value) => setState(() => _overrideAllowed = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Override Allowed'),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: SwitchListTile(
                value: _uploadRequired,
                onChanged: (value) => setState(() => _uploadRequired = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Upload Required'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SwitchListTile(
                value: _overrideAllowed,
                onChanged: (value) => setState(() => _overrideAllowed = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Override Allowed'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(ModuleDocumentUiState data) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _filterDropdown(
          width: 210,
          value: data.statusFilter,
          label: 'Status',
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Active', child: Text('Active')),
            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
          ],
          onChanged: (value) => ref
              .read(moduleDocumentViewModelProvider.notifier)
              .setStatusFilter(value),
        ),
        _filterDropdown(
          width: 210,
          value: data.applicableToFilter,
          label: 'Applicable To',
          items: [
            const DropdownMenuItem(value: 'All', child: Text('All')),
            for (final value in ModuleDocumentViewModel.applicableToOptions)
              DropdownMenuItem(value: value, child: Text(value)),
          ],
          onChanged: (value) => ref
              .read(moduleDocumentViewModelProvider.notifier)
              .setApplicableToFilter(value),
        ),
        _filterDropdown(
          width: 210,
          value: data.mandatoryFilter,
          label: 'Mandatory',
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Mandatory', child: Text('Mandatory')),
            DropdownMenuItem(value: 'Optional', child: Text('Optional')),
          ],
          onChanged: (value) => ref
              .read(moduleDocumentViewModelProvider.notifier)
              .setMandatoryFilter(value),
        ),
        _filterDropdown(
          width: 210,
          value: data.blockingFilter,
          label: 'Blocking Type',
          items: [
            const DropdownMenuItem(value: 'All', child: Text('All')),
            for (final action in ModuleDocumentViewModel.actionTypes)
              DropdownMenuItem(value: action, child: Text(action)),
          ],
          onChanged: (value) => ref
              .read(moduleDocumentViewModelProvider.notifier)
              .setBlockingFilter(value),
        ),
        _filterDropdown(
          width: 210,
          value: data.stageFilter,
          label: 'Required Stage',
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Assignment', child: Text('Assignment')),
            DropdownMenuItem(value: 'Inspection', child: Text('Inspection')),
            DropdownMenuItem(value: 'Dispatch', child: Text('Dispatch')),
            DropdownMenuItem(value: 'Trip Start', child: Text('Trip Start')),
            DropdownMenuItem(
              value: 'Delivery Closure',
              child: Text('Delivery Closure'),
            ),
          ],
          onChanged: (value) => ref
              .read(moduleDocumentViewModelProvider.notifier)
              .setStageFilter(value),
        ),
        _filterDropdown(
          width: 210,
          value: data.expiryTrackingFilter,
          label: 'Expiry Tracking Enabled',
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Enabled', child: Text('Enabled')),
            DropdownMenuItem(value: 'Disabled', child: Text('Disabled')),
          ],
          onChanged: (value) => ref
              .read(moduleDocumentViewModelProvider.notifier)
              .setExpiryTrackingFilter(value),
        ),
      ],
    );
  }

  Widget _filterDropdown({
    required double width,
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items,
        onChanged: (next) {
          if (next != null) {
            onChanged(next);
          }
        },
      ),
    );
  }

  Future<void> _submitRule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(moduleDocumentViewModelProvider.notifier);
    final message = _isEditMode
        ? await notifier.updateDocument(
            id: _editingRuleId!,
            documentCode: _documentCodeController.text,
            documentName: _documentNameController.text,
            description: _descriptionController.text,
            applicableTo: _selectedApplicableTo,
            mandatory: _mandatory,
            hasExpiry: _hasExpiry,
            alertBeforeDays: int.tryParse(_alertDaysController.text) ?? 0,
            checkAtAssignment: _checkAtAssignment,
            checkAtInspection: _checkAtInspection,
            checkAtDispatch: _checkAtDispatch,
            checkAtTripStart: _checkAtTripStart,
            checkAtDeliveryClosure: _checkAtDeliveryClosure,
            missingAction: _selectedMissingAction,
            expiredAction: _selectedExpiredAction,
            uploadRequired: _uploadRequired,
            overrideAllowed: _overrideAllowed,
            status: _selectedStatus,
          )
        : await notifier.addDocument(
            documentCode: _documentCodeController.text,
            documentName: _documentNameController.text,
            description: _descriptionController.text,
            applicableTo: _selectedApplicableTo,
            mandatory: _mandatory,
            hasExpiry: _hasExpiry,
            alertBeforeDays: int.tryParse(_alertDaysController.text) ?? 0,
            checkAtAssignment: _checkAtAssignment,
            checkAtInspection: _checkAtInspection,
            checkAtDispatch: _checkAtDispatch,
            checkAtTripStart: _checkAtTripStart,
            checkAtDeliveryClosure: _checkAtDeliveryClosure,
            missingAction: _selectedMissingAction,
            expiredAction: _selectedExpiredAction,
            uploadRequired: _uploadRequired,
            overrideAllowed: _overrideAllowed,
            status: _selectedStatus,
          );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (message.startsWith('Compliance rule created') ||
        message.startsWith('Compliance rule updated')) {
      _closeEditor();
    }
  }

  void _openEditorForCreate() {
    _resetForm();
    setState(() {
      _showEditor = true;
      _editingRuleId = null;
    });
  }

  void _openEditorForEdit(ModuleDocument item) {
    _applyRuleToForm(item);
    setState(() {
      _showEditor = true;
      _editingRuleId = item.id;
    });
  }

  Future<void> _deleteRule(ModuleDocument item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete compliance rule?'),
          content: Text(
              'Delete `${item.documentName}` for `${item.applicableTo}` from the master list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) {
      return;
    }

    final message = await ref
        .read(moduleDocumentViewModelProvider.notifier)
        .deleteDocument(item.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRuleDetails(ModuleDocument item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.documentName),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Code', item.documentCode),
                  _detailRow('Applicable To', item.applicableTo),
                  _detailRow('Status', item.status),
                  _detailRow('Mandatory', item.mandatory ? 'Yes' : 'No'),
                  _detailRow('Description', item.description),
                  _detailRow('Required Stages', item.requiredStageLabel),
                  _detailRow('Missing Action', item.missingAction),
                  _detailRow('Expired Action', item.expiredAction),
                  _detailRow('Has Expiry', item.hasExpiry ? 'Yes' : 'No'),
                  _detailRow('Alert Before Days',
                      item.hasExpiry ? '${item.alertBeforeDays}' : '-'),
                  _detailRow(
                      'Upload Required', item.uploadRequired ? 'Yes' : 'No'),
                  _detailRow(
                      'Override Allowed', item.overrideAllowed ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.trim().isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  void _closeEditor() {
    _resetForm();
    setState(() {
      _showEditor = false;
      _editingRuleId = null;
    });
  }

  void _applyRuleToForm(ModuleDocument item) {
    _documentCodeController.text = item.documentCode;
    _documentNameController.text = item.documentName;
    _descriptionController.text = item.description;
    _alertDaysController.text = item.alertBeforeDays.toString();
    _selectedApplicableTo = item.applicableTo;
    _selectedStatus = item.status;
    _selectedMissingAction = item.missingAction;
    _selectedExpiredAction = item.expiredAction;
    _mandatory = item.mandatory;
    _hasExpiry = item.hasExpiry;
    _checkAtAssignment = item.checkAtAssignment;
    _checkAtInspection = item.checkAtInspection;
    _checkAtDispatch = item.checkAtDispatch;
    _checkAtTripStart = item.checkAtTripStart;
    _checkAtDeliveryClosure = item.checkAtDeliveryClosure;
    _uploadRequired = item.uploadRequired;
    _overrideAllowed = item.overrideAllowed;
  }

  void _resetForm() {
    _documentCodeController.clear();
    _documentNameController.clear();
    _descriptionController.clear();
    _alertDaysController.text = '30';
    _selectedApplicableTo = ModuleDocumentViewModel.applicableToOptions.first;
    _selectedStatus = 'Active';
    _selectedMissingAction = ModuleDocumentViewModel.actionTypes[1];
    _selectedExpiredAction = ModuleDocumentViewModel.actionTypes[3];
    _mandatory = true;
    _hasExpiry = true;
    _checkAtAssignment = true;
    _checkAtInspection = false;
    _checkAtDispatch = true;
    _checkAtTripStart = false;
    _checkAtDeliveryClosure = false;
    _uploadRequired = true;
    _overrideAllowed = false;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateAlertDays(String? value) {
    if (!_hasExpiry) {
      return null;
    }
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return 'Enter 0 or positive number';
    }
    return null;
  }
}

class _ComplianceRuleTableSource extends DataTableSource {
  _ComplianceRuleTableSource({
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ModuleDocument> items;
  final ValueChanged<ModuleDocument> onView;
  final ValueChanged<ModuleDocument> onEdit;
  final Future<void> Function(ModuleDocument) onDelete;

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= items.length) {
      return null;
    }
    final item = items[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.documentCode)),
        DataCell(Text(item.documentName)),
        DataCell(Text(item.applicableTo)),
        DataCell(Text(item.mandatory ? 'Yes' : 'No')),
        DataCell(Text(item.requiredStageLabel)),
        DataCell(Text(item.blockingType)),
        DataCell(Text(item.hasExpiry ? '${item.alertBeforeDays}' : '-')),
        DataCell(Text(item.status)),
        DataCell(
          Wrap(
            spacing: 2,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View',
                onPressed: () => onView(item),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => onEdit(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => onDelete(item),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;
}
