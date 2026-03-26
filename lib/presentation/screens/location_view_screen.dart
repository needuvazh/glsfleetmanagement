import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/location_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/location_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class LocationViewScreen extends ConsumerWidget {
  const LocationViewScreen({super.key, required this.locationCode});

  final String locationCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationViewModelProvider);

    return OpsShell(
      title: 'Location Details',
      currentRoute: RoutePaths.locationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.locationMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          LocationModel? location;
          for (final entry in data.locations) {
            if (entry.locationCode.toLowerCase() == locationCode.toLowerCase()) {
              location = entry;
              break;
            }
          }

          if (location == null) {
            return const Center(child: Text('Location not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: location.locationName,
                subtitle: 'Read-only Location Master details',
                icon: Icons.visibility_outlined,
                accent: const Color(0xFF0EA5E9),
                child: _LocationDetailsGrid(location: location),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LocationDetailsGrid extends StatelessWidget {
  const _LocationDetailsGrid({required this.location});

  final LocationModel location;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.isDesktop(context)
        ? 2
        : (Responsive.isTablet(context) ? 2 : 1);
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _DetailTile(
              width: itemWidth,
              label: 'Location Name',
              value: location.locationName,
            ),
            _DetailTile(
              width: itemWidth,
              label: 'Location Code',
              value: location.locationCode,
            ),
            _DetailTile(
              width: itemWidth,
              label: 'Latitude',
              value: location.latitude.toStringAsFixed(4),
            ),
            _DetailTile(
              width: itemWidth,
              label: 'Longitude',
              value: location.longitude.toStringAsFixed(4),
            ),
          ],
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(value),
      ),
    );
  }
}
