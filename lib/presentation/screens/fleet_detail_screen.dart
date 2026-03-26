import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/access_control_viewmodel.dart';
import '../widgets/ops_shell.dart';

class FleetDetailScreen extends ConsumerWidget {
  const FleetDetailScreen({
    super.key,
    required this.fleetId,
    this.initialTab,
  });

  final String fleetId;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accessControlProvider);
    TransportItem? fleet;
    for (final item in state.transports) {
      if (item.vehicleNumber == fleetId) {
        fleet = item;
        break;
      }
    }

    return OpsShell(
      title: 'Fleet Detail',
      currentRoute: RoutePaths.fleetManagement,
      child: fleet == null
          ? const Center(child: Text('Fleet not found.'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _section('Summary', [
                  _pair('Fleet Number', fleet.vehicleNumber),
                  _pair('Type', fleet.vehicleType),
                  _pair('Registration', fleet.registrationNumber),
                  _pair('Status', fleet.status),
                  _pair('Availability', fleet.availabilityStatus),
                ]),
                _section('Capability', [
                  _pair('Capacity',
                      '${fleet.capacity.toStringAsFixed(0)} ${fleet.capacityUnit}'),
                  _pair('Class', fleet.vehicleClass),
                  _pair(
                      'Preferred Cargo Types',
                      fleet.preferredCargoTypes.join(', ').isEmpty
                          ? '-'
                          : fleet.preferredCargoTypes.join(', ')),
                  _pair(
                      'Special Restrictions',
                      fleet.specialRestrictions.isEmpty
                          ? '-'
                          : fleet.specialRestrictions),
                ]),
                _section('Operational Status', [
                  _pair(
                      'Current Location',
                      fleet.currentLocation.isEmpty
                          ? '-'
                          : fleet.currentLocation),
                  _pair(
                      'Current Work Order',
                      fleet.currentWorkOrder.isEmpty
                          ? '-'
                          : fleet.currentWorkOrder),
                  _pair(
                      'Dispatch Blocked', fleet.dispatchBlocked ? 'Yes' : 'No'),
                  _pair('Block Reason',
                      fleet.blockReason.isEmpty ? '-' : fleet.blockReason),
                  _pair('Assignment Allowed',
                      fleet.assignmentAllowed ? 'Yes' : 'No'),
                  _pair(
                      'Assignment Eligibility',
                      fleet.assignmentEligible
                          ? 'Assignable'
                          : 'Not Assignable'),
                ]),
                _section('Compliance', [
                  _pair('Registration Validity', fleet.registrationExpiry),
                  _pair('Insurance Validity', fleet.insuranceExpiry),
                  _pair('Permit Validity', fleet.permitExpiry),
                  _pair('Inspection Validity', fleet.inspectionExpiry),
                  _pair('IVMS Installed', fleet.ivmsInstalled ? 'Yes' : 'No'),
                  _pair('DFMS Installed', fleet.dfmsInstalled ? 'Yes' : 'No'),
                  _pair('Escort Required', fleet.escortRequired ? 'Yes' : 'No'),
                  _pair(
                      'Compliance Ready', fleet.complianceReady ? 'Yes' : 'No'),
                ]),
                _section('Maintenance', [
                  _pair('Last Service Date', fleet.lastServiceDate),
                  _pair('Next Service Due', fleet.nextServiceDue),
                  _pair('Maintenance Status', fleet.maintenanceStatus),
                  _pair(
                      'Notes',
                      fleet.maintenanceNotes.isEmpty
                          ? '-'
                          : fleet.maintenanceNotes),
                ]),
                _section('Usage', [
                  _pair(
                      'Preferred Routes',
                      fleet.preferredRoutes.join(', ').isEmpty
                          ? '-'
                          : fleet.preferredRoutes.join(', ')),
                  _pair('Region', fleet.region.isEmpty ? '-' : fleet.region),
                  _pair('Night Driving Allowed',
                      fleet.nightDrivingAllowed ? 'Yes' : 'No'),
                  _pair('Documents Attached', '${fleet.documents.length}'),
                ]),
              ],
            ),
    );
  }

  Widget _section(String title, List<Widget> children) {
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
            ...children,
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
            width: 190,
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
