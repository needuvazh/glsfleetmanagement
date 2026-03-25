import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/compliance_viewmodel.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _typeFilter = 'All';
  String _severityFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final logistics = ref.watch(logisticsViewModelProvider);
    final inspections = ref.watch(inspectionViewModelProvider).items;
    final compliance = ref.watch(complianceViewModelProvider);

    return OpsShell(
      title: 'Alerts',
      currentRoute: RoutePaths.alerts,
      child: logistics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (logisticsData) {
          final complianceItems = compliance.valueOrNull?.items ?? const [];
          final alerts =
              _buildAlerts(logisticsData, inspections, complianceItems);

          final typeOptions = [
            'All',
            ...{for (final item in alerts) item.alertType}.toList()..sort()
          ];
          final severityOptions = [
            'All',
            ...{for (final item in alerts) item.severity}.toList()..sort()
          ];

          final filtered = alerts.where((item) {
            if (_typeFilter != 'All' && item.alertType != _typeFilter) {
              return false;
            }
            if (_severityFilter != 'All' && item.severity != _severityFilter) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Drop(
                        label: 'Alert Type',
                        value: _typeFilter,
                        options: typeOptions,
                        onChanged: (v) => setState(() => _typeFilter = v),
                      ),
                      _Drop(
                        label: 'Severity',
                        value: _severityFilter,
                        options: severityOptions,
                        onChanged: (v) => setState(() => _severityFilter = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Card(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No alerts found for selected filters.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Alert ID')),
                              DataColumn(label: Text('Alert Type')),
                              DataColumn(label: Text('Severity')),
                              DataColumn(label: Text('Related Module')),
                              DataColumn(label: Text('Related Record')),
                              DataColumn(label: Text('Created At')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Assigned To')),
                              DataColumn(label: Text('Open')),
                            ],
                            rows: [
                              for (final alert in filtered)
                                DataRow(
                                  onSelectChanged: (_) =>
                                      _openRelatedRecord(context, alert),
                                  cells: [
                                    DataCell(Text(alert.alertId)),
                                    DataCell(Text(alert.alertType)),
                                    DataCell(
                                      Text(
                                        alert.severity,
                                        style: TextStyle(
                                          color: alert.severity == 'High'
                                              ? const Color(0xFFB91C1C)
                                              : alert.severity == 'Medium'
                                                  ? const Color(0xFFD97706)
                                                  : const Color(0xFF15803D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(alert.relatedModule)),
                                    DataCell(Text(alert.relatedRecord)),
                                    DataCell(
                                        Text(_fmtDateTime(alert.createdAt))),
                                    DataCell(Text(alert.status)),
                                    DataCell(Text(alert.assignedTo)),
                                    DataCell(
                                      IconButton(
                                        tooltip: 'Open related record',
                                        onPressed: () =>
                                            _openRelatedRecord(context, alert),
                                        icon: const Icon(
                                            Icons.open_in_new_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_OperationalAlert> _buildAlerts(
    LogisticsUiState logistics,
    List inspections,
    List complianceItems,
  ) {
    final now = DateTime.now();
    final items = <_OperationalAlert>[];

    var seq = 1;
    String nextId() => 'ALT-${(9000 + seq++).toString()}';

    for (final inspection in inspections) {
      if (inspection.overallResult.label == 'Failed') {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'inspection failed',
          severity: inspection.criticalFailureCount > 0 ? 'High' : 'Medium',
          relatedModule: 'Inspections',
          relatedRecord: inspection.inspectionId,
          createdAt: inspection.lastUpdated,
          status: 'Open',
          assignedTo: 'Compliance Officer',
        ));
      }

      final due = inspection.nextInspectionDate ??
          inspection.inspectedAt.add(const Duration(days: 30));
      if (due.isBefore(DateTime(now.year, now.month, now.day))) {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'inspection overdue',
          severity: 'High',
          relatedModule: 'Inspections',
          relatedRecord: inspection.inspectionId,
          createdAt: due,
          status: 'Open',
          assignedTo: 'Inspection Desk',
        ));
      }
    }

    for (final driver in logistics.drivers) {
      final expiry = DateTime.tryParse(driver.expiryDate.trim());
      if (expiry != null) {
        final days = expiry.difference(now).inDays;
        if (days >= 0 && days <= 30) {
          items.add(_OperationalAlert(
            alertId: nextId(),
            alertType: 'license expiring',
            severity: days <= 7 ? 'High' : 'Medium',
            relatedModule: 'Drivers',
            relatedRecord: driver.driverId,
            createdAt: now.subtract(const Duration(hours: 2)),
            status: 'Open',
            assignedTo: 'HR Compliance',
          ));
        }
      }

      if (!driver.status.toLowerCase().contains('available')) {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'driver unavailable',
          severity: 'Medium',
          relatedModule: 'Drivers',
          relatedRecord: driver.driverId,
          createdAt: now.subtract(const Duration(hours: 1)),
          status: 'Investigating',
          assignedTo: 'Dispatch Team',
        ));
      }
    }

    for (final item in complianceItems) {
      if (item.complianceStatus.label == 'Expiring Soon') {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'insurance expiring',
          severity: 'Medium',
          relatedModule: 'Fleet',
          relatedRecord: item.vehicleId,
          createdAt: now.subtract(const Duration(hours: 4)),
          status: 'Open',
          assignedTo: 'Fleet Compliance',
        ));
      }
    }

    for (final wo in logistics.workOrders) {
      if (wo.status.toLowerCase().contains('delay')) {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'trip delayed',
          severity: 'High',
          relatedModule: 'Trips',
          relatedRecord: wo.woId,
          createdAt: now.subtract(const Duration(minutes: 40)),
          status: 'Open',
          assignedTo: 'Operations Control',
        ));
      }

      final hash = wo.woId.codeUnits.fold<int>(0, (a, b) => a + b);
      final podMissing = hash % 2 == 1;
      if (podMissing) {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'POD missing',
          severity: 'Medium',
          relatedModule: 'Documents',
          relatedRecord: wo.woId,
          createdAt: now.subtract(const Duration(hours: 6)),
          status: 'Open',
          assignedTo: 'Document Controller',
        ));
      }
    }

    for (final vehicle in logistics.vehicles) {
      if (!vehicle.status.toLowerCase().contains('available')) {
        items.add(_OperationalAlert(
          alertId: nextId(),
          alertType: 'fleet unavailable',
          severity: 'Medium',
          relatedModule: 'Fleet',
          relatedRecord: vehicle.vehicleNo,
          createdAt: now.subtract(const Duration(hours: 2)),
          status: 'Investigating',
          assignedTo: 'Fleet Desk',
        ));
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }

  void _openRelatedRecord(BuildContext context, _OperationalAlert alert) {
    final module = alert.relatedModule.toLowerCase();
    final record = alert.relatedRecord;

    if (module.contains('inspection')) {
      context.push(RoutePaths.inspectionDetailById(record));
      return;
    }
    if (module.contains('fleet')) {
      context.push(RoutePaths.fleetDetailById(record));
      return;
    }
    if (module.contains('driver')) {
      context.push(RoutePaths.driverDetailById(record));
      return;
    }
    if (module.contains('trip')) {
      context.push(RoutePaths.tripMonitoring);
      return;
    }
    if (record.toUpperCase().startsWith('WO-')) {
      context.push(RoutePaths.workOrderDetailById(record));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('No deep link configured for ${alert.relatedModule}.')),
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
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _OperationalAlert {
  const _OperationalAlert({
    required this.alertId,
    required this.alertType,
    required this.severity,
    required this.relatedModule,
    required this.relatedRecord,
    required this.createdAt,
    required this.status,
    required this.assignedTo,
  });

  final String alertId;
  final String alertType;
  final String severity;
  final String relatedModule;
  final String relatedRecord;
  final DateTime createdAt;
  final String status;
  final String assignedTo;
}
