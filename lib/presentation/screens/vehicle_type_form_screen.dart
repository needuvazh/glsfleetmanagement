import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/oman_fleet_master.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/vehicle_type.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vehicle_type_viewmodel.dart';
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
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(vehicleTypeViewModelProvider);
    final formState = ref.watch(vehicleTypeFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit Vehicle Type' : 'Add Vehicle Type',
      currentRoute: RoutePaths.vehicleTypes,
      actions: const [],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          VehicleType? editItem;
          if (widget.editCode != null) {
            for (final item in data.items) {
              if (item.code.toLowerCase() == widget.editCode!.toLowerCase()) {
                editItem = item;
                break;
              }
            }
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref
                  .read(vehicleTypeFormProvider.notifier)
                  .initialize(editItem),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(vehicleTypeFormProvider);
          final notifier = ref.read(vehicleTypeFormProvider.notifier);

          if (!OmanFleetMaster.fleetTypes.contains(form.name)) {
            Future.microtask(() {
              final first = OmanFleetMaster.fleetTypes.first;
              notifier.setName(first);
              notifier.setCode(OmanFleetMaster.codeForType(first));
              notifier.setCategory(OmanFleetMaster.categoryForType(first));
              notifier.setVehicleClass('Dry Movers');
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Responsive.isMobile(context)
                      ? SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () =>
                                context.go(RoutePaths.vehicleTypes),
                            child: const Text('Back to List'),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              form.isEditMode
                                  ? 'Edit Vehicle Type'
                                  : 'Add Vehicle Type',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  context.go(RoutePaths.vehicleTypes),
                              child: const Text('Back to List'),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: form.isEditMode
                    ? 'Edit Vehicle Type'
                    : 'Add Vehicle Type (Oman/JMP)',
                subtitle:
                    'Step 1: Basic Details, Step 2: Operation + Ownership, Step 3: Compliance + Documents',
                icon: Icons.route_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Stepper(
                    currentStep: _currentStep,
                    type: StepperType.vertical,
                    onStepTapped: (value) =>
                        setState(() => _currentStep = value),
                    onStepContinue: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep += 1);
                        return;
                      }
                      _submit(context, ref);
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
                    controlsBuilder: (context, details) {
                      final isLast = _currentStep == 2;
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            FilledButton.icon(
                              onPressed: details.onStepContinue,
                              icon: Icon(isLast
                                  ? Icons.save_outlined
                                  : Icons.navigate_next),
                              label: Text(
                                isLast
                                    ? (form.isEditMode ? 'Update' : 'Create')
                                    : 'Continue',
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_currentStep > 0)
                              OutlinedButton(
                                onPressed: details.onStepCancel,
                                child: const Text('Back'),
                              ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      Step(
                        title: const Text('Step 1 - Basic Details'),
                        isActive: _currentStep >= 0,
                        content: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value:
                                  OmanFleetMaster.fleetTypes.contains(form.name)
                                      ? form.name
                                      : OmanFleetMaster.fleetTypes.first,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Type Name',
                              ),
                              items: [
                                for (final item in OmanFleetMaster.fleetTypes)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                notifier.setName(value);
                                notifier.setCode(
                                    OmanFleetMaster.codeForType(value));
                                notifier.setCategory(
                                    OmanFleetMaster.categoryForType(value));
                                notifier.setVehicleClass(
                                  OmanFleetMaster.vehicleClassForType(value) ==
                                          'Light'
                                      ? 'Dry Movers'
                                      : 'XXXL',
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              initialValue: form.code.trim().isEmpty
                                  ? OmanFleetMaster.codeForType(form.name)
                                  : form.code,
                              decoration: const InputDecoration(
                                labelText: 'Short Code',
                              ),
                              readOnly: true,
                              validator: _required,
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: form.category,
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.categories)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setCategory(value);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: form.vehicleClass,
                              decoration: const InputDecoration(
                                  labelText: 'Vehicle Class'),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.vehicleClasses)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setVehicleClass(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Step(
                        title: const Text('Step 2 - Operation + Ownership'),
                        isActive: _currentStep >= 1,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(context, 'Ownership Configuration'),
                            _ownershipSelector(context, form),
                            const SizedBox(height: 6),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Vendor Required'),
                              subtitle: const Text(
                                  'Enable when Vendor Owned is selected'),
                              value: form.vendorRequired,
                              onChanged:
                                  form.ownershipTypes.contains('Vendor Owned')
                                      ? notifier.setVendorRequired
                                      : null,
                            ),
                            const SizedBox(height: 8),
                            _sectionTitle(context, 'Operation Details'),
                            DropdownButtonFormField<String>(
                              value: form.loadType,
                              decoration:
                                  const InputDecoration(labelText: 'Load Type'),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.loadTypes)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setLoadType(value);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: form.transportType,
                              decoration: const InputDecoration(
                                labelText: 'Transport Type',
                              ),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.transportTypes)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setTransportType(value);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              initialValue: form.maxTripsPerDay,
                              decoration: const InputDecoration(
                                labelText: 'Max Trips Per Day',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: notifier.setMaxTripsPerDay,
                              validator: _positiveIntValidator,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Allow Multi-Day Journey'),
                              value: form.allowMultiDayJourney,
                              onChanged: notifier.setAllowMultiDayJourney,
                            ),
                            const SizedBox(height: 8),
                            _sectionTitle(context, 'Route Configuration'),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Allow Multiple Stops'),
                              value: form.allowMultipleStops,
                              onChanged: notifier.setAllowMultipleStops,
                            ),
                            TextFormField(
                              initialValue: form.maxStopsAllowed,
                              decoration: const InputDecoration(
                                labelText: 'Max Stops Allowed',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: notifier.setMaxStopsAllowed,
                              validator: _positiveIntValidator,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Require Route Plan Approval'),
                              value: form.requireRoutePlanApproval,
                              onChanged: notifier.setRequireRoutePlanApproval,
                            ),
                            const SizedBox(height: 8),
                            _sectionTitle(context, 'Special Handling'),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Is Hazardous'),
                              value: form.isHazardous,
                              onChanged: notifier.setIsHazardous,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Requires Safety Compliance'),
                              value: form.requiresSafetyCompliance,
                              onChanged: notifier.setRequiresSafetyCompliance,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Temperature Controlled'),
                              value: form.temperatureControlled,
                              onChanged: notifier.setTemperatureControlled,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Requires Escort Vehicle'),
                              value: form.requiresEscortVehicle,
                              onChanged: notifier.setRequiresEscortVehicle,
                            ),
                            const SizedBox(height: 8),
                            _sectionTitle(context, 'Capacity'),
                            TextFormField(
                              initialValue: form.defaultCapacity,
                              decoration: const InputDecoration(
                                labelText: 'Default Capacity',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: notifier.setDefaultCapacity,
                              validator: _capacityValidator,
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: form.capacityUnit,
                              decoration: const InputDecoration(
                                labelText: 'Capacity Unit',
                              ),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.capacityUnits)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setCapacityUnit(value);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            _sectionTitle(context, 'Features'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final feature
                                    in VehicleTypeFormNotifier.featureOptions)
                                  FilterChip(
                                    label: Text(feature),
                                    selected: form.features.contains(feature),
                                    onSelected: (_) =>
                                        notifier.toggleFeature(feature),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _sectionTitle(context, 'Status'),
                            DropdownButtonFormField<String>(
                              value: form.status,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.statuses)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setStatus(value);
                                }
                              },
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Default Vehicle Type'),
                              value: form.isDefaultType,
                              onChanged: notifier.setIsDefaultType,
                            ),
                          ],
                        ),
                      ),
                      Step(
                        title: const Text('Step 3 - Compliance + Documents'),
                        isActive: _currentStep >= 2,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(context, 'Compliance Requirements'),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Requires Insurance'),
                              value: form.requiresInsurance,
                              onChanged: notifier.setRequiresInsurance,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Requires Permit'),
                              value: form.requiresPermit,
                              onChanged: notifier.setRequiresPermit,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Requires Fitness'),
                              value: form.requiresFitness,
                              onChanged: notifier.setRequiresFitness,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Requires Pollution'),
                              value: form.requiresPollution,
                              onChanged: notifier.setRequiresPollution,
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: form.complianceMode,
                              decoration: const InputDecoration(
                                  labelText: 'Compliance Mode'),
                              items: [
                                for (final item
                                    in VehicleTypeFormNotifier.complianceModes)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.setComplianceMode(value);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _sectionTitle(
                                      context, 'Document Requirements'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: notifier.addDocumentRequirement,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Document'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (form.documentRequirements.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'No document requirements yet. PDO/Trailer rules auto-add defaults.',
                                ),
                              ),
                            for (int i = 0;
                                i < form.documentRequirements.length;
                                i++)
                              _documentRequirementCard(
                                context: context,
                                index: i,
                                requirement: form.documentRequirements[i],
                                notifier: notifier,
                              ),
                          ],
                        ),
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

  Widget _ownershipSelector(BuildContext context, VehicleTypeFormState form) {
    final notifier = ref.read(vehicleTypeFormProvider.notifier);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Ownership Type',
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in VehicleTypeFormNotifier.ownershipOptions)
                FilterChip(
                  label: Text(option),
                  selected: form.ownershipTypes.contains(option),
                  onSelected: (_) => notifier.toggleOwnershipType(option),
                ),
            ],
          ),
          if (form.ownershipTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'At least one ownership type is required.',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _documentRequirementCard({
    required BuildContext context,
    required int index,
    required VehicleTypeDocumentRequirement requirement,
    required VehicleTypeFormNotifier notifier,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE6F7)),
        color: const Color(0xFFF8FAFC),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Document ${index + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => notifier.removeDocumentRequirement(index),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: requirement.documentName,
            decoration: const InputDecoration(labelText: 'Document Name'),
            items: [
              for (final option in VehicleTypeFormNotifier.documentNameOptions)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.updateDocumentRequirementName(index, value);
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mandatory'),
            value: requirement.mandatory,
            onChanged: (value) =>
                notifier.updateDocumentRequirementMandatory(index, value),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: '${requirement.validityValue}',
                  decoration: const InputDecoration(labelText: 'Validity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      notifier.updateDocumentRequirementValidityValue(
                    index,
                    value,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: requirement.validityUnit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: [
                    for (final unit in VehicleTypeFormNotifier.validityUnits)
                      DropdownMenuItem(value: unit, child: Text(unit)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      notifier.updateDocumentRequirementValidityUnit(
                          index, value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: requirement.applicableFor,
            decoration: const InputDecoration(labelText: 'Applicable For'),
            items: [
              for (final option in VehicleTypeFormNotifier.applicableFor)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.updateDocumentRequirementApplicableFor(index, value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveIntValidator(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  String? _capacityValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Capacity must be numeric';
    }
    return null;
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(vehicleTypeFormProvider);
    final entity = form.toEntity();
    final notifier = ref.read(vehicleTypeViewModelProvider.notifier);

    final message = form.isEditMode
        ? await notifier.updateVehicleType(form.originalCode!, entity)
        : await notifier.addVehicleType(entity);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.vehicleTypes);
    }
  }
}
