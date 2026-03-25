enum InspectionType {
  preTrip,
  trailer,
  safety,
  trip,
}

extension InspectionTypeX on InspectionType {
  String get label {
    switch (this) {
      case InspectionType.preTrip:
        return 'Pre-Trip';
      case InspectionType.trailer:
        return 'Trailer';
      case InspectionType.safety:
        return 'Safety';
      case InspectionType.trip:
        return 'Trip';
    }
  }
}

enum InspectionStatus {
  draft,
  submitted,
  passed,
  failed,
  pendingApproval,
  approved,
  rejected,
  sentBack,
}

extension InspectionStatusX on InspectionStatus {
  String get label {
    switch (this) {
      case InspectionStatus.draft:
        return 'Draft';
      case InspectionStatus.submitted:
        return 'Submitted';
      case InspectionStatus.passed:
        return 'Passed';
      case InspectionStatus.failed:
        return 'Failed';
      case InspectionStatus.pendingApproval:
        return 'Pending Approval';
      case InspectionStatus.approved:
        return 'Approved';
      case InspectionStatus.rejected:
        return 'Rejected';
      case InspectionStatus.sentBack:
        return 'Sent Back';
    }
  }
}

enum InspectionResult { passed, failed }

extension InspectionResultX on InspectionResult {
  String get label {
    switch (this) {
      case InspectionResult.passed:
        return 'Passed';
      case InspectionResult.failed:
        return 'Failed';
    }
  }
}

enum InspectionApprovalStatus { none, pending, approved, rejected, sentBack }

extension InspectionApprovalStatusX on InspectionApprovalStatus {
  String get label {
    switch (this) {
      case InspectionApprovalStatus.none:
        return 'Not Requested';
      case InspectionApprovalStatus.pending:
        return 'Pending Approval';
      case InspectionApprovalStatus.approved:
        return 'Approved';
      case InspectionApprovalStatus.rejected:
        return 'Rejected';
      case InspectionApprovalStatus.sentBack:
        return 'Sent Back';
    }
  }
}

enum InspectionFailureSeverity { none, low, medium, high, critical }

extension InspectionFailureSeverityX on InspectionFailureSeverity {
  String get label {
    switch (this) {
      case InspectionFailureSeverity.none:
        return '-';
      case InspectionFailureSeverity.low:
        return 'Low';
      case InspectionFailureSeverity.medium:
        return 'Medium';
      case InspectionFailureSeverity.high:
        return 'High';
      case InspectionFailureSeverity.critical:
        return 'Critical';
    }
  }
}

class InspectionChecklistItemResult {
  const InspectionChecklistItemResult({
    required this.itemName,
    required this.passed,
    required this.remarks,
    required this.mediaCount,
    this.severity = InspectionFailureSeverity.none,
  });

  final String itemName;
  final bool passed;
  final String remarks;
  final int mediaCount;
  final InspectionFailureSeverity severity;
}

