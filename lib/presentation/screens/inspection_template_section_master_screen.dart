import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionTemplateSectionMasterScreen extends ConsumerWidget {
  const InspectionTemplateSectionMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final sections = [...catalog.sections]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    String templateName(String id) {
      return catalog.templates
              .where((item) => item.templateId == id)
              .map((item) => item.templateName)
              .firstOrNull ??
          id;
    }

    return OpsShell(
      title: 'Template Section Master',
      currentRoute: RoutePaths.inspectionTemplateSectionMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Section'),
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
                  DataColumn(label: Text('Section Code')),
                  DataColumn(label: Text('Section Name')),
                  DataColumn(label: Text('Template')),
                  DataColumn(label: Text('Order')),
                  DataColumn(label: Text('Stage Tag')),
                  DataColumn(label: Text('Collapsible')),
                  DataColumn(label: Text('Visible Summary')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in sections)
                    DataRow(cells: [
                      DataCell(Text(item.sectionCode)),
                      DataCell(Text(item.sectionName)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: Text(
                            templateName(item.templateId),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text('${item.displayOrder}')),
                      DataCell(Text(item.stageTag)),
                      DataCell(Text(item.collapsibleFlag ? 'Yes' : 'No')),
                      DataCell(Text(item.visibleInSummaryFlag ? 'Yes' : 'No')),
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
                                  notifier.toggleSectionActive(item.sectionId),
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
      [TemplateSectionMasterV2? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TemplateSectionEditorDialog(existing: existing),
    );
  }
}

class _TemplateSectionEditorDialog extends ConsumerStatefulWidget {
  const _TemplateSectionEditorDialog({this.existing});

  final TemplateSectionMasterV2? existing;

  @override
  ConsumerState<_TemplateSectionEditorDialog> createState() =>
      _TemplateSectionEditorDialogState();
}

class _TemplateSectionEditorDialogState
    extends ConsumerState<_TemplateSectionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _templateId;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _stageTagCtrl;
  bool _collapsible = true;
  bool _visibleSummary = true;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final catalog = ref.read(inspectionMasterCatalogProvider);
    final existing = widget.existing;

    _templateId = existing?.templateId ??
        (catalog.templates.isEmpty ? '' : catalog.templates.first.templateId);
    _codeCtrl = TextEditingController(text: existing?.sectionCode ?? '');
    _nameCtrl = TextEditingController(text: existing?.sectionName ?? '');
    _descriptionCtrl = TextEditingController(text: existing?.description ?? '');
    _orderCtrl = TextEditingController(
      text: existing?.displayOrder.toString() ?? '1',
    );
    _stageTagCtrl =
        TextEditingController(text: existing?.stageTag ?? 'pre-dispatch');
    _collapsible = existing?.collapsibleFlag ?? true;
    _visibleSummary = existing?.visibleInSummaryFlag ?? true;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _orderCtrl.dispose();
    _stageTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Section Master' : 'Add Section Master'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: catalog.templates
                          .any((item) => item.templateId == _templateId)
                      ? _templateId
                      : null,
                  decoration: const InputDecoration(labelText: 'Template'),
                  items: [
                    for (final item in catalog.templates)
                      DropdownMenuItem(
                        value: item.templateId,
                        child: Text(item.templateName),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _templateId = value);
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
                            const InputDecoration(labelText: 'Section Code'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Section Name'),
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
                        controller: _stageTagCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Stage Tag'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _collapsible,
                  onChanged: (value) =>
                      setState(() => _collapsible = value ?? false),
                  title: const Text('Collapsible'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _visibleSummary,
                  onChanged: (value) =>
                      setState(() => _visibleSummary = value ?? false),
                  title: const Text('Visible In Summary'),
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
    final id = widget.existing?.sectionId ?? notifier.nextSectionId();

    notifier.upsertSection(
      TemplateSectionMasterV2(
        sectionId: id,
        templateId: _templateId,
        sectionCode: _codeCtrl.text.trim().toUpperCase(),
        sectionName: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        displayOrder: int.parse(_orderCtrl.text.trim()),
        collapsibleFlag: _collapsible,
        visibleInSummaryFlag: _visibleSummary,
        stageTag: _stageTagCtrl.text.trim(),
        activeFlag: _active,
      ),
    );
    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
