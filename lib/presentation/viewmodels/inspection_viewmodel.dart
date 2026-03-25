import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/user.dart';

class InspectionUiState {
  const InspectionUiState({
    required this.items,
    this.query = '',
    this.statusFilter = 'All',
    this.inspectorFilter = 'All',
    this.resultFilter = 'All',
    this.pendingApprovalOnly = false,
    this.dateRange,
    required this.lastUpdated,
  });

  final List<InspectionRecord> items;
  final String query;
  final String statusFilter;
  final String inspectorFilter;
  final String resultFilter;
  final bool pendingApprovalOnly;
  final DateTimeRange? dateRange;
  final DateTime lastUpdated;

  List<InspectionRecord> get filteredItems {
    final normalized = query.trim().toLowerCase();

    return items.where((item) {
      if (statusFilter != 'All' && item.status.label != statusFilter) {
        return false;
      }
      if (inspectorFilter != 'All' && item.inspector != inspectorFilter) {
        return false;
      }
      if (resultFilter != 'All' && item.overallResult.label != resultFilter) {
        return false;
      }
      if (pendingApprovalOnly &&
          item.approvalStatus != InspectionApprovalStatus.pending) {
        return false;
      }
      if (dateRange != null) {
        final start = DateTime(
          dateRange!.start.year,
          dateRange!.start.month,
          dateRange!.start.day,
        );
        final end = DateTime(
          dateRange!.end.year,
          dateRange!.end.month,
          dateRange!.end.day,
          23,
          59,
          59,
        );
        if (item.inspectedAt.isBefore(start) || item.inspectedAt.isAfter(end)) {
          return false;
        }
      }

      if (normalized.isEmpty) {
        return true;
      }

      final searchable = [
        item.inspectionId,
        item.workOrder,
        item.fleet,
        item.driver,
      ].join(' ').toLowerCase();

      return searchable.contains(normalized);
    }).toList();
  }

