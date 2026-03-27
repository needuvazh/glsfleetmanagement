import 'vehicle_type_master_model.dart';

enum OwnershipType {
  owned('Owned'),
  leased('Leased'),
  contracted('Contracted');

  const OwnershipType(this.label);
  final String label;
}

enum AvailabilityStatusType {
  available('Available'),
  assigned('Assigned'),
  maintenance('Maintenance'),
  underReview('Under Review');

  const AvailabilityStatusType(this.label);
  final String label;
}

enum MaintenanceStatusType {
  operational('Operational'),
  preventiveDue('Preventive Due'),
  inMaintenance('In Maintenance'),
  grounded('Grounded');

  const MaintenanceStatusType(this.label);
  final String label;
}

enum ComplianceIndicatorType {
  valid('Valid'),
  expiringSoon('Expiring Soon'),
  expired('Expired');

  const ComplianceIndicatorType(this.label);
  final String label;
}

class ComplianceBadge {
  const ComplianceBadge({
    required this.label,
    required this.state,
    required this.expiryDate,
  });

  final String label;
  final ComplianceIndicatorType state;
  final DateTime expiryDate;
}

class FleetMasterModel {
  const FleetMasterModel({
    required this.fleetId,
    required this.fleetNumber,
    required this.vehicleTypeId,
    required this.ownershipType,
    required this.status,
    required this.registrationNumber,
    required this.registrationExpiryDate,
    required this.insuranceExpiryDate,
    required this.permitExpiryDate,
    required this.rasExpiryDate,
    required this.inspectionDueDate,
    required this.ivmsInstalled,
    required this.dfmsInstalled,
    required this.capacityOverride,
    required this.axleType,
    required this.fuelType,
    required this.bodyType,
    required this.availabilityStatus,
    required this.maintenanceStatus,
    required this.currentTripId,
    required this.vendorId,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  final String fleetId;
  final String fleetNumber;
  final String vehicleTypeId;
  final OwnershipType ownershipType;
  final RecordStatusType status;
  final String registrationNumber;
  final DateTime registrationExpiryDate;
  final DateTime insuranceExpiryDate;
  final DateTime permitExpiryDate;
  final DateTime rasExpiryDate;
  final DateTime inspectionDueDate;
  final bool ivmsInstalled;
  final bool dfmsInstalled;
  final double? capacityOverride;
  final AxleType axleType;
  final FuelType fuelType;
  final BodyType bodyType;
  final AvailabilityStatusType availabilityStatus;
  final MaintenanceStatusType maintenanceStatus;
  final String currentTripId;
  final String vendorId;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;

  List<ComplianceBadge> complianceBadges(DateTime now) {
    return [
      ComplianceBadge(
        label: 'Registration',
        state: _complianceState(registrationExpiryDate, now),
        expiryDate: registrationExpiryDate,
      ),
      ComplianceBadge(
        label: 'Insurance',
        state: _complianceState(insuranceExpiryDate, now),
        expiryDate: insuranceExpiryDate,
      ),
      ComplianceBadge(
        label: 'Permit',
        state: _complianceState(permitExpiryDate, now),
        expiryDate: permitExpiryDate,
      ),
      ComplianceBadge(
        label: 'RAS',
        state: _complianceState(rasExpiryDate, now),
        expiryDate: rasExpiryDate,
      ),
      ComplianceBadge(
        label: 'Inspection',
        state: _complianceState(inspectionDueDate, now),
        expiryDate: inspectionDueDate,
      ),
    ];
  }

  ComplianceIndicatorType overallCompliance(DateTime now) {
    final badges = complianceBadges(now);
    if (badges.any((entry) => entry.state == ComplianceIndicatorType.expired)) {
      return ComplianceIndicatorType.expired;
    }
    if (badges.any(
      (entry) => entry.state == ComplianceIndicatorType.expiringSoon,
    )) {
      return ComplianceIndicatorType.expiringSoon;
    }
    return ComplianceIndicatorType.valid;
  }

  bool isAssignable(DateTime now) {
    return status == RecordStatusType.active &&
        availabilityStatus == AvailabilityStatusType.available &&
        maintenanceStatus != MaintenanceStatusType.inMaintenance &&
        maintenanceStatus != MaintenanceStatusType.grounded &&
        overallCompliance(now) != ComplianceIndicatorType.expired;
  }

  FleetMasterModel copyWith({
    String? fleetId,
    String? fleetNumber,
    String? vehicleTypeId,
    OwnershipType? ownershipType,
    RecordStatusType? status,
    String? registrationNumber,
    DateTime? registrationExpiryDate,
    DateTime? insuranceExpiryDate,
    DateTime? permitExpiryDate,
    DateTime? rasExpiryDate,
    DateTime? inspectionDueDate,
    bool? ivmsInstalled,
    bool? dfmsInstalled,
    double? capacityOverride,
    bool clearCapacityOverride = false,
    AxleType? axleType,
    FuelType? fuelType,
    BodyType? bodyType,
    AvailabilityStatusType? availabilityStatus,
    MaintenanceStatusType? maintenanceStatus,
    String? currentTripId,
    String? vendorId,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return FleetMasterModel(
      fleetId: fleetId ?? this.fleetId,
      fleetNumber: fleetNumber ?? this.fleetNumber,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      ownershipType: ownershipType ?? this.ownershipType,
      status: status ?? this.status,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationExpiryDate:
          registrationExpiryDate ?? this.registrationExpiryDate,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      permitExpiryDate: permitExpiryDate ?? this.permitExpiryDate,
      rasExpiryDate: rasExpiryDate ?? this.rasExpiryDate,
      inspectionDueDate: inspectionDueDate ?? this.inspectionDueDate,
      ivmsInstalled: ivmsInstalled ?? this.ivmsInstalled,
      dfmsInstalled: dfmsInstalled ?? this.dfmsInstalled,
      capacityOverride: clearCapacityOverride
          ? null
          : (capacityOverride ?? this.capacityOverride),
      axleType: axleType ?? this.axleType,
      fuelType: fuelType ?? this.fuelType,
      bodyType: bodyType ?? this.bodyType,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      currentTripId: currentTripId ?? this.currentTripId,
      vendorId: vendorId ?? this.vendorId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  static ComplianceIndicatorType _complianceState(
    DateTime expiryDate,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final difference = expiry.difference(today).inDays;
    if (difference < 0) {
      return ComplianceIndicatorType.expired;
    }
    if (difference <= 30) {
      return ComplianceIndicatorType.expiringSoon;
    }
    return ComplianceIndicatorType.valid;
  }
}
