import '../../domain/entities/vehicle_type.dart';

class VehicleTypeModel extends VehicleType {
  const VehicleTypeModel({
    required super.name,
    required super.code,
    required super.category,
    required super.vehicleClass,
    required super.ownershipTypes,
    required super.vendorRequired,
    required super.loadType,
    required super.transportType,
    required super.maxTripsPerDay,
    required super.allowMultiDayJourney,
    required super.allowMultipleStops,
    required super.maxStopsAllowed,
    required super.requireRoutePlanApproval,
    required super.isHazardous,
    required super.requiresSafetyCompliance,
    required super.temperatureControlled,
    required super.requiresEscortVehicle,
    required super.defaultCapacity,
    required super.capacityUnit,
    required super.features,
    required super.requiresInsurance,
    required super.requiresPermit,
    required super.requiresFitness,
    required super.requiresPollution,
    required super.complianceMode,
    required super.documentRequirements,
    required super.status,
    required super.isDefaultType,
  });

  factory VehicleTypeModel.fromMap(Map<String, dynamic> map) {
    return VehicleTypeModel(
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      category: map['category'] as String? ?? 'Heavy Vehicle',
      vehicleClass: map['vehicleClass'] as String? ?? 'Dry Movers',
      ownershipTypes: (map['ownershipTypes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      vendorRequired: map['vendorRequired'] as bool? ?? false,
      loadType: map['loadType'] as String? ?? 'NON-PDO',
      transportType: map['transportType'] as String? ?? 'Internal',
      maxTripsPerDay: (map['maxTripsPerDay'] as num?)?.toInt() ?? 1,
      allowMultiDayJourney: map['allowMultiDayJourney'] as bool? ?? false,
      allowMultipleStops: map['allowMultipleStops'] as bool? ?? true,
      maxStopsAllowed: (map['maxStopsAllowed'] as num?)?.toInt() ?? 1,
      requireRoutePlanApproval:
          map['requireRoutePlanApproval'] as bool? ?? false,
      isHazardous: map['isHazardous'] as bool? ?? false,
      requiresSafetyCompliance:
          map['requiresSafetyCompliance'] as bool? ?? false,
      temperatureControlled: map['temperatureControlled'] as bool? ?? false,
      requiresEscortVehicle: map['requiresEscortVehicle'] as bool? ?? false,
      defaultCapacity: (map['defaultCapacity'] as num?)?.toDouble() ?? 0,
      capacityUnit: map['capacityUnit'] as String? ?? 'KG',
      features: (map['features'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      requiresInsurance: map['requiresInsurance'] as bool? ?? true,
      requiresPermit: map['requiresPermit'] as bool? ?? true,
      requiresFitness: map['requiresFitness'] as bool? ?? true,
      requiresPollution: map['requiresPollution'] as bool? ?? true,
      complianceMode: map['complianceMode'] as String? ?? 'NON-PDO',
      documentRequirements:
          _readDocumentRequirements(map['documentRequirements']),
      status: map['status'] as String? ?? 'Active',
      isDefaultType: map['isDefaultType'] as bool? ?? false,
    );
  }

  static List<VehicleTypeDocumentRequirement> _readDocumentRequirements(
    dynamic raw,
  ) {
    final list = raw as List<dynamic>? ?? const [];
    return list.map((entry) {
      final value = entry as Map<String, dynamic>;
      return VehicleTypeDocumentRequirement(
        documentName: value['documentName'] as String? ?? '',
        mandatory: value['mandatory'] as bool? ?? true,
        validityValue: (value['validityValue'] as num?)?.toInt() ?? 1,
        validityUnit: value['validityUnit'] as String? ?? 'Year',
        applicableFor: value['applicableFor'] as String? ?? 'All',
      );
    }).toList();
  }
}
