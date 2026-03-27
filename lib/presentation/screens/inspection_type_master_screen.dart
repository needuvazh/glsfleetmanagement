import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionTypeMasterScreen extends ConsumerWidget {
  const InspectionTypeMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final types = [...catalog.inspectionTypes]
      ..sort((a, b) => a.code.compareTo(b.code));

    return OpsShell(
      title: 'Inspection Type Master',
      currentRoute: RoutePaths.inspectionTypeMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openTypeEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Type'),
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
                  DataColumn(label: Text('Object Type')),
                  DataColumn(label: Text('Stage')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in types)
                    DataRow(
                      cells: [
                        DataCell(Text(item.code)),
                        DataCell(Text(item.name)),
                        DataCell(Text(_object(item.objectType))),
                        DataCell(Text(_stage(item.stage))),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Text(
                              item.description,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
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
                                    _openTypeEditor(context, ref, item),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Toggle Active',
                                onPressed: () {
                                  notifier.toggleInspectionTypeActive(
                                    item.inspectionTypeId,
                                  );
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

  Future<void> _openTypeEditor(BuildContext context, WidgetRef ref,
      [InspectionTypeMasterV2? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TypeEditorDialog(existing: existing),
    );
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

  String _object(InspectionObjectType value) {
    switch (value) {
      case InspectionObjectType.fleet:
        return 'Fleet';
      case InspectionObjectType.trailer:
        return 'Trailer';
      case InspectionObjectType.driver:
        return 'Driver';
      case InspectionObjectType.workOrder:
        return 'Work Order';
      case InspectionObjectType.trip:
        return 'Trip';
      case InspectionObjectType.cargo:
        return 'Cargo';
    }
  }
}

class _TypeEditorDialog extends ConsumerStatefulWidget {
  const _TypeEditorDialog({this.existing});

  final InspectionTypeMasterV2? existing;

  @override
  ConsumerState<_TypeEditorDialog> createState() => _TypeEditorDialogState();
}

class _TypeEditorDialogState extends ConsumerState<_TypeEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late InspectionStage _stage;
  late InspectionObjectType _objectType;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _codeCtrl = TextEditingController(text: existing?.code ?? '');
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _descriptionCtrl = TextEditingController(text: existing?.description ?? '');
    _stage = existing?.stage ?? InspectionStage.beforeDispatch;
    _objectType = existing?.objectType ?? InspectionObjectType.trip;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Inspection Type' : 'Add Inspection Type'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _required,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<InspectionObjectType>(
                  value: _objectType,
                  decoration: const InputDecoration(labelText: 'Object Type'),
                  items: const [
                    DropdownMenuItem(
                      value: InspectionObjectType.fleet,
                      child: Text('Fleet'),
                    ),
                    DropdownMenuItem(
                      value: InspectionObjectType.trailer,
                      child: Text('Trailer'),
                    ),
                    DropdownMenuItem(
                      value: InspectionObjectType.driver,
                      child: Text('Driver'),
                    ),
                    DropdownMenuItem(
                      value: InspectionObjectType.workOrder,
                      child: Text('Work Order'),
                    ),
                    DropdownMenuItem(
                      value: InspectionObjectType.trip,
                      child: Text('Trip'),
                    ),
                    DropdownMenuItem(
                      value: InspectionObjectType.cargo,
                      child: Text('Cargo'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _objectType = value);
                    }
                  },
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
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
    final id =
        widget.existing?.inspectionTypeId ?? notifier.nextInspectionTypeId();

    notifier.upsertInspectionType(
      InspectionTypeMasterV2(
        inspectionTypeId: id,
        code: _codeCtrl.text.trim().toUpperCase(),
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        stage: _stage,
        objectType: _objectType,
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