class InspectionEvidence {
  const InspectionEvidence({
    required this.type,
    required this.name,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  final String type;
  final String name;
  final DateTime uploadedAt;
  final String uploadedBy;
}

class CorrectiveActionItem {
  const CorrectiveActionItem({
    required this.issueRaised,
    required this.actionRequired,
    required this.assignedTo,
    required this.dueDate,
    required this.closureNote,
    required this.status,
  });

  final String issueRaised;
  final String actionRequired;
  final String assignedTo;
  final DateTime dueDate;
  final String closureNote;
  final String status;
}

class ApprovalHistoryItem {
  const ApprovalHistoryItem({
    required this.decision,
    required this.reviewer,
    required this.remarks,
    required this.at,
  });

  final String decision;
  final String reviewer;
  final String remarks;
  final DateTime at;
}

class InspectionAuditEvent {
  const InspectionAuditEvent({
    required this.event,
    required this.actor,
    required this.at,
  });

  final String event;
  final String actor;
  final DateTime at;
}

class InspectionRecord {
  const InspectionRecord({
    required this.inspectionId,
    required this.inspectionType,
    required this.workOrder,
    required this.fleet,
    required this.trailer,
    required this.driver,
    required this.inspector,
    required this.inspectedAt,
    required this.overallResult,
    required this.status,
    required this.approvalStatus,
    required this.mediaCount,
    required this.lastUpdated,
    this.checklistItems = const [],
    this.notes = '',
    this.correctiveAction = '',
    this.recommendation = '',
    this.reviewerName = '',
    this.signaturePlaceholder = true,
    this.linkedTrip = '',
    this.overrideApplied = false,
    this.overrideReason = '',
    this.nextInspectionDate,
    this.evidence = const [],
    this.correctiveActions = const [],
    this.approvalHistory = const [],
    this.auditHistory = const [],
  });

  final String inspectionId;
  final InspectionType inspectionType;
  final String workOrder;
  final String fleet;
  final String trailer;
  final String driver;
  final String inspector;
  final DateTime inspectedAt;
  final InspectionResult overallResult;
  final InspectionStatus status;
  final InspectionApprovalStatus approvalStatus;
  final int mediaCount;
  final DateTime lastUpdated;
  final List<InspectionChecklistItemResult> checklistItems;
  final String notes;
  final String correctiveAction;
  final String recommendation;
  final String reviewerName;
  final bool signaturePlaceholder;
  final String linkedTrip;
  final bool overrideApplied;
  final String overrideReason;
  final DateTime? nextInspectionDate;
  final List<InspectionEvidence> evidence;
  final List<CorrectiveActionItem> correctiveActions;
  final List<ApprovalHistoryItem> approvalHistory;
  final List<InspectionAuditEvent> auditHistory;

  int get failedItemsCount =>
      checklistItems.where((item) => !item.passed).length;

  int get criticalFailureCount => checklistItems
      .where((item) =>
          !item.passed && item.severity == InspectionFailureSeverity.critical)
      .length;

  bool get dispatchBlocked => criticalFailureCount > 0 && !overrideApplied;

  InspectionRecord copyWith({
    String? inspectionId,
    InspectionType? inspectionType,
    String? workOrder,
    String? fleet,
    String? trailer,
    String? driver,
    String? inspector,
    DateTime? inspectedAt,
    InspectionResult? overallResult,
    InspectionStatus? status,
    InspectionApprovalStatus? approvalStatus,
    int? mediaCount,
    DateTime? lastUpdated,
    List<InspectionChecklistItemResult>? checklistItems,
    String? notes,
    String? correctiveAction,
    String? recommendation,
    String? reviewerName,
    bool? signaturePlaceholder,
    String? linkedTrip,
    bool? overrideApplied,
    String? overrideReason,
    DateTime? nextInspectionDate,
    bool clearNextInspectionDate = false,
    List<InspectionEvidence>? evidence,
    List<CorrectiveActionItem>? correctiveActions,
    List<ApprovalHistoryItem>? approvalHistory,
    List<InspectionAuditEvent>? auditHistory,
  }) {
    return InspectionRecord(
      inspectionId: inspectionId ?? this.inspectionId,
      inspectionType: inspectionType ?? this.inspectionType,
      workOrder: workOrder ?? this.workOrder,
      fleet: fleet ?? this.fleet,
      trailer: trailer ?? this.trailer,
      driver: driver ?? this.driver,
      inspector: inspector ?? this.inspector,
      inspectedAt: inspectedAt ?? this.inspectedAt,
      overallResult: overallResult ?? this.overallResult,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      mediaCount: mediaCount ?? this.mediaCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      checklistItems: checklistItems ?? this.checklistItems,
      notes: notes ?? this.notes,
      correctiveAction: correctiveAction ?? this.correctiveAction,
      recommendation: recommendation ?? this.recommendation,
      reviewerName: reviewerName ?? this.reviewerName,
      signaturePlaceholder: signaturePlaceholder ?? this.signaturePlaceholder,
      linkedTrip: linkedTrip ?? this.linkedTrip,
      overrideApplied: overrideApplied ?? this.overrideApplied,
      overrideReason: overrideReason ?? this.overrideReason,
      nextInspectionDate: clearNextInspectionDate
          ? null
          : (nextInspectionDate ?? this.nextInspectionDate),
      evidence: evidence ?? this.evidence,
      correctiveActions: correctiveActions ?? this.correctiveActions,
      approvalHistory: approvalHistory ?? this.approvalHistory,
      auditHistory: auditHistory ?? this.auditHistory,
    );
  }
}
