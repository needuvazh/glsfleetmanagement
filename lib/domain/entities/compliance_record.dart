enum ComplianceStatus { compliant, expiringSoon, overdue }

extension ComplianceStatusX on ComplianceStatus {
  String get label {
    switch (this) {
      case ComplianceStatus.compliant:
        return 'Compliant';
      case ComplianceStatus.expiringSoon:
        return 'Expiring Soon';
      case ComplianceStatus.overdue:
        return 'Overdue';
    }
  }

  static ComplianceStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'expiring soon':
      case 'expiring_soon':
      case 'expiringsoon':
        return ComplianceStatus.expiringSoon;
      case 'overdue':
      case 'non-compliant':
      case 'non compliant':
        return ComplianceStatus.overdue;
      default:
        return ComplianceStatus.compliant;
    }
  }
}

class ComplianceRecord {
  const ComplianceRecord({
    required this.vehicleId,
    required this.registrationExpiry,
    required this.insuranceExpiry,
    required this.inspectionDue,
    required this.complianceStatus,
  });

  final String vehicleId;
  final DateTime registrationExpiry;
  final DateTime insuranceExpiry;
  final DateTime inspectionDue;
  final ComplianceStatus complianceStatus;

  ComplianceRecord copyWith({
    String? vehicleId,
    DateTime? registrationExpiry,
    DateTime? insuranceExpiry,
    DateTime? inspectionDue,
    ComplianceStatus? complianceStatus,
  }) {
    return ComplianceRecord(
      vehicleId: vehicleId ?? this.vehicleId,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      inspectionDue: inspectionDue ?? this.inspectionDue,
      complianceStatus: complianceStatus ?? this.complianceStatus,
    );
  }
}
