import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionTemplateMasterScreen extends ConsumerWidget {
  const InspectionTemplateMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final templates = [...catalog.templates]
      ..sort((a, b) => a.templateCode.compareTo(b.templateCode));

    String typeName(String typeId) {
      return catalog.inspectionTypes
              .where((item) => item.inspectionTypeId == typeId)
              .map((item) => item.name)
              .firstOrNull ??
          typeId;
    }

    return OpsShell(
      title: 'Inspection Template Master',
      currentRoute: RoutePaths.inspectionTemplateMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Template'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Version')),
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Cargo')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Approval')),
                  DataColumn(label: Text('Dispatch Block')),
                  DataColumn(label: Text('Active')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in templates)
                    DataRow(cells: [
                      DataCell(Text(item.templateCode)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            item.templateName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(typeName(item.inspectionTypeId))),
                      DataCell(Text(item.version)),
                      DataCell(Text(item.clientId)),
                      DataCell(Text(item.vehicleType)),
                      DataCell(Text(item.cargoType)),
                      DataCell(Text(_status(item.status))),
                      DataCell(Text(item.requiresApproval ? 'Yes' : 'No')),
                      DataCell(Text(item.blocksDispatchOnFail ? 'Yes' : 'No')),
                      DataCell(
                        Text(
                          item.activeFlag ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: item.activeFlag
                                ? const Color(0xFF15803D)
                                : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _openEditor(context, ref, item),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Toggle Active',
                              onPressed: () => notifier
                                  .toggleTemplateActive(item.templateId),
                              icon: Icon(item.activeFlag
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                            ),
                          ],
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref,
      [InspectionTemplateMasterV2? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TemplateEditorDialog(existing: existing),
    );
  }

  String _status(TemplateStatus value) {
    switch (value) {
      case TemplateStatus.draft:
        return 'Draft';
      case TemplateStatus.published:
        return 'Published';
      case TemplateStatus.retired:
        return 'Retired';
    }
  }
}

class _TemplateEditorDialog extends ConsumerStatefulWidget {
  const _TemplateEditorDialog({this.existing});

  final InspectionTemplateMasterV2? existing;

  @override
  ConsumerState<_TemplateEditorDialog> createState() =>
      _TemplateEditorDialogState();
}

class _TemplateEditorDialogState extends ConsumerState<_TemplateEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _inspectionTypeId;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _versionCtrl;
  late final TextEditingController _effectiveFromCtrl;
  late final TextEditingController _effectiveToCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _vehicleCtrl;
  late final TextEditingController _trailerCtrl;
  late final TextEditingController _cargoCtrl;
  late final TextEditingController _routeCtrl;
  late final TextEditingController _clonedFromCtrl;
  late final TextEditingController _publishedByCtrl;
  late TemplateStatus _status;
  bool _requiresApproval = true;
  bool _blocksDispatchOnFail = true;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final catalog = ref.read(inspectionMasterCatalogProvider);
    final existing = widget.existing;

    _inspectionTypeId = existing?.inspectionTypeId ??
        (catalog.inspectionTypes.isEmpty
            ? ''
            : catalog.inspectionTypes.first.inspectionTypeId);
    _codeCtrl = TextEditingController(text: existing?.templateCode ?? '');
    _nameCtrl = TextEditingController(text: existing?.templateName ?? '');
    _versionCtrl = TextEditingController(text: existing?.version ?? '1.0.0');
    _effectiveFromCtrl = TextEditingController(
      text: _dateText(existing?.effectiveFrom ?? DateTime.now()),
    );
    _effectiveToCtrl = TextEditingController(
      text: existing?.effectiveTo == null
          ? ''
          : _dateText(existing!.effectiveTo!),
    );
    _clientCtrl = TextEditingController(text: existing?.clientId ?? 'ALL');
    _vehicleCtrl = TextEditingController(text: existing?.vehicleType ?? 'Any');
    _trailerCtrl = TextEditingController(text: existing?.trailerType ?? 'Any');
    _cargoCtrl = TextEditingController(text: existing?.cargoType ?? 'Any');
    _routeCtrl = TextEditingController(text: existing?.routeType ?? 'Any');
    _clonedFromCtrl =
        TextEditingController(text: existing?.clonedFromVersion ?? '');
    _publishedByCtrl =
        TextEditingController(text: existing?.publishedBy ?? 'Admin');
    _status = existing?.status ?? TemplateStatus.published;
    _requiresApproval = existing?.requiresApproval ?? true;
    _blocksDispatchOnFail = existing?.blocksDispatchOnFail ?? true;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _versionCtrl.dispose();
    _effectiveFromCtrl.dispose();
    _effectiveToCtrl.dispose();
    _clientCtrl.dispose();
    _vehicleCtrl.dispose();
    _trailerCtrl.dispose();
    _cargoCtrl.dispose();
    _routeCtrl.dispose();
    _clonedFromCtrl.dispose();
    _publishedByCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Template Master' : 'Add Template Master'),
      content: SizedBox(
        width: 700,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: catalog.inspectionTypes.any(
                          (item) => item.inspectionTypeId == _inspectionTypeId)
                      ? _inspectionTypeId
                      : null,
                  decoration:
                      const InputDecoration(labelText: 'Inspection Type'),
                  items: [
                    for (final item in catalog.inspectionTypes)
                      DropdownMenuItem(
                        value: item.inspectionTypeId,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _inspectionTypeId = value);
                    }
                  },
                  validator: _required,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Template Code'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Template Name'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _versionCtrl,
                        decoration: const InputDecoration(labelText: 'Version'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<TemplateStatus>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: TemplateStatus.draft,
                            child: Text('Draft'),
                          ),
                          DropdownMenuItem(
                            value: TemplateStatus.published,
                            child: Text('Published'),
                          ),
                          DropdownMenuItem(
                            value: TemplateStatus.retired,
                            child: Text('Retired'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _effectiveFromCtrl,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Effective From'),
                        validator: _required,
                        onTap: () => _pickDate(_effectiveFromCtrl),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _effectiveToCtrl,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Effective To'),
                        onTap: () => _pickDate(_effectiveToCtrl),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clientCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Client ID'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _vehicleCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Type'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _trailerCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Trailer Type'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cargoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Cargo Type'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _routeCtrl,
                  decoration: const InputDecoration(labelText: 'Route Type'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clonedFromCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Cloned From Version'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _publishedByCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Published By'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Approval'),
                  value: _requiresApproval,
                  onChanged: (value) =>
                      setState(() => _requiresApproval = value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Blocks Dispatch On Fail'),
                  value: _blocksDispatchOnFail,
                  onChanged: (value) =>
                      setState(() => _blocksDispatchOnFail = value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _active,
                  onChanged: (value) =>
                      setState(() => _active = value ?? false),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _parseDate(controller.text) ?? DateTime.now(),
    );
    if (picked != null) {
      controller.text = _dateText(picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final id = widget.existing?.templateId ?? notifier.nextTemplateId();
    notifier.upsertTemplate(
      InspectionTemplateMasterV2(
        templateId: id,
        inspectionTypeId: _inspectionTypeId,
        templateCode: _codeCtrl.text.trim().toUpperCase(),
        templateName: _nameCtrl.text.trim(),
        version: _versionCtrl.text.trim(),
        status: _status,
        effectiveFrom: _parseDate(_effectiveFromCtrl.text) ?? DateTime.now(),
        effectiveTo: _parseDate(_effectiveToCtrl.text),
        clientId: _clientCtrl.text.trim(),
        vehicleType: _vehicleCtrl.text.trim(),
        trailerType: _trailerCtrl.text.trim(),
        cargoType: _cargoCtrl.text.trim(),
        routeType: _routeCtrl.text.trim(),
        requiresApproval: _requiresApproval,
        blocksDispatchOnFail: _blocksDispatchOnFail,
        activeFlag: _active,
        clonedFromVersion: _clonedFromCtrl.text.trim().isEmpty
            ? null
            : _clonedFromCtrl.text.trim(),
        publishedBy: _publishedByCtrl.text.trim(),
        publishedAt: DateTime.now(),
      ),
    );
    Navigator.of(context).pop();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) {
      return null;
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  String _dateText(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
