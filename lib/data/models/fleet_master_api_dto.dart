class FleetMasterUpsertRequestDto {
  const FleetMasterUpsertRequestDto({
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
    required this.updatedBy,
  });

  final String fleetNumber;
  final String vehicleTypeId;
  final String ownershipType;
  final String status;
  final String registrationNumber;
  final String registrationExpiryDate;
  final String insuranceExpiryDate;
  final String permitExpiryDate;
  final String rasExpiryDate;
  final String inspectionDueDate;
  final bool ivmsInstalled;
  final bool dfmsInstalled;
  final double? capacityOverride;
  final String axleType;
  final String fuelType;
  final String bodyType;
  final String availabilityStatus;
  final String maintenanceStatus;
  final String currentTripId;
  final String vendorId;
  final String updatedBy;

  Map<String, dynamic> toMap() {
    return {
      'fleetNumber': fleetNumber,
      'vehicleTypeId': vehicleTypeId,
      'ownershipType': ownershipType,
      'status': status,
      'registrationNumber': registrationNumber,
      'registrationExpiryDate': registrationExpiryDate,
      'insuranceExpiryDate': insuranceExpiryDate,
      'permitExpiryDate': permitExpiryDate,
      'rasExpiryDate': rasExpiryDate,
      'inspectionDueDate': inspectionDueDate,
      'ivmsInstalled': ivmsInstalled,
      'dfmsInstalled': dfmsInstalled,
      'capacityOverride': capacityOverride,
      'axleType': axleType,
      'fuelType': fuelType,
      'bodyType': bodyType,
      'availabilityStatus': availabilityStatus,
      'maintenanceStatus': maintenanceStatus,
      'currentTripId': currentTripId,
      'vendorId': vendorId,
      'updatedBy': updatedBy,
    };
  }
}

class FleetMasterResponseDto extends FleetMasterUpsertRequestDto {
  const FleetMasterResponseDto({
    required this.fleetId,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required super.fleetNumber,
    required super.vehicleTypeId,
    required super.ownershipType,
    required super.status,
    required super.registrationNumber,
    required super.registrationExpiryDate,
    required super.insuranceExpiryDate,
    required super.permitExpiryDate,
    required super.rasExpiryDate,
    required super.inspectionDueDate,
    required super.ivmsInstalled,
    required super.dfmsInstalled,
    required super.capacityOverride,
    required super.axleType,
    required super.fuelType,
    required super.bodyType,
    required super.availabilityStatus,
    required super.maintenanceStatus,
    required super.currentTripId,
    required super.vendorId,
    required super.updatedBy,
  });

  final String fleetId;
  final String createdAt;
  final String createdBy;
  final String updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      'fleetId': fleetId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      ...super.toMap(),
    };
  }
}
