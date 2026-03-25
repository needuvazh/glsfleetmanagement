import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fleet.dart';
import '../../domain/entities/inspection.dart';
import 'fleet_viewmodel.dart';
import 'inspection_viewmodel.dart';

class FleetDetailMediaItem {
  const FleetDetailMediaItem({
    required this.name,
    required this.type,
    required this.uploadedAt,
    required this.uploader,
  });

  final String name;
  final String type;
  final DateTime uploadedAt;
  final String uploader;
}

class FleetDetailHistoryItem {
  const FleetDetailHistoryItem({
    required this.event,
    required this.actor,
    required this.at,
  });

  final String event;
  final String actor;
  final DateTime at;
}

class FleetDetailTripItem {
  const FleetDetailTripItem({
    required this.tripId,
    required this.status,
    required this.at,
  });

  final String tripId;
  final String status;
  final DateTime at;
}

class FleetDetailData {
  const FleetDetailData({
    required this.fleet,
    required this.inspections,
    required this.registration,
    required this.ownershipType,
    required this.insuranceExpiry,
    required this.permitExpiry,
    required this.inspectionDueDate,
    required this.expiryWarnings,
    required this.trips,
    required this.media,
    required this.history,
  });

  final Fleet fleet;
  final List<InspectionRecord> inspections;
  final String registration;
  final String ownershipType;
  final DateTime insuranceExpiry;
  final DateTime permitExpiry;
  final DateTime inspectionDueDate;
  final String expiryWarnings;
  final List<FleetDetailTripItem> trips;
  final List<FleetDetailMediaItem> media;
  final List<FleetDetailHistoryItem> history;
}

final fleetDetailProvider =
    Provider.family<FleetDetailData?, String>((ref, fleetId) {
  final fleetState = ref.watch(fleetViewModelProvider);
  final inspectionState = ref.watch(inspectionViewModelProvider);

  final fleets = fleetState.valueOrNull?.items ?? const <Fleet>[];

  Fleet? fleet;
  for (final item in fleets) {
    if (item.vehicleNumber == fleetId) {
      fleet = item;
      break;
    }
  }
  if (fleet == null) {
    return null;
  }

  final inspections = inspectionState.items
      .where((item) => item.fleet == fleet!.vehicleNumber)
      .toList();

  final seed = fleet.id.codeUnits.fold<int>(0, (a, b) => a + b);
  final insuranceExpiry = DateTime.now().add(Duration(days: 12 + (seed % 60)));
  final permitExpiry = DateTime.now().add(Duration(days: 8 + (seed % 45)));
  final inspectionDueDate = DateTime.now().add(Duration(days: 5 + (seed % 30)));

  final warnings = <String>[];
  if (insuranceExpiry.difference(DateTime.now()).inDays <= 30) {
    warnings.add('Insurance expiry within 30 days');
  }
  if (permitExpiry.difference(DateTime.now()).inDays <= 20) {
    warnings.add('Permit expiry within 20 days');
  }
  if (inspectionDueDate.difference(DateTime.now()).inDays <= 15) {
    warnings.add('Inspection due within 15 days');
  }

  final media = <FleetDetailMediaItem>[];
  for (final inspection in inspections) {
    for (final evidence in inspection.evidence) {
      media.add(
        FleetDetailMediaItem(
          name: evidence.name,
          type: evidence.type,
          uploadedAt: evidence.uploadedAt,
          uploader: evidence.uploadedBy,
        ),
      );
    }
  }

  final history = <FleetDetailHistoryItem>[
    FleetDetailHistoryItem(
      event: 'Fleet record created',
      actor: 'Admin',
      at: DateTime.now().subtract(const Duration(days: 220)),
    ),
    FleetDetailHistoryItem(
      event: 'Last service updated',
      actor: 'Maintenance Team',
      at: fleet.lastServiceDate,
    ),
    ...inspections.map(
      (inspection) => FleetDetailHistoryItem(
        event:
            'Inspection ${inspection.inspectionId} (${inspection.overallResult.label})',
        actor: inspection.inspector,
        at: inspection.inspectedAt,
      ),
    ),
  ]..sort((a, b) => b.at.compareTo(a.at));

  final trips = [
    FleetDetailTripItem(
      tripId: 'TRP-${3000 + (seed % 70)}',
      status: fleet.status == FleetStatus.active ? 'Active' : 'Completed',
      at: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    FleetDetailTripItem(
      tripId: 'TRP-${2920 + (seed % 40)}',
      status: 'Completed',
      at: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    ),
  ];

  return FleetDetailData(
    fleet: fleet,
    inspections: inspections,
    registration: 'REG-${fleet.vehicleNumber.replaceAll(' ', '')}',
    ownershipType: 'Company Owned',
    insuranceExpiry: insuranceExpiry,
    permitExpiry: permitExpiry,
    inspectionDueDate: inspectionDueDate,
    expiryWarnings:
        warnings.isEmpty ? 'No active warning' : warnings.join(' • '),
    trips: trips,
    media: media,
    history: history,
  );
});
