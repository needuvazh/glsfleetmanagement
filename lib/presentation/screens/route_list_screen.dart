import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RouteListScreen extends ConsumerWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routeViewModelProvider);
    final logistics = ref.watch(logisticsViewModelProvider).valueOrNull;
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Route Location Master',
      currentRoute: RoutePaths.routeLocationMaster,
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredRoutes;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Search & Filters',
                  subtitle: 'Search by route code, name, origin, destination',
                  icon: Icons.search,
                  accent: const Color(0xFF2563EB),
                  child: Column(
                    children: [
                      if (isMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: data.searchQuery,
                              decoration: const InputDecoration(
                                labelText:
                                    'Route Code / Name / Origin / Destination',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(routeViewModelProvider.notifier)
                                  .setSearchQuery,
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.routeLocationForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Route'),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: data.searchQuery,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Route Code / Name / Origin / Destination',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: ref
                                    .read(routeViewModelProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.routeLocationForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Route'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _filterDropdown<RouteOperationalStatus?>(
                            label: 'Status',
                            value: data.statusFilter,
                            options: const [
                              null,
                              ...RouteOperationalStatus.values
                            ],
                            itemLabel: (item) =>
                                item == null ? 'All' : item.label,
                            onChanged: (value) => ref
                                .read(routeViewModelProvider.notifier)
                                .setStatusFilter(value),
                          ),
                          _filterDropdown<RouteRiskLevel?>(
                            label: 'Risk Level',
                            value: data.riskFilter,
                            options: const [null, ...RouteRiskLevel.values],
                            itemLabel: (item) =>
                                item == null ? 'All' : item.label,
                            onChanged: (value) => ref
                                .read(routeViewModelProvider.notifier)
                                .setRiskFilter(value),
                          ),
                          _filterDropdown<String>(
                            label: 'Region',
                            value: data.regionFilter,
                            options: data.regionOptions,
                            itemLabel: (item) => item,
                            onChanged: (value) => ref
                                .read(routeViewModelProvider.notifier)
                                .setRegionFilter(value),
                          ),
                          _filterDropdown<String>(
                            label: 'Distance',
                            value: data.distanceFilter,
                            options: const [
                              'All',
                              'Short Distance',
                              'Long Distance'
                            ],
                            itemLabel: (item) => item,
                            onChanged: (value) => ref
                                .read(routeViewModelProvider.notifier)
                                .setDistanceFilter(value),
                          ),
                          _filterDropdown<String>(
                            label: 'Type',
                            value: data.customerSpecificFilter,
                            options: const [
                              'All',
                              'Customer Specific',
                              'General'
                            ],
                            itemLabel: (item) => item,
                            onChanged: (value) => ref
                                .read(routeViewModelProvider.notifier)
                                .setCustomerSpecificFilter(value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Route List',
                    subtitle:
                        'Master routes with planning, risk and dispatch usability indicators',
                    icon: Icons.alt_route_outlined,
                    accent: const Color(0xFF16A34A),
                    expandChild: true,
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No routes found.'),
                          )
                        : (isMobile
                            ? _MobileRouteList(
                                items: items, logistics: logistics)
                            : _DesktopRouteTable(
                                items: items, logistics: logistics)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required T value,
    required List<T> options,
    required String Function(T) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return SizedBox(
      width: 210,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in options)
            DropdownMenuItem(
              value: option,
              child: Text(
                itemLabel(option),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (value) => onChanged(value as T),
      ),
    );
  }
}

class _DesktopRouteTable extends ConsumerStatefulWidget {
  const _DesktopRouteTable({required this.items, required this.logistics});

  final List<RouteLocationModel> items;
  final LogisticsUiState? logistics;

  @override
  ConsumerState<_DesktopRouteTable> createState() => _DesktopRouteTableState();
}

class _DesktopRouteTableState extends ConsumerState<_DesktopRouteTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _horizontalController,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                horizontalMargin: 14,
                columnSpacing: 20,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 74,
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Route')),
                  DataColumn(label: Text('ETA')),
                  DataColumn(label: Text('Distance')),
                  DataColumn(label: Text('Risk')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Active WO')),
                  DataColumn(label: Text('Delayed Trips')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final route in widget.items)
                    DataRow(
                      cells: [
                        DataCell(Text(route.routeCode)),
                        DataCell(Text(route.routeName)),
                        DataCell(Text(route.estimatedTime)),
                        DataCell(
                            Text('${route.distanceKm.toStringAsFixed(1)} km')),
                        DataCell(_RiskChip(level: route.riskLevel)),
                        DataCell(_StatusChip(route: route)),
                        DataCell(
                            Text('${_activeWorkOrders(route, widget.logistics)}')),
                        DataCell(
                            Text('${_delayedTrips(route, widget.logistics)}')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(64, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onPressed: () => context.go(
                                  RoutePaths.routeLocationViewById(
                                      route.routeId),
                                ),
                                child: const Text('View'),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(60, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onPressed: () => context.go(
                                  '${RoutePaths.routeLocationForm}?id=${route.routeId}',
                                ),
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 6),
                              PopupMenuButton<String>(
                                constraints: const BoxConstraints(minWidth: 140),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'deactivate',
                                      child: Text('Deactivate')),
                                  PopupMenuItem(
                                      value: 'restrict',
                                      child: Text('Mark Restricted')),
                                  PopupMenuItem(
                                      value: 'activate',
                                      child: Text('Mark Active')),
                                ],
                                onSelected: (value) async {
                                  final notifier =
                                      ref.read(routeViewModelProvider.notifier);
                                  String message;
                                  if (value == 'deactivate') {
                                    message = await notifier.setRouteStatus(
                                      route.routeId,
                                      RouteOperationalStatus.inactive,
                                    );
                                  } else if (value == 'restrict') {
                                    message = await notifier.setRouteStatus(
                                      route.routeId,
                                      RouteOperationalStatus.restricted,
                                      temporarilyRestricted: true,
                                      restrictionReason:
                                          'Temporarily blocked by operations',
                                    );
                                  } else {
                                    message = await notifier.setRouteStatus(
                                      route.routeId,
                                      RouteOperationalStatus.active,
                                      temporarilyRestricted: false,
                                      restrictionReason: '',
                                    );
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileRouteList extends ConsumerWidget {
  const _MobileRouteList({required this.items, required this.logistics});

  final List<RouteLocationModel> items;
  final LogisticsUiState? logistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
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
                '${route.routeCode} • ${route.routeName}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                  'Origin: ${route.startLocation.locationName}  ->  ${route.endLocation.locationName}'),
              Text('ETA: ${route.estimatedTime}'),
              Text('Distance: ${route.distanceKm.toStringAsFixed(1)} km'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  _RiskChip(level: route.riskLevel),
                  _StatusChip(route: route),
                ],
              ),
              const SizedBox(height: 6),
              Text('Active WO: ${_activeWorkOrders(route, logistics)}'),
              Text('Delayed Trips: ${_delayedTrips(route, logistics)}'),
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

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.level});

  final RouteRiskLevel level;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level) {
      case RouteRiskLevel.low:
        color = const Color(0xFF15803D);
        break;
      case RouteRiskLevel.medium:
        color = const Color(0xFFD97706);
        break;
      case RouteRiskLevel.high:
        color = const Color(0xFFEA580C);
        break;
      case RouteRiskLevel.critical:
        color = const Color(0xFFB91C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.route});

  final RouteLocationModel route;

  @override
  Widget build(BuildContext context) {
    var text = route.status.label;
    Color color;
    if (route.status == RouteOperationalStatus.active &&
        !route.temporarilyRestricted) {
      color = const Color(0xFF15803D);
    } else if (route.status == RouteOperationalStatus.inactive) {
      color = const Color(0xFF6B7280);
    } else {
      text = 'Restricted';
      color = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

int _activeWorkOrders(RouteLocationModel route, LogisticsUiState? logistics) {
  if (logistics == null) {
    return 0;
  }
  var count = 0;
  for (final item in logistics.workOrders) {
    final routeText = item.route.toLowerCase();
    final active = !item.status.toLowerCase().contains('complete');
    if (active && _matchesRouteText(route, routeText)) {
      count += 1;
    }
  }
  return count;
}

int _delayedTrips(RouteLocationModel route, LogisticsUiState? logistics) {
  if (logistics == null) {
    return 0;
  }
  var count = 0;
  for (final item in logistics.workOrders) {
    final routeText = item.route.toLowerCase();
    final delayed = item.status.toLowerCase().contains('delay');
    if (delayed && _matchesRouteText(route, routeText)) {
      count += 1;
    }
  }
  return count;
}

bool _matchesRouteText(RouteLocationModel route, String routeText) {
  final code = route.routeCode.toLowerCase();
  final name = route.routeName.toLowerCase();
  final origin = route.startLocation.locationName.toLowerCase();
  final destination = route.endLocation.locationName.toLowerCase();

  return routeText.contains(code) ||
      routeText.contains(name) ||
      (routeText.contains(origin) && routeText.contains(destination));
}
