import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/location_model.dart';
import '../../domain/route_model.dart';
import '../../domain/vehicle_type_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/route_viewmodel.dart';
import '../viewmodels/vehicle_type_master_viewmodel.dart';
import '../widgets/module_document_upload_section.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RouteFormScreen extends ConsumerStatefulWidget {
  const RouteFormScreen({super.key, this.editRouteId});

  final String? editRouteId;

  @override
  ConsumerState<RouteFormScreen> createState() => _RouteFormScreenState();
}

class _RouteFormScreenState extends ConsumerState<RouteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeViewModelProvider);
    final formState = ref.watch(routeFormProvider);
    final vehicleTypeState =
        ref.watch(vehicleTypeMasterViewModelProvider).valueOrNull;

    return OpsShell(
      title: formState.isEditMode ? 'Edit Route' : 'Create Route',
      currentRoute: RoutePaths.routeLocationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.routeLocationMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: routeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          RouteLocationModel? editRoute;
          if (widget.editRouteId != null) {
            for (final route in data.routes) {
              if (route.routeId == widget.editRouteId) {
                editRoute = route;
                break;
              }
            }
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref.read(routeFormProvider.notifier).initialize(editRoute),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(routeFormProvider);
          final notifier = ref.read(routeFormProvider.notifier);
          final locations = data.locations;
          final preferredVehicleOptions = _preferredVehicleOptions(
            vehicleTypeState?.items ?? const <VehicleTypeMasterModel>[],
            form.preferredVehicleType,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode
                    ? 'Edit Route Master'
                    : 'Create Route Master',
                subtitle:
                    'Define planning, risk, compliance and usage controls',
                icon: Icons.route_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionLabel(title: '1. Basic Route Identity'),
                      const SizedBox(height: 12),
                      _ResponsiveFormGrid(children: [
                        TextFormField(
                          initialValue: form.routeCode,
                          decoration:
                              const InputDecoration(labelText: 'Route Code *'),
                          validator: _required,
                          onChanged: notifier.setRouteCode,
                        ),
                        TextFormField(
                          initialValue: form.routeName,
                          decoration:
                              const InputDecoration(labelText: 'Route Name *'),
                          validator: _required,
                          onChanged: notifier.setRouteName,
                        ),
                        TextFormField(
                          initialValue: form.region,
                          decoration:
                              const InputDecoration(labelText: 'Region'),
                          onChanged: notifier.setRegion,
                        ),
                        _SearchableLocationDropdown(
                          fieldId: 'origin',
                          labelText: 'Origin *',
                          hintText: 'Select Origin',
                          value: form.startLocationCode,
                          options: locations,
                          validator: _requiredSelection,
                          onSelected: notifier.setStartLocation,
                        ),
                        _SearchableLocationDropdown(
                          fieldId: 'destination',
                          labelText: 'Destination *',
                          hintText: 'Select Destination',
                          value: form.endLocationCode,
                          options: locations,
                          validator: _requiredSelection,
                          onSelected: notifier.setEndLocation,
                        ),
                        DropdownButtonFormField<RouteOperationalStatus>(
                          value: form.status,
                          decoration:
                              const InputDecoration(labelText: 'Status *'),
                          items: [
                            for (final value in RouteOperationalStatus.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              notifier.setStatus(value);
                            }
                          },
                        ),
                      ]),
                      const _SectionBreak(),
                      _SectionLabel(title: '2. Travel Planning'),
                      const SizedBox(height: 12),
                      _ResponsiveFormGrid(children: [
                        TextFormField(
                          initialValue: form.distanceKm,
                          decoration: const InputDecoration(
                              labelText: 'Distance (km) *'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: _positiveNumber,
                          onChanged: notifier.setDistanceKm,
                        ),
                        TextFormField(
                          initialValue: form.estimatedTime,
                          decoration: const InputDecoration(
                            labelText: 'Estimated Travel Time *',
                            hintText: 'e.g. 6 hrs',
                          ),
                          validator: _required,
                          onChanged: notifier.setEstimatedTime,
                        ),
                        TextFormField(
                          initialValue: form.expectedStops,
                          decoration: const InputDecoration(
                              labelText: 'Expected Stops'),
                          keyboardType: TextInputType.number,
                          onChanged: notifier.setExpectedStops,
                        ),
                        TextFormField(
                          initialValue: form.standardRestPoints,
                          decoration: const InputDecoration(
                            labelText: 'Standard Rest Points',
                            hintText: 'Comma separated',
                          ),
                          onChanged: notifier.setStandardRestPoints,
                        ),
                        TextFormField(
                          initialValue: form.standardStartWindow,
                          decoration: const InputDecoration(
                            labelText: 'Standard Start Window',
                            hintText: 'e.g. 06:00 - 09:00',
                          ),
                          onChanged: notifier.setStandardStartWindow,
                        ),
                        TextFormField(
                          initialValue: form.standardDeliveryWindow,
                          decoration: const InputDecoration(
                            labelText: 'Standard Delivery Window',
                            hintText: 'e.g. 14:00 - 18:00',
                          ),
                          onChanged: notifier.setStandardDeliveryWindow,
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('Intermediate stops with type mapping'),
                          ),
                          OutlinedButton.icon(
                            onPressed: notifier.addStop,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Stop'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (form.stopDrafts.isEmpty)
                        const Text('No stops configured for this route.'),
                      for (int i = 0; i < form.stopDrafts.length; i++) ...[
                        _StopRow(
                          index: i,
                          value: form.stopDrafts[i],
                          options: _availableStopOptions(
                            locations: locations,
                            form: form,
                            index: i,
                          ),
                          onLocationSelected: (value) =>
                              notifier.updateStopLocation(i, value),
                          onTypeSelected: (value) =>
                              notifier.updateStopType(i, value),
                          onNoteChanged: (value) =>
                              notifier.updateStopNote(i, value),
                          onRemove: () => notifier.removeStop(i),
                        ),
                        if (i != form.stopDrafts.length - 1)
                          const SizedBox(height: 8),
                      ],
                      const _SectionBreak(),
                      _SectionLabel(title: '3. Risk Classification'),
                      const SizedBox(height: 12),
                      _ResponsiveFormGrid(children: [
                        DropdownButtonFormField<RouteRiskLevel>(
                          value: form.riskLevel,
                          decoration:
                              const InputDecoration(labelText: 'Risk Level *'),
                          items: [
                            for (final value in RouteRiskLevel.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              notifier.setRiskLevel(value);
                            }
                          },
                        ),
                        SwitchListTile(
                          value: form.nightDrivingAllowed,
                          onChanged: notifier.setNightDrivingAllowed,
                          title: const Text('Night Driving Allowed'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          value: form.weatherSensitive,
                          onChanged: notifier.setWeatherSensitive,
                          title: const Text('Weather Sensitive'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        TextFormField(
                          initialValue: form.restrictedSegments,
                          decoration: const InputDecoration(
                              labelText: 'Restricted Segments'),
                          onChanged: notifier.setRestrictedSegments,
                        ),
                        TextFormField(
                          initialValue: form.routeNotes,
                          decoration:
                              const InputDecoration(labelText: 'Route Notes'),
                          onChanged: notifier.setRouteNotes,
                          maxLines: 2,
                        ),
                      ]),
                      const _SectionBreak(),
                      _SectionLabel(title: '4. Operational Preferences'),
                      const SizedBox(height: 12),
                      _ResponsiveFormGrid(children: [
                        DropdownButtonFormField<String>(
                          value: _dropdownValue(
                            value: form.preferredVehicleType,
                            options: preferredVehicleOptions,
                          ),
                          decoration: const InputDecoration(
                              labelText: 'Preferred Vehicle Type'),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Select Preferred Vehicle Type'),
                            ),
                            for (final vehicleType in preferredVehicleOptions)
                              DropdownMenuItem(
                                value: vehicleType,
                                child: Text(vehicleType),
                              ),
                          ],
                          onChanged: (value) =>
                              notifier.setPreferredVehicleType(value ?? ''),
                        ),
                        TextFormField(
                          initialValue: form.trailerTypePreference,
                          decoration: const InputDecoration(
                              labelText: 'Trailer Preference'),
                          onChanged: notifier.setTrailerTypePreference,
                        ),
                        SwitchListTile(
                          value: form.escortRequired,
                          onChanged: notifier.setEscortRequired,
                          title: const Text('Escort Required'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          value: form.alternateRouteAvailable,
                          onChanged: notifier.setAlternateRouteAvailable,
                          title: const Text('Alternate Route Available'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        TextFormField(
                          initialValue: form.specialHandlingNotes,
                          decoration: const InputDecoration(
                              labelText: 'Special Handling Notes'),
                          onChanged: notifier.setSpecialHandlingNotes,
                          maxLines: 2,
                        ),
                        SwitchListTile(
                          value: form.customerSpecific,
                          onChanged: notifier.setCustomerSpecific,
                          title: const Text('Customer Specific Route'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ]),
                      const _SectionBreak(),
                      _SectionLabel(title: '5. Compliance / Safety Notes'),
                      const SizedBox(height: 12),
                      _ResponsiveFormGrid(children: [
                        SwitchListTile(
                          value: form.specialComplianceRequired,
                          onChanged: notifier.setSpecialComplianceRequired,
                          title: const Text('Special Compliance Required'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        TextFormField(
                          initialValue: form.safetyInstructions,
                          decoration: const InputDecoration(
                              labelText: 'Safety Instructions'),
                          onChanged: notifier.setSafetyInstructions,
                          maxLines: 2,
                        ),
                        TextFormField(
                          initialValue: form.customerAuthorityRestrictions,
                          decoration: const InputDecoration(
                              labelText: 'Customer/Authority Restrictions'),
                          onChanged: notifier.setCustomerAuthorityRestrictions,
                          maxLines: 2,
                        ),
                        TextFormField(
                          initialValue: form.permitRequirement,
                          decoration: const InputDecoration(
                              labelText: 'Permit Requirement'),
                          onChanged: notifier.setPermitRequirement,
                        ),
                        TextFormField(
                          initialValue: form.requiredDocuments,
                          decoration: const InputDecoration(
                            labelText: 'Route Documents Required',
                            hintText: 'Comma separated',
                          ),
                          onChanged: notifier.setRequiredDocuments,
                        ),
                      ]),
                      const _SectionBreak(),
                      _SectionLabel(title: '6. Control / Status'),
                      const SizedBox(height: 12),
                      _ResponsiveFormGrid(children: [
                        SwitchListTile(
                          value: form.temporarilyRestricted,
                          onChanged: notifier.setTemporarilyRestricted,
                          title: const Text('Temporarily Restricted'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        TextFormField(
                          initialValue: form.restrictionReason,
                          decoration: const InputDecoration(
                              labelText: 'Restriction Reason'),
                          onChanged: notifier.setRestrictionReason,
                          validator: (_) {
                            if (form.temporarilyRestricted &&
                                form.restrictionReason.trim().isEmpty) {
                              return 'Restriction reason required';
                            }
                            return null;
                          },
                        ),
                      ]),
                      const ModuleDocumentUploadSection(
                        moduleName: 'Route',
                        title: 'Route Document Uploads',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () =>
                                context.go(RoutePaths.routeLocationMaster),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: () => _submit(context, locations),
                            child: const Text('Save'),
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

  List<LocationModel> _availableStopOptions({
    required List<LocationModel> locations,
    required RouteFormState form,
    required int index,
  }) {
    final blockedCodes = <String>{
      if (form.startLocationCode != null) form.startLocationCode!,
      if (form.endLocationCode != null) form.endLocationCode!,
    };

    for (int i = 0; i < form.stopDrafts.length; i++) {
      if (i == index) {
        continue;
      }
      final code = form.stopDrafts[i].locationCode;
      if (code != null && code.isNotEmpty) {
        blockedCodes.add(code);
      }
    }

    return locations.where((location) {
      final currentCode = form.stopDrafts[index].locationCode;
      if (currentCode == location.locationCode) {
        return true;
      }
      return !blockedCodes.contains(location.locationCode);
    }).toList();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _requiredSelection(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Must be greater than 0';
    }
    return null;
  }

  String? _dropdownValue({
    required String value,
    required List<String> options,
  }) {
    if (value.isEmpty) {
      return '';
    }
    return options.contains(value) ? value : null;
  }

  List<String> _preferredVehicleOptions(
    List<VehicleTypeMasterModel> masterItems,
    String selectedValue,
  ) {
    final set = <String>{};
    for (final item in masterItems) {
      final name = item.vehicleTypeName.trim();
      if (name.isNotEmpty) {
        set.add(name);
      }
    }
    final selected = selectedValue.trim();
    if (selected.isNotEmpty) {
      set.add(selected);
    }
    final options = set.toList()..sort();
    return options;
  }

  Future<void> _submit(
    BuildContext context,
    List<LocationModel> locations,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(routeFormProvider);
    if (form.startLocationCode == null || form.endLocationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Origin and destination are required.')),
      );
      return;
    }

    RouteLocationModel route;
    try {
      route = form.toRouteModel(locations);
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message.toString())),
      );
      return;
    }

    final notifier = ref.read(routeViewModelProvider.notifier);
    final message = form.isEditMode
        ? await notifier.updateRoute(form.originalRouteId!, route)
        : await notifier.addRoute(route);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.routeLocationMaster);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _SectionBreak extends StatelessWidget {
  const _SectionBreak();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1),
    );
  }
}

class _ResponsiveFormGrid extends StatelessWidget {
  const _ResponsiveFormGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.isDesktop(context)
        ? 3
        : (Responsive.isTablet(context) ? 2 : 1);
    const spacing = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.index,
    required this.value,
    required this.options,
    required this.onLocationSelected,
    required this.onTypeSelected,
    required this.onNoteChanged,
    required this.onRemove,
  });

  final int index;
  final RouteStopDraft value;
  final List<LocationModel> options;
  final ValueChanged<String?> onLocationSelected;
  final ValueChanged<RouteStopType> onTypeSelected;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SearchableLocationDropdown(
                  fieldId: 'stop-location-$index',
                  hintText: 'Select Stop Location',
                  value: value.locationCode,
                  options: options,
                  onSelected: onLocationSelected,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<RouteStopType>(
                  value: value.stopType,
                  decoration: const InputDecoration(labelText: 'Stop Type'),
                  items: [
                    for (final item in RouteStopType.values)
                      DropdownMenuItem(
                        value: item,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (next) {
                    if (next != null) {
                      onTypeSelected(next);
                    }
                  },
                ),
              ),
              IconButton(
                tooltip: 'Remove stop',
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (value.stopType == RouteStopType.other) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: value.note,
              decoration: const InputDecoration(labelText: 'Other Stop Note *'),
              onChanged: onNoteChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchableLocationDropdown extends StatelessWidget {
  const _SearchableLocationDropdown({
    required this.fieldId,
    required this.hintText,
    required this.value,
    required this.options,
    required this.onSelected,
    this.labelText,
    this.validator,
  });

  final String fieldId;
  final String? labelText;
  final String hintText;
  final String? value;
  final List<LocationModel> options;
  final ValueChanged<String?> onSelected;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: ValueKey('$fieldId-${value ?? ''}-${options.length}'),
      initialValue: value,
      validator: validator,
      builder: (field) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<String>(
                  width: constraints.maxWidth,
                  requestFocusOnTap: true,
                  enableFilter: true,
                  enableSearch: true,
                  initialSelection: field.value,
                  label: labelText == null ? null : Text(labelText!),
                  hintText: hintText,
                  dropdownMenuEntries: [
                    for (final location in options)
                      DropdownMenuEntry<String>(
                        value: location.locationCode,
                        label:
                            '${location.locationName} (${location.locationCode})',
                      ),
                  ],
                  onSelected: (selection) {
                    field.didChange(selection);
                    onSelected(selection);
                  },
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Text(
                      field.errorText ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
