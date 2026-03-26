import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/oman_fleet_master.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class DriverManagementScreen extends ConsumerStatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  ConsumerState<DriverManagementScreen> createState() =>
      _DriverManagementScreenState();
}

class _DriverManagementScreenState
    extends ConsumerState<DriverManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _activeFilter = 'All';
  String _availabilityFilter = 'All';
  String _licenseFilter = 'All';
  String _vehicleClassFilter = 'All';
  String _complianceFilter = 'All';
  String _certFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Driver Master',
      currentRoute: RoutePaths.driverManagement,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = _filteredRows(data);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  hintText:
                                      'Search by code, name, license, location',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: () => _openDriverDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Driver'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _filter(
                              label: 'Status',
                              value: _activeFilter,
                              width: 130,
                              items: const ['All', 'Active', 'Inactive'],
                              onChanged: (v) =>
                                  setState(() => _activeFilter = v),
                            ),
                            _filter(
                              label: 'Availability',
                              value: _availabilityFilter,
                              width: 170,
                              items: const [
                                'All',
                                'Available',
                                'Assigned',
                                'On Leave',
                                'Resting / Off Duty',
                                'Suspended',
                                'Inactive',
                              ],
                              onChanged: (v) =>
                                  setState(() => _availabilityFilter = v),
                            ),
                            _filter(
                              label: 'License',
                              value: _licenseFilter,
                              width: 150,
                              items: const ['All', 'Valid', 'Expired'],
                              onChanged: (v) =>
                                  setState(() => _licenseFilter = v),
                            ),
                            _filter(
                              label: 'Vehicle Class',
                              value: _vehicleClassFilter,
                              width: 150,
                              items: const ['All', 'Light', 'Heavy'],
                              onChanged: (v) =>
                                  setState(() => _vehicleClassFilter = v),
                            ),
                            _filter(
                              label: 'Compliance',
                              value: _complianceFilter,
                              width: 160,
                              items: const ['All', 'Ready', 'Not Ready'],
                              onChanged: (v) =>
                                  setState(() => _complianceFilter = v),
                            ),
                            _filter(
                              label: 'Certifications',
                              value: _certFilter,
                              width: 160,
                              items: const ['All', 'Available', 'Missing'],
                              onChanged: (v) => setState(() => _certFilter = v),
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
                        ? const Center(child: Text('No drivers found'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Driver Code')),
                                DataColumn(label: Text('Driver Name')),
                                DataColumn(label: Text('License Number')),
                                DataColumn(label: Text('License Class')),
                                DataColumn(label: Text('Availability')),
                                DataColumn(label: Text('Compliance')),
                                DataColumn(label: Text('Assignment')),
                                DataColumn(label: Text('Expiry Warning')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: [
                                for (final row in rows)
                                  DataRow(cells: [
                                    DataCell(Text(row.driver.driverId)),
                                    DataCell(Text(row.driver.name)),
                                    DataCell(Text(row.driver.licenseNo)),
                                    DataCell(Text(row.driver.licenseType)),
                                    DataCell(
                                        _availabilityChip(row.driver.status)),
                                    DataCell(
                                      Text(
                                        row.driver.complianceReady
                                            ? 'Ready'
                                            : 'Not Ready',
                                        style: TextStyle(
                                          color: row.driver.complianceReady
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFFB91C1C),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        row.driver.assignmentEligible
                                            ? 'Assignable'
                                            : 'Blocked',
                                        style: TextStyle(
                                          color: row.driver.assignmentEligible
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFFB91C1C),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(row.expiryWarning)),
                                    DataCell(
                                      Wrap(
                                        spacing: 2,
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit Driver',
                                            onPressed: () => _openDriverDialog(
                                              context,
                                              existing: row.driver,
                                            ),
                                            icon:
                                                const Icon(Icons.edit_outlined),
                                          ),
                                          IconButton(
                                            tooltip: 'View Details',
                                            onPressed: () => context.push(
                                              RoutePaths.driverDetailById(
                                                  row.driver.driverId),
                                            ),
                                            icon: const Icon(
                                                Icons.open_in_new_rounded),
                                          ),
                                          IconButton(
                                            tooltip: 'Mark Unavailable',
                                            onPressed: () {
                                              final msg = ref
                                                  .read(
                                                      logisticsViewModelProvider
                                                          .notifier)
                                                  .markDriverUnavailable(
                                                      row.driver.driverId);
                                              _toast(msg);
                                            },
                                            icon:
                                                const Icon(Icons.pause_circle),
                                          ),
                                          IconButton(
                                            tooltip: 'Suspend Driver',
                                            onPressed: () {
                                              final msg = ref
                                                  .read(
                                                      logisticsViewModelProvider
                                                          .notifier)
                                                  .suspendDriver(
                                                    row.driver.driverId,
                                                    reason:
                                                        'Temporary operational suspension',
                                                  );
                                              _toast(msg);
                                            },
                                            icon: const Icon(Icons.block),
                                          ),
                                          IconButton(
                                            tooltip: 'Deactivate',
                                            onPressed: () {
                                              final msg = ref
                                                  .read(
                                                      logisticsViewModelProvider
                                                          .notifier)
                                                  .deactivateDriver(
                                                    row.driver.driverId,
                                                    reason: 'Deactivated',
                                                  );
                                              _toast(msg);
                                            },
                                            icon: const Icon(Icons.person_off),
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
          );
        },
      ),
    );
  }

  Widget _filter({
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

  Widget _availabilityChip(String status) {
    final color = switch (status) {
      'Available' => const Color(0xFF15803D),
      'Assigned' => const Color(0xFF1D4ED8),
      'On Leave' => const Color(0xFFF59E0B),
      'Suspended' => const Color(0xFFB91C1C),
      'Inactive' => const Color(0xFF6B7280),
      _ => const Color(0xFFD97706),
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

  List<_DriverRow> _filteredRows(LogisticsUiState data) {
    final query = _searchController.text.trim().toLowerCase();
    return data.drivers
        .map((driver) => _DriverRow(
              driver: driver,
              expiryWarning: _expiryWarning(driver.expiryDate),
            ))
        .where((row) {
      final driver = row.driver;
      if (_activeFilter == 'Active' && !driver.active) {
        return false;
      }
      if (_activeFilter == 'Inactive' && driver.active) {
        return false;
      }
      if (_availabilityFilter != 'All' &&
          driver.status != _availabilityFilter) {
        return false;
      }
      final licenseValid = _licenseStatus(driver.expiryDate) == 'Valid';
      if (_licenseFilter == 'Valid' && !licenseValid) {
        return false;
      }
      if (_licenseFilter == 'Expired' && licenseValid) {
        return false;
      }
      if (_vehicleClassFilter == 'Light' && driver.heavyVehicleAllowed) {
        return false;
      }
      if (_vehicleClassFilter == 'Heavy' && !driver.heavyVehicleAllowed) {
        return false;
      }
      if (_complianceFilter == 'Ready' && !driver.complianceReady) {
        return false;
      }
      if (_complianceFilter == 'Not Ready' && driver.complianceReady) {
        return false;
      }
      if (_certFilter == 'Available' && driver.certifications.isEmpty) {
        return false;
      }
      if (_certFilter == 'Missing' && driver.certifications.isNotEmpty) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final merged =
          '${driver.driverId} ${driver.name} ${driver.licenseNo} ${driver.baseLocation}'
              .toLowerCase();
      return merged.contains(query);
    }).toList();
  }

  String _licenseStatus(String expiryDate) {
    final expiry = DateTime.tryParse(expiryDate.trim());
    if (expiry == null) {
      return 'Expired';
    }
    return expiry.isBefore(DateTime.now()) ? 'Expired' : 'Valid';
  }

  String _expiryWarning(String expiryDate) {
    final expiry = DateTime.tryParse(expiryDate.trim());
    if (expiry == null) {
      return 'Missing';
    }
    final days = expiry.difference(DateTime.now()).inDays;
    if (days < 0) {
      return 'Expired';
    }
    if (days <= 30) {
      return 'Expiring Soon';
    }
    return 'OK';
  }

  Future<void> _openDriverDialog(
    BuildContext context, {
    DriverData? existing,
  }) async {
    final isEdit = existing != null;
    final codeCtrl = TextEditingController(text: existing?.driverId ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final employeeCtrl =
        TextEditingController(text: existing?.employeeRef ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final nationalityCtrl =
        TextEditingController(text: existing?.nationality ?? 'Omani');
    final licenseCtrl = TextEditingController(text: existing?.licenseNo ?? '');
    final licenseTypeCtrl =
        TextEditingController(text: existing?.licenseType ?? 'Light Vehicle');
    final licenseIssueCtrl =
        TextEditingController(text: existing?.licenseIssueDate ?? '');
    final expiryCtrl = TextEditingController(text: existing?.expiryDate ?? '');
    final endorsementCtrl =
        TextEditingController(text: existing?.specialEndorsementNotes ?? '');
    final certCtrl =
        TextEditingController(text: existing?.certifications.join(', ') ?? '');
    final allowedVehicleCtrl = TextEditingController(
      text: existing?.allowedVehicleTypes.join(', ') ?? '',
    );
    final routeRestrictionCtrl =
        TextEditingController(text: existing?.routeRestrictions ?? '');
    final skillsCtrl =
        TextEditingController(text: existing?.specialSkillsNotes ?? '');
    final complianceNotesCtrl =
        TextEditingController(text: existing?.complianceNotes ?? '');
    final currentWorkOrderCtrl =
        TextEditingController(text: existing?.currentWorkOrder ?? '');
    final medicalCtrl =
        TextEditingController(text: existing?.medicalFitnessNote ?? '');
    final disciplinaryCtrl =
        TextEditingController(text: existing?.disciplinaryNote ?? '');
    final temporaryCtrl =
        TextEditingController(text: existing?.temporaryRestrictionNote ?? '');
    final blockReasonCtrl =
        TextEditingController(text: existing?.blockReason ?? '');
    final suspensionReasonCtrl =
        TextEditingController(text: existing?.suspensionReason ?? '');
    final preferredRegionCtrl =
        TextEditingController(text: existing?.preferredRegion ?? '');
    final preferredRouteTypeCtrl =
        TextEditingController(text: existing?.preferredRouteType ?? '');
    final preferredVehicleTypeCtrl =
        TextEditingController(text: existing?.preferredVehicleType ?? '');
    final preferredCargoTypeCtrl =
        TextEditingController(text: existing?.preferredCargoType ?? '');
    final specialAssignmentCtrl =
        TextEditingController(text: existing?.specialAssignmentNotes ?? '');

    var baseLocation =
        existing?.baseLocation ?? OmanFleetMaster.omanLocations.first;
    var active = existing?.active ?? true;
    var availability = existing?.status ?? 'Available';
    var heavyAllowed = existing?.heavyVehicleAllowed ?? false;
    var longHaulAllowed = existing?.longHaulAllowed ?? true;
    var nightAllowed = existing?.nightDrivingAllowed ?? true;
    var hazardousAllowed = existing?.hazardousCargoAllowed ?? false;
    var oilfieldAllowed = existing?.oilfieldAllowed ?? false;
    var onLeave = existing?.onLeave ?? false;
    var suspended = existing?.suspended ?? false;
    var dispatchBlocked = existing?.dispatchBlocked ?? false;
    var assignmentAllowed = existing?.assignmentAllowed ?? true;
    var dispatchAllowed = existing?.dispatchAllowed ?? true;
    var safetyIncident = existing?.safetyIncidentFlag ?? false;
    var incidentCount = existing?.incidentCount ?? 0;
    var pdoStatus = existing?.pdoPassportStatus ?? 'Not Required';
    var defensiveStatus = existing?.defensiveDrivingStatus ?? 'Not Required';
    var h2sStatus = existing?.h2sStatus ?? 'Not Required';
    var ftwStatus = existing?.ftwStatus ?? 'Not Required';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Driver' : 'Create Driver'),
              content: SizedBox(
                width: 760,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _sectionTitle('Driver Identity'),
                      TextField(
                        controller: codeCtrl,
                        enabled: !isEdit,
                        decoration:
                            const InputDecoration(labelText: 'Driver Code'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Full Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: employeeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Employee ID / Ref'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Mobile Number'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nationalityCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Nationality'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: baseLocation,
                        decoration:
                            const InputDecoration(labelText: 'Base Location'),
                        items: [
                          for (final location in OmanFleetMaster.omanLocations)
                            DropdownMenuItem(
                                value: location, child: Text(location)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setInnerState(() => baseLocation = value);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('License Information'),
                      TextField(
                        controller: licenseCtrl,
                        decoration:
                            const InputDecoration(labelText: 'License Number'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: licenseTypeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'License Type / Class'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: licenseIssueCtrl,
                        decoration: const InputDecoration(
                            labelText: 'License Issue Date (YYYY-MM-DD)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: expiryCtrl,
                        decoration: const InputDecoration(
                            labelText: 'License Expiry Date (YYYY-MM-DD)'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Heavy Vehicle Allowed'),
                        value: heavyAllowed,
                        onChanged: (value) =>
                            setInnerState(() => heavyAllowed = value),
                      ),
                      TextField(
                        controller: endorsementCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Special Endorsement Notes'),
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('Operational Qualification'),
                      TextField(
                        controller: allowedVehicleCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'Allowed Vehicle Types (comma separated)'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Long Haul Allowed'),
                        value: longHaulAllowed,
                        onChanged: (value) =>
                            setInnerState(() => longHaulAllowed = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Night Driving Allowed'),
                        value: nightAllowed,
                        onChanged: (value) =>
                            setInnerState(() => nightAllowed = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hazardous Cargo Allowed'),
                        value: hazardousAllowed,
                        onChanged: (value) =>
                            setInnerState(() => hazardousAllowed = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Oilfield / Special Site Allowed'),
                        value: oilfieldAllowed,
                        onChanged: (value) =>
                            setInnerState(() => oilfieldAllowed = value),
                      ),
                      TextField(
                        controller: routeRestrictionCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Route Restrictions'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: skillsCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Special Skills / Notes'),
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('Compliance Summary'),
                      Row(
                        children: [
                          Expanded(
                            child: _statusDrop(
                              label: 'PDO Passport',
                              value: pdoStatus,
                              onChanged: (v) =>
                                  setInnerState(() => pdoStatus = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _statusDrop(
                              label: 'Defensive Driving',
                              value: defensiveStatus,
                              onChanged: (v) =>
                                  setInnerState(() => defensiveStatus = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _statusDrop(
                              label: 'H2S / Safety Training',
                              value: h2sStatus,
                              onChanged: (v) =>
                                  setInnerState(() => h2sStatus = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _statusDrop(
                              label: 'FTW / Client Training',
                              value: ftwStatus,
                              onChanged: (v) =>
                                  setInnerState(() => ftwStatus = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: certCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Certifications (comma separated)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: complianceNotesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Compliance Notes'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('Availability / Control'),
                      DropdownButtonFormField<String>(
                        value: availability,
                        decoration: const InputDecoration(
                            labelText: 'Availability Status'),
                        items: const [
                          'Available',
                          'Assigned',
                          'On Leave',
                          'Resting / Off Duty',
                          'Suspended',
                          'Inactive',
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setInnerState(() => availability = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: currentWorkOrderCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Current Work Order'),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('On Leave'),
                        value: onLeave,
                        onChanged: (value) =>
                            setInnerState(() => onLeave = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Suspended'),
                        value: suspended,
                        onChanged: (value) =>
                            setInnerState(() => suspended = value),
                      ),
                      TextField(
                        controller: suspensionReasonCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Suspension Reason'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dispatch Blocked'),
                        value: dispatchBlocked,
                        onChanged: (value) =>
                            setInnerState(() => dispatchBlocked = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Assignment Allowed'),
                        value: assignmentAllowed,
                        onChanged: (value) =>
                            setInnerState(() => assignmentAllowed = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dispatch Allowed'),
                        value: dispatchAllowed,
                        onChanged: (value) =>
                            setInnerState(() => dispatchAllowed = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: active,
                        onChanged: (value) =>
                            setInnerState(() => active = value),
                      ),
                      TextField(
                        controller: blockReasonCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Block Reason'),
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('Health / Safety / Discipline'),
                      TextField(
                        controller: medicalCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Medical Fitness Note'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Safety Incident Flag'),
                        value: safetyIncident,
                        onChanged: (value) =>
                            setInnerState(() => safetyIncident = value),
                      ),
                      Row(
                        children: [
                          const Text('Incident Count'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Slider(
                              value: incidentCount.toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: incidentCount.toString(),
                              onChanged: (value) => setInnerState(
                                  () => incidentCount = value.round()),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: disciplinaryCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Disciplinary Note'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: temporaryCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Temporary Restriction Note'),
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('Preferences / Suitability'),
                      TextField(
                        controller: preferredRegionCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Preferred Region'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: preferredRouteTypeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Preferred Route Type'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: preferredVehicleTypeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Preferred Vehicle Type'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: preferredCargoTypeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Preferred Cargo Type'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: specialAssignmentCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Special Assignment Notes'),
                        maxLines: 2,
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
                    final vm = ref.read(logisticsViewModelProvider.notifier);
                    final message = isEdit
                        ? vm.updateDriver(
                            driverCode: existing.driverId,
                            name: nameCtrl.text.trim(),
                            employeeRef: employeeCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            licenseNo: licenseCtrl.text.trim(),
                            licenseType: licenseTypeCtrl.text.trim(),
                            licenseIssueDate: licenseIssueCtrl.text.trim(),
                            licenseExpiry: expiryCtrl.text.trim(),
                            availability: availability,
                            nationality: nationalityCtrl.text.trim(),
                            baseLocation: baseLocation,
                            heavyVehicleAllowed: heavyAllowed,
                            specialEndorsementNotes:
                                endorsementCtrl.text.trim(),
                            allowedVehicleTypes: _csv(allowedVehicleCtrl.text),
                            longHaulAllowed: longHaulAllowed,
                            nightDrivingAllowed: nightAllowed,
                            hazardousCargoAllowed: hazardousAllowed,
                            oilfieldAllowed: oilfieldAllowed,
                            routeRestrictions: routeRestrictionCtrl.text.trim(),
                            specialSkillsNotes: skillsCtrl.text.trim(),
                            pdoPassportStatus: pdoStatus,
                            defensiveDrivingStatus: defensiveStatus,
                            h2sStatus: h2sStatus,
                            ftwStatus: ftwStatus,
                            complianceNotes: complianceNotesCtrl.text.trim(),
                            currentAssignmentStatus: availability,
                            currentWorkOrder: currentWorkOrderCtrl.text.trim(),
                            currentLocation: baseLocation,
                            onLeave: onLeave,
                            suspended: suspended,
                            suspensionReason: suspensionReasonCtrl.text.trim(),
                            assignmentAllowed: assignmentAllowed,
                            dispatchAllowed: dispatchAllowed,
                            dispatchBlocked: dispatchBlocked,
                            blockReason: blockReasonCtrl.text.trim(),
                            medicalFitnessNote: medicalCtrl.text.trim(),
                            safetyIncidentFlag: safetyIncident,
                            incidentCount: incidentCount,
                            disciplinaryNote: disciplinaryCtrl.text.trim(),
                            temporaryRestrictionNote: temporaryCtrl.text.trim(),
                            preferredRegion: preferredRegionCtrl.text.trim(),
                            preferredRouteType:
                                preferredRouteTypeCtrl.text.trim(),
                            preferredVehicleType:
                                preferredVehicleTypeCtrl.text.trim(),
                            preferredCargoType:
                                preferredCargoTypeCtrl.text.trim(),
                            specialAssignmentNotes:
                                specialAssignmentCtrl.text.trim(),
                            active: active,
                            certifications: certCtrl.text.trim(),
                          )
                        : vm.addDriver(
                            driverCode: codeCtrl.text.trim(),
                            name: nameCtrl.text.trim(),
                            employeeRef: employeeCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            licenseNo: licenseCtrl.text.trim(),
                            licenseType: licenseTypeCtrl.text.trim(),
                            licenseIssueDate: licenseIssueCtrl.text.trim(),
                            licenseExpiry: expiryCtrl.text.trim(),
                            availability: availability,
                            nationality: nationalityCtrl.text.trim(),
                            baseLocation: baseLocation,
                            heavyVehicleAllowed: heavyAllowed,
                            specialEndorsementNotes:
                                endorsementCtrl.text.trim(),
                            allowedVehicleTypes: _csv(allowedVehicleCtrl.text),
                            longHaulAllowed: longHaulAllowed,
                            nightDrivingAllowed: nightAllowed,
                            hazardousCargoAllowed: hazardousAllowed,
                            oilfieldAllowed: oilfieldAllowed,
                            routeRestrictions: routeRestrictionCtrl.text.trim(),
                            specialSkillsNotes: skillsCtrl.text.trim(),
                            pdoPassportStatus: pdoStatus,
                            defensiveDrivingStatus: defensiveStatus,
                            h2sStatus: h2sStatus,
                            ftwStatus: ftwStatus,
                            complianceNotes: complianceNotesCtrl.text.trim(),
                            currentAssignmentStatus: availability,
                            currentWorkOrder: currentWorkOrderCtrl.text.trim(),
                            currentLocation: baseLocation,
                            onLeave: onLeave,
                            suspended: suspended,
                            suspensionReason: suspensionReasonCtrl.text.trim(),
                            assignmentAllowed: assignmentAllowed,
                            dispatchAllowed: dispatchAllowed,
                            dispatchBlocked: dispatchBlocked,
                            blockReason: blockReasonCtrl.text.trim(),
                            medicalFitnessNote: medicalCtrl.text.trim(),
                            safetyIncidentFlag: safetyIncident,
                            incidentCount: incidentCount,
                            disciplinaryNote: disciplinaryCtrl.text.trim(),
                            temporaryRestrictionNote: temporaryCtrl.text.trim(),
                            preferredRegion: preferredRegionCtrl.text.trim(),
                            preferredRouteType:
                                preferredRouteTypeCtrl.text.trim(),
                            preferredVehicleType:
                                preferredVehicleTypeCtrl.text.trim(),
                            preferredCargoType:
                                preferredCargoTypeCtrl.text.trim(),
                            specialAssignmentNotes:
                                specialAssignmentCtrl.text.trim(),
                            active: active,
                            certifications: certCtrl.text.trim(),
                          );
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

    codeCtrl.dispose();
    nameCtrl.dispose();
    employeeCtrl.dispose();
    phoneCtrl.dispose();
    nationalityCtrl.dispose();
    licenseCtrl.dispose();
    licenseTypeCtrl.dispose();
    licenseIssueCtrl.dispose();
    expiryCtrl.dispose();
    endorsementCtrl.dispose();
    certCtrl.dispose();
    allowedVehicleCtrl.dispose();
    routeRestrictionCtrl.dispose();
    skillsCtrl.dispose();
    complianceNotesCtrl.dispose();
    currentWorkOrderCtrl.dispose();
    medicalCtrl.dispose();
    disciplinaryCtrl.dispose();
    temporaryCtrl.dispose();
    blockReasonCtrl.dispose();
    suspensionReasonCtrl.dispose();
    preferredRegionCtrl.dispose();
    preferredRouteTypeCtrl.dispose();
    preferredVehicleTypeCtrl.dispose();
    preferredCargoTypeCtrl.dispose();
    specialAssignmentCtrl.dispose();
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }

  Widget _statusDrop({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: const ['Valid', 'Expired', 'Not Required']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }

  List<String> _csv(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DriverRow {
  const _DriverRow({required this.driver, required this.expiryWarning});

  final DriverData driver;
  final String expiryWarning;
}
