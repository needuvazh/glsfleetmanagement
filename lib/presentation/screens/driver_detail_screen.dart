import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class DriverDetailScreen extends ConsumerWidget {
  const DriverDetailScreen({
    super.key,
    required this.driverId,
    this.initialTab,
  });

  final String driverId;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(logisticsViewModelProvider).valueOrNull;
    if (data == null) {
      return const OpsShell(
        title: 'Driver Detail',
        currentRoute: RoutePaths.driverManagement,
        child: Center(child: Text('Driver data not loaded.')),
      );
    }

    DriverData? driver;
    for (final item in data.drivers) {
      if (item.driverId == driverId) {
        driver = item;
        break;
      }
    }
    if (driver == null) {
      return const OpsShell(
        title: 'Driver Detail',
        currentRoute: RoutePaths.driverManagement,
        child: Center(child: Text('Driver not found.')),
      );
    }
    final d = driver;

    final recentTrips = data.workOrders
        .where((item) => item.woId == d.currentWorkOrder)
        .map((item) => '${item.woId} • ${item.route}')
        .toList();

    return OpsShell(
      title: 'Driver Detail',
      currentRoute: RoutePaths.driverManagement,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section('Summary', [
            _pair('Driver Code', d.driverId),
            _pair('Name', d.name),
            _pair('License Number', d.licenseNo),
            _pair('License Class', d.licenseType),
            _pair('Status', d.status),
            _pair('Availability', d.status),
          ]),
          _section('License View', [
            _pair('Issue Date',
                d.licenseIssueDate.isEmpty ? '-' : d.licenseIssueDate),
            _pair('Expiry Date', d.expiryDate),
            _pair(
                'Heavy Vehicle Allowed', d.heavyVehicleAllowed ? 'Yes' : 'No'),
            _pair(
                'Endorsement Notes',
                d.specialEndorsementNotes.isEmpty
                    ? '-'
                    : d.specialEndorsementNotes),
          ]),
          _section('Operational Qualification', [
            _pair(
                'Allowed Vehicle Types',
                d.allowedVehicleTypes.isEmpty
                    ? '-'
                    : d.allowedVehicleTypes.join(', ')),
            _pair(
                'Night Driving Allowed', d.nightDrivingAllowed ? 'Yes' : 'No'),
            _pair('Hazardous Cargo Allowed',
                d.hazardousCargoAllowed ? 'Yes' : 'No'),
            _pair('Oilfield Fit', d.oilfieldAllowed ? 'Yes' : 'No'),
            _pair('Route Restrictions',
                d.routeRestrictions.isEmpty ? '-' : d.routeRestrictions),
          ]),
          _section('Compliance Summary', [
            _pair('License Validity', d.licenseValid ? 'Valid' : 'Expired'),
            _pair('PDO Passport', d.pdoPassportStatus),
            _pair('Defensive Driving', d.defensiveDrivingStatus),
            _pair('H2S Safety', d.h2sStatus),
            _pair('FTW / Client Training', d.ftwStatus),
            _pair(
                'Readiness', d.complianceReady ? 'Ready' : 'Warning / Blocked'),
          ]),
          _section('Availability', [
            _pair('Current Assignment', d.currentAssignmentStatus),
            _pair('Current Work Order',
                d.currentWorkOrder.isEmpty ? '-' : d.currentWorkOrder),
            _pair('Current Location', d.currentLocation),
            _pair('On Leave', d.onLeave ? 'Yes' : 'No'),
            _pair('Suspended', d.suspended ? 'Yes' : 'No'),
            _pair('Block Reason', d.blockReason.isEmpty ? '-' : d.blockReason),
          ]),
          _section('Usage', [
            _pair('Recent Trips',
                recentTrips.isEmpty ? '-' : recentTrips.join(', ')),
            _pair(
                'Recent Assigned Fleet',
                data.assignedDriverId == d.driverId
                    ? (data.assignedVehicleNo ?? '-')
                    : '-'),
            _pair(
                'Inspection Involvement',
                data.preTripPassed && data.assignedDriverId == d.driverId
                    ? '1'
                    : '0'),
            _pair('Incident Count', d.incidentCount.toString()),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ...rows,
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
            width: 210,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
