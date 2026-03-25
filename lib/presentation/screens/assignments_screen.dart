import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  final TextEditingController _fleetSearchController = TextEditingController();
  final TextEditingController _driverSearchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _fleetStatusFilter = 'All';
  String _driverStatusFilter = 'All';

  String? _selectedOrderId;
  String? _selectedVehicleNo;
  String? _selectedTrailerId;
  String? _selectedDriverId;

  bool _validated = false;
  bool _assignmentAllowed = false;

  static const _trailers = [
    'TRL-88 (Flatbed)',
    'TRL-44 (Lowbed)',
    'TRL-11 (Tanker)',
    'TRL-52 (Container)',
  ];

  @override
  void dispose() {
    _fleetSearchController.dispose();
    _driverSearchController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Assignments',
      currentRoute: RoutePaths.assignments,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final selectedOrder = _selectedWorkOrder(data.workOrders);
          final selectedVehicle = _selectedVehicle(data.vehicles);
          final selectedDriver = _selectedDriver(data.drivers);

          final fleetRows = _filteredFleet(data.vehicles);
          final driverRows = _filteredDrivers(data.drivers);

          final checks = _buildValidationChecks(
            data: data,
            selectedVehicle: selectedVehicle,
            selectedDriver: selectedDriver,
          );

          final isDesktop = MediaQuery.of(context).size.width > 1200;

          return Column(
            children: [
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLeftPanel(data, selectedOrder)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMiddlePanel(
                              fleetRows,
                              selectedVehicle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildRightPanel(
                              driverRows,
                              selectedDriver,
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          _buildLeftPanel(data, selectedOrder),
                          _buildMiddlePanel(fleetRows, selectedVehicle),
                          _buildRightPanel(driverRows, selectedDriver),
                        ],
                      ),
              ),
              const SizedBox(height: 10),
              _buildValidationSection(checks),
              const SizedBox(height: 10),
              _buildActionsBar(
                onValidate: () {
                  final allowed = checks.values.every((v) => v);
                  setState(() {
                    _validated = true;
                    _assignmentAllowed = allowed;
                  });
                  _toast(allowed
                      ? 'Validation successful. Assignment allowed.'
                      : 'Validation failed. Assignment blocked.');
                },
                onAssign: () => _assignOrReassign(data),
                onSaveRemarks: () => _toast('Assignment remarks saved.'),
                onReassign: () => _assignOrReassign(data, forceReassign: true),
                canAssign: _validated &&
                    _assignmentAllowed &&
                    _selectedOrderId != null &&
                    _selectedVehicleNo != null &&
                    _selectedDriverId != null,
                hasExistingAssignment: _selectedOrderId == data.assignedOrderId,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftPanel(
      LogisticsUiState data, WorkOrderFlowItem? selectedOrder) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work Order Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedOrderId,
              decoration: const InputDecoration(labelText: 'Work Order'),
              items: [
                for (final item in data.workOrders)
                  DropdownMenuItem(
                    value: item.woId,
                    child: Text('${item.woId} (${item.customer})'),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedOrderId = value;
                  _validated = false;
                });
              },
            ),
            const SizedBox(height: 10),
            _pair('WO Number', selectedOrder?.woId ?? '-'),
            _pair('Customer', selectedOrder?.customer ?? '-'),
            _pair('Route', selectedOrder?.route ?? '-'),
            _pair('Cargo', selectedOrder?.cargo ?? '-'),
            _pair('Planned Date', _plannedDate(selectedOrder?.woId)),
            _pair('Inspection Need', 'Required'),
            _pair('Trip Readiness',
                data.canStartTrip ? 'Ready' : 'Pending checks'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Assignment Remarks',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiddlePanel(
      List<FleetVehicleData> rows, FleetVehicleData? selectedVehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fleet Selection',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fleetSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search truck / type',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: _fleetStatusFilter,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Available', child: Text('Available')),
                      DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fleetStatusFilter = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedVehicleNo,
              decoration: const InputDecoration(labelText: 'Available Trucks'),
              items: [
                for (final item in rows)
                  DropdownMenuItem(
                    value: item.vehicleNo,
                    child: Text(
                        '${item.vehicleNo} • ${item.type} • ${item.status}'),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVehicleNo = value;
                  _validated = false;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTrailerId,
              decoration: const InputDecoration(labelText: 'Trailer List'),
              items: [
                for (final trailer in _trailers)
                  DropdownMenuItem(value: trailer, child: Text(trailer)),
              ],
              onChanged: (value) => setState(() => _selectedTrailerId = value),
            ),
            const SizedBox(height: 12),
            Text('Fleet Details Preview',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _pair('Vehicle Number', selectedVehicle?.vehicleNo ?? '-'),
            _pair('Vehicle Type', selectedVehicle?.type ?? '-'),
            _pair('Capacity', selectedVehicle?.capacity ?? '-'),
            _pair('Fuel Type', selectedVehicle?.fuelType ?? '-'),
            _pair('IVMS Device', selectedVehicle?.ivmsDeviceId ?? '-'),
            _pair('Operational Status', selectedVehicle?.status ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(List<DriverData> rows, DriverData? selectedDriver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Selection + Validation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _driverSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search driver / id',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: _driverStatusFilter,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Available', child: Text('Available')),
                      DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _driverStatusFilter = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDriverId,
              decoration: const InputDecoration(labelText: 'Driver List'),
              items: [
                for (final item in rows)
                  DropdownMenuItem(
                    value: item.driverId,
                    child: Text('${item.name} • ${item.status}'),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDriverId = value;
                  _validated = false;
                });
              },
            ),
            const SizedBox(height: 12),
            _pair('Driver', selectedDriver?.name ?? '-'),
            _pair('License', selectedDriver?.licenseNo ?? '-'),
            _pair('License Expiry', selectedDriver?.expiryDate ?? '-'),
            _pair('Availability', selectedDriver?.status ?? '-'),
            _pair('Compliance Readiness',
                _licenseValid(selectedDriver) ? 'Ready' : 'Action required'),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSection(Map<String, bool> checks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validation Section',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: checks.entries
                  .map(
                    (entry) => _validationChip(entry.key, entry.value),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Text(
              _validated
                  ? (_assignmentAllowed
                      ? 'Assignment allowed'
                      : 'Assignment blocked')
                  : 'Run validation before assignment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsBar({
    required VoidCallback onValidate,
    required VoidCallback onAssign,
    required VoidCallback onSaveRemarks,
    required VoidCallback onReassign,
    required bool canAssign,
    required bool hasExistingAssignment,
  }) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onValidate,
          icon: const Icon(Icons.rule_folder_outlined),
          label: const Text('Validate'),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: canAssign ? onAssign : null,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Assign'),
        ),
        const SizedBox(width: 10),
        TextButton.icon(
          onPressed: onSaveRemarks,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Remarks'),
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: hasExistingAssignment ? onReassign : null,
          icon: const Icon(Icons.swap_horiz_outlined),
          label: const Text('Reassign'),
        ),
      ],
    );
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _validationChip(String label, bool pass) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: pass ? const Color(0xFFE9F9EF) : const Color(0xFFFFF1F1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pass ? Icons.check_circle_outline : Icons.block_outlined,
            size: 16,
            color: pass ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  List<FleetVehicleData> _filteredFleet(List<FleetVehicleData> source) {
    final query = _fleetSearchController.text.trim().toLowerCase();
    return source.where((item) {
      if (_fleetStatusFilter == 'Available' && !_isAvailable(item.status)) {
        return false;
      }
      if (_fleetStatusFilter == 'Busy' && _isAvailable(item.status)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final text =
          '${item.vehicleNo} ${item.type} ${item.status}'.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  List<DriverData> _filteredDrivers(List<DriverData> source) {
    final query = _driverSearchController.text.trim().toLowerCase();
    return source.where((item) {
      if (_driverStatusFilter == 'Available' && !_isAvailable(item.status)) {
        return false;
      }
      if (_driverStatusFilter == 'Busy' && _isAvailable(item.status)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final text = '${item.driverId} ${item.name} ${item.status}'.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  WorkOrderFlowItem? _selectedWorkOrder(List<WorkOrderFlowItem> orders) {
    for (final item in orders) {
      if (item.woId == _selectedOrderId) {
        return item;
      }
    }
    return null;
  }

  FleetVehicleData? _selectedVehicle(List<FleetVehicleData> vehicles) {
    for (final item in vehicles) {
      if (item.vehicleNo == _selectedVehicleNo) {
        return item;
      }
    }
    return null;
  }

  DriverData? _selectedDriver(List<DriverData> drivers) {
    for (final item in drivers) {
      if (item.driverId == _selectedDriverId) {
        return item;
      }
    }
    return null;
  }

  Map<String, bool> _buildValidationChecks({
    required LogisticsUiState data,
    required FleetVehicleData? selectedVehicle,
    required DriverData? selectedDriver,
  }) {
    final fleetAvailable =
        selectedVehicle != null && _isAvailable(selectedVehicle.status);
    final fleetInspectionValid = data.vehicleDocStatus == 'Valid' ||
        data.vehicleDocStatus == 'Expiring Soon';
    final driverAvailable =
        selectedDriver != null && _isAvailable(selectedDriver.status);
    final driverLicenseValid = _licenseValid(selectedDriver);
    final documentsComplete = (data.vehicleDocStatus == 'Valid' ||
            data.vehicleDocStatus == 'Expiring Soon') &&
        (data.driverDocStatus == 'Valid' ||
            data.driverDocStatus == 'Expiring Soon');
    final assignmentAllowed = fleetAvailable &&
        fleetInspectionValid &&
        driverAvailable &&
        driverLicenseValid &&
        documentsComplete;

    return {
      'Fleet Available': fleetAvailable,
      'Fleet Inspection Valid': fleetInspectionValid,
      'Driver Available': driverAvailable,
      'Driver License Valid': driverLicenseValid,
      'Documents Complete': documentsComplete,
      'Assignment Allowed': assignmentAllowed,
    };
  }

  bool _isAvailable(String status) {
    return status.toLowerCase().contains('available');
  }

  bool _licenseValid(DriverData? driver) {
    if (driver == null) {
      return false;
    }
    final parsed = DateTime.tryParse(driver.expiryDate);
    if (parsed == null) {
      return true;
    }
    return parsed.isAfter(DateTime.now());
  }

  String _plannedDate(String? orderId) {
    if (orderId == null) {
      return '-';
    }
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day/$month/${now.year}';
  }

  void _assignOrReassign(LogisticsUiState data, {bool forceReassign = false}) {
    if (_selectedOrderId == null ||
        _selectedVehicleNo == null ||
        _selectedDriverId == null) {
      _toast('Select work order, truck, and driver before assigning.');
      return;
    }

    final msg = ref.read(logisticsViewModelProvider.notifier).assignFleetDriver(
          orderId: _selectedOrderId!,
          vehicleNo: _selectedVehicleNo!,
          driverId: _selectedDriverId!,
        );
    _toast(forceReassign ? 'Reassignment done. $msg' : msg);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
