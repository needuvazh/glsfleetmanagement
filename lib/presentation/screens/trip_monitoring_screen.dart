import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class TripMonitoringScreen extends ConsumerStatefulWidget {
  const TripMonitoringScreen({super.key});

  @override
  ConsumerState<TripMonitoringScreen> createState() =>
      _TripMonitoringScreenState();
}

class _TripMonitoringScreenState extends ConsumerState<TripMonitoringScreen> {
  bool _delayedOnly = false;
  String _workOrderFilter = 'All';
  String _fleetFilter = 'All';
  String _routeFilter = 'All';
  _TripRow? _selectedRow;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Trip Monitoring',
      currentRoute: RoutePaths.tripMonitoring,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = _buildRows(data);
          final filtered = _applyFilters(rows);

          final workOrderOptions =
              _withAll(rows.map((e) => e.workOrder).toSet().toList()..sort());
          final fleetOptions =
              _withAll(rows.map((e) => e.fleet).toSet().toList()..sort());
          final routeOptions =
              _withAll(rows.map((e) => e.route).toSet().toList()..sort());

          return Column(
            children: [
              _FilterBar(
                delayedOnly: _delayedOnly,
                workOrderFilter: _workOrderFilter,
                fleetFilter: _fleetFilter,
                routeFilter: _routeFilter,
                workOrderOptions: workOrderOptions,
                fleetOptions: fleetOptions,
                routeOptions: routeOptions,
                onDelayedChanged: (v) => setState(() => _delayedOnly = v),
                onWorkOrderChanged: (v) => setState(() => _workOrderFilter = v),
                onFleetChanged: (v) => setState(() => _fleetFilter = v),
                onRouteChanged: (v) => setState(() => _routeFilter = v),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showDrawerPanel = constraints.maxWidth > 1200;

                    return Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: filtered.isEmpty
                                  ? const Center(
                                      child: Text(
                                          'No trips match selected filters'))
                                  : _TripTable(
                                      rows: filtered,
                                      onRowTap: (row) {
                                        if (showDrawerPanel) {
                                          setState(() => _selectedRow = row);
                                        } else {
                                          _openDrawerSheet(context, row);
                                        }
                                      },
                                      onOpenWorkOrder: (row) => context.push(
                                          RoutePaths.workOrderDetailById(
                                              row.workOrder)),
                                    ),
                            ),
                          ),
                        ),
                        if (showDrawerPanel) ...[
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 360,
                            child: _TripDetailDrawer(row: _selectedRow),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _withAll(List<String> items) => ['All', ...items];

  List<_TripRow> _applyFilters(List<_TripRow> rows) {
    return rows.where((row) {
      if (_delayedOnly && !row.delayIndicator.toLowerCase().contains('yes')) {
        return false;
      }
      if (_workOrderFilter != 'All' && row.workOrder != _workOrderFilter) {
        return false;
      }
      if (_fleetFilter != 'All' && row.fleet != _fleetFilter) {
        return false;
      }
      if (_routeFilter != 'All' && row.route != _routeFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<_TripRow> _buildRows(LogisticsUiState data) {
    final now = DateTime.now();
    final rows = <_TripRow>[];

    for (var i = 0; i < data.workOrders.length; i++) {
      final wo = data.workOrders[i];
      final vehicle = data.vehicles.isEmpty
          ? null
          : data.vehicles[i % data.vehicles.length];
      final driver =
          data.drivers.isEmpty ? null : data.drivers[i % data.drivers.length];

      final isDelayed =
          wo.status.toLowerCase().contains('delay') || (i % 3 == 2);
      final isActive = i % 2 == 0;
      final milestone = isActive ? 'In Transit' : 'Scheduled for Dispatch';
      final status = isActive ? 'Active' : 'Upcoming';

      rows.add(
        _TripRow(
          tripNumber: 'TRP-${3001 + i}',
          workOrder: wo.woId,
          customer: wo.customer,
          fleet: vehicle?.vehicleNo ?? 'Unassigned',
          driver: driver?.name ?? 'Unassigned',
          route: wo.route,
          routeRisk: wo.routeRiskLevel,
          routeStatus: wo.routeOperationalStatus,
          currentStatus: status,
          lastMilestone: milestone,
          delayIndicator: isDelayed ? 'Yes (${20 + (i * 8)}m)' : 'No',
          lastUpdated:
              _formatDateTime(now.subtract(Duration(minutes: i * 17 + 3))),
          inspectionCleared: (i % 4 == 1) ? 'No' : 'Yes',
          recentNotes: isDelayed
              ? 'Traffic congestion near checkpoint, reroute advised.'
              : 'Normal trip progression with on-time milestones.',
          delayReason: isDelayed
              ? 'Road hold at permit validation gate.'
              : 'No delays reported.',
          uploadedMedia: isDelayed ? '3 images, 1 voice note' : '2 images',
          timeline: const [
            'Trip Created',
            'Assigned',
            'Dispatched',
            'In Transit',
            'Near Destination',
            'Delivered',
          ],
        ),
      );
    }

    return rows;
  }

  Future<void> _openDrawerSheet(BuildContext context, _TripRow row) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _TripDetailDrawer(row: row),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $hour:$minute';
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.delayedOnly,
    required this.workOrderFilter,
    required this.fleetFilter,
    required this.routeFilter,
    required this.workOrderOptions,
    required this.fleetOptions,
    required this.routeOptions,
    required this.onDelayedChanged,
    required this.onWorkOrderChanged,
    required this.onFleetChanged,
    required this.onRouteChanged,
  });

  final bool delayedOnly;
  final String workOrderFilter;
  final String fleetFilter;
  final String routeFilter;
  final List<String> workOrderOptions;
  final List<String> fleetOptions;
  final List<String> routeOptions;
  final ValueChanged<bool> onDelayedChanged;
  final ValueChanged<String> onWorkOrderChanged;
  final ValueChanged<String> onFleetChanged;
  final ValueChanged<String> onRouteChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              selected: delayedOnly,
              onSelected: onDelayedChanged,
              label: const Text('Delayed Trips Only'),
            ),
            _Drop(
              label: 'Work Order',
              value: workOrderFilter,
              options: workOrderOptions,
              onChanged: onWorkOrderChanged,
            ),
            _Drop(
              label: 'Fleet',
              value: fleetFilter,
              options: fleetOptions,
              onChanged: onFleetChanged,
            ),
            _Drop(
              label: 'Route',
              value: routeFilter,
              options: routeOptions,
              onChanged: onRouteChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _Drop extends StatelessWidget {
  const _Drop({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
      ),
    );
  }
}

class _TripTable extends StatelessWidget {
  const _TripTable({
    required this.rows,
    required this.onRowTap,
    required this.onOpenWorkOrder,
  });

  final List<_TripRow> rows;
  final ValueChanged<_TripRow> onRowTap;
  final ValueChanged<_TripRow> onOpenWorkOrder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Trip Number')),
          DataColumn(label: Text('Work Order')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Fleet')),
          DataColumn(label: Text('Driver')),
          DataColumn(label: Text('Route')),
          DataColumn(label: Text('Current Status')),
          DataColumn(label: Text('Last Milestone')),
          DataColumn(label: Text('Delay Indicator')),
          DataColumn(label: Text('Last Updated')),
          DataColumn(label: Text('Inspection Cleared')),
          DataColumn(label: Text('Action')),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              onSelectChanged: (_) => onRowTap(row),
              cells: [
                DataCell(Text(row.tripNumber)),
                DataCell(Text(row.workOrder)),
                DataCell(Text(row.customer)),
                DataCell(Text(row.fleet)),
                DataCell(Text(row.driver)),
                DataCell(Text(row.route)),
                DataCell(Text(row.currentStatus)),
                DataCell(Text(row.lastMilestone)),
                DataCell(
                  Text(
                    row.delayIndicator,
                    style: TextStyle(
                      color: row.delayIndicator.startsWith('Yes')
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF15803D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(Text(row.lastUpdated)),
                DataCell(Text(row.inspectionCleared)),
                DataCell(
                  IconButton(
                    tooltip: 'Open Related Work Order',
                    onPressed: () => onOpenWorkOrder(row),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TripDetailDrawer extends StatelessWidget {
  const _TripDetailDrawer({required this.row});

  final _TripRow? row;

  @override
  Widget build(BuildContext context) {
    if (row == null) {
      return const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
                'Select a trip row to view summary, notes, delay reason, media and timeline.'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text('Trip Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _pair('Trip Number', row!.tripNumber),
            _pair('Work Order', row!.workOrder),
            _pair('Customer', row!.customer),
            _pair('Fleet', row!.fleet),
            _pair('Driver', row!.driver),
            _pair('Route', row!.route),
            _pair('Route Risk', row!.routeRisk),
            _pair('Route Status', row!.routeStatus),
            const Divider(height: 22),
            Text('Recent Notes', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(row!.recentNotes),
            const SizedBox(height: 12),
            Text('Delay Reason', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(row!.delayReason),
            const SizedBox(height: 12),
            Text('Uploaded Media',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(row!.uploadedMedia),
            const SizedBox(height: 12),
            Text('Current Timeline',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (var i = 0; i < row!.timeline.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  i <= 3 ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: i <= 3 ? const Color(0xFF15803D) : null,
                ),
                title: Text(row!.timeline[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 104,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TripRow {
  const _TripRow({
    required this.tripNumber,
    required this.workOrder,
    required this.customer,
    required this.fleet,
    required this.driver,
    required this.route,
    required this.routeRisk,
    required this.routeStatus,
    required this.currentStatus,
    required this.lastMilestone,
    required this.delayIndicator,
    required this.lastUpdated,
    required this.inspectionCleared,
    required this.recentNotes,
    required this.delayReason,
    required this.uploadedMedia,
    required this.timeline,
  });

  final String tripNumber;
  final String workOrder;
  final String customer;
  final String fleet;
  final String driver;
  final String route;
  final String routeRisk;
  final String routeStatus;
  final String currentStatus;
  final String lastMilestone;
  final String delayIndicator;
  final String lastUpdated;
  final String inspectionCleared;
  final String recentNotes;
  final String delayReason;
  final String uploadedMedia;
  final List<String> timeline;
}
