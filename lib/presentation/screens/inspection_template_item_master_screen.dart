import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionTemplateItemMasterScreen extends ConsumerWidget {
  const InspectionTemplateItemMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final items = [...catalog.items]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    String sectionName(String sectionId) {
      return catalog.sections
              .where((item) => item.sectionId == sectionId)
              .map((item) => item.sectionName)
              .firstOrNull ??
          sectionId;
    }

    return OpsShell(
      title: 'Template Item Master',
      currentRoute: RoutePaths.inspectionTemplateItemMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
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
                  DataColumn(label: Text('Section')),
                  DataColumn(label: Text('Input Type')),
                  DataColumn(label: Text('Severity')),
                  DataColumn(label: Text('Order')),
                  DataColumn(label: Text('Mandatory')),
                  DataColumn(label: Text('Dispatch Blocker')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in items)
                    DataRow(cells: [
                      DataCell(Text(item.itemCode)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            item.itemName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(sectionName(item.sectionId))),
                      DataCell(Text(_inputType(item.inputType))),
                      DataCell(Text(item.severity.label)),
                      DataCell(Text('${item.displayOrder}')),
                      DataCell(Text(item.mandatoryFlag ? 'Yes' : 'No')),
                      DataCell(Text(item.dispatchBlockerFlag ? 'Yes' : 'No')),
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
                              onPressed: () =>
                                  notifier.toggleItemActive(item.itemId),
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
      [TemplateItemMasterV2? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TemplateItemEditorDialog(existing: existing),
    );
  }

  String _inputType(InspectionInputType value) {
    switch (value) {
      case InspectionInputType.passFail:
        return 'Pass/Fail';
      case InspectionInputType.yesNo:
        return 'Yes/No';
      case InspectionInputType.text:
        return 'Text';
      case InspectionInputType.number:
        return 'Number';
      case InspectionInputType.date:
        return 'Date';
      case InspectionInputType.expiryCheck:
        return 'Expiry Check';
      case InspectionInputType.dropdown:
        return 'Dropdown';
      case InspectionInputType.photoOnly:
        return 'Photo Only';
      case InspectionInputType.videoOnly:
        return 'Video Only';
    }
  }
}

class _TemplateItemEditorDialog extends ConsumerStatefulWidget {
  const _TemplateItemEditorDialog({this.existing});

  final TemplateItemMasterV2? existing;

  @override
  ConsumerState<_TemplateItemEditorDialog> createState() =>
      _TemplateItemEditorDialogState();
}

class _TemplateItemEditorDialogState
    extends ConsumerState<_TemplateItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _sectionId;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _expectedValueCtrl;
  late final TextEditingController _helpTextCtrl;
  late InspectionInputType _inputType;
  late InspectionFailureSeverity _severity;
  bool _mandatory = true;
  bool _remarkOnFail = true;
  bool _photoOnFail = false;
  bool _videoOnFail = false;
  bool _dispatchBlocker = true;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final catalog = ref.read(inspectionMasterCatalogProvider);
    final existing = widget.existing;
    _sectionId = existing?.sectionId ??
        (catalog.sections.isEmpty ? '' : catalog.sections.first.sectionId);
    _codeCtrl = TextEditingController(text: existing?.itemCode ?? '');
    _nameCtrl = TextEditingController(text: existing?.itemName ?? '');
    _descriptionCtrl =
        TextEditingController(text: existing?.itemDescription ?? '');
    _orderCtrl = TextEditingController(
      text: existing?.displayOrder.toString() ?? '1',
    );
    _expectedValueCtrl =
        TextEditingController(text: existing?.defaultExpectedValue ?? 'pass');
    _helpTextCtrl = TextEditingController(text: existing?.helpText ?? '');
    _inputType = existing?.inputType ?? InspectionInputType.passFail;
    _severity = existing?.severity ?? InspectionFailureSeverity.low;
    _mandatory = existing?.mandatoryFlag ?? true;
    _remarkOnFail = existing?.requiresRemarkOnFail ?? true;
    _photoOnFail = existing?.requiresPhotoOnFail ?? false;
    _videoOnFail = existing?.requiresVideoOnFail ?? false;
    _dispatchBlocker = existing?.dispatchBlockerFlag ?? true;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _orderCtrl.dispose();
    _expectedValueCtrl.dispose();
    _helpTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Item Master' : 'Add Item Master'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: catalog.sections
                          .any((item) => item.sectionId == _sectionId)
                      ? _sectionId
                      : null,
                  decoration: const InputDecoration(labelText: 'Section'),
                  items: [
                    for (final item in catalog.sections)
                      DropdownMenuItem(
                        value: item.sectionId,
                        child: Text(item.sectionName),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sectionId = value);
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
                            const InputDecoration(labelText: 'Item Code'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Item Name'),
                        validator: _required,
                      ),
                    ),
                  ],
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
                      child: DropdownButtonFormField<InspectionInputType>(
                        value: _inputType,
                        decoration:
                            const InputDecoration(labelText: 'Input Type'),
                        items: [
                          for (final item in InspectionInputType.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(_inputTypeText(item)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _inputType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<InspectionFailureSeverity>(
                        value: _severity,
                        decoration:
                            const InputDecoration(labelText: 'Severity'),
                        items: [
                          for (final item in InspectionFailureSeverity.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _severity = value);
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
                        controller: _orderCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Display Order'),
                        validator: (value) {
                          final parsed = int.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter valid order';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _expectedValueCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Default Expected Value'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _helpTextCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Help Text'),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _mandatory,
                  onChanged: (value) =>
                      setState(() => _mandatory = value ?? false),
                  title: const Text('Mandatory'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _remarkOnFail,
                  onChanged: (value) =>
                      setState(() => _remarkOnFail = value ?? false),
                  title: const Text('Requires Remark On Fail'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _photoOnFail,
                  onChanged: (value) =>
                      setState(() => _photoOnFail = value ?? false),
                  title: const Text('Requires Photo On Fail'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _videoOnFail,
                  onChanged: (value) =>
                      setState(() => _videoOnFail = value ?? false),
                  title: const Text('Requires Video On Fail'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _dispatchBlocker,
                  onChanged: (value) =>
                      setState(() => _dispatchBlocker = value ?? false),
                  title: const Text('Dispatch Blocker'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (value) =>
                      setState(() => _active = value ?? false),
                  title: const Text('Active'),
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

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final id = widget.existing?.itemId ?? notifier.nextItemId();

    notifier.upsertItem(
      TemplateItemMasterV2(
        itemId: id,
        sectionId: _sectionId,
        itemCode: _codeCtrl.text.trim().toUpperCase(),
        itemName: _nameCtrl.text.trim(),
        itemDescription: _descriptionCtrl.text.trim(),
        inputType: _inputType,
        severity: _severity,
        mandatoryFlag: _mandatory,
        requiresRemarkOnFail: _remarkOnFail,
        requiresPhotoOnFail: _photoOnFail,
        requiresVideoOnFail: _videoOnFail,
        dispatchBlockerFlag: _dispatchBlocker,
        defaultExpectedValue: _expectedValueCtrl.text.trim(),
        displayOrder: int.parse(_orderCtrl.text.trim()),
        helpText: _helpTextCtrl.text.trim(),
        activeFlag: _active,
      ),
    );
    Navigator.of(context).pop();
  }

  String _inputTypeText(InspectionInputType value) {
    switch (value) {
      case InspectionInputType.passFail:
        return 'Pass/Fail';
      case InspectionInputType.yesNo:
        return 'Yes/No';
      case InspectionInputType.text:
        return 'Text';
      case InspectionInputType.number:
        return 'Number';
      case InspectionInputType.date:
        return 'Date';
      case InspectionInputType.expiryCheck:
        return 'Expiry Check';
      case InspectionInputType.dropdown:
        return 'Dropdown';
      case InspectionInputType.photoOnly:
        return 'Photo Only';
      case InspectionInputType.videoOnly:
        return 'Video Only';
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
