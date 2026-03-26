import '../../domain/entities/module_document.dart';

class ModuleDocumentModel extends ModuleDocument {
  const ModuleDocumentModel({
    required super.id,
    required super.documentCode,
    required super.documentName,
    required super.description,
    required super.applicableTo,
    required super.status,
    required super.mandatory,
    required super.hasExpiry,
    required super.alertBeforeDays,
    required super.checkAtAssignment,
    required super.checkAtInspection,
    required super.checkAtDispatch,
    required super.checkAtTripStart,
    required super.checkAtDeliveryClosure,
    required super.missingAction,
    required super.expiredAction,
    required super.uploadRequired,
    required super.overrideAllowed,
  });

  factory ModuleDocumentModel.fromMap(Map<String, dynamic> map) {
    final fallbackApplicableTo =
        (map['targetType'] as String? ?? 'Driver').trim();
    return ModuleDocumentModel(
      id: map['id'] as String? ?? '',
      documentCode:
          map['documentCode'] as String? ?? (map['id'] as String? ?? ''),
      documentName: map['documentName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      applicableTo: map['applicableTo'] as String? ?? fallbackApplicableTo,
      status: map['status'] as String? ?? 'Active',
      mandatory: map['mandatory'] as bool? ?? true,
      hasExpiry: map['hasExpiry'] as bool? ?? false,
      alertBeforeDays: _toInt(map['alertBeforeDays'], fallback: 0),
      checkAtAssignment: map['checkAtAssignment'] as bool? ?? false,
      checkAtInspection: map['checkAtInspection'] as bool? ?? false,
      checkAtDispatch: map['checkAtDispatch'] as bool? ?? false,
      checkAtTripStart: map['checkAtTripStart'] as bool? ?? false,
      checkAtDeliveryClosure: map['checkAtDeliveryClosure'] as bool? ?? false,
      missingAction: map['missingAction'] as String? ?? 'Warning',
      expiredAction: map['expiredAction'] as String? ?? 'Warning',
      uploadRequired: map['uploadRequired'] as bool? ?? false,
      overrideAllowed: map['overrideAllowed'] as bool? ?? false,
    );
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? fallback;
  }
}
