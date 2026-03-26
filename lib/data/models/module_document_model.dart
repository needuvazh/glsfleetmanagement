import 'dart:convert';

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

  static Map<String, dynamic> toMap(ModuleDocument item) {
    return {
      'id': item.id,
      'documentCode': item.documentCode,
      'documentName': item.documentName,
      'description': item.description,
      'applicableTo': item.applicableTo,
      'status': item.status,
      'mandatory': item.mandatory,
      'hasExpiry': item.hasExpiry,
      'alertBeforeDays': item.alertBeforeDays,
      'checkAtAssignment': item.checkAtAssignment,
      'checkAtInspection': item.checkAtInspection,
      'checkAtDispatch': item.checkAtDispatch,
      'checkAtTripStart': item.checkAtTripStart,
      'checkAtDeliveryClosure': item.checkAtDeliveryClosure,
      'missingAction': item.missingAction,
      'expiredAction': item.expiredAction,
      'uploadRequired': item.uploadRequired,
      'overrideAllowed': item.overrideAllowed,
    };
  }

  static String encodeList(List<ModuleDocument> items) {
    final payload = items.map(toMap).toList();
    return jsonEncode(payload);
  }

  static List<ModuleDocument> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((entry) => entry.map(
              (key, value) => MapEntry(key.toString(), value),
            ))
        .map(ModuleDocumentModel.fromMap)
        .toList();
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
