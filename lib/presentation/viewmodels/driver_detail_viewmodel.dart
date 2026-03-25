import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/logistics_flow.dart';
import 'inspection_viewmodel.dart';
import 'logistics_viewmodel.dart';

class DriverIncident {
  const DriverIncident({
    required this.title,
    required this.severity,
    required this.reportedAt,
  });

  final String title;
  final String severity;
  final DateTime reportedAt;
}

class DriverMediaItem {
  const DriverMediaItem({
    required this.name,
    required this.type,
    required this.uploadedAt,
    required this.source,
  });

  final String name;
  final String type;
  final DateTime uploadedAt;
  final String source;
}

class DriverHistoryItem {
  const DriverHistoryItem({
    required this.event,
    required this.actor,
    required this.at,
  });

  final String event;
  final String actor;
  final DateTime at;
}

class DriverDetailData {
  const DriverDetailData({
    required this.driver,
    required this.complianceStatus,
    required this.currentTrip,
    required this.assignments,
    required this.inspections,
    required this.incidents,
    required this.media,
    required this.history,
  });

  final DriverData driver;
  final String complianceStatus;
  final String currentTrip;
  final List<String> assignments;
  final List<InspectionRecord> inspections;
  final List<DriverIncident> incidents;
  final List<DriverMediaItem> media;
  final List<DriverHistoryItem> history;
}

final driverDetailProvider =
    Provider.family<DriverDetailData?, String>((ref, driverId) {
  final logistics = ref.watch(logisticsViewModelProvider).valueOrNull;
  if (logistics == null) {
    return null;
  }
  DriverData? driver;
  for (final item in logistics.drivers) {
    if (item.driverId == driverId) {
      driver = item;
      break;
    }
  }
  if (driver == null) {
    return null;
  }

  final inspections =
      ref.watch(inspectionViewModelProvider).items.where((item) {
    return item.driver == driver!.name || item.driver == driver.driverId;
  }).toList();

  final currentTrip = logistics.assignedDriverId == driver.driverId
      ? (logistics.assignedOrderId == null
          ? '-'
          : 'TRP-${logistics.assignedOrderId}')
      : '-';

  final assignments = <String>[];
  for (final order in logistics.workOrders) {
    if (logistics.assignedDriverId == driver.driverId &&
        logistics.assignedOrderId == order.woId) {
      assignments.add('${order.woId} • ${order.route}');
    }
  }

  final incidents = <DriverIncident>[
    DriverIncident(
      title: 'Fatigue alert reported by DFMS',
      severity: 'Medium',
      reportedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    DriverIncident(
      title: 'Late check-in at checkpoint',
      severity: 'Low',
      reportedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  final media = <DriverMediaItem>[];
  for (final inspection in inspections) {
    for (final evidence in inspection.evidence) {
      media.add(
        DriverMediaItem(
          name: evidence.name,
          type: evidence.type,
          uploadedAt: evidence.uploadedAt,
          source: inspection.inspectionId,
        ),
      );
    }
  }

  final history = <DriverHistoryItem>[
    DriverHistoryItem(
      event: 'Driver profile created',
      actor: 'Admin',
      at: DateTime.now().subtract(const Duration(days: 300)),
    ),
    DriverHistoryItem(
      event: 'License renewed',
      actor: 'Compliance',
      at: DateTime.now().subtract(const Duration(days: 45)),
    ),
    ...inspections.map(
      (inspection) => DriverHistoryItem(
        event:
            'Inspection ${inspection.inspectionId} (${inspection.overallResult.label})',
        actor: inspection.inspector,
        at: inspection.inspectedAt,
      ),
    ),
  ]..sort((a, b) => b.at.compareTo(a.at));

  final complianceStatus = _driverComplianceStatus(driver.expiryDate);

  return DriverDetailData(
    driver: driver,
    complianceStatus: complianceStatus,
    currentTrip: currentTrip,
    assignments: assignments,
    inspections: inspections,
    incidents: incidents,
    media: media,
    history: history,
  );
});

String _driverComplianceStatus(String expiryDate) {
  final expiry = DateTime.tryParse(expiryDate.trim());
  if (expiry == null) {
    return 'Unknown';
  }
  final days = expiry.difference(DateTime.now()).inDays;
  if (days < 0) {
    return 'Expired';
  }
  if (days <= 30) {
    return 'Expiring Soon';
  }
  return 'Valid';
}
