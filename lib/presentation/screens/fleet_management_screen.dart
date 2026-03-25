import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/fleet.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/fleet_viewmodel.dart';
import '../widgets/ops_shell.dart';

class FleetManagementScreen extends ConsumerWidget {
  const FleetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fleetState = ref.watch(fleetViewModelProvider);

    return OpsShell(
      title: 'Fleet List',
      currentRoute: RoutePaths.fleetManagement,
      actions: [
        FilledButton.icon(
          onPressed: () => _openFleetDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Fleet'),
        ),
        const SizedBox(width: 8),
      ],
      child: fleetState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (state) {
          final rows =
              state.filteredItems.map(_FleetListRow.fromFleet).toList();

          return Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: ref
                              .read(fleetViewModelProvider.notifier)
                              .setQuery,
                          decoration: const InputDecoration(
                            hintText: 'Search by fleet number, type, driver',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<FleetFilter>(
                          value: state.filter,
                          decoration:
                              const InputDecoration(labelText: 'Status'),
                          items: [
                            for (final value in FleetFilter.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(fleetViewModelProvider.notifier)
                                  .setFilter(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Card(
                  child: rows.isEmpty
                      ? const Center(child: Text('No fleet records found'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Fleet Number')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Registration')),
                              DataColumn(label: Text('Insurance Expiry')),
                              DataColumn(label: Text('Inspection Due Date')),
                              DataColumn(label: Text('Current Status')),
                              DataColumn(label: Text('Current Work Order')),
                              DataColumn(label: Text('Current Trip')),
                              DataColumn(label: Text('Compliance Warning')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: [
                              for (final row in rows)
                                DataRow(cells: [
                                  DataCell(Text(row.fleetNumber)),
                                  DataCell(Text(row.type)),
                                  DataCell(Text(row.registration)),
                                  DataCell(Text(_fmtDate(row.insuranceExpiry))),
                                  DataCell(
                                      Text(_fmtDate(row.inspectionDueDate))),
                                  DataCell(Text(row.currentStatus)),
                                  DataCell(Text(row.currentWorkOrder)),
                                  DataCell(Text(row.currentTrip)),
                                  DataCell(
                                    Text(
                                      row.complianceWarning,
                                      style: TextStyle(
                                        color: row.complianceWarning == 'None'
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFFB91C1C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Wrap(
                                      spacing: 2,
                                      children: [
                                        IconButton(
                                          tooltip: 'Edit',
                                          onPressed: () => _openFleetDialog(
                                            context,
                                            ref,
                                            existing: row.source,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                        IconButton(
                                          tooltip: 'Open Details',
                                          onPressed: () => context.push(
                                            RoutePaths.fleetDetailById(
                                                row.fleetNumber),
                                          ),
                                          icon: const Icon(
                                              Icons.open_in_new_rounded),
                                        ),
                                        IconButton(
                                          tooltip: 'View Inspections',
                                          onPressed: () => context.push(
                                            RoutePaths.inspections,
                                          ),
                                          icon: const Icon(
                                              Icons.fact_check_outlined),
                                        ),
                                        IconButton(
                                          tooltip: 'View Media',
                                          onPressed: () =>
                                              _showMediaPlaceholder(
                                            context,
                                            row.fleetNumber,
                                          ),
                                          icon: const Icon(
                                              Icons.perm_media_outlined),
                                        ),
                                        IconButton(
                                          tooltip: 'View History',
                                          onPressed: () => context.push(
                                            '${RoutePaths.fleetDetailById(row.fleetNumber)}?tab=history',
                                          ),
                                          icon: const Icon(
                                              Icons.history_outlined),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
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

  static String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  Future<void> _openFleetDialog(
    BuildContext context,
    WidgetRef ref, {
    Fleet? existing,
  }) async {
    final isEdit = existing != null;
    final fleetNumberCtrl =
        TextEditingController(text: existing?.vehicleNumber ?? '');
    final typeCtrl = TextEditingController(text: existing?.type ?? 'Truck');
    final driverCtrl = TextEditingController(
        text: existing?.driver == 'Unassigned' ? '' : existing?.driver ?? '');
    final fuelCtrl = TextEditingController(
      text: (existing?.fuelLevel ?? 70).toString(),
    );
    final odometerCtrl = TextEditingController(
      text: (existing?.odometerKm ?? 0).toString(),
    );
    var status = existing?.status ?? FleetStatus.idle;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Fleet' : 'Add Fleet'),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fleetNumberCtrl,
                      enabled: !isEdit,
                      decoration:
                          const InputDecoration(labelText: 'Fleet Number'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: typeCtrl,
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: driverCtrl,
                      decoration: const InputDecoration(labelText: 'Driver'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<FleetStatus>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        for (final value in FleetStatus.values)
                          DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setInnerState(() => status = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fuelCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Fuel Level %'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: odometerCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Odometer Km'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final fleetNumber = fleetNumberCtrl.text.trim();
                    final type = typeCtrl.text.trim();
                    final driver = driverCtrl.text.trim();
                    final fuel = int.tryParse(fuelCtrl.text.trim()) ?? 0;
                    final odometer =
                        int.tryParse(odometerCtrl.text.trim()) ?? 0;

                    final vm = ref.read(fleetViewModelProvider.notifier);
                    final message = isEdit
                        ? vm.updateFleet(
                            fleetNumber: existing.vehicleNumber,
                            type: type,
                            driver: driver,
                            status: status,
                            fuelLevel: fuel,
                            odometerKm: odometer,
                          )
                        : vm.addFleet(
                            fleetNumber: fleetNumber,
                            type: type,
                            driver: driver,
                            status: status,
                            fuelLevel: fuel,
                            odometerKm: odometer,
                          );

                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  child: Text(isEdit ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    fleetNumberCtrl.dispose();
    typeCtrl.dispose();
    driverCtrl.dispose();
    fuelCtrl.dispose();
    odometerCtrl.dispose();
  }

  static void _showMediaPlaceholder(BuildContext context, String fleetNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Media viewer placeholder for $fleetNumber.')),
    );
  }
}

class _FleetListRow {
  const _FleetListRow({
    required this.source,
    required this.fleetNumber,
    required this.type,
    required this.registration,
    required this.insuranceExpiry,
    required this.inspectionDueDate,
    required this.currentStatus,
    required this.currentWorkOrder,
    required this.currentTrip,
    required this.complianceWarning,
  });

  final String fleetNumber;
  final Fleet source;
  final String type;
  final String registration;
  final DateTime insuranceExpiry;
  final DateTime inspectionDueDate;
  final String currentStatus;
  final String currentWorkOrder;
  final String currentTrip;
  final String complianceWarning;

  factory _FleetListRow.fromFleet(Fleet fleet) {
    final index = fleet.id.codeUnits.fold<int>(0, (a, b) => a + b) % 9;
    final insuranceExpiry =
        DateTime.now().add(Duration(days: 15 + (index * 9)));
    final inspectionDueDate =
        DateTime.now().add(Duration(days: 5 + (index * 6)));
    final warning = insuranceExpiry.difference(DateTime.now()).inDays <= 30 ||
            inspectionDueDate.difference(DateTime.now()).inDays <= 15
        ? 'Expiring Soon'
        : 'None';

    return _FleetListRow(
      source: fleet,
      fleetNumber: fleet.vehicleNumber,
      type: fleet.type,
      registration: 'REG-${fleet.vehicleNumber.replaceAll(' ', '')}',
      insuranceExpiry: insuranceExpiry,
      inspectionDueDate: inspectionDueDate,
      currentStatus: fleet.status.label,
      currentWorkOrder: 'WO-24${100 + index}',
      currentTrip:
          fleet.status == FleetStatus.active ? 'TRP-30${index + 1}' : '-',
      complianceWarning: warning,
    );
  }
}
