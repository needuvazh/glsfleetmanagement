import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionMediaRuleMasterScreen extends ConsumerWidget {
  const InspectionMediaRuleMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final rules = [...catalog.mediaRules]
      ..sort((a, b) => a.mediaRuleId.compareTo(b.mediaRuleId));

    return OpsShell(
      title: 'Media Requirement Rule Master',
      currentRoute: RoutePaths.inspectionMediaRuleMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
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
                  DataColumn(label: Text('Rule ID')),
                  DataColumn(label: Text('Target')),
                  DataColumn(label: Text('Media Type')),
                  DataColumn(label: Text('Mandatory')),
                  DataColumn(label: Text('Min-Max')),
                  DataColumn(label: Text('Allowed On Result')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in rules)
                    DataRow(cells: [
                      DataCell(Text(item.mediaRuleId)),
                      DataCell(
                          Text('${item.targetLevel.name}:${item.targetId}')),
                      DataCell(Text(item.mediaType.name.toUpperCase())),
                      DataCell(Text(item.mandatoryFlag ? 'Yes' : 'No')),
                      DataCell(Text('${item.minCount}-${item.maxCount}')),
                      DataCell(Text(_allowed(item.allowedOnResult))),
                      DataCell(Text(item.activeFlag ? 'Active' : 'Inactive')),
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
                                  .toggleMediaRuleActive(item.mediaRuleId),
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
      [MediaRequirementRuleMaster? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _MediaRuleEditorDialog(existing: existing),
    );
  }

  String _allowed(AllowedOnResult value) {
    switch (value) {
      case AllowedOnResult.any:
        return 'Any';
      case AllowedOnResult.failOnly:
        return 'Fail Only';
      case AllowedOnResult.passOnly:
        return 'Pass Only';
    }
  }
}

class _MediaRuleEditorDialog extends ConsumerStatefulWidget {
  const _MediaRuleEditorDialog({this.existing});

  final MediaRequirementRuleMaster? existing;

  @override
  ConsumerState<_MediaRuleEditorDialog> createState() =>
      _MediaRuleEditorDialogState();
}

class _MediaRuleEditorDialogState
    extends ConsumerState<_MediaRuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late RuleTargetLevel _targetLevel;
  late final TextEditingController _targetIdCtrl;
  late MediaType _mediaType;
  bool _mandatory = true;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late AllowedOnResult _allowed;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _targetLevel = e?.targetLevel ?? RuleTargetLevel.item;
    _targetIdCtrl = TextEditingController(text: e?.targetId ?? '');
    _mediaType = e?.mediaType ?? MediaType.photo;
    _mandatory = e?.mandatoryFlag ?? true;
    _minCtrl = TextEditingController(text: (e?.minCount ?? 1).toString());
    _maxCtrl = TextEditingController(text: (e?.maxCount ?? 3).toString());
    _allowed = e?.allowedOnResult ?? AllowedOnResult.any;
    _active = e?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _targetIdCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Media Rule' : 'Add Media Rule'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RuleTargetLevel>(
                  value: _targetLevel,
                  decoration: const InputDecoration(labelText: 'Target Level'),
                  items: const [
                    DropdownMenuItem(
                        value: RuleTargetLevel.bundle, child: Text('Bundle')),
                    DropdownMenuItem(
                        value: RuleTargetLevel.template,
                        child: Text('Template')),
                    DropdownMenuItem(
                        value: RuleTargetLevel.section, child: Text('Section')),
                    DropdownMenuItem(
                        value: RuleTargetLevel.item, child: Text('Item')),
                  ],
                  onChanged: (v) =>
                      setState(() => _targetLevel = v ?? _targetLevel),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetIdCtrl,
                  decoration: const InputDecoration(labelText: 'Target ID'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MediaType>(
                  value: _mediaType,
                  decoration: const InputDecoration(labelText: 'Media Type'),
                  items: const [
                    DropdownMenuItem(
                        value: MediaType.photo, child: Text('Photo')),
                    DropdownMenuItem(
                        value: MediaType.video, child: Text('Video')),
                  ],
                  onChanged: (v) =>
                      setState(() => _mediaType = v ?? _mediaType),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Min Count'),
                        validator: _validNum,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Max Count'),
                        validator: _validNum,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AllowedOnResult>(
                  value: _allowed,
                  decoration:
                      const InputDecoration(labelText: 'Allowed On Result'),
                  items: const [
                    DropdownMenuItem(
                        value: AllowedOnResult.any, child: Text('Any')),
                    DropdownMenuItem(
                        value: AllowedOnResult.failOnly,
                        child: Text('Fail Only')),
                    DropdownMenuItem(
                        value: AllowedOnResult.passOnly,
                        child: Text('Pass Only')),
                  ],
                  onChanged: (v) => setState(() => _allowed = v ?? _allowed),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _mandatory,
                  onChanged: (v) => setState(() => _mandatory = v ?? false),
                  title: const Text('Mandatory'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v ?? false),
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
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Create')),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final id = widget.existing?.mediaRuleId ?? notifier.nextMediaRuleId();
    notifier.upsertMediaRule(
      MediaRequirementRuleMaster(
        mediaRuleId: id,
        targetLevel: _targetLevel,
        targetId: _targetIdCtrl.text.trim(),
        mediaType: _mediaType,
        mandatoryFlag: _mandatory,
        minCount: int.parse(_minCtrl.text.trim()),
        maxCount: int.parse(_maxCtrl.text.trim()),
        allowedOnResult: _allowed,
        activeFlag: _active,
      ),
    );
    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _validNum(String? value) {
    final v = int.tryParse((value ?? '').trim());
    if (v == null || v < 0) return 'Invalid number';
    return null;
  }
}
