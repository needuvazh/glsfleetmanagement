import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/location_model.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/route_viewmodel.dart';
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode ? 'Edit Route' : 'Create Route',
                subtitle: 'Maintain route master data for planning and trip execution',
                icon: Icons.route_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionLabel(title: 'Route Info'),
                      const SizedBox(height: 16),
                      _ResponsiveFormGrid(
                        children: [
                          _SearchableLocationDropdown(
                            fieldId: 'start-location',
                            labelText: 'Start Location *',
                            hintText: 'Select Start Location',
                            value: form.startLocationCode,
                            options: locations,
                            validator: _requiredSelection,
                            onSelected: notifier.setStartLocation,
                          ),
                          _SearchableLocationDropdown(
                            fieldId: 'end-location',
                            labelText: 'End Location *',
                            hintText: 'Select End Location',
                            value: form.endLocationCode,
                            options: locations,
                            validator: _requiredSelection,
                            onSelected: notifier.setEndLocation,
                          ),
                          TextFormField(
                            initialValue: form.estimatedTime,
                            decoration: const InputDecoration(
                              labelText: 'Estimated Time *',
                              hintText: 'e.g. 6 hrs',
                            ),
                            validator: _requiredText,
                            onChanged: notifier.setEstimatedTime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel(title: 'Intermediate Stops'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('Add optional stops between start and end'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: notifier.addStop,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Stop'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (form.stopLocationCodes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(color: const Color(0xFFDCE6F7)),
                          ),
                          child: const Text('No intermediate stops added.'),
                        ),
                      for (int i = 0; i < form.stopLocationCodes.length; i++) ...[
                        _StopRow(
                          index: i,
                          value: form.stopLocationCodes[i],
                          options: _availableStopOptions(
                            locations: locations,
                            form: form,
                            index: i,
                          ),
                          validator: (value) => _validateStopLocation(
                            value,
                            form: form,
                            index: i,
                          ),
                          onSelected: (value) => notifier.updateStop(i, value),
                          onRemove: () => notifier.removeStop(i),
                        ),
                        if (i != form.stopLocationCodes.length - 1)
                          const SizedBox(height: 16),
                      ],
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

    for (int i = 0; i < form.stopLocationCodes.length; i++) {
      if (i == index) {
        continue;
      }
      final code = form.stopLocationCodes[i];
      if (code != null && code.isNotEmpty) {
        blockedCodes.add(code);
      }
    }

    return locations.where((location) {
      final currentCode = form.stopLocationCodes[index];
      if (currentCode == location.locationCode) {
        return true;
      }
      return !blockedCodes.contains(location.locationCode);
    }).toList();
  }

  String? _requiredText(String? value) {
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

  String? _validateStopLocation(
    String? value, {
    required RouteFormState form,
    required int index,
  }) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return 'Required';
    }
    if (code == form.startLocationCode || code == form.endLocationCode) {
      return 'Cannot match start/end';
    }
    for (int i = 0; i < form.stopLocationCodes.length; i++) {
      if (i == index) {
        continue;
      }
      if (form.stopLocationCodes[i] == code) {
        return 'Duplicate stop';
      }
    }
    return null;
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
        const SnackBar(
          content: Text('Start location and end location are required.'),
        ),
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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    required this.validator,
    required this.onSelected,
    required this.onRemove,
  });

  final int index;
  final String? value;
  final List<LocationModel> options;
  final String? Function(String?) validator;
  final ValueChanged<String?> onSelected;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _SearchableLocationDropdown(
              fieldId: 'stop-$index',
              hintText: 'Select Stop Location',
              value: value,
              options: options,
              validator: validator,
              onSelected: onSelected,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'Remove Stop',
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
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
