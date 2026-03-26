import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/location_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/location_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class LocationFormScreen extends ConsumerStatefulWidget {
  const LocationFormScreen({super.key, this.editCode});

  final String? editCode;

  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(locationViewModelProvider);
    final formState = ref.watch(locationFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit Location' : 'Create Location',
      currentRoute: RoutePaths.locationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.locationMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          LocationModel? editLocation;
          if (widget.editCode != null) {
            for (final location in data.locations) {
              if (location.locationCode.toLowerCase() ==
                  widget.editCode!.toLowerCase()) {
                editLocation = location;
                break;
              }
            }
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref
                  .read(locationFormProvider.notifier)
                  .initialize(editLocation),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(locationFormProvider);
          final notifier = ref.read(locationFormProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode ? 'Edit Location' : 'Create Location',
                subtitle: 'Maintain master data for routes and trip planning',
                icon: Icons.edit_location_alt_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResponsiveFormGrid(
                        children: [
                          TextFormField(
                            initialValue: form.locationName,
                            decoration: const InputDecoration(
                              labelText: 'Location Name *',
                            ),
                            validator: _required,
                            onChanged: notifier.setLocationName,
                          ),
                          TextFormField(
                            initialValue: form.locationCode,
                            decoration: const InputDecoration(
                              labelText: 'Location Code *',
                            ),
                            validator: _required,
                            onChanged: notifier.setLocationCode,
                          ),
                          TextFormField(
                            initialValue: form.latitude,
                            decoration:
                                const InputDecoration(labelText: 'Latitude *'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: _validateCoordinate,
                            onChanged: notifier.setLatitude,
                          ),
                          TextFormField(
                            initialValue: form.longitude,
                            decoration:
                                const InputDecoration(labelText: 'Longitude *'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: _validateCoordinate,
                            onChanged: notifier.setLongitude,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(RoutePaths.locationMaster),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: () => _submit(context),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateCoordinate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Must be numeric';
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(locationFormProvider);
    final location = form.toLocationModel();
    final notifier = ref.read(locationViewModelProvider.notifier);
    final message = form.isEditMode
        ? await notifier.updateLocation(form.originalCode!, location)
        : await notifier.addLocation(location);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.locationMaster);
    }
  }
}

class _ResponsiveFormGrid extends StatelessWidget {
  const _ResponsiveFormGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.isDesktop(context)
        ? 2
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
