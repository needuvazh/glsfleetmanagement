import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/route_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RouteViewScreen extends ConsumerWidget {
  const RouteViewScreen({super.key, required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routeViewModelProvider);

    return OpsShell(
      title: 'Route Details',
      currentRoute: RoutePaths.routeLocationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.routeLocationMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          RouteLocationModel? route;
          for (final entry in data.routes) {
            if (entry.routeId == routeId) {
              route = entry;
              break;
            }
          }

          if (route == null) {
            return const Center(child: Text('Route not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: route.routeName,
                subtitle: 'Read-only route master details',
                icon: Icons.visibility_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RouteDetailsGrid(route: route),
                    const SizedBox(height: 16),
                    Text(
                      'Intermediate Stops',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    if (route.stops.isEmpty)
                      const Text('No intermediate stops configured.')
                    else
                      Column(
                        children: [
                          for (int i = 0; i < route.stops.length; i++) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: const Color(0xFFDCE6F7),
                                ),
                              ),
                              child: Text(
                                '${i + 1}. ${route.stops[i].locationName} (${route.stops[i].locationCode})',
                              ),
                            ),
                            if (i != route.stops.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteDetailsGrid extends StatelessWidget {
  const _RouteDetailsGrid({required this.route});

  final RouteLocationModel route;

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
            _DetailTile(
              width: itemWidth,
              label: 'Start Location',
              value:
                  '${route.startLocation.locationName} (${route.startLocation.locationCode})',
            ),
            _DetailTile(
              width: itemWidth,
              label: 'End Location',
              value:
                  '${route.endLocation.locationName} (${route.endLocation.locationCode})',
            ),
            _DetailTile(
              width: itemWidth,
              label: 'Estimated Time',
              value: route.estimatedTime,
            ),
            _DetailTile(
              width: itemWidth,
              label: 'Stops Count',
              value: '${route.stopsCount}',
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
