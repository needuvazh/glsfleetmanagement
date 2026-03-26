enum CargoStatus {
  active('Active'),
  inactive('Inactive');

  const CargoStatus(this.label);
  final String label;
}

enum CargoRiskLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const CargoRiskLevel(this.label);
  final String label;
}

class CargoModel {
  const CargoModel({
    required this.cargoCode,
    required this.cargoName,
    required this.category,
    required this.subcategory,
    required this.status,
    required this.standardWeightRange,
    required this.length,
    required this.width,
    required this.height,
    required this.volumeSizeClass,
    required this.oversized,
    required this.riskLevel,
    required this.hazardous,
    required this.fragile,
    required this.temperatureSensitive,
    required this.specialHandlingRequired,
    required this.riskNotes,
    required this.preferredVehicleType,
    required this.preferredTrailerType,
    required this.loadingMethod,
    required this.unloadingMethod,
    required this.lashingRequired,
    required this.escortRequired,
    required this.specialEquipmentRequired,
    required this.handlingInstructions,
    required this.specialComplianceRequired,
    required this.requiredCertifications,
    required this.requiredPermits,
    required this.authorityApprovalNeeded,
    required this.customerIndustryRestrictions,
    required this.complianceNotes,
    required this.inspectionRequired,
    required this.inspectionTemplateType,
    required this.preDispatchInspectionRequired,
    required this.inTransitCheckRequired,
    required this.postDeliveryCheckRequired,
    required this.photoEvidenceMandatory,
    required this.videoEvidenceMandatory,
    required this.inspectionNotes,
    required this.restricted,
    required this.restrictionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  final String cargoCode;
  final String cargoName;
  final String category;
  final String subcategory;
  final CargoStatus status;

  final String standardWeightRange;
  final double? length;
  final double? width;
  final double? height;
  final String volumeSizeClass;
  final bool oversized;

  final CargoRiskLevel riskLevel;
  final bool hazardous;
  final bool fragile;
  final bool temperatureSensitive;
  final bool specialHandlingRequired;
  final String riskNotes;

  final String preferredVehicleType;
  final String preferredTrailerType;
  final String loadingMethod;
  final String unloadingMethod;
  final bool lashingRequired;
  final bool escortRequired;
  final String specialEquipmentRequired;
  final String handlingInstructions;

  final bool specialComplianceRequired;
  final List<String> requiredCertifications;
  final List<String> requiredPermits;
  final bool authorityApprovalNeeded;
  final String customerIndustryRestrictions;
  final String complianceNotes;

  final bool inspectionRequired;
  final String inspectionTemplateType;
  final bool preDispatchInspectionRequired;
  final bool inTransitCheckRequired;
  final bool postDeliveryCheckRequired;
  final bool photoEvidenceMandatory;
  final bool videoEvidenceMandatory;
  final String inspectionNotes;

  final bool restricted;
  final String restrictionReason;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSelectable => status == CargoStatus.active && !restricted;

  CargoModel copyWith({
    String? cargoCode,
    String? cargoName,
    String? category,
    String? subcategory,
    CargoStatus? status,
    String? standardWeightRange,
    double? length,
    bool clearLength = false,
    double? width,
    bool clearWidth = false,
    double? height,
    bool clearHeight = false,
    String? volumeSizeClass,
    bool? oversized,
    CargoRiskLevel? riskLevel,
    bool? hazardous,
    bool? fragile,
    bool? temperatureSensitive,
    bool? specialHandlingRequired,
    String? riskNotes,
    String? preferredVehicleType,
    String? preferredTrailerType,
    String? loadingMethod,
    String? unloadingMethod,
    bool? lashingRequired,
    bool? escortRequired,
    String? specialEquipmentRequired,
    String? handlingInstructions,
    bool? specialComplianceRequired,
    List<String>? requiredCertifications,
    List<String>? requiredPermits,
    bool? authorityApprovalNeeded,
    String? customerIndustryRestrictions,
    String? complianceNotes,
    bool? inspectionRequired,
    String? inspectionTemplateType,
    bool? preDispatchInspectionRequired,
    bool? inTransitCheckRequired,
    bool? postDeliveryCheckRequired,
    bool? photoEvidenceMandatory,
    bool? videoEvidenceMandatory,
    String? inspectionNotes,
    bool? restricted,
    String? restrictionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CargoModel(
      cargoCode: cargoCode ?? this.cargoCode,
      cargoName: cargoName ?? this.cargoName,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      status: status ?? this.status,
      standardWeightRange: standardWeightRange ?? this.standardWeightRange,
      length: clearLength ? null : (length ?? this.length),
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      volumeSizeClass: volumeSizeClass ?? this.volumeSizeClass,
      oversized: oversized ?? this.oversized,
      riskLevel: riskLevel ?? this.riskLevel,
      hazardous: hazardous ?? this.hazardous,
      fragile: fragile ?? this.fragile,
      temperatureSensitive: temperatureSensitive ?? this.temperatureSensitive,
      specialHandlingRequired:
          specialHandlingRequired ?? this.specialHandlingRequired,
      riskNotes: riskNotes ?? this.riskNotes,
      preferredVehicleType: preferredVehicleType ?? this.preferredVehicleType,
      preferredTrailerType: preferredTrailerType ?? this.preferredTrailerType,
      loadingMethod: loadingMethod ?? this.loadingMethod,
      unloadingMethod: unloadingMethod ?? this.unloadingMethod,
      lashingRequired: lashingRequired ?? this.lashingRequired,
      escortRequired: escortRequired ?? this.escortRequired,
      specialEquipmentRequired:
          specialEquipmentRequired ?? this.specialEquipmentRequired,
      handlingInstructions: handlingInstructions ?? this.handlingInstructions,
      specialComplianceRequired:
          specialComplianceRequired ?? this.specialComplianceRequired,
      requiredCertifications:
          requiredCertifications ?? this.requiredCertifications,
      requiredPermits: requiredPermits ?? this.requiredPermits,
      authorityApprovalNeeded:
          authorityApprovalNeeded ?? this.authorityApprovalNeeded,
      customerIndustryRestrictions:
          customerIndustryRestrictions ?? this.customerIndustryRestrictions,
      complianceNotes: complianceNotes ?? this.complianceNotes,
      inspectionRequired: inspectionRequired ?? this.inspectionRequired,
      inspectionTemplateType:
          inspectionTemplateType ?? this.inspectionTemplateType,
      preDispatchInspectionRequired:
          preDispatchInspectionRequired ?? this.preDispatchInspectionRequired,
      inTransitCheckRequired:
          inTransitCheckRequired ?? this.inTransitCheckRequired,
      postDeliveryCheckRequired:
          postDeliveryCheckRequired ?? this.postDeliveryCheckRequired,
      photoEvidenceMandatory:
          photoEvidenceMandatory ?? this.photoEvidenceMandatory,
      videoEvidenceMandatory:
          videoEvidenceMandatory ?? this.videoEvidenceMandatory,
      inspectionNotes: inspectionNotes ?? this.inspectionNotes,
      restricted: restricted ?? this.restricted,
      restrictionReason: restrictionReason ?? this.restrictionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
