import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionResultLogicRuleMasterScreen extends ConsumerWidget {
  const InspectionResultLogicRuleMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final rules = [...catalog.resultRules]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return OpsShell(
      title: 'Result Logic Rule Master',
      currentRoute: RoutePaths.inspectionResultLogicRuleMaster,
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
                  DataColumn(label: Text('Target Scope')),
                  DataColumn(label: Text('Target ID')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Condition')),
                  DataColumn(label: Text('Output Status')),
                  DataColumn(label: Text('Output Result')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in rules)
                    DataRow(cells: [
                      DataCell(Text(item.resultRuleId)),
                      DataCell(Text(_targetScope(item.targetScope))),
                      DataCell(Text(item.targetId)),
                      DataCell(Text('${item.priority}')),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            item.conditionExpression,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(item.outputStatus.label)),
                      DataCell(Text(item.outputResult.label)),
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
                                  .toggleResultRuleActive(item.resultRuleId),
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
      [ResultLogicRuleMaster? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ResultLogicRuleEditorDialog(existing: existing),
    );
  }

  String _targetScope(RuleTargetLevel value) {
    switch (value) {
      case RuleTargetLevel.bundle:
        return 'Bundle';
      case RuleTargetLevel.template:
        return 'Template';
      case RuleTargetLevel.section:
        return 'Section';
      case RuleTargetLevel.item:
        return 'Item';
    }
  }
}

class _ResultLogicRuleEditorDialog extends ConsumerStatefulWidget {
  const _ResultLogicRuleEditorDialog({this.existing});

  final ResultLogicRuleMaster? existing;

  @override
  ConsumerState<_ResultLogicRuleEditorDialog> createState() =>
      _ResultLogicRuleEditorDialogState();
}

class _ResultLogicRuleEditorDialogState
    extends ConsumerState<_ResultLogicRuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late RuleTargetLevel _targetScope;
  late final TextEditingController _targetIdCtrl;
  late final TextEditingController _priorityCtrl;
  late final TextEditingController _conditionCtrl;
  late InspectionStatus _outputStatus;
  late InspectionResult _outputResult;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _targetScope = existing?.targetScope ?? RuleTargetLevel.bundle;
    _targetIdCtrl = TextEditingController(text: existing?.targetId ?? '');
    _priorityCtrl =
        TextEditingController(text: existing?.priority.toString() ?? '10');
    _conditionCtrl =
        TextEditingController(text: existing?.conditionExpression ?? '');
    _outputStatus = existing?.outputStatus ?? InspectionStatus.draft;
    _outputResult = existing?.outputResult ?? InspectionResult.failed;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _targetIdCtrl.dispose();
    _priorityCtrl.dispose();
    _conditionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Result Logic Rule' : 'Add Result Logic Rule'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RuleTargetLevel>(
                  value: _targetScope,
                  decoration: const InputDecoration(labelText: 'Target Scope'),
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _targetScope = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetIdCtrl,
                  decoration: const InputDecoration(labelText: 'Target ID'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priorityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  validator: (value) {
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter valid priority';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _conditionCtrl,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'Condition Expression'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<InspectionStatus>(
                  value: _outputStatus,
                  decoration: const InputDecoration(labelText: 'Output Status'),
                  items: [
                    for (final item in InspectionStatus.values)
                      DropdownMenuItem(
                        value: item,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _outputStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<InspectionResult>(
                  value: _outputResult,
                  decoration: const InputDecoration(labelText: 'Output Result'),
                  items: [
                    for (final item in InspectionResult.values)
                      DropdownMenuItem(
                        value: item,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _outputResult = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
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
    final id = widget.existing?.resultRuleId ?? notifier.nextResultRuleId();
    notifier.upsertResultRule(
      ResultLogicRuleMaster(
        resultRuleId: id,
        targetScope: _targetScope,
        targetId: _targetIdCtrl.text.trim(),
        priority: int.parse(_priorityCtrl.text.trim()),
        conditionExpression: _conditionCtrl.text.trim(),
        outputStatus: _outputStatus,
        outputResult: _outputResult,
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
