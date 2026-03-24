class VehicleTypeDocumentRequirement {
  const VehicleTypeDocumentRequirement({
    required this.documentName,
    required this.mandatory,
    required this.validityValue,
    required this.validityUnit,
    required this.applicableFor,
  });

  final String documentName;
  final bool mandatory;
  final int validityValue;
  final String validityUnit;
  final String applicableFor;

  VehicleTypeDocumentRequirement copyWith({
    String? documentName,
    bool? mandatory,
    int? validityValue,
    String? validityUnit,
    String? applicableFor,
  }) {
    return VehicleTypeDocumentRequirement(
      documentName: documentName ?? this.documentName,
      mandatory: mandatory ?? this.mandatory,
      validityValue: validityValue ?? this.validityValue,
      validityUnit: validityUnit ?? this.validityUnit,
      applicableFor: applicableFor ?? this.applicableFor,
    );
  }
}

class VehicleType {
  const VehicleType({
    required this.name,
    required this.code,
    required this.category,
    required this.vehicleClass,
    required this.ownershipTypes,
    required this.vendorRequired,
    required this.loadType,
    required this.transportType,
    required this.maxTripsPerDay,
    required this.allowMultiDayJourney,
    required this.allowMultipleStops,
    required this.maxStopsAllowed,
    required this.requireRoutePlanApproval,
    required this.isHazardous,
    required this.requiresSafetyCompliance,
    required this.temperatureControlled,
    required this.requiresEscortVehicle,
    required this.defaultCapacity,
    required this.capacityUnit,
    required this.features,
    required this.requiresInsurance,
    required this.requiresPermit,
    required this.requiresFitness,
    required this.requiresPollution,
    required this.complianceMode,
    required this.documentRequirements,
    required this.status,
    required this.isDefaultType,
  });

  final String name;
  final String code;
  final String category;
  final String vehicleClass;
  final List<String> ownershipTypes;
  final bool vendorRequired;
  final String loadType;
  final String transportType;
  final int maxTripsPerDay;
  final bool allowMultiDayJourney;
  final bool allowMultipleStops;
  final int maxStopsAllowed;
  final bool requireRoutePlanApproval;
  final bool isHazardous;
  final bool requiresSafetyCompliance;
  final bool temperatureControlled;
  final bool requiresEscortVehicle;
  final double defaultCapacity;
  final String capacityUnit;
  final List<String> features;
  final bool requiresInsurance;
  final bool requiresPermit;
  final bool requiresFitness;
  final bool requiresPollution;
  final String complianceMode;
  final List<VehicleTypeDocumentRequirement> documentRequirements;
  final String status;
  final bool isDefaultType;

  VehicleType copyWith({
    String? name,
    String? code,
    String? category,
    String? vehicleClass,
    List<String>? ownershipTypes,
    bool? vendorRequired,
    String? loadType,
    String? transportType,
    int? maxTripsPerDay,
    bool? allowMultiDayJourney,
    bool? allowMultipleStops,
    int? maxStopsAllowed,
    bool? requireRoutePlanApproval,
    bool? isHazardous,
    bool? requiresSafetyCompliance,
    bool? temperatureControlled,
    bool? requiresEscortVehicle,
    double? defaultCapacity,
    String? capacityUnit,
    List<String>? features,
    bool? requiresInsurance,
    bool? requiresPermit,
    bool? requiresFitness,
    bool? requiresPollution,
    String? complianceMode,
    List<VehicleTypeDocumentRequirement>? documentRequirements,
    String? status,
    bool? isDefaultType,
  }) {
    return VehicleType(
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      ownershipTypes: ownershipTypes ?? this.ownershipTypes,
      vendorRequired: vendorRequired ?? this.vendorRequired,
      loadType: loadType ?? this.loadType,
      transportType: transportType ?? this.transportType,
      maxTripsPerDay: maxTripsPerDay ?? this.maxTripsPerDay,
      allowMultiDayJourney: allowMultiDayJourney ?? this.allowMultiDayJourney,
      allowMultipleStops: allowMultipleStops ?? this.allowMultipleStops,
      maxStopsAllowed: maxStopsAllowed ?? this.maxStopsAllowed,
      requireRoutePlanApproval:
          requireRoutePlanApproval ?? this.requireRoutePlanApproval,
      isHazardous: isHazardous ?? this.isHazardous,
      requiresSafetyCompliance:
          requiresSafetyCompliance ?? this.requiresSafetyCompliance,
      temperatureControlled:
          temperatureControlled ?? this.temperatureControlled,
      requiresEscortVehicle:
          requiresEscortVehicle ?? this.requiresEscortVehicle,
      defaultCapacity: defaultCapacity ?? this.defaultCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      features: features ?? this.features,
      requiresInsurance: requiresInsurance ?? this.requiresInsurance,
      requiresPermit: requiresPermit ?? this.requiresPermit,
      requiresFitness: requiresFitness ?? this.requiresFitness,
      requiresPollution: requiresPollution ?? this.requiresPollution,
      complianceMode: complianceMode ?? this.complianceMode,
      documentRequirements: documentRequirements ?? this.documentRequirements,
      status: status ?? this.status,
      isDefaultType: isDefaultType ?? this.isDefaultType,
    );
  }
}
