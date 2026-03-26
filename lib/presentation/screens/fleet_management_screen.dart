import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/oman_fleet_master.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/access_control_viewmodel.dart';
import '../widgets/ops_shell.dart';

class FleetManagementScreen extends ConsumerStatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  ConsumerState<FleetManagementScreen> createState() =>
      _FleetManagementScreenState();
}

class _FleetManagementScreenState extends ConsumerState<FleetManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _typeFilter = 'All';
  String _statusFilter = 'All';
  String _assignmentFilter = 'All';
  String _complianceFilter = 'All';
  bool _inspectionDueOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessControlProvider);
    final rows = _filtered(state.transports);

    return OpsShell(
      title: 'Fleet Master',
      currentRoute: RoutePaths.fleetManagement,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search by fleet/type/registration',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: () => _openFleetDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Fleet'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _dropdown(
                          label: 'Vehicle Type',
                          value: _typeFilter,
                          width: 210,
                          items: ['All', ...OmanFleetMaster.fleetTypes],
                          onChanged: (value) =>
                              setState(() => _typeFilter = value),
                        ),
                        _dropdown(
                          label: 'Status',
                          value: _statusFilter,
                          width: 160,
                          items: [
                            'All',
                            ...OmanFleetMaster.availabilityStatuses
                          ],
                          onChanged: (value) =>
                              setState(() => _statusFilter = value),
                        ),
                        _dropdown(
                          label: 'Assignment',
                          value: _assignmentFilter,
                          width: 160,
                          items: const ['All', 'Assignable', 'Not Assignable'],
                          onChanged: (value) =>
                              setState(() => _assignmentFilter = value),
                        ),
                        _dropdown(
                          label: 'Compliance',
                          value: _complianceFilter,
                          width: 180,
                          items: const ['All', 'Ready', 'Not Ready'],
                          onChanged: (value) =>
                              setState(() => _complianceFilter = value),
                        ),
                        SizedBox(
                          width: 220,
                          child: CheckboxListTile(
                            value: _inspectionDueOnly,
                            onChanged: (value) => setState(
                                () => _inspectionDueOnly = value ?? false),
                            title: const Text('Inspection Due (30d)'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
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
                            DataColumn(label: Text('Vehicle Type')),
                            DataColumn(label: Text('Registration Number')),
                            DataColumn(label: Text('Capacity')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Compliance Status')),
                            DataColumn(label: Text('Assignment Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: [
                            for (final item in rows)
                              DataRow(cells: [
                                DataCell(Text(item.vehicleNumber)),
                                DataCell(Text(item.vehicleType)),
                                DataCell(Text(item.registrationNumber)),
                                DataCell(Text(
                                    '${item.capacity.toStringAsFixed(0)} ${item.capacityUnit}')),
                                DataCell(_statusChip(item.availabilityStatus)),
                                DataCell(Text(
                                  item.complianceReady ? 'Ready' : 'Not Ready',
                                  style: TextStyle(
                                    color: item.complianceReady
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                                DataCell(Text(
                                  item.assignmentEligible
                                      ? 'Assignable'
                                      : 'Not Assignable',
                                  style: TextStyle(
                                    color: item.assignmentEligible
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                                DataCell(
                                  Wrap(
                                    spacing: 2,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit Fleet',
                                        onPressed: () => _openFleetDialog(
                                          context,
                                          existing: item,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'View Details',
                                        onPressed: () => context.push(
                                          RoutePaths.fleetDetailById(
                                              item.vehicleNumber),
                                        ),
                                        icon: const Icon(
                                            Icons.open_in_new_rounded),
                                      ),
                                      IconButton(
                                        tooltip: 'Mark Maintenance',
                                        onPressed: () {
                                          final msg = ref
                                              .read(accessControlProvider
                                                  .notifier)
                                              .markMaintenance(
                                                  item.vehicleNumber);
                                          _toast(msg);
                                        },
                                        icon: const Icon(Icons.build_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Deactivate',
                                        onPressed: () {
                                          final msg = ref
                                              .read(accessControlProvider
                                                  .notifier)
                                              .deactivateTransport(
                                                item.vehicleNumber,
                                                reason:
                                                    'Deactivated from Fleet Master',
                                              );
                                          _toast(msg);
                                        },
                                        icon: const Icon(Icons.block_outlined),
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
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required double width,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (next) {
          if (next != null) {
            onChanged(next);
          }
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'Available' => const Color(0xFF15803D),
      'Assigned' => const Color(0xFF1D4ED8),
      'Maintenance' => const Color(0xFFF59E0B),
      _ => const Color(0xFFB91C1C),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  List<TransportItem> _filtered(List<TransportItem> source) {
    final query = _searchController.text.trim().toLowerCase();
    return source.where((item) {
      if (_typeFilter != 'All' && item.vehicleType != _typeFilter) {
        return false;
      }
      if (_statusFilter != 'All' && item.availabilityStatus != _statusFilter) {
        return false;
      }
      if (_assignmentFilter == 'Assignable' && !item.assignmentEligible) {
        return false;
      }
      if (_assignmentFilter == 'Not Assignable' && item.assignmentEligible) {
        return false;
      }
      if (_complianceFilter == 'Ready' && !item.complianceReady) {
        return false;
      }
      if (_complianceFilter == 'Not Ready' && item.complianceReady) {
        return false;
      }
      if (_inspectionDueOnly && !_isInspectionDue(item.inspectionExpiry)) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }
      final text =
          '${item.vehicleNumber} ${item.vehicleType} ${item.registrationNumber}'
              .toLowerCase();
      return text.contains(query);
    }).toList();
  }

  bool _isInspectionDue(String dateValue) {
    final parsed = DateTime.tryParse(dateValue.trim());
    if (parsed == null) {
      return false;
    }
    final days = parsed.difference(DateTime.now()).inDays;
    return days <= 30;
  }

  Future<void> _openFleetDialog(
    BuildContext context, {
    TransportItem? existing,
  }) async {
    final isEdit = existing != null;
    final fleetNoController =
        TextEditingController(text: existing?.vehicleNumber ?? '');
    final registrationController =
        TextEditingController(text: existing?.registrationNumber ?? '');
    final capacityController = TextEditingController(
      text: existing == null ? '10' : existing.capacity.toStringAsFixed(0),
    );
    final registrationExpiry =
        TextEditingController(text: existing?.registrationExpiry ?? '');
    final insuranceExpiry =
        TextEditingController(text: existing?.insuranceExpiry ?? '');
    final permitExpiry =
        TextEditingController(text: existing?.permitExpiry ?? '');
    final inspectionExpiry =
        TextEditingController(text: existing?.inspectionExpiry ?? '');
    final blockReasonController =
        TextEditingController(text: existing?.blockReason ?? '');
    final suspensionReasonController =
        TextEditingController(text: existing?.suspensionReason ?? '');

    var fleetType = existing?.vehicleType ?? OmanFleetMaster.fleetTypes.first;
    var ownership =
        existing?.ownershipType ?? OmanFleetMaster.ownershipTypes.first;
    var baseLocation =
        existing?.baseLocation ?? OmanFleetMaster.omanLocations.first;
    var activeStatus = existing?.status ?? 'Active';
    var availability = existing?.availabilityStatus ??
        OmanFleetMaster.availabilityStatuses.first;
    var assignmentAllowed = existing?.assignmentAllowed ?? true;
    var dispatchBlocked = existing?.dispatchBlocked ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Fleet' : 'Create Fleet'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: fleetNoController,
                        enabled: !isEdit,
                        decoration:
                            const InputDecoration(labelText: 'Fleet Number'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: fleetType,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Type'),
                        items: [
                          for (final item in OmanFleetMaster.fleetTypes)
                            DropdownMenuItem(value: item, child: Text(item)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setInnerState(() => fleetType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: registrationController,
                        decoration: const InputDecoration(
                            labelText: 'Registration Number'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: ownership,
                              decoration: const InputDecoration(
                                  labelText: 'Ownership Type'),
                              items: [
                                for (final item
                                    in OmanFleetMaster.ownershipTypes)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setInnerState(() => ownership = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: baseLocation,
                              decoration: const InputDecoration(
                                  labelText: 'Base Location'),
                              items: [
                                for (final item
                                    in OmanFleetMaster.omanLocations)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setInnerState(() => baseLocation = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Load Capacity'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: activeStatus,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: [
                                for (final item
                                    in OmanFleetMaster.activeStatuses)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setInnerState(() => activeStatus = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: availability,
                              decoration: const InputDecoration(
                                  labelText: 'Availability'),
                              items: [
                                for (final item
                                    in OmanFleetMaster.availabilityStatuses)
                                  DropdownMenuItem(
                                      value: item, child: Text(item)),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setInnerState(() => availability = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Assignment Allowed'),
                        value: assignmentAllowed,
                        onChanged: (value) =>
                            setInnerState(() => assignmentAllowed = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dispatch Blocked'),
                        value: dispatchBlocked,
                        onChanged: (value) =>
                            setInnerState(() => dispatchBlocked = value),
                      ),
                      TextField(
                        controller: blockReasonController,
                        decoration:
                            const InputDecoration(labelText: 'Block Reason'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: suspensionReasonController,
                        decoration: const InputDecoration(
                            labelText: 'Suspension Reason'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: registrationExpiry,
                        decoration: const InputDecoration(
                            labelText: 'Registration Validity (YYYY-MM-DD)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: insuranceExpiry,
                        decoration: const InputDecoration(
                            labelText: 'Insurance Validity (YYYY-MM-DD)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: permitExpiry,
                        decoration: const InputDecoration(
                            labelText: 'Permit Validity (YYYY-MM-DD)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: inspectionExpiry,
                        decoration: const InputDecoration(
                            labelText: 'Inspection Validity (YYYY-MM-DD)'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final notifier = ref.read(accessControlProvider.notifier);
                    final parsedCapacity =
                        double.tryParse(capacityController.text.trim()) ?? 0;

                    final message = isEdit
                        ? notifier.updateTransportBasics(
                            vehicleNumber: existing.vehicleNumber,
                            vehicleType: fleetType,
                            registrationNumber:
                                registrationController.text.trim(),
                            baseLocation: baseLocation,
                            ownershipType: ownership,
                            availabilityStatus: availability,
                            assignmentAllowed: assignmentAllowed,
                            dispatchBlocked: dispatchBlocked,
                            blockReason: blockReasonController.text.trim(),
                            status: activeStatus,
                            suspensionReason:
                                suspensionReasonController.text.trim(),
                            registrationExpiry: registrationExpiry.text.trim(),
                            insuranceExpiry: insuranceExpiry.text.trim(),
                            permitExpiry: permitExpiry.text.trim(),
                            inspectionExpiry: inspectionExpiry.text.trim(),
                          )
                        : notifier.addTransport(
                            vehicleNumber: fleetNoController.text.trim(),
                            vehicleName: fleetNoController.text.trim(),
                            vehicleClass:
                                OmanFleetMaster.vehicleClassForType(fleetType),
                            vehicleCategory:
                                OmanFleetMaster.vehicleClassForType(
                                            fleetType) ==
                                        'Light'
                                    ? 'Light Vehicle'
                                    : 'Heavy Vehicle',
                            vehicleType: fleetType,
                            registrationNumber:
                                registrationController.text.trim(),
                            ownershipType: ownership,
                            baseLocation: baseLocation,
                            vendorName:
                                ownership == 'Contracted' ? 'Contracted' : '',
                            capacity: parsedCapacity,
                            capacityUnit: 'Tons',
                            fuelType: 'Diesel',
                            manufacturer: 'NA',
                            model: 'NA',
                            yearOfManufacture: DateTime.now().year,
                            status: activeStatus,
                            availabilityStatus: availability,
                            assignmentAllowed: assignmentAllowed,
                            dispatchBlocked: dispatchBlocked,
                            blockReason: blockReasonController.text.trim(),
                            currentLocation: baseLocation,
                            currentWorkOrder: '',
                            registrationExpiry: registrationExpiry.text.trim(),
                            insuranceExpiry: insuranceExpiry.text.trim(),
                            permitExpiry: permitExpiry.text.trim(),
                            inspectionExpiry: inspectionExpiry.text.trim(),
                            ivmsInstalled: true,
                            dfmsInstalled: true,
                            escortRequired: false,
                            lastServiceDate: DateTime.now()
                                .toIso8601String()
                                .split('T')
                                .first,
                            nextServiceDue: DateTime.now()
                                .add(const Duration(days: 90))
                                .toIso8601String()
                                .split('T')
                                .first,
                            maintenanceStatus: 'Good',
                            maintenanceNotes: '',
                            suspensionReason:
                                suspensionReasonController.text.trim(),
                            preferredRoutes: const [],
                            preferredCargoTypes: const [],
                            region: baseLocation,
                            nightDrivingAllowed: true,
                            specialRestrictions: '',
                            isPdoVehicleType: false,
                            documents: const [],
                          );

                    if (!mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _toast(message);
                  },
                  child: Text(isEdit ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    fleetNoController.dispose();
    registrationController.dispose();
    capacityController.dispose();
    registrationExpiry.dispose();
    insuranceExpiry.dispose();
    permitExpiry.dispose();
    inspectionExpiry.dispose();
    blockReasonController.dispose();
    suspensionReasonController.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
