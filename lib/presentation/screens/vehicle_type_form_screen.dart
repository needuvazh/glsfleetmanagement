import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vehicle_type_master_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VehicleTypeFormScreen extends ConsumerStatefulWidget {
  const VehicleTypeFormScreen({super.key, this.editCode});

  final String? editCode;

  @override
  ConsumerState<VehicleTypeFormScreen> createState() =>
      _VehicleTypeFormScreenState();
}

class _VehicleTypeFormScreenState extends ConsumerState<VehicleTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(vehicleTypeMasterViewModelProvider);
    final formState = ref.watch(vehicleTypeMasterFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit Vehicle Type' : 'Create Vehicle Type',
      currentRoute: RoutePaths.vehicleTypes,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.vehicleTypes),
          child: const Text('Back to List'),
        ),
      ],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          VehicleTypeMasterModel? editItem;
          if (widget.editCode != null) {
            for (final item in data.items) {
              if (item.vehicleTypeId == widget.editCode) {
                editItem = item;
                break;
              }
            }
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref
                  .read(vehicleTypeMasterFormProvider.notifier)
                  .initialize(editItem),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(vehicleTypeMasterFormProvider);
          final notifier = ref.read(vehicleTypeMasterFormProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode
                    ? 'Update Vehicle Type Template'
                    : 'Create Vehicle Type Template',
                subtitle:
                    'Reusable master template for customer request, quotation, feasibility, and pricing.',
                icon: Icons.route_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (form.isEditMode) ...[
                        OpsPill(
                          label: 'Vehicle Type ID: ${form.vehicleTypeId}',
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _sectionTitle(context, 'Basic Info'),
                      _grid(
                        children: [
                          _field(
                            child: _TextFieldItem(
                              label: 'Vehicle Type Name',
                              initialValue: form.vehicleTypeName,
                              onChanged: notifier.setVehicleTypeName,
                              validator: _required,
                            ),
                          ),
                          _field(
                            child: DropdownButtonFormField<VehicleCategoryType>(
                              initialValue: form.vehicleCategory,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Category',
                              ),
                              items: [
                                for (final item in VehicleCategoryType.values)
                                  DropdownMenuItem(
                                    value: item,
                                    child: Text(item.label),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setVehicleCategory(value);
                                }
                              },
                            ),
                          ),
                          _field(
                            span: 2,
                            child: _TextFieldItem(
                              label: 'Description',
                              initialValue: form.description,
                              onChanged: notifier.setDescription,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Capacity & Suitability'),
                      _grid(
                        children: [
                          _field(
                            child: _TextFieldItem(
                              label: 'Seating Capacity',
                              initialValue: form.seatingCapacity,
                              onChanged: notifier.setSeatingCapacity,
                              keyboardType: TextInputType.number,
                              validator: (value) => _conditionalNumber(
                                value,
                                required:
                                    form.vehicleCategory == VehicleCategoryType.passenger,
                              ),
                            ),
                          ),
                          _field(
                            child: _TextFieldItem(
                              label: 'Load Capacity (Ton)',
                              initialValue: form.loadCapacity,
                              onChanged: notifier.setLoadCapacity,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) => _conditionalNumber(
                                value,
                                required:
                                    form.vehicleCategory == VehicleCategoryType.goods,
                              ),
                            ),
                          ),
                          _field(
                            child: _enumDropdown<AxleType>(
                              label: 'Axle Type',
                              value: form.axleType,
                              values: AxleType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setAxleType,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<BodyType>(
                              label: 'Body Type',
                              value: form.bodyType,
                              values: BodyType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setBodyType,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Configuration'),
                      _grid(
                        children: [
                          _field(
                            child: _enumDropdown<FuelType>(
                              label: 'Fuel Type',
                              value: form.fuelType,
                              values: FuelType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setFuelType,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<TransmissionType>(
                              label: 'Transmission Type',
                              value: form.transmissionType,
                              values: TransmissionType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setTransmissionType,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<AcType>(
                              label: 'AC Type',
                              value: form.acType,
                              values: AcType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setAcType,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Business Rules'),
                      _grid(
                        children: [
                          _field(
                            child: _TextFieldItem(
                              label: 'Base Fare Per Km',
                              initialValue: form.baseFarePerKm,
                              onChanged: notifier.setBaseFarePerKm,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: _positiveDecimal,
                            ),
                          ),
                          _field(
                            child: _TextFieldItem(
                              label: 'Base Fare Per Hour',
                              initialValue: form.baseFarePerHour,
                              onChanged: notifier.setBaseFarePerHour,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: _positiveDecimal,
                            ),
                          ),
                          _field(
                            child: _TextFieldItem(
                              label: 'Mileage',
                              initialValue: form.mileage,
                              onChanged: notifier.setMileage,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: _positiveDecimal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Operational Rules'),
                      _grid(
                        children: [
                          _field(
                            child: _TextFieldItem(
                              label: 'Max Trip Distance',
                              initialValue: form.maxTripDistance,
                              onChanged: notifier.setMaxTripDistance,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: _optionalDecimal,
                            ),
                          ),
                          _field(
                            child: _TextFieldItem(
                              label: 'Max Driving Hours / Day',
                              initialValue: form.maxDrivingHoursPerDay,
                              onChanged: notifier.setMaxDrivingHoursPerDay,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: _optionalDecimal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _sectionTitle(context, 'Document Upload'),
                          ),
                          OutlinedButton.icon(
                            onPressed: notifier.addDocument,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Document'),
                          ),
                        ],
                      ),
                      if (form.documents.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDCE6F7)),
                          ),
                          child: const Text(
                            'No template/reference documents added yet.',
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (var i = 0; i < form.documents.length; i++) ...[
                              _VehicleTypeDocumentCard(
                                index: i,
                                document: form.documents[i],
                                onTypeChanged: (value) => notifier.updateDocument(
                                  i,
                                  (current) => current.copyWith(documentType: value),
                                ),
                                onNameChanged: (value) => notifier.updateDocument(
                                  i,
                                  (current) => current.copyWith(documentName: value),
                                ),
                                onPathChanged: (value) => notifier.updateDocument(
                                  i,
                                  (current) => current.copyWith(filePath: value),
                                ),
                                onUploadedByChanged: (value) =>
                                    notifier.updateDocument(
                                  i,
                                  (current) => current.copyWith(uploadedBy: value),
                                ),
                                onMandatoryChanged: (value) =>
                                    notifier.updateDocument(
                                  i,
                                  (current) => current.copyWith(isMandatory: value),
                                ),
                                onMockUpload: () {
                                  final now = DateTime.now();
                                  notifier.updateDocument(
                                    i,
                                    (current) => current.copyWith(
                                      documentId: current.documentId.isEmpty
                                          ? 'DOC-${now.millisecondsSinceEpoch}'
                                          : current.documentId,
                                      uploadedAt: now,
                                      filePath: current.filePath.trim().isEmpty
                                          ? '/mock/vehicle-types/upload-${i + 1}.pdf'
                                          : current.filePath,
                                      uploadedBy: current.uploadedBy.trim().isEmpty
                                          ? 'fleet.admin'
                                          : current.uploadedBy,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Mock uploaded ${form.documents[i].documentName.isEmpty ? 'document ${i + 1}' : form.documents[i].documentName}',
                                      ),
                                    ),
                                  );
                                },
                                onPreview: () => _showDocumentAction(
                                  title: 'Preview',
                                  message:
                                      'Preview ready for ${form.documents[i].filePath.isEmpty ? 'selected file' : form.documents[i].filePath}',
                                ),
                                onDownload: () => _showDocumentAction(
                                  title: 'Download',
                                  message:
                                      'Download ready for ${form.documents[i].filePath.isEmpty ? 'selected file' : form.documents[i].filePath}',
                                ),
                                onDelete: () => notifier.removeDocument(i),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Status'),
                      SizedBox(
                        width: 240,
                        child: _enumDropdown<RecordStatusType>(
                          label: 'Status',
                          value: form.status,
                          values: RecordStatusType.values,
                          itemLabel: (item) => item.label,
                          onChanged: notifier.setStatus,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(RoutePaths.vehicleTypes),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _submit,
                            child: Text(form.isEditMode ? 'Update' : 'Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _grid({required List<_GridField> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = constraints.maxWidth >= 1120
            ? 3
            : (constraints.maxWidth >= 720 ? 2 : 1);
        final baseWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(
                width: (baseWidth * child.span.clamp(1, columns)) +
                    (spacing * (child.span.clamp(1, columns) - 1)),
                child: child.child,
              ),
          ],
        );
      },
    );
  }

  _GridField _field({required Widget child, int span = 1}) =>
      _GridField(child: child, span: span);

  Widget _enumDropdown<T extends Enum>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          ),
      ],
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveDecimal(String? value) {
    final raw = value?.trim() ?? '';
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _optionalDecimal(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _conditionalNumber(String? value, {required bool required}) {
    final raw = value?.trim() ?? '';
    if (!required && raw.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(vehicleTypeMasterFormProvider);
    final model = form.toModel();
    final notifier = ref.read(vehicleTypeMasterViewModelProvider.notifier);
    final message = form.isEditMode
        ? await notifier.updateVehicleType(model)
        : await notifier.addVehicleType(model);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.vehicleTypes);
    }
  }

  void _showDocumentAction({
    required String title,
    required String message,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$title: $message')));
  }
}

class _GridField {
  const _GridField({required this.child, this.span = 1});

  final Widget child;
  final int span;
}

class _TextFieldItem extends StatelessWidget {
  const _TextFieldItem({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}

class _VehicleTypeDocumentCard extends StatelessWidget {
  const _VehicleTypeDocumentCard({
    required this.index,
    required this.document,
    required this.onTypeChanged,
    required this.onNameChanged,
    required this.onPathChanged,
    required this.onUploadedByChanged,
    required this.onMandatoryChanged,
    required this.onMockUpload,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
  });

  final int index;
  final VehicleTypeTemplateDocument document;
  final ValueChanged<VehicleTypeDocumentType> onTypeChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPathChanged;
  final ValueChanged<String> onUploadedByChanged;
  final ValueChanged<bool> onMandatoryChanged;
  final VoidCallback onMockUpload;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Document ${index + 1}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete document',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<VehicleTypeDocumentType>(
                  initialValue: document.documentType,
                  decoration: const InputDecoration(labelText: 'Document Type'),
                  items: [
                    for (final item in VehicleTypeDocumentType.values)
                      DropdownMenuItem(
                        value: item,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onTypeChanged(value);
                    }
                  },
                ),
              ),
              SizedBox(
                width: 260,
                child: TextFormField(
                  initialValue: document.documentName,
                  decoration: const InputDecoration(labelText: 'Document Name'),
                  onChanged: onNameChanged,
                ),
              ),
              SizedBox(
                width: 280,
                child: TextFormField(
                  initialValue: document.filePath,
                  decoration: const InputDecoration(
                    labelText: 'File Path / URL',
                    helperText: 'PDF or image reference',
                  ),
                  onChanged: onPathChanged,
                ),
              ),
              SizedBox(
                width: 220,
                child: TextFormField(
                  initialValue: document.uploadedBy,
                  decoration: const InputDecoration(labelText: 'Uploaded By'),
                  onChanged: onUploadedByChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Mandatory'),
                selected: document.isMandatory,
                onSelected: onMandatoryChanged,
              ),
              Text(
                'Uploaded: ${_formatDateTime(document.uploadedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              OutlinedButton.icon(
                onPressed: onMockUpload,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload'),
              ),
              TextButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview'),
              ),
              TextButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}
