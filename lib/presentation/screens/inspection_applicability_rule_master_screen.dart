import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionApplicabilityRuleMasterScreen extends ConsumerWidget {
  const InspectionApplicabilityRuleMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final rules = [...catalog.applicabilityRules]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return OpsShell(
      title: 'Applicability Rule Master',
      currentRoute: RoutePaths.inspectionApplicabilityRuleMaster,
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
                  DataColumn(label: Text('Target Level')),
                  DataColumn(label: Text('Target ID')),
                  DataColumn(label: Text('Condition')),
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in rules)
                    DataRow(cells: [
                      DataCell(Text(item.ruleId)),
                      DataCell(Text(_targetLevel(item.targetLevel))),
                      DataCell(Text(item.targetId)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            '${item.conditionField} ${_operator(item.operator)} ${item.conditionValue}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(_action(item.action))),
                      DataCell(Text('${item.priority}')),
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
                                  .toggleApplicabilityRuleActive(item.ruleId),
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
      [ApplicabilityRuleMaster? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ApplicabilityRuleEditorDialog(existing: existing),
    );
  }

  String _targetLevel(RuleTargetLevel value) {
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

  String _operator(RuleOperator value) {
    switch (value) {
      case RuleOperator.equals:
        return '=';
      case RuleOperator.notEquals:
        return '!=';
      case RuleOperator.contains:
        return 'contains';
      case RuleOperator.greaterThan:
        return '>';
      case RuleOperator.lessThan:
        return '<';
      case RuleOperator.inList:
        return 'in';
    }
  }

  String _action(RuleAction value) {
    switch (value) {
      case RuleAction.include:
        return 'Include';
      case RuleAction.exclude:
        return 'Exclude';
      case RuleAction.show:
        return 'Show';
      case RuleAction.hide:
        return 'Hide';
      case RuleAction.block:
        return 'Block';
    }
  }
}

class _ApplicabilityRuleEditorDialog extends ConsumerStatefulWidget {
  const _ApplicabilityRuleEditorDialog({this.existing});

  final ApplicabilityRuleMaster? existing;

  @override
  ConsumerState<_ApplicabilityRuleEditorDialog> createState() =>
      _ApplicabilityRuleEditorDialogState();
}

class _ApplicabilityRuleEditorDialogState
    extends ConsumerState<_ApplicabilityRuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late RuleTargetLevel _targetLevel;
  late final TextEditingController _targetIdCtrl;
  late final TextEditingController _conditionFieldCtrl;
  late RuleOperator _operator;
  late final TextEditingController _conditionValueCtrl;
  late RuleAction _action;
  late final TextEditingController _priorityCtrl;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _targetLevel = existing?.targetLevel ?? RuleTargetLevel.item;
    _targetIdCtrl = TextEditingController(text: existing?.targetId ?? '');
    _conditionFieldCtrl =
        TextEditingController(text: existing?.conditionField ?? '');
    _operator = existing?.operator ?? RuleOperator.equals;
    _conditionValueCtrl =
        TextEditingController(text: existing?.conditionValue ?? '');
    _action = existing?.action ?? RuleAction.show;
    _priorityCtrl =
        TextEditingController(text: existing?.priority.toString() ?? '10');
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _targetIdCtrl.dispose();
    _conditionFieldCtrl.dispose();
    _conditionValueCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title:
          Text(isEdit ? 'Edit Applicability Rule' : 'Add Applicability Rule'),
      content: SizedBox(
        width: 620,
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _targetLevel = value);
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
                  controller: _conditionFieldCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Condition Field'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<RuleOperator>(
                  value: _operator,
                  decoration: const InputDecoration(labelText: 'Operator'),
                  items: const [
                    DropdownMenuItem(
                        value: RuleOperator.equals, child: Text('Equals')),
                    DropdownMenuItem(
                        value: RuleOperator.notEquals,
                        child: Text('Not Equals')),
                    DropdownMenuItem(
                        value: RuleOperator.contains, child: Text('Contains')),
                    DropdownMenuItem(
                        value: RuleOperator.greaterThan,
                        child: Text('Greater Than')),
                    DropdownMenuItem(
                        value: RuleOperator.lessThan, child: Text('Less Than')),
                    DropdownMenuItem(
                        value: RuleOperator.inList, child: Text('In List')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _operator = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _conditionValueCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Condition Value'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<RuleAction>(
                  value: _action,
                  decoration: const InputDecoration(labelText: 'Action'),
                  items: const [
                    DropdownMenuItem(
                        value: RuleAction.include, child: Text('Include')),
                    DropdownMenuItem(
                        value: RuleAction.exclude, child: Text('Exclude')),
                    DropdownMenuItem(
                        value: RuleAction.show, child: Text('Show')),
                    DropdownMenuItem(
                        value: RuleAction.hide, child: Text('Hide')),
                    DropdownMenuItem(
                        value: RuleAction.block, child: Text('Block')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _action = value);
                    }
                  },
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
    final id = widget.existing?.ruleId ?? notifier.nextApplicabilityRuleId();
    notifier.upsertApplicabilityRule(
      ApplicabilityRuleMaster(
        ruleId: id,
        targetLevel: _targetLevel,
        targetId: _targetIdCtrl.text.trim(),
        conditionField: _conditionFieldCtrl.text.trim(),
        operator: _operator,
        conditionValue: _conditionValueCtrl.text.trim(),
        action: _action,
        priority: int.parse(_priorityCtrl.text.trim()),
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
