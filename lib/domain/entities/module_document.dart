class ModuleDocument {
  const ModuleDocument({
    required this.id,
    required this.documentCode,
    required this.documentName,
    required this.description,
    required this.applicableTo,
    required this.status,
    required this.mandatory,
    required this.hasExpiry,
    required this.alertBeforeDays,
    required this.checkAtAssignment,
    required this.checkAtInspection,
    required this.checkAtDispatch,
    required this.checkAtTripStart,
    required this.checkAtDeliveryClosure,
    required this.missingAction,
    required this.expiredAction,
    required this.uploadRequired,
    required this.overrideAllowed,
  });

  final String id;
  final String documentCode;
  final String documentName;
  final String description;
  final String applicableTo;
  final String status;
  final bool mandatory;
  final bool hasExpiry;
  final int alertBeforeDays;
  final bool checkAtAssignment;
  final bool checkAtInspection;
  final bool checkAtDispatch;
  final bool checkAtTripStart;
  final bool checkAtDeliveryClosure;
  final String missingAction;
  final String expiredAction;
  final bool uploadRequired;
  final bool overrideAllowed;

  String get targetType => applicableTo;

  String get blockingType {
    final severity = {
      'Ignore': 0,
      'Warning': 1,
      'Soft Block': 2,
      'Hard Block': 3,
    };
    final missingScore = severity[missingAction] ?? 0;
    final expiredScore = severity[expiredAction] ?? 0;
    final selected =
        missingScore >= expiredScore ? missingAction : expiredAction;
    return selected;
  }

  String get requiredStageLabel {
    final stages = <String>[];
    if (checkAtAssignment) {
      stages.add('Assignment');
    }
    if (checkAtInspection) {
      stages.add('Inspection');
    }
    if (checkAtDispatch) {
      stages.add('Dispatch');
    }
    if (checkAtTripStart) {
      stages.add('Trip Start');
    }
    if (checkAtDeliveryClosure) {
      stages.add('Delivery Closure');
    }
    if (stages.isEmpty) {
      return '-';
    }
    return stages.join(', ');
  }

  ModuleDocument copyWith({
    String? id,
    String? documentCode,
    String? documentName,
    String? description,
    String? applicableTo,
    String? status,
    bool? mandatory,
    bool? hasExpiry,
    int? alertBeforeDays,
    bool? checkAtAssignment,
    bool? checkAtInspection,
    bool? checkAtDispatch,
    bool? checkAtTripStart,
    bool? checkAtDeliveryClosure,
    String? missingAction,
    String? expiredAction,
    bool? uploadRequired,
    bool? overrideAllowed,
  }) {
    return ModuleDocument(
      id: id ?? this.id,
      documentCode: documentCode ?? this.documentCode,
      documentName: documentName ?? this.documentName,
      description: description ?? this.description,
      applicableTo: applicableTo ?? this.applicableTo,
      status: status ?? this.status,
      mandatory: mandatory ?? this.mandatory,
      hasExpiry: hasExpiry ?? this.hasExpiry,
      alertBeforeDays: alertBeforeDays ?? this.alertBeforeDays,
      checkAtAssignment: checkAtAssignment ?? this.checkAtAssignment,
      checkAtInspection: checkAtInspection ?? this.checkAtInspection,
      checkAtDispatch: checkAtDispatch ?? this.checkAtDispatch,
      checkAtTripStart: checkAtTripStart ?? this.checkAtTripStart,
      checkAtDeliveryClosure:
          checkAtDeliveryClosure ?? this.checkAtDeliveryClosure,
      missingAction: missingAction ?? this.missingAction,
      expiredAction: expiredAction ?? this.expiredAction,
      uploadRequired: uploadRequired ?? this.uploadRequired,
      overrideAllowed: overrideAllowed ?? this.overrideAllowed,
    );
  }
}
