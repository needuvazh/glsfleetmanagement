import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionBundleMasterScreen extends ConsumerWidget {
  const InspectionBundleMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final bundles = [...catalog.bundles]
      ..sort((a, b) => a.bundleCode.compareTo(b.bundleCode));

    return OpsShell(
      title: 'Inspection Bundle Master',
      currentRoute: RoutePaths.inspectionBundleMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openBundleEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Bundle'),
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
                  DataColumn(label: Text('Stage')),
                  DataColumn(label: Text('Version')),
                  DataColumn(label: Text('Effective From')),
                  DataColumn(label: Text('Effective To')),
                  DataColumn(label: Text('Companies')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in bundles)
                    DataRow(
                      cells: [
                        DataCell(Text(item.bundleCode)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              item.bundleName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(_stage(item.stage))),
                        DataCell(Text(item.version)),
                        DataCell(Text(_fmtDate(item.effectiveFrom))),
                        DataCell(
                          Text(item.effectiveTo == null
                              ? '-'
                              : _fmtDate(item.effectiveTo!)),
                        ),
                        DataCell(Text(item.companyScope.join(', '))),
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
                                onPressed: () =>
                                    _openBundleEditor(context, ref, item),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Toggle Active',
                                onPressed: () {
                                  notifier.toggleBundleActive(item.bundleId);
                                },
                                icon: Icon(item.activeFlag
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                              ),
                            ],
                          ),
                        ),
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

  Future<void> _openBundleEditor(BuildContext context, WidgetRef ref,
      [InspectionBundleMaster? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _BundleEditorDialog(existing: existing),
    );
  }

  String _fmtDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }

  String _stage(InspectionStage value) {
    switch (value) {
      case InspectionStage.beforeDispatch:
        return 'Before Dispatch';
      case InspectionStage.duringTrip:
        return 'During Trip';
      case InspectionStage.postTrip:
        return 'Post Trip';
    }
  }
}

class _BundleEditorDialog extends ConsumerStatefulWidget {
  const _BundleEditorDialog({this.existing});

  final InspectionBundleMaster? existing;

  @override
  ConsumerState<_BundleEditorDialog> createState() =>
      _BundleEditorDialogState();
}

class _BundleEditorDialogState extends ConsumerState<_BundleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _versionCtrl;
  late final TextEditingController _effectiveFromCtrl;
  late final TextEditingController _effectiveToCtrl;
  late final TextEditingController _companyScopeCtrl;
  late InspectionStage _stage;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _codeCtrl = TextEditingController(text: existing?.bundleCode ?? '');
    _nameCtrl = TextEditingController(text: existing?.bundleName ?? '');
    _descriptionCtrl = TextEditingController(text: existing?.description ?? '');
    _versionCtrl = TextEditingController(text: existing?.version ?? '1.0.0');
    _effectiveFromCtrl = TextEditingController(
      text: _dateText(existing?.effectiveFrom ?? DateTime.now()),
    );
    _effectiveToCtrl = TextEditingController(
      text: existing?.effectiveTo == null
          ? ''
          : _dateText(existing!.effectiveTo!),
    );
    _companyScopeCtrl =
        TextEditingController(text: existing?.companyScope.join(', ') ?? 'GLS');
    _stage = existing?.stage ?? InspectionStage.beforeDispatch;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _versionCtrl.dispose();
    _effectiveFromCtrl.dispose();
    _effectiveToCtrl.dispose();
    _companyScopeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Bundle' : 'Add Bundle'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Bundle Code'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Bundle Name'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<InspectionStage>(
                  value: _stage,
                  decoration: const InputDecoration(labelText: 'Stage'),
                  items: const [
                    DropdownMenuItem(
                      value: InspectionStage.beforeDispatch,
                      child: Text('Before Dispatch'),
                    ),
                    DropdownMenuItem(
                      value: InspectionStage.duringTrip,
                      child: Text('During Trip'),
                    ),
                    DropdownMenuItem(
                      value: InspectionStage.postTrip,
                      child: Text('Post Trip'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _stage = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: _active,
                        onChanged: (value) => setState(() => _active = value),
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
                TextFormField(
                  controller: _companyScopeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company Scope (comma separated)',
                  ),
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
    final id = widget.existing?.bundleId ?? notifier.nextBundleId();

    final record = InspectionBundleMaster(
      bundleId: id,
      bundleCode: _codeCtrl.text.trim().toUpperCase(),
      bundleName: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      stage: _stage,
      activeFlag: _active,
      version: _versionCtrl.text.trim(),
      effectiveFrom: _parseDate(_effectiveFromCtrl.text) ?? DateTime.now(),
      effectiveTo: _parseDate(_effectiveToCtrl.text),
      companyScope: _companyScopeCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    notifier.upsertBundle(record);
    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
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
}
