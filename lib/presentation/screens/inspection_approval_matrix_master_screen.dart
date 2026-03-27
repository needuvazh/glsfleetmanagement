import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionApprovalMatrixMasterScreen extends ConsumerWidget {
  const InspectionApprovalMatrixMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final rules = [...catalog.approvalRules]
      ..sort((a, b) => a.approvalRuleId.compareTo(b.approvalRuleId));

    return OpsShell(
      title: 'Approval Matrix Master',
      currentRoute: RoutePaths.inspectionApprovalMatrixMaster,
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
                  DataColumn(label: Text('Condition')),
                  DataColumn(label: Text('Approver')),
                  DataColumn(label: Text('Escalation')),
                  DataColumn(label: Text('Override Allowed')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in rules)
                    DataRow(cells: [
                      DataCell(Text(item.approvalRuleId)),
                      DataCell(Text(item.targetScope.name)),
                      DataCell(Text(item.targetId)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            item.conditionExpression,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(item.approverRole)),
                      DataCell(Text(item.escalationRole)),
                      DataCell(Text(item.overrideAllowedFlag ? 'Yes' : 'No')),
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
                              onPressed: () =>
                                  notifier.toggleApprovalRuleActive(
                                      item.approvalRuleId),
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
      [ApprovalMatrixRuleMaster? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ApprovalRuleEditorDialog(existing: existing),
    );
  }
}

class _ApprovalRuleEditorDialog extends ConsumerStatefulWidget {
  const _ApprovalRuleEditorDialog({this.existing});

  final ApprovalMatrixRuleMaster? existing;

  @override
  ConsumerState<_ApprovalRuleEditorDialog> createState() =>
      _ApprovalRuleEditorDialogState();
}

class _ApprovalRuleEditorDialogState
    extends ConsumerState<_ApprovalRuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late RuleTargetLevel _targetScope;
  late final TextEditingController _targetIdCtrl;
  late final TextEditingController _conditionCtrl;
  late final TextEditingController _approverCtrl;
  late final TextEditingController _escalationCtrl;
  bool _overrideAllowed = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _targetScope = e?.targetScope ?? RuleTargetLevel.bundle;
    _targetIdCtrl = TextEditingController(text: e?.targetId ?? '');
    _conditionCtrl = TextEditingController(text: e?.conditionExpression ?? '');
    _approverCtrl =
        TextEditingController(text: e?.approverRole ?? 'Transport Supervisor');
    _escalationCtrl =
        TextEditingController(text: e?.escalationRole ?? 'Transport Manager');
    _overrideAllowed = e?.overrideAllowedFlag ?? false;
    _active = e?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _targetIdCtrl.dispose();
    _conditionCtrl.dispose();
    _approverCtrl.dispose();
    _escalationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Approval Rule' : 'Add Approval Rule'),
      content: SizedBox(
        width: 600,
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
                  onChanged: (v) =>
                      setState(() => _targetScope = v ?? _targetScope),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetIdCtrl,
                  decoration: const InputDecoration(labelText: 'Target ID'),
                  validator: _required,
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
                TextFormField(
                  controller: _approverCtrl,
                  decoration: const InputDecoration(labelText: 'Approver Role'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _escalationCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Escalation Role'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _overrideAllowed,
                  onChanged: (v) =>
                      setState(() => _overrideAllowed = v ?? false),
                  title: const Text('Override Allowed'),
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
    final id = widget.existing?.approvalRuleId ?? notifier.nextApprovalRuleId();
    notifier.upsertApprovalRule(
      ApprovalMatrixRuleMaster(
        approvalRuleId: id,
        targetScope: _targetScope,
        targetId: _targetIdCtrl.text.trim(),
        conditionExpression: _conditionCtrl.text.trim(),
        approverRole: _approverCtrl.text.trim(),
        escalationRole: _escalationCtrl.text.trim(),
        overrideAllowedFlag: _overrideAllowed,
        activeFlag: _active,
      ),
    );
    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}
