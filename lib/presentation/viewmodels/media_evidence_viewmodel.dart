import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import 'inspection_viewmodel.dart';
import 'logistics_viewmodel.dart';

enum MediaEvidenceType { photo, video, document }

extension MediaEvidenceTypeX on MediaEvidenceType {
  String get label {
    switch (this) {
      case MediaEvidenceType.photo:
        return 'Photo';
      case MediaEvidenceType.video:
        return 'Video';
      case MediaEvidenceType.document:
        return 'Document';
    }
  }

  String get tabLabel {
    switch (this) {
      case MediaEvidenceType.photo:
        return 'Photos';
      case MediaEvidenceType.video:
        return 'Videos';
      case MediaEvidenceType.document:
        return 'Documents';
    }
  }
}

class MediaEvidenceItem {
  const MediaEvidenceItem({
    required this.id,
    required this.type,
    required this.fileName,
    required this.linkedModule,
    required this.linkedRecord,
    required this.capturedBy,
    required this.capturedAt,
    required this.remarks,
    this.workOrder,
    this.inspection,
    this.trip,
    this.fleet,
    this.driver,
    this.linkedAuditRecords = const [],
  });

  final String id;
  final MediaEvidenceType type;
  final String fileName;
  final String linkedModule;
  final String linkedRecord;
  final String capturedBy;
  final DateTime capturedAt;
  final String remarks;
  final String? workOrder;
  final String? inspection;
  final String? trip;
  final String? fleet;
  final String? driver;
  final List<String> linkedAuditRecords;
}

class MediaEvidenceState {
  const MediaEvidenceState({required this.items});

  final List<MediaEvidenceItem> items;

  MediaEvidenceItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}

final mediaEvidenceProvider = Provider<MediaEvidenceState>((ref) {
  final inspections = ref.watch(inspectionViewModelProvider).items;
  final logistics = ref.watch(logisticsViewModelProvider).valueOrNull;

  final items = <MediaEvidenceItem>[];

  for (final inspection in inspections) {
    for (var index = 0; index < inspection.evidence.length; index++) {
      final evidence = inspection.evidence[index];
      final type = _resolveType(evidence.type, evidence.name);
      items.add(
        MediaEvidenceItem(
          id: '${inspection.inspectionId}_${index}_${type.name}',
          type: type,
          fileName: evidence.name,
          linkedModule: 'Inspection',
          linkedRecord: inspection.inspectionId,
          capturedBy: evidence.uploadedBy,
          capturedAt: evidence.uploadedAt,
          remarks: inspection.notes.isEmpty
              ? 'Captured during ${inspection.inspectionType.label.toLowerCase()} inspection.'
              : inspection.notes,
          workOrder: inspection.workOrder,
          inspection: inspection.inspectionId,
          trip: inspection.linkedTrip,
          fleet: inspection.fleet,
          driver: inspection.driver,
          linkedAuditRecords: [
            'Inspection created',
            'Evidence uploaded',
            'Inspection ${inspection.status.label.toLowerCase()}',
          ],
        ),
      );
    }
  }

  if (logistics != null) {
    for (final wo in logistics.workOrders) {
      final hash = wo.woId.codeUnits.fold<int>(0, (a, b) => a + b);
      final hasPod = hash % 2 == 0;
      final hasDn = hash % 3 != 0;

      if (hasPod) {
        items.add(
          MediaEvidenceItem(
            id: '${wo.woId}_pod_doc',
            type: MediaEvidenceType.document,
            fileName: 'POD_${wo.woId}.pdf',
            linkedModule: 'Work Order',
            linkedRecord: wo.woId,
            capturedBy: 'Operations Desk',
            capturedAt:
                DateTime.now().subtract(Duration(hours: 3 + (hash % 8))),
            remarks: 'POD document uploaded for closure readiness.',
            workOrder: wo.woId,
            trip: 'TRP-${3000 + (hash % 60)}',
            linkedAuditRecords: const [
              'Document submitted',
              'Document verified',
            ],
          ),
        );
      }
      if (hasDn) {
        items.add(
          MediaEvidenceItem(
            id: '${wo.woId}_dn_doc',
            type: MediaEvidenceType.document,
            fileName: 'DN_${wo.woId}.pdf',
            linkedModule: 'Work Order',
            linkedRecord: wo.woId,
            capturedBy: 'Document Controller',
            capturedAt:
                DateTime.now().subtract(Duration(hours: 5 + (hash % 10))),
            remarks: 'Delivery note attached for compliance.',
            workOrder: wo.woId,
            trip: 'TRP-${3000 + (hash % 60)}',
            linkedAuditRecords: const [
              'Document linked',
              'Compliance cross-check done',
            ],
          ),
        );
      }
    }
  }

  items.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
  return MediaEvidenceState(items: items);
});

MediaEvidenceType _resolveType(String rawType, String fileName) {
  final normalized = rawType.toLowerCase();
  if (normalized.contains('image') || normalized.contains('photo')) {
    return MediaEvidenceType.photo;
  }
  if (normalized.contains('video')) {
    return MediaEvidenceType.video;
  }

  final lowerName = fileName.toLowerCase();
  if (lowerName.endsWith('.jpg') ||
      lowerName.endsWith('.jpeg') ||
      lowerName.endsWith('.png') ||
      lowerName.endsWith('.webp')) {
    return MediaEvidenceType.photo;
  }
  if (lowerName.endsWith('.mp4') || lowerName.endsWith('.mov')) {
    return MediaEvidenceType.video;
  }
  return MediaEvidenceType.document;
}
