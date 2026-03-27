import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection_master_v2.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_master_v2_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionBundleTypeMappingMasterScreen extends ConsumerWidget {
  const InspectionBundleTypeMappingMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final notifier = ref.read(inspectionMasterCatalogProvider.notifier);
    final mappings = [...catalog.bundleTypeMappings]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    String bundleName(String id) {
      return catalog.bundles
              .where((item) => item.bundleId == id)
              .map((item) => item.bundleName)
              .firstOrNull ??
          id;
    }

    String typeName(String id) {
      return catalog.inspectionTypes
              .where((item) => item.inspectionTypeId == id)
              .map((item) => item.name)
              .firstOrNull ??
          id;
    }

    return OpsShell(
      title: 'Bundle-Type Mapping Master',
      currentRoute: RoutePaths.inspectionBundleTypeMappingMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => _openMappingEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Mapping'),
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
                  DataColumn(label: Text('Mapping ID')),
                  DataColumn(label: Text('Bundle')),
                  DataColumn(label: Text('Inspection Type')),
                  DataColumn(label: Text('Order')),
                  DataColumn(label: Text('Mandatory')),
                  DataColumn(label: Text('Inclusion Mode')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in mappings)
                    DataRow(cells: [
                      DataCell(Text(item.mappingId)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(
                            bundleName(item.bundleId),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(typeName(item.inspectionTypeId))),
                      DataCell(Text('${item.displayOrder}')),
                      DataCell(Text(item.mandatoryFlag ? 'Yes' : 'No')),
                      DataCell(Text(_inclusion(item.inclusionMode))),
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
                                  _openMappingEditor(context, ref, item),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Toggle Active',
                              onPressed: () =>
                                  notifier.toggleBundleTypeMappingActive(
                                      item.mappingId),
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

  Future<void> _openMappingEditor(BuildContext context, WidgetRef ref,
      [BundleInspectionTypeMapping? existing]) {
    return showDialog<void>(
      context: context,
      builder: (_) => _MappingEditorDialog(existing: existing),
    );
  }

  String _inclusion(BundleInclusionMode mode) {
    switch (mode) {
      case BundleInclusionMode.always:
        return 'Always';
      case BundleInclusionMode.conditional:
        return 'Conditional';
      case BundleInclusionMode.manual:
        return 'Manual';
    }
  }
}

class _MappingEditorDialog extends ConsumerStatefulWidget {
  const _MappingEditorDialog({this.existing});

  final BundleInspectionTypeMapping? existing;

  @override
  ConsumerState<_MappingEditorDialog> createState() =>
      _MappingEditorDialogState();
}

class _MappingEditorDialogState extends ConsumerState<_MappingEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _bundleId;
  late String _inspectionTypeId;
  late final TextEditingController _orderCtrl;
  late BundleInclusionMode _inclusionMode;
  bool _mandatory = true;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final catalog = ref.read(inspectionMasterCatalogProvider);
    final existing = widget.existing;
    _bundleId = existing?.bundleId ??
        (catalog.bundles.isEmpty ? '' : catalog.bundles.first.bundleId);
    _inspectionTypeId = existing?.inspectionTypeId ??
        (catalog.inspectionTypes.isEmpty
            ? ''
            : catalog.inspectionTypes.first.inspectionTypeId);
    _orderCtrl = TextEditingController(
      text: existing?.displayOrder.toString() ?? '1',
    );
    _inclusionMode = existing?.inclusionMode ?? BundleInclusionMode.always;
    _mandatory = existing?.mandatoryFlag ?? true;
    _active = existing?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _orderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(inspectionMasterCatalogProvider);
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Mapping' : 'Add Mapping'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value:
                      catalog.bundles.any((item) => item.bundleId == _bundleId)
                          ? _bundleId
                          : null,
                  decoration: const InputDecoration(labelText: 'Bundle'),
                  items: [
                    for (final item in catalog.bundles)
                      DropdownMenuItem(
                        value: item.bundleId,
                        child: Text(item.bundleName),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _bundleId = value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bundle is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inspection type is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _orderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Display Order'),
                  validator: (value) {
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid positive order';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<BundleInclusionMode>(
                  value: _inclusionMode,
                  decoration:
                      const InputDecoration(labelText: 'Inclusion Mode'),
                  items: const [
                    DropdownMenuItem(
                      value: BundleInclusionMode.always,
                      child: Text('Always'),
                    ),
                    DropdownMenuItem(
                      value: BundleInclusionMode.conditional,
                      child: Text('Conditional'),
                    ),
                    DropdownMenuItem(
                      value: BundleInclusionMode.manual,
                      child: Text('Manual'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _inclusionMode = value);
                    }
                  },
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
    final id = widget.existing?.mappingId ?? notifier.nextBundleTypeMappingId();

    notifier.upsertBundleTypeMapping(
      BundleInspectionTypeMapping(
        mappingId: id,
        bundleId: _bundleId,
        inspectionTypeId: _inspectionTypeId,
        displayOrder: int.parse(_orderCtrl.text.trim()),
        mandatoryFlag: _mandatory,
        inclusionMode: _inclusionMode,
        activeFlag: _active,
      ),
    );
    Navigator.of(context).pop();
  }
}
