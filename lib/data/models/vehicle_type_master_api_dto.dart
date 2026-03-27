class VehicleTypeMasterUpsertRequestDto {
  const VehicleTypeMasterUpsertRequestDto({
    required this.vehicleTypeName,
    required this.vehicleCategory,
    required this.description,
    required this.seatingCapacity,
    required this.loadCapacity,
    required this.axleType,
    required this.bodyType,
    required this.fuelType,
    required this.transmissionType,
    required this.acType,
    required this.baseFarePerKm,
    required this.baseFarePerHour,
    required this.mileage,
    required this.maxTripDistance,
    required this.maxDrivingHoursPerDay,
    required this.status,
  });

  final String vehicleTypeName;
  final String vehicleCategory;
  final String description;
  final int seatingCapacity;
  final double loadCapacity;
  final String axleType;
  final String bodyType;
  final String fuelType;
  final String transmissionType;
  final String acType;
  final double baseFarePerKm;
  final double baseFarePerHour;
  final double mileage;
  final double? maxTripDistance;
  final double? maxDrivingHoursPerDay;
  final String status;

  Map<String, dynamic> toMap() {
    return {
      'vehicleTypeName': vehicleTypeName,
      'vehicleCategory': vehicleCategory,
      'description': description,
      'seatingCapacity': seatingCapacity,
      'loadCapacity': loadCapacity,
      'axleType': axleType,
      'bodyType': bodyType,
      'fuelType': fuelType,
      'transmissionType': transmissionType,
      'acType': acType,
      'baseFarePerKm': baseFarePerKm,
      'baseFarePerHour': baseFarePerHour,
      'mileage': mileage,
      'maxTripDistance': maxTripDistance,
      'maxDrivingHoursPerDay': maxDrivingHoursPerDay,
      'status': status,
    };
  }
}

class VehicleTypeMasterResponseDto extends VehicleTypeMasterUpsertRequestDto {
  const VehicleTypeMasterResponseDto({
    required this.vehicleTypeId,
    required super.vehicleTypeName,
    required super.vehicleCategory,
    required super.description,
    required super.seatingCapacity,
    required super.loadCapacity,
    required super.axleType,
    required super.bodyType,
    required super.fuelType,
    required super.transmissionType,
    required super.acType,
    required super.baseFarePerKm,
    required super.baseFarePerHour,
    required super.mileage,
    required super.maxTripDistance,
    required super.maxDrivingHoursPerDay,
    required super.status,
  });

  final String vehicleTypeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'vehicleTypeId': vehicleTypeId,
      ...super.toMap(),
    };
  }
}
