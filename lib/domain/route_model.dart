import 'location_model.dart';

enum RouteRiskLevel { low, medium, high, critical }

extension RouteRiskLevelX on RouteRiskLevel {
  String get label {
    switch (this) {
      case RouteRiskLevel.low:
        return 'Low';
      case RouteRiskLevel.medium:
        return 'Medium';
      case RouteRiskLevel.high:
        return 'High';
      case RouteRiskLevel.critical:
        return 'Critical';
    }
  }
}

enum RouteOperationalStatus { active, inactive, restricted }

extension RouteOperationalStatusX on RouteOperationalStatus {
  String get label {
    switch (this) {
      case RouteOperationalStatus.active:
        return 'Active';
      case RouteOperationalStatus.inactive:
        return 'Inactive';
      case RouteOperationalStatus.restricted:
        return 'Restricted';
    }
  }
}

enum RouteStopType {
  rest,
  fuel,
  checkpoint,
  toll,
  customer,
  other,
}

extension RouteStopTypeX on RouteStopType {
  String get label {
    switch (this) {
      case RouteStopType.rest:
        return 'Rest Stop';
      case RouteStopType.fuel:
        return 'Fuel';
      case RouteStopType.checkpoint:
        return 'Checkpoint';
      case RouteStopType.toll:
        return 'Toll';
      case RouteStopType.customer:
        return 'Customer';
      case RouteStopType.other:
        return 'Other';
    }
  }
}

class RouteStopModel {
  const RouteStopModel({
    required this.location,
    required this.type,
    this.note = '',
  });

  final LocationModel location;
  final RouteStopType type;
  final String note;

  RouteStopModel copyWith({
    LocationModel? location,
    RouteStopType? type,
    String? note,
  }) {
    return RouteStopModel(
      location: location ?? this.location,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }
}

class RouteLocationModel {
  const RouteLocationModel({
    required this.routeId,
    required this.routeCode,
    required this.routeName,
    required this.startLocation,
    required this.endLocation,
    required this.stopPoints,
    required this.estimatedTime,
    required this.distanceKm,
    required this.region,
    required this.riskLevel,
    required this.status,
    required this.customerSpecific,
    required this.expectedStops,
    required this.standardRestPoints,
    required this.standardStartWindow,
    required this.standardDeliveryWindow,
    required this.nightDrivingAllowed,
    required this.restrictedSegments,
    required this.weatherSensitive,
    required this.routeNotes,
    required this.preferredVehicleType,
    required this.trailerTypePreference,
    required this.escortRequired,
    required this.specialHandlingNotes,
    required this.alternateRouteAvailable,
    required this.specialComplianceRequired,
    required this.safetyInstructions,
    required this.customerAuthorityRestrictions,
    required this.permitRequirement,
    required this.requiredDocuments,
    required this.temporarilyRestricted,
    required this.restrictionReason,
  });

  final String routeId;
  final String routeCode;
  final String routeName;
  final LocationModel startLocation;
  final LocationModel endLocation;
  final List<RouteStopModel> stopPoints;
  final String estimatedTime;
  final double distanceKm;
  final String region;
  final RouteRiskLevel riskLevel;
  final RouteOperationalStatus status;
  final bool customerSpecific;
  final int expectedStops;
  final List<String> standardRestPoints;
  final String standardStartWindow;
  final String standardDeliveryWindow;
  final bool nightDrivingAllowed;
  final String restrictedSegments;
  final bool weatherSensitive;
  final String routeNotes;
  final String preferredVehicleType;
  final String trailerTypePreference;
  final bool escortRequired;
  final String specialHandlingNotes;
  final bool alternateRouteAvailable;
  final bool specialComplianceRequired;
  final String safetyInstructions;
  final String customerAuthorityRestrictions;
  final String permitRequirement;
  final List<String> requiredDocuments;
  final bool temporarilyRestricted;
  final String restrictionReason;

  List<LocationModel> get stops => [
        for (final stop in stopPoints) stop.location,
      ];

  int get stopsCount => stopPoints.length;

  bool get isSelectableForNewOperations =>
      status == RouteOperationalStatus.active && !temporarilyRestricted;

  RouteLocationModel copyWith({
    String? routeId,
    String? routeCode,
    String? routeName,
    LocationModel? startLocation,
    LocationModel? endLocation,
    List<RouteStopModel>? stopPoints,
    String? estimatedTime,
    double? distanceKm,
    String? region,
    RouteRiskLevel? riskLevel,
    RouteOperationalStatus? status,
    bool? customerSpecific,
    int? expectedStops,
    List<String>? standardRestPoints,
    String? standardStartWindow,
    String? standardDeliveryWindow,
    bool? nightDrivingAllowed,
    String? restrictedSegments,
    bool? weatherSensitive,
    String? routeNotes,
    String? preferredVehicleType,
    String? trailerTypePreference,
    bool? escortRequired,
    String? specialHandlingNotes,
    bool? alternateRouteAvailable,
    bool? specialComplianceRequired,
    String? safetyInstructions,
    String? customerAuthorityRestrictions,
    String? permitRequirement,
    List<String>? requiredDocuments,
    bool? temporarilyRestricted,
    String? restrictionReason,
  }) {
    return RouteLocationModel(
      routeId: routeId ?? this.routeId,
      routeCode: routeCode ?? this.routeCode,
      routeName: routeName ?? this.routeName,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      stopPoints: stopPoints ?? this.stopPoints,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      distanceKm: distanceKm ?? this.distanceKm,
      region: region ?? this.region,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      customerSpecific: customerSpecific ?? this.customerSpecific,
      expectedStops: expectedStops ?? this.expectedStops,
      standardRestPoints: standardRestPoints ?? this.standardRestPoints,
      standardStartWindow: standardStartWindow ?? this.standardStartWindow,
      standardDeliveryWindow:
          standardDeliveryWindow ?? this.standardDeliveryWindow,
      nightDrivingAllowed: nightDrivingAllowed ?? this.nightDrivingAllowed,
      restrictedSegments: restrictedSegments ?? this.restrictedSegments,
      weatherSensitive: weatherSensitive ?? this.weatherSensitive,
      routeNotes: routeNotes ?? this.routeNotes,
      preferredVehicleType: preferredVehicleType ?? this.preferredVehicleType,
      trailerTypePreference:
          trailerTypePreference ?? this.trailerTypePreference,
      escortRequired: escortRequired ?? this.escortRequired,
      specialHandlingNotes: specialHandlingNotes ?? this.specialHandlingNotes,
      alternateRouteAvailable:
          alternateRouteAvailable ?? this.alternateRouteAvailable,
      specialComplianceRequired:
          specialComplianceRequired ?? this.specialComplianceRequired,
      safetyInstructions: safetyInstructions ?? this.safetyInstructions,
      customerAuthorityRestrictions:
          customerAuthorityRestrictions ?? this.customerAuthorityRestrictions,
      permitRequirement: permitRequirement ?? this.permitRequirement,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      temporarilyRestricted:
          temporarilyRestricted ?? this.temporarilyRestricted,
      restrictionReason: restrictionReason ?? this.restrictionReason,
    );
  }
}
