import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/route_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RouteListScreen extends ConsumerWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routeViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Route Location Master',
      currentRoute: RoutePaths.routeLocationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.routeLocationForm),
          child: const Text('Create Route'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredRoutes;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search',
                subtitle: 'Search by route name or locations',
                icon: Icons.search,
                accent: const Color(0xFF2563EB),
                child: TextFormField(
                  initialValue: data.searchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Route / Location',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ref
                      .read(routeViewModelProvider.notifier)
                      .setSearchQuery,
                ),
              ),
              const SizedBox(height: 16),
              OpsSectionCard(
                title: 'Route List',
                subtitle: 'Master data for route planning and trip execution',
                icon: Icons.alt_route_outlined,
                accent: const Color(0xFF16A34A),
                trailing: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.routeLocationForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Route'),
                ),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No routes found.'),
                      )
                    : (isMobile
                        ? _MobileRouteList(items: items)
                        : _DesktopRouteTable(items: items)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopRouteTable extends StatelessWidget {
  const _DesktopRouteTable({required this.items});

  final List<RouteLocationModel> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
        columns: const [
          DataColumn(label: Text('Start Location')),
          DataColumn(label: Text('End Location')),
          DataColumn(label: Text('Stops Count')),
          DataColumn(label: Text('Estimated Time')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final route in items)
            DataRow(
              cells: [
                DataCell(Text(route.startLocation.locationName)),
                DataCell(Text(route.endLocation.locationName)),
                DataCell(Text('${route.stopsCount}')),
                DataCell(Text(route.estimatedTime)),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.go(
                          RoutePaths.routeLocationViewById(route.routeId),
                        ),
                        child: const Text('View'),
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '${RoutePaths.routeLocationForm}?id=${route.routeId}',
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobileRouteList extends StatelessWidget {
  const _MobileRouteList({required this.items});

  final List<RouteLocationModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final route = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFDCE6F7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${route.startLocation.locationName} -> ${route.endLocation.locationName}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('Stops Count: ${route.stopsCount}'),
              Text('Estimated Time: ${route.estimatedTime}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(
                      RoutePaths.routeLocationViewById(route.routeId),
                    ),
                    child: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => context.go(
                      '${RoutePaths.routeLocationForm}?id=${route.routeId}',
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
