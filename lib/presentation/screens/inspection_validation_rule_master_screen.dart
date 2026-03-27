import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionValidationRuleMasterScreen extends ConsumerWidget {
  const InspectionValidationRuleMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final rules = [...catalog.validationRules]
      ..sort((a, b) => a.validationId.compareTo(b.validationId));

    return OpsShell(
      title: 'Validation Rule Master',
      currentRoute: RoutePaths.inspectionValidationRuleMaster,
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
                  DataColumn(label: Text('Validation ID')),
                  DataColumn(label: Text('Target Level')),
                  DataColumn(label: Text('Target ID')),
                  DataColumn(label: Text('Trigger')),
                  DataColumn(label: Text('Expression')),
                  DataColumn(label: Text('Blocking Type')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in rules)
                    DataRow(cells: [
                      DataCell(Text(item.validationId)),
                      DataCell(Text(_targetLevel(item.targetLevel))),
                      DataCell(Text(item.targetId)),
                      DataCell(Text(item.triggerEvent)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Text(
                            item.validationExpression,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(_blocking(item.blockingType))),
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
                                  notifier.toggleValidationRuleActive(
                                item.validationId,
                              ),
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
      [ValidationRuleMaster? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ValidationRuleEditorDialog(existing: existing),
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

  String _blocking(BlockingType value) {
    switch (value) {
      case BlockingType.saveBlocker:
        return 'Save Blocker';
      case BlockingType.submitBlocker:
        return 'Submit Blocker';
      case BlockingType.dispatchBlocker:
        return 'Dispatch Blocker';
      case BlockingType.approvalBlocker:
        return 'Approval Blocker';
    }
  }
}

class _ValidationRuleEditorDialog extends ConsumerStatefulWidget {
  const _ValidationRuleEditorDialog({this.existing});

  final ValidationRuleMaster? existing;

  @override
  ConsumerState<_ValidationRuleEditorDialog> createState() =>
      _ValidationRuleEditorDialogState();
}

class _ValidationRuleEditorDialogState
    extends ConsumerState<_ValidationRuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late RuleTargetLevel _targetLevel;
  late final TextEditingController _targetIdCtrl;
  late final TextEditingController _triggerCtrl;
  late final TextEditingController _expressionCtrl;
  late final TextEditingController _errorCtrl;
  late BlockingType _blockingType;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _targetLevel = existing?.targetLevel ?? RuleTargetLevel.item;
    _targetIdCtrl = TextEditingController(text: existing?.targetId ?? '');
    _triggerCtrl =
        TextEditingController(text: existing?.triggerEvent ?? 'on_submit');
    _expressionCtrl =
        TextEditingController(text: existing?.validationExpression ?? '');
    _errorCtrl = TextEditingController(text: existing?.errorMessage ?? '');
    _blockingType = existing?.blockingType ?? BlockingType.submitBlocker;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _targetIdCtrl.dispose();
    _triggerCtrl.dispose();
    _expressionCtrl.dispose();
    _errorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Validation Rule' : 'Add Validation Rule'),
      content: SizedBox(
        width: 640,
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
                  controller: _triggerCtrl,
                  decoration: const InputDecoration(labelText: 'Trigger Event'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _expressionCtrl,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'Validation Expression'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _errorCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Error Message'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<BlockingType>(
                  value: _blockingType,
                  decoration: const InputDecoration(labelText: 'Blocking Type'),
                  items: const [
                    DropdownMenuItem(
                        value: BlockingType.saveBlocker,
                        child: Text('Save Blocker')),
                    DropdownMenuItem(
                        value: BlockingType.submitBlocker,
                        child: Text('Submit Blocker')),
                    DropdownMenuItem(
                        value: BlockingType.dispatchBlocker,
                        child: Text('Dispatch Blocker')),
                    DropdownMenuItem(
                        value: BlockingType.approvalBlocker,
                        child: Text('Approval Blocker')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _blockingType = value);
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
    final id = widget.existing?.validationId ?? notifier.nextValidationRuleId();

    notifier.upsertValidationRule(
      ValidationRuleMaster(
        validationId: id,
        targetLevel: _targetLevel,
        targetId: _targetIdCtrl.text.trim(),
        triggerEvent: _triggerCtrl.text.trim(),
        validationExpression: _expressionCtrl.text.trim(),
        errorMessage: _errorCtrl.text.trim(),
        blockingType: _blockingType,
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
