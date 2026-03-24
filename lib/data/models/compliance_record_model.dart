import '../../domain/entities/compliance_record.dart';

class ComplianceRecordModel extends ComplianceRecord {
  const ComplianceRecordModel({
    required super.vehicleId,
    required super.registrationExpiry,
    required super.insuranceExpiry,
    required super.inspectionDue,
    required super.complianceStatus,
  });

  factory ComplianceRecordModel.fromMap(Map<String, dynamic> map) {
    return ComplianceRecordModel(
      vehicleId: map['vehicleId'] as String? ?? '',
      registrationExpiry:
          DateTime.tryParse(map['registrationExpiry'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      insuranceExpiry:
          DateTime.tryParse(map['insuranceExpiry'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      inspectionDue: DateTime.tryParse(map['inspectionDue'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      complianceStatus:
          ComplianceStatusX.fromString(map['complianceStatus'] as String? ?? ''),
    );
  }
}