  InspectionUiState copyWith({
    List<InspectionRecord>? items,
    String? query,
    String? statusFilter,
    String? inspectorFilter,
    String? resultFilter,
    bool? pendingApprovalOnly,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    DateTime? lastUpdated,
  }) {
    return InspectionUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      inspectorFilter: inspectorFilter ?? this.inspectorFilter,
      resultFilter: resultFilter ?? this.resultFilter,
      pendingApprovalOnly: pendingApprovalOnly ?? this.pendingApprovalOnly,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final inspectionViewModelProvider =
    StateNotifierProvider<InspectionViewModel, InspectionUiState>(
  (ref) => InspectionViewModel(),
);

class InspectionViewModel extends StateNotifier<InspectionUiState> {
  InspectionViewModel()
      : super(
          InspectionUiState(
            items: _mockInspections(),
            lastUpdated: DateTime.now(),
          ),
        );

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setStatusFilter(String value) {
    state = state.copyWith(statusFilter: value);
  }

  void setInspectorFilter(String value) {
    state = state.copyWith(inspectorFilter: value);
  }

  void setResultFilter(String value) {
    state = state.copyWith(resultFilter: value);
  }

  void setPendingApprovalOnly(bool value) {
    state = state.copyWith(pendingApprovalOnly: value);
  }

  void setDateRange(DateTimeRange? value) {
    state = state.copyWith(dateRange: value, clearDateRange: value == null);
  }

  void createInspection(InspectionRecord record) {
    state = state.copyWith(
      items: [record, ...state.items],
      lastUpdated: DateTime.now(),
    );
  }

  InspectionRecord? byId(String inspectionId) {
    for (final item in state.items) {
      if (item.inspectionId == inspectionId) {
        return item;
      }
    }
    return null;
  }

  String approveInspection({
    required String inspectionId,
    required String reviewer,
    required String remarks,
    required DateTime? nextInspectionDate,
    required UserRole? role,
    String overrideReason = '',
  }) {
    final item = byId(inspectionId);
    if (item == null) {
      return 'Inspection not found.';
    }

    final hasOverridePermission =
        role == UserRole.admin || role == UserRole.compliance;
    final needsOverride = item.dispatchBlocked;

    if (needsOverride && !hasOverridePermission) {
      return 'Critical failures present. Dispatch remains blocked. Override permission required.';
    }
    if (needsOverride && overrideReason.trim().isEmpty) {
      return 'Override reason is mandatory for critical failures.';
    }

    final updated = item.copyWith(
      status: InspectionStatus.approved,
      approvalStatus: InspectionApprovalStatus.approved,
      reviewerName: reviewer,
      nextInspectionDate: nextInspectionDate,
      overrideApplied: needsOverride,
      overrideReason: overrideReason.trim(),
      approvalHistory: [
        ApprovalHistoryItem(
          decision: 'Approved',
          reviewer: reviewer,
          remarks: remarks,
          at: DateTime.now(),
        ),
        ...item.approvalHistory,
      ],
      auditHistory: [
        InspectionAuditEvent(
          event: needsOverride
              ? 'Approved with override due to critical failures'
              : 'Approved',
          actor: reviewer,
          at: DateTime.now(),
        ),
        ...item.auditHistory,
      ],
      lastUpdated: DateTime.now(),
    );

    _upsert(updated);
    return needsOverride
        ? 'Inspection approved with override. Dispatch unblocked by authorized reviewer.'
        : 'Inspection approved.';
  }

  String rejectInspection({
    required String inspectionId,
    required String reviewer,
    required String remarks,
    required String mandatoryActionNote,
    required DateTime? nextInspectionDate,
  }) {
    if (mandatoryActionNote.trim().isEmpty) {
      return 'Mandatory action note is required when rejecting.';
    }
    final item = byId(inspectionId);
    if (item == null) {
      return 'Inspection not found.';
    }

    final updated = item.copyWith(
      status: InspectionStatus.rejected,
      approvalStatus: InspectionApprovalStatus.rejected,
      reviewerName: reviewer,
      correctiveAction: mandatoryActionNote,
      nextInspectionDate: nextInspectionDate,
      approvalHistory: [
        ApprovalHistoryItem(
          decision: 'Rejected',
          reviewer: reviewer,
          remarks: remarks,
          at: DateTime.now(),
        ),
        ...item.approvalHistory,
      ],
      auditHistory: [
        InspectionAuditEvent(
          event: 'Rejected for correction',
          actor: reviewer,
          at: DateTime.now(),
        ),
        ...item.auditHistory,
      ],
      lastUpdated: DateTime.now(),
    );

    _upsert(updated);
    return 'Inspection rejected and returned with mandatory action note.';
  }

  String sendBackForCorrection({
    required String inspectionId,
    required String reviewer,
    required String remarks,
  }) {
    final item = byId(inspectionId);
    if (item == null) {
      return 'Inspection not found.';
    }

    final updated = item.copyWith(
      status: InspectionStatus.sentBack,
      approvalStatus: InspectionApprovalStatus.sentBack,
      reviewerName: reviewer,
      approvalHistory: [
        ApprovalHistoryItem(
          decision: 'Sent Back',
          reviewer: reviewer,
          remarks: remarks,
          at: DateTime.now(),
        ),
        ...item.approvalHistory,
      ],
      auditHistory: [
        InspectionAuditEvent(
          event: 'Sent back for correction',
          actor: reviewer,
          at: DateTime.now(),
        ),
        ...item.auditHistory,
      ],
      lastUpdated: DateTime.now(),
    );

    _upsert(updated);
    return 'Inspection sent back for correction.';
  }

  void _upsert(InspectionRecord updated) {
    final next = [
      for (final item in state.items)
        if (item.inspectionId == updated.inspectionId) updated else item,
    ];
    state = state.copyWith(items: next, lastUpdated: DateTime.now());
  }

  static List<InspectionRecord> _mockInspections() {
    final now = DateTime.now();
    return [
      InspectionRecord(
        inspectionId: 'INS-24091',
        inspectionType: InspectionType.preTrip,
        workOrder: 'WO-24004',
        fleet: 'TRK-309',
        trailer: 'TRL-88',
        driver: 'Majid Ali',
        inspector: 'Khaled Noor',
        inspectedAt: now.subtract(const Duration(hours: 2)),
        overallResult: InspectionResult.failed,
        status: InspectionStatus.pendingApproval,
        approvalStatus: InspectionApprovalStatus.pending,
        mediaCount: 6,
        lastUpdated: now.subtract(const Duration(hours: 1, minutes: 20)),
        linkedTrip: 'TRP-3004',
        checklistItems: const [
          InspectionChecklistItemResult(
            itemName: 'Rear Brake',
            passed: false,
            remarks: 'Brake wear exceeds threshold',
            mediaCount: 2,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionChecklistItemResult(
            itemName: 'Tyre Pressure',
            passed: true,
            remarks: 'Within limits',
            mediaCount: 1,
          ),
          InspectionChecklistItemResult(
            itemName: 'Lights',
            passed: false,
            remarks: 'Left rear indicator not functioning',
            mediaCount: 1,
            severity: InspectionFailureSeverity.high,
          ),
        ],
        evidence: [
          InspectionEvidence(
            type: 'Image',
            name: 'brake_closeup.jpg',
            uploadedAt: now.subtract(const Duration(hours: 2)),
            uploadedBy: 'Khaled Noor',
          ),
          InspectionEvidence(
            type: 'Video',
            name: 'indicator_test.mp4',
            uploadedAt: now.subtract(const Duration(hours: 2, minutes: 5)),
            uploadedBy: 'Khaled Noor',
          ),
        ],
        correctiveActions: [
          CorrectiveActionItem(
            issueRaised: 'Rear brake wear',
            actionRequired: 'Replace brake pads and re-test braking',
            assignedTo: 'Maintenance Team A',
            dueDate: now.add(const Duration(days: 1)),
            closureNote: '',
            status: 'Open',
          ),
        ],
        approvalHistory: const [],
        auditHistory: [
          InspectionAuditEvent(
            event: 'Created',
            actor: 'Khaled Noor',
            at: now.subtract(const Duration(hours: 2, minutes: 30)),
          ),
          InspectionAuditEvent(
            event: 'Submitted for approval',
            actor: 'Khaled Noor',
            at: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      InspectionRecord(
        inspectionId: 'INS-24090',
        inspectionType: InspectionType.trailer,
        workOrder: 'WO-24003',
        fleet: 'TRK-166',
        trailer: 'TRL-44',
        driver: 'Khalid Omar',
        inspector: 'Rashid Ahmed',
        inspectedAt: now.subtract(const Duration(hours: 5)),
        overallResult: InspectionResult.passed,
        status: InspectionStatus.approved,
        approvalStatus: InspectionApprovalStatus.approved,
        mediaCount: 3,
        lastUpdated: now.subtract(const Duration(hours: 4, minutes: 15)),
        linkedTrip: 'TRP-3003',
        checklistItems: const [
          InspectionChecklistItemResult(
            itemName: 'Trailer Hitch',
            passed: true,
            remarks: 'Secure',
            mediaCount: 1,
          ),
          InspectionChecklistItemResult(
            itemName: 'Tyres',
            passed: true,
            remarks: 'OK',
            mediaCount: 0,
          ),
        ],
        approvalHistory: [
          ApprovalHistoryItem(
            decision: 'Approved',
            reviewer: 'Fatma Salim',
            remarks: 'All compliant.',
            at: now.subtract(const Duration(hours: 4)),
          ),
        ],
        auditHistory: [
          InspectionAuditEvent(
            event: 'Approved',
            actor: 'Fatma Salim',
            at: now.subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      InspectionRecord(
        inspectionId: 'INS-24089',
        inspectionType: InspectionType.safety,
        workOrder: 'WO-24002',
        fleet: 'TRK-114',
        trailer: 'TRL-11',
        driver: 'Salim Rashid',
        inspector: 'Fatma Salim',
        inspectedAt: now.subtract(const Duration(days: 1, hours: 3)),
        overallResult: InspectionResult.failed,
        status: InspectionStatus.rejected,
        approvalStatus: InspectionApprovalStatus.rejected,
        mediaCount: 8,
        lastUpdated: now.subtract(const Duration(days: 1, hours: 1)),
        linkedTrip: 'TRP-3002',
        checklistItems: const [
          InspectionChecklistItemResult(
            itemName: 'Fire Extinguisher',
            passed: false,
            remarks: 'Expired',
            mediaCount: 1,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionChecklistItemResult(
            itemName: 'Safety Belt',
            passed: false,
            remarks: 'Driver belt latch damaged',
            mediaCount: 2,
            severity: InspectionFailureSeverity.high,
          ),
        ],
      ),
      InspectionRecord(
        inspectionId: 'INS-24088',
        inspectionType: InspectionType.preTrip,
        workOrder: 'WO-24001',
        fleet: 'TRK-201',
        trailer: 'TRL-52',
        driver: 'Ahmed Nasser',
        inspector: 'Khaled Noor',
        inspectedAt: now.subtract(const Duration(hours: 9)),
        overallResult: InspectionResult.passed,
        status: InspectionStatus.submitted,
        approvalStatus: InspectionApprovalStatus.pending,
        mediaCount: 2,
        lastUpdated: now.subtract(const Duration(hours: 8, minutes: 40)),
        linkedTrip: 'TRP-3001',
        checklistItems: const [
          InspectionChecklistItemResult(
            itemName: 'Tyres',
            passed: true,
            remarks: 'OK',
            mediaCount: 0,
          ),
          InspectionChecklistItemResult(
            itemName: 'Brake',
            passed: true,
            remarks: 'OK',
            mediaCount: 0,
          ),
        ],
      ),
      InspectionRecord(
        inspectionId: 'INS-24087',
        inspectionType: InspectionType.trip,
        workOrder: 'WO-23998',
        fleet: 'TRK-188',
        trailer: 'TRL-20',
        driver: 'Rafiq Khan',
        inspector: 'Fatma Salim',
        inspectedAt: now.subtract(const Duration(days: 2)),
        overallResult: InspectionResult.failed,
        status: InspectionStatus.sentBack,
        approvalStatus: InspectionApprovalStatus.sentBack,
        mediaCount: 5,
        lastUpdated: now.subtract(const Duration(days: 1, hours: 20)),
        linkedTrip: 'TRP-2998',
      ),
      InspectionRecord(
        inspectionId: 'INS-24086',
        inspectionType: InspectionType.preTrip,
        workOrder: 'WO-23990',
        fleet: 'TRK-155',
        trailer: 'TRL-31',
        driver: 'Javed Khan',
        inspector: 'Rashid Ahmed',
        inspectedAt: now.subtract(const Duration(days: 3)),
        overallResult: InspectionResult.passed,
        status: InspectionStatus.draft,
        approvalStatus: InspectionApprovalStatus.none,
        mediaCount: 1,
        lastUpdated: now.subtract(const Duration(days: 2, hours: 18)),
        linkedTrip: 'TRP-2990',
      ),
    ];
  }
}
