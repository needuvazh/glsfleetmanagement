enum VehicleCategoryType {
  passenger('Passenger'),
  goods('Goods');

  const VehicleCategoryType(this.label);
  final String label;
}

enum AxleType {
  axle4x2('4x2'),
  axle6x4('6x4'),
  axle8x4('8x4'),
  multiAxle('Multi Axle');

  const AxleType(this.label);
  final String label;
}

enum BodyType {
  flatbed('Flatbed'),
  tanker('Tanker'),
  box('Box'),
  tipper('Tipper'),
  busCoach('Bus Coach');

  const BodyType(this.label);
  final String label;
}

enum FuelType {
  diesel('Diesel'),
  petrol('Petrol'),
  ev('EV');

  const FuelType(this.label);
  final String label;
}

enum TransmissionType {
  manual('Manual'),
  automatic('Automatic');

  const TransmissionType(this.label);
  final String label;
}

enum AcType {
  ac('AC'),
  nonAc('Non-AC');

  const AcType(this.label);
  final String label;
}

enum RecordStatusType {
  active('Active'),
  inactive('Inactive');

  const RecordStatusType(this.label);
  final String label;
}

enum VehicleTypeDocumentType {
  rcTemplate('RC Template'),
  insuranceTemplate('Insurance Template'),
  permitFormat('Permit Format'),
  other('Other');

  const VehicleTypeDocumentType(this.label);
  final String label;
}

class VehicleTypeTemplateDocument {
  const VehicleTypeTemplateDocument({
    required this.documentId,
    required this.documentType,
    required this.documentName,
    required this.filePath,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.isMandatory,
  });

  final String documentId;
  final VehicleTypeDocumentType documentType;
  final String documentName;
  final String filePath;
  final DateTime uploadedAt;
  final String uploadedBy;
  final bool isMandatory;

  VehicleTypeTemplateDocument copyWith({
    String? documentId,
    VehicleTypeDocumentType? documentType,
    String? documentName,
    String? filePath,
    DateTime? uploadedAt,
    String? uploadedBy,
    bool? isMandatory,
  }) {
    return VehicleTypeTemplateDocument(
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      documentName: documentName ?? this.documentName,
      filePath: filePath ?? this.filePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isMandatory: isMandatory ?? this.isMandatory,
    );
  }
}

class VehicleTypeMasterModel {
  const VehicleTypeMasterModel({
    required this.vehicleTypeId,
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
    required this.documents,
    required this.status,
  });

  final String vehicleTypeId;
  final String vehicleTypeName;
  final VehicleCategoryType vehicleCategory;
  final String description;
  final int seatingCapacity;
  final double loadCapacity;
  final AxleType axleType;
  final BodyType bodyType;
  final FuelType fuelType;
  final TransmissionType transmissionType;
  final AcType acType;
  final double baseFarePerKm;
  final double baseFarePerHour;
  final double mileage;
  final double? maxTripDistance;
  final double? maxDrivingHoursPerDay;
  final List<VehicleTypeTemplateDocument> documents;
  final RecordStatusType status;

  bool get isPassenger => vehicleCategory == VehicleCategoryType.passenger;
  bool get isActive => status == RecordStatusType.active;
  String get capacityLabel =>
      isPassenger ? '$seatingCapacity seats' : '${loadCapacity.toStringAsFixed(1)} ton';

  VehicleTypeMasterModel copyWith({
    String? vehicleTypeId,
    String? vehicleTypeName,
    VehicleCategoryType? vehicleCategory,
    String? description,
    int? seatingCapacity,
    double? loadCapacity,
    AxleType? axleType,
    BodyType? bodyType,
    FuelType? fuelType,
    TransmissionType? transmissionType,
    AcType? acType,
    double? baseFarePerKm,
    double? baseFarePerHour,
    double? mileage,
    double? maxTripDistance,
    bool clearMaxTripDistance = false,
    double? maxDrivingHoursPerDay,
    bool clearMaxDrivingHoursPerDay = false,
    List<VehicleTypeTemplateDocument>? documents,
    RecordStatusType? status,
  }) {
    return VehicleTypeMasterModel(
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      description: description ?? this.description,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      loadCapacity: loadCapacity ?? this.loadCapacity,
      axleType: axleType ?? this.axleType,
      bodyType: bodyType ?? this.bodyType,
      fuelType: fuelType ?? this.fuelType,
      transmissionType: transmissionType ?? this.transmissionType,
      acType: acType ?? this.acType,
      baseFarePerKm: baseFarePerKm ?? this.baseFarePerKm,
      baseFarePerHour: baseFarePerHour ?? this.baseFarePerHour,
      mileage: mileage ?? this.mileage,
      maxTripDistance: clearMaxTripDistance
          ? null
          : (maxTripDistance ?? this.maxTripDistance),
      maxDrivingHoursPerDay: clearMaxDrivingHoursPerDay
          ? null
          : (maxDrivingHoursPerDay ?? this.maxDrivingHoursPerDay),
      documents: documents ?? this.documents,
      status: status ?? this.status,
    );
  }
}
