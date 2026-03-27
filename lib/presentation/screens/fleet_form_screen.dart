import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/fleet_master_model.dart';
import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/fleet_master_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FleetFormScreen extends ConsumerStatefulWidget {
  const FleetFormScreen({super.key, this.editFleetId});

  final String? editFleetId;

  @override
  ConsumerState<FleetFormScreen> createState() => _FleetFormScreenState();
}

class _FleetFormScreenState extends ConsumerState<FleetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(fleetMasterViewModelProvider);
    final formState = ref.watch(fleetMasterFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit Fleet' : 'Create Fleet',
      currentRoute: RoutePaths.fleetManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.fleetManagement),
          child: const Text('Back to Fleet'),
        ),
      ],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          FleetMasterModel? editItem;
          if (widget.editFleetId != null) {
            for (final item in data.fleets) {
              if (item.fleetId == widget.editFleetId) {
                editItem = item;
                break;
              }
            }
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref
                  .read(fleetMasterFormProvider.notifier)
                  .initialize(editItem, data.vehicleTypes),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(fleetMasterFormProvider);
          final notifier = ref.read(fleetMasterFormProvider.notifier);
          final vehicleType = data.vehicleTypeFor(form.vehicleTypeId);
          final capacityHint = vehicleType == null
              ? 'Auto from vehicle type'
              : vehicleType.vehicleCategory == VehicleCategoryType.passenger
                  ? '${vehicleType.seatingCapacity} seats'
                  : '${vehicleType.loadCapacity} ton';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode
                    ? 'Update Fleet Control Record'
                    : 'Create Fleet Control Record',
                subtitle:
                    'Operational fleet record with compliance, readiness, and assignment controls.',
                icon: Icons.local_shipping_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (form.isEditMode) ...[
                        OpsPill(
                          label: 'Fleet ID: ${form.fleetId}',
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _sectionTitle(context, 'Basic Info'),
                      _grid(
                        children: [
                          _field(
                            child: DropdownButtonFormField<String>(
                              initialValue: form.vehicleTypeId,
                              decoration:
                                  const InputDecoration(labelText: 'Vehicle Type'),
                              items: [
                                for (final item in data.vehicleTypes)
                                  DropdownMenuItem(
                                    value: item.vehicleTypeId,
                                    child: Text(
                                      '${item.vehicleTypeName} (${item.vehicleTypeId})',
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setVehicleType(value, data.vehicleTypes);
                                }
                              },
                            ),
                          ),
                          _field(
                            span: 2,
                            child: _VehicleNumberField(
                              initialPlateNumber:
                                  _plateNumberFromFleetNumber(form.fleetNumber),
                              initialPlateCode:
                                  _plateCodeFromFleetNumber(form.fleetNumber),
                              onChanged: (plateNumber, plateCode) {
                                notifier.setFleetNumber(
                                  _composeFleetNumber(plateNumber, plateCode),
                                );
                              },
                            ),
                          ),
                          _field(
                            child: _enumDropdown<OwnershipType>(
                              label: 'Ownership Type',
                              value: form.ownershipType,
                              values: OwnershipType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setOwnershipType,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<RecordStatusType>(
                              label: 'Status',
                              value: form.status,
                              values: RecordStatusType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setStatus,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Registration'),
                      _grid(
                        children: [
                          _field(
                            child: _InputField(
                              label: 'Registration Number',
                              initialValue: form.registrationNumber,
                              onChanged: notifier.setRegistrationNumber,
                              validator: _required,
                            ),
                          ),
                          _field(
                            child: _DateField(
                              label: 'Registration Expiry Date',
                              fieldId: 'registrationExpiryDate',
                              value: form.registrationExpiryDate,
                              onTap: () => _pickDate(
                                form.registrationExpiryDate,
                                notifier.setRegistrationExpiryDate,
                              ),
                              validator: _futureDateRequired,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Compliance'),
                      _grid(
                        children: [
                          _field(
                            child: _DateField(
                              label: 'Insurance Expiry Date',
                              fieldId: 'insuranceExpiryDate',
                              value: form.insuranceExpiryDate,
                              onTap: () => _pickDate(
                                form.insuranceExpiryDate,
                                notifier.setInsuranceExpiryDate,
                              ),
                              validator: _futureDateRequired,
                            ),
                          ),
                          _field(
                            child: _DateField(
                              label: 'Permit Expiry Date',
                              fieldId: 'permitExpiryDate',
                              value: form.permitExpiryDate,
                              onTap: () => _pickDate(
                                form.permitExpiryDate,
                                notifier.setPermitExpiryDate,
                              ),
                              validator: _futureDateRequired,
                            ),
                          ),
                          _field(
                            child: _DateField(
                              label: 'RAS Expiry Date',
                              fieldId: 'rasExpiryDate',
                              value: form.rasExpiryDate,
                              onTap: () => _pickDate(
                                form.rasExpiryDate,
                                notifier.setRasExpiryDate,
                              ),
                              validator: _futureDateRequired,
                            ),
                          ),
                          _field(
                            child: _DateField(
                              label: 'Inspection Due Date',
                              fieldId: 'inspectionDueDate',
                              value: form.inspectionDueDate,
                              onTap: () => _pickDate(
                                form.inspectionDueDate,
                                notifier.setInspectionDueDate,
                              ),
                              validator: _futureDateRequired,
                            ),
                          ),
                          _field(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('IVMS Installed'),
                              value: form.ivmsInstalled,
                              onChanged: notifier.setIvmsInstalled,
                            ),
                          ),
                          _field(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('DFMS Installed'),
                              value: form.dfmsInstalled,
                              onChanged: notifier.setDfmsInstalled,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Technical'),
                      _grid(
                        children: [
                          _field(
                            child: _InputField(
                              label: 'Capacity Override',
                              helperText: capacityHint,
                              initialValue: form.capacityOverride,
                              onChanged: notifier.setCapacityOverride,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: _optionalPositiveNumber,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<AxleType>(
                              label: 'Axle Type',
                              value: form.axleType,
                              values: AxleType.values,
                              itemLabel: (item) => item.label,
                              onChanged: (_) {},
                              enabled: false,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<FuelType>(
                              label: 'Fuel Type',
                              value: form.fuelType,
                              values: FuelType.values,
                              itemLabel: (item) => item.label,
                              onChanged: (_) {},
                              enabled: false,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<BodyType>(
                              label: 'Body Type',
                              value: form.bodyType,
                              values: BodyType.values,
                              itemLabel: (item) => item.label,
                              onChanged: (_) {},
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Operational'),
                      _grid(
                        children: [
                          _field(
                            child: _enumDropdown<AvailabilityStatusType>(
                              label: 'Availability Status',
                              value: form.availabilityStatus,
                              values: AvailabilityStatusType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setAvailabilityStatus,
                            ),
                          ),
                          _field(
                            child: _enumDropdown<MaintenanceStatusType>(
                              label: 'Maintenance Status',
                              value: form.maintenanceStatus,
                              values: MaintenanceStatusType.values,
                              itemLabel: (item) => item.label,
                              onChanged: notifier.setMaintenanceStatus,
                            ),
                          ),
                          _field(
                            child: _InputField(
                              label: 'Current Trip / Work Order Ref',
                              initialValue: form.currentTripId,
                              onChanged: notifier.setCurrentTripId,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Vendor & Audit'),
                      _grid(
                        children: [
                          _field(
                            child: DropdownButtonFormField<String>(
                              initialValue: form.vendorId.isEmpty ? null : form.vendorId,
                              decoration: InputDecoration(
                                labelText: 'Vendor',
                                helperText: form.ownershipType == OwnershipType.owned
                                    ? 'Not required for owned fleet'
                                    : 'Required for leased / contracted fleet',
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('No Vendor'),
                                ),
                                for (final item in data.vendors)
                                  DropdownMenuItem(
                                    value: item.vendorId,
                                    child: Text(
                                      '${item.vendorName} (${item.vendorId})',
                                    ),
                                  ),
                              ],
                              onChanged: form.ownershipType == OwnershipType.owned
                                  ? (value) => notifier.setVendorId('')
                                  : (value) => notifier.setVendorId(value ?? ''),
                              validator: (_) => form.ownershipType != OwnershipType.owned &&
                                      form.vendorId.trim().isEmpty
                                  ? 'Vendor required'
                                  : null,
                            ),
                          ),
                          _field(
                            child: _InputField(
                              label: 'Created By',
                              initialValue: form.createdBy,
                              onChanged: notifier.setCreatedBy,
                              validator: _required,
                            ),
                          ),
                          _field(
                            child: _InputField(
                              label: 'Updated By',
                              initialValue: form.updatedBy,
                              onChanged: notifier.setUpdatedBy,
                              validator: _required,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(RoutePaths.fleetManagement),
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
    bool enabled = true,
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
      onChanged: enabled
          ? (next) {
              if (next != null) {
                onChanged(next);
              }
            }
          : null,
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _optionalPositiveNumber(String? value) {
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

  String? _futureDateRequired(DateTime? value) {
    if (value == null) {
      return 'Required';
    }
    final now = DateTime.now();
    final currentDay = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(value.year, value.month, value.day);
    if (!targetDay.isAfter(currentDay)) {
      return 'Must be a future date';
    }
    return null;
  }

  Future<void> _pickDate(
    DateTime? initialDate,
    ValueChanged<DateTime> onSelected,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: initialDate ?? now.add(const Duration(days: 1)),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(fleetMasterFormProvider);
    if (form.registrationExpiryDate == null ||
        form.insuranceExpiryDate == null ||
        form.permitExpiryDate == null ||
        form.rasExpiryDate == null ||
        form.inspectionDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All compliance dates are required.')),
      );
      return;
    }

    final model = form.toModel();
    final notifier = ref.read(fleetMasterViewModelProvider.notifier);
    final message = form.isEditMode
        ? await notifier.updateFleet(model)
        : await notifier.addFleet(model);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.fleetManagement);
    }
  }
}

String _plateNumberFromFleetNumber(String fleetNumber) {
  final digits = fleetNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    return '';
  }
  return digits.length > 5 ? digits.substring(0, 5) : digits;
}

String _plateCodeFromFleetNumber(String fleetNumber) {
  final letters = fleetNumber
      .replaceAll(RegExp(r'[^A-Za-z]'), '')
      .toUpperCase();
  if (letters.isEmpty) {
    return '';
  }
  return letters.length > 2 ? letters.substring(0, 2) : letters;
}

String _composeFleetNumber(String plateNumber, String plateCode) {
  final number = plateNumber.trim();
  final code = plateCode.trim().toUpperCase();
  if (number.isEmpty && code.isEmpty) {
    return '';
  }
  return '$number $code'.trim();
}

class _GridField {
  const _GridField({required this.child, this.span = 1});

  final Widget child;
  final int span;
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.helperText,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
      ),
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.fieldId,
    required this.value,
    required this.onTap,
    this.validator,
  });

  final String label;
  final String fieldId;
  final DateTime? value;
  final VoidCallback onTap;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$fieldId-${value?.toIso8601String() ?? ''}'),
      initialValue: value == null ? '' : _formatDate(value!),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      onTap: onTap,
      validator: (_) => validator?.call(value),
    );
  }
}

class _VehicleNumberField extends StatefulWidget {
  const _VehicleNumberField({
    required this.initialPlateNumber,
    required this.initialPlateCode,
    required this.onChanged,
  });

  final String initialPlateNumber;
  final String initialPlateCode;
  final void Function(String plateNumber, String plateCode) onChanged;

  @override
  State<_VehicleNumberField> createState() => _VehicleNumberFieldState();
}

class _VehicleNumberFieldState extends State<_VehicleNumberField> {
  late final TextEditingController _plateNumberController;
  late final TextEditingController _plateCodeController;

  @override
  void initState() {
    super.initState();
    _plateNumberController =
        TextEditingController(text: widget.initialPlateNumber);
    _plateCodeController =
        TextEditingController(text: widget.initialPlateCode.toUpperCase());
  }

  @override
  void didUpdateWidget(covariant _VehicleNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_plateNumberController.text != widget.initialPlateNumber) {
      _plateNumberController.text = widget.initialPlateNumber;
    }
    final nextCode = widget.initialPlateCode.toUpperCase();
    if (_plateCodeController.text != nextCode) {
      _plateCodeController.text = nextCode;
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _plateCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Number',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _plateNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      decoration: const InputDecoration(
                        hintText: 'Plate Number',
                        counterText: '',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) {
                          return 'Required';
                        }
                        if (raw.length > 5) {
                          return 'Max 5 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        widget.onChanged(value, _plateCodeController.text);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _plateCodeController,
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Code',
                        counterText: '',
                      ),
                      inputFormatters: [
                        _UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                      ],
                      validator: (value) {
                        final raw = value?.trim().toUpperCase() ?? '';
                        if (raw.isEmpty) {
                          return 'Required';
                        }
                        if (!RegExp(r'^[A-Z]{2}$').hasMatch(raw)) {
                          return 'Enter 2 letters';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        widget.onChanged(_plateNumberController.text, value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  const _UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
