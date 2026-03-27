import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vehicle_type_viewmodel.dart';
import '../widgets/module_document_upload_section.dart';
import '../widgets/ops_shell.dart';
import 'inspection_template_store.dart';

class InspectionTemplateFormScreen extends ConsumerStatefulWidget {
  const InspectionTemplateFormScreen({super.key, this.editTemplateId});

  final String? editTemplateId;

  @override
  ConsumerState<InspectionTemplateFormScreen> createState() =>
      _InspectionTemplateFormScreenState();
}

class _InspectionTemplateFormScreenState
    extends ConsumerState<InspectionTemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _frequencyCtrl;
  late final List<_ItemDraft> _items;
  late InspectionType _type;
  String _selectedVehicleType = 'Truck';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final existing = widget.editTemplateId == null
        ? null
        : InspectionTemplateStore.byId(widget.editTemplateId!);
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _descriptionCtrl = TextEditingController(text: existing?.description ?? '');
    _frequencyCtrl = TextEditingController(
      text: existing?.frequency ?? 'On Demand',
    );
    _selectedVehicleType = existing?.applicableVehicleType ?? 'Truck';
    _type = existing?.inspectionType ?? InspectionType.preTrip;
    _items = existing == null
        ? <_ItemDraft>[_ItemDraft.withName('Tyres')]
        : existing.items
            .map(
              (item) => _ItemDraft(
                nameController: TextEditingController(text: item.name),
                categoryController: TextEditingController(text: item.category),
                mandatory: item.mandatory,
                requiresPhoto: item.requiresPhoto,
                requiresVideo: item.requiresVideo,
                severity: item.severity,
              ),
            )
            .toList();
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _frequencyCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editTemplateId != null;
    final vehicleTypeState = ref.watch(vehicleTypeViewModelProvider);
    final vehicleTypeOptions = _vehicleTypeOptions(vehicleTypeState);
    final selectedVehicleType =
        vehicleTypeOptions.contains(_selectedVehicleType)
            ? _selectedVehicleType
            : (vehicleTypeOptions.isEmpty ? null : vehicleTypeOptions.first);

    return OpsShell(
      title: isEdit ? 'Edit Inspection Template' : 'Create Inspection Template',
      currentRoute: RoutePaths.inspectionTemplates,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Template' : 'Create Template',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Template Name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Template name is required'
                              : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionCtrl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<InspectionType>(
                            value: _type,
                            decoration: const InputDecoration(
                              labelText: 'Inspection Type',
                            ),
                            items: [
                              for (final value in InspectionType.values)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(value.label),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _type = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _frequencyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Frequency',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedVehicleType,
                            decoration: const InputDecoration(
                              labelText: 'Applicable Vehicle Type',
                            ),
                            items: [
                              for (final option in vehicleTypeOptions)
                                DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ),
                            ],
                            onChanged: vehicleTypeOptions.isEmpty
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(
                                          () => _selectedVehicleType = value);
                                    }
                                  },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Applicable vehicle type is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Checklist Items',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _items.add(
                                _ItemDraft.withName('New Item'),
                              );
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    for (var i = 0; i < _items.length; i++) _itemCard(i),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => context.go(RoutePaths.inspectionTemplates),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
          const ModuleDocumentUploadSection(
            moduleName: 'Inspection Template',
            title: 'Template Attachment Uploads',
          ),
        ],
      ),
    );
  }

  Widget _itemCard(int index) {
    final item = _items[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: item.categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete item',
                  onPressed: _items.length == 1
                      ? null
                      : () => setState(() => _items.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: item.mandatory,
                    onChanged: (value) =>
                        setState(() => item.mandatory = value ?? false),
                    title: const Text('Mandatory'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    value: item.requiresPhoto,
                    onChanged: (value) =>
                        setState(() => item.requiresPhoto = value ?? false),
                    title: const Text('Requires Photo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    value: item.requiresVideo,
                    onChanged: (value) =>
                        setState(() => item.requiresVideo = value ?? false),
                    title: const Text('Requires Video'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<InspectionFailureSeverity>(
                    value: item.severity,
                    decoration:
                        const InputDecoration(labelText: 'Failure Severity'),
                    items: [
                      for (final value in InspectionFailureSeverity.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => item.severity = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = _nameCtrl.text.trim();
    final nextItems = _items
        .map(
          (item) => InspectionTemplateItem(
            name: item.nameController.text.trim(),
            category: item.categoryController.text.trim().isEmpty
                ? 'General'
                : item.categoryController.text.trim(),
            mandatory: item.mandatory,
            requiresPhoto: item.requiresPhoto,
            requiresVideo: item.requiresVideo,
            applicableVehicleType: _selectedVehicleType.trim().isEmpty
                ? 'Any'
                : _selectedVehicleType.trim(),
            severity: item.severity,
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
    if (nextItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('At least one checklist item is required.')),
      );
      return;
    }
    final record = InspectionTemplateRecord(
      id: widget.editTemplateId ?? InspectionTemplateStore.nextId(),
      name: name,
      inspectionType: _type,
      description: _descriptionCtrl.text.trim(),
      frequency: _frequencyCtrl.text.trim().isEmpty
          ? 'On Demand'
          : _frequencyCtrl.text.trim(),
      applicableVehicleType: _selectedVehicleType.trim().isEmpty
          ? 'Truck'
          : _selectedVehicleType.trim(),
      isActive: true,
      items: nextItems,
      updatedBy: 'Admin',
      updatedAt: DateTime.now(),
    );
    InspectionTemplateStore.upsert(record);
    context.go(RoutePaths.inspectionTemplates);
  }

  List<String> _vehicleTypeOptions(AsyncValue<VehicleTypeUiState> state) {
    final names =
        state.valueOrNull?.items.map((item) => item.name).toSet() ?? <String>{};
    if (_selectedVehicleType.trim().isNotEmpty) {
      names.add(_selectedVehicleType.trim());
    }
    if (names.isEmpty) {
      return const ['Truck', 'Trailer'];
    }
    final list = names.toList()..sort();
    return list;
  }
}

class _ItemDraft {
  _ItemDraft({
    required this.nameController,
    required this.categoryController,
    required this.mandatory,
    required this.requiresPhoto,
    required this.requiresVideo,
    required this.severity,
  });

  factory _ItemDraft.withName(String name) {
    return _ItemDraft(
      nameController: TextEditingController(text: name),
      categoryController: TextEditingController(text: 'General'),
      mandatory: false,
      requiresPhoto: false,
      requiresVideo: false,
      severity: InspectionFailureSeverity.low,
    );
  }

  final TextEditingController nameController;
  final TextEditingController categoryController;
  bool mandatory;
  bool requiresPhoto;
  bool requiresVideo;
  InspectionFailureSeverity severity;

  void dispose() {
    nameController.dispose();
    categoryController.dispose();
  }
}
