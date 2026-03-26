import '../../domain/entities/logistics_flow.dart';

class CustomerRequestModel extends CustomerRequestData {
  const CustomerRequestModel({
    required super.enquiryNumber,
    required super.requestSource,
    required super.customerName,
    required super.requestType,
    required super.emailOrReference,
    required super.contact,
    required super.cargoType,
    required super.weightVolume,
    required super.pickup,
    required super.delivery,
    required super.requestDate,
    required super.notes,
    required super.hazardous,
    required super.pdoSpec,
    required super.route,
    required super.routeMasterId,
    required super.routeCode,
    required super.routeName,
    required super.routeRiskLevel,
    required super.routeOperationalStatus,
    required super.routeRestricted,
    required super.routeRestrictionReason,
    required super.quantity,
    required super.dimensions,
    required super.customerSpecificRequirement,
    required super.requiredVehicleType,
    required super.tentativeDispatchDate,
    required super.routeRiskFlag,
    required super.hazardousComplianceRequired,
    required super.status,
    required super.cancellationReason,
    super.feasibilityStatus = 'Pending',
    super.feasibilityRiskLevel = 'Low',
    super.estimatedCost = 0.0,
    super.paymentTerms = '',
    super.creditCheckStatus = 'Pending',
    super.feasibilityRemarks = '',
    super.vehicleSuitability = '',
    super.routeSuitability = '',
    super.manpowerReadiness = '',
    super.reviewedBy = '',
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerRequestModel.fromMap(Map<String, dynamic> map) {
    final pickup =
        map['pickup'] as String? ?? map['pickupLocation'] as String? ?? '';
    final drop = map['delivery'] as String? ?? map['drop'] as String? ?? '';
    final weightRaw = map['weightVolume'] ?? map['weight'];
    final requestDate =
        map['requestDate'] as String? ?? map['date'] as String? ?? '2026-03-24';
    final createdAtRaw = map['createdAt'] as String?;
    final updatedAtRaw = map['updatedAt'] as String?;
    final parsedCreatedAt =
        DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();
    final parsedUpdatedAt =
        DateTime.tryParse(updatedAtRaw ?? '') ?? parsedCreatedAt;

    return CustomerRequestModel(
      enquiryNumber: map['enquiryNumber'] as String? ??
          map['requestId'] as String? ??
          'ENQ-${DateTime.now().millisecondsSinceEpoch % 100000}',
      requestSource: map['requestSource'] as String? ??
          map['clientType'] as String? ??
          'Phone',
      customerName:
          map['customerName'] as String? ?? map['clientName'] as String? ?? '',
      requestType: map['requestType'] as String? ?? 'Transport Request',
      emailOrReference: map['emailOrReference'] as String? ??
          map['requestId'] as String? ??
          '',
      contact: map['contact'] as String? ?? '+968-00000000',
      cargoType: map['cargoType'] as String? ?? map['cargo'] as String? ?? '',
      weightVolume: weightRaw == null ? '' : weightRaw.toString(),
      pickup: pickup,
      delivery: drop,
      requestDate: requestDate,
      notes: map['notes'] as String? ?? map['remarks'] as String? ?? '',
      hazardous: map['hazardous'] as bool? ?? false,
      pdoSpec: map['pdoSpec'] as String? ??
          map['clientType'] as String? ??
          'Non-PDO',
      route: map['route'] as String? ?? '${pickup.trim()} -> ${drop.trim()}',
      routeMasterId: map['routeMasterId'] as String? ?? '',
      routeCode: map['routeCode'] as String? ?? '',
      routeName: map['routeName'] as String? ?? '',
      routeRiskLevel: map['routeRiskLevel'] as String? ?? 'Low',
      routeOperationalStatus:
          map['routeOperationalStatus'] as String? ?? 'Active',
      routeRestricted: map['routeRestricted'] as bool? ?? false,
      routeRestrictionReason: map['routeRestrictionReason'] as String? ?? '',
      quantity: map['quantity']?.toString() ?? '',
      dimensions: map['dimensions'] as String? ?? '',
      customerSpecificRequirement:
          map['customerSpecificRequirement'] as String? ?? '',
      requiredVehicleType: map['requiredVehicleType'] as String? ?? '',
      tentativeDispatchDate: map['tentativeDispatchDate'] as String? ?? '',
      routeRiskFlag: map['routeRiskFlag'] as bool? ?? false,
      hazardousComplianceRequired:
          map['hazardousComplianceRequired'] as bool? ??
              (map['hazardous'] as bool? ?? false),
      status: map['status'] as String? ?? 'New Enquiry',
      cancellationReason: map['cancellationReason'] as String? ?? '',
      feasibilityStatus: map['feasibilityStatus'] as String? ?? 'Pending',
      feasibilityRiskLevel: map['feasibilityRiskLevel'] as String? ?? 'Low',
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      paymentTerms: map['paymentTerms'] as String? ?? '',
      creditCheckStatus: map['creditCheckStatus'] as String? ?? 'Pending',
      feasibilityRemarks: map['feasibilityRemarks'] as String? ?? '',
      vehicleSuitability: map['vehicleSuitability'] as String? ?? '',
      routeSuitability: map['routeSuitability'] as String? ?? '',
      manpowerReadiness: map['manpowerReadiness'] as String? ?? '',
      reviewedBy: map['reviewedBy'] as String? ?? '',
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }
}

class WorkOrderFlowModel extends WorkOrderFlowItem {
  const WorkOrderFlowModel({
    required super.woId,
    required super.customer,
    required super.route,
    required super.cargo,
    required super.status,
    required super.linkedQuotationRef,
    required super.linkedEnquiryNumber,
    required super.routeMasterId,
    required super.routeCode,
    required super.routeName,
    required super.routeRiskLevel,
    required super.routeOperationalStatus,
    required super.routeRestricted,
    required super.routeRestrictionReason,
    required super.customerPoReference,
    required super.jobFileReference,
    required super.serviceStartDate,
    required super.serviceEndDate,
    required super.internalNotes,
  });

  factory WorkOrderFlowModel.fromMap(Map<String, dynamic> map) {
    final route = map['route'] as String? ?? '';
    final requestId = map['requestId'] as String? ?? '';
    return WorkOrderFlowModel(
      woId: map['woId'] as String? ?? map['id'] as String? ?? '',
      customer: map['customer'] as String? ?? map['client'] as String? ?? '',
      route: route,
      cargo: map['cargo'] as String? ?? requestId,
      status: map['status'] as String? ?? '',
      linkedQuotationRef: map['linkedQuotationRef'] as String? ?? '',
      linkedEnquiryNumber: map['linkedEnquiryNumber'] as String? ??
          map['requestId'] as String? ??
          '',
      routeMasterId: map['routeMasterId'] as String? ?? '',
      routeCode: map['routeCode'] as String? ?? '',
      routeName: map['routeName'] as String? ?? '',
      routeRiskLevel: map['routeRiskLevel'] as String? ?? 'Low',
      routeOperationalStatus:
          map['routeOperationalStatus'] as String? ?? 'Active',
      routeRestricted: map['routeRestricted'] as bool? ?? false,
      routeRestrictionReason: map['routeRestrictionReason'] as String? ?? '',
      customerPoReference: map['customerPoReference'] as String? ?? '',
      jobFileReference: map['jobFileReference'] as String? ?? '',
      serviceStartDate: map['serviceStartDate'] as String? ?? '',
      serviceEndDate: map['serviceEndDate'] as String? ?? '',
      internalNotes: map['internalNotes'] as String? ?? '',
    );
  }
}

class QuotationModel extends QuotationData {
  const QuotationModel({
    required super.quoteRef,
    required super.enquiryRef,
    required super.customer,
    required super.date,
    required super.validityDate,
    required super.rate,
    required super.costSummary,
    required super.terms,
    required super.remarks,
    required super.status,
    super.decisionResponseDate,
    super.customerPoRef,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
  });

  factory QuotationModel.fromMap(Map<String, dynamic> map) {
    return QuotationModel(
      quoteRef: map['quoteRef'] as String? ?? '',
      enquiryRef: map['enquiryRef'] as String? ?? map['enquiryNumber'] as String? ?? '',
      customer: map['customer'] as String? ?? '',
      date: map['date'] as String? ?? '',
      validityDate: map['validityDate'] as String? ?? '',
      rate: (map['rate'] as num?)?.toDouble() ?? 0,
      costSummary: map['costSummary'] as String? ?? '',
      terms: map['terms'] as String? ?? '',
      remarks: map['remarks'] as String? ?? '',
      status: map['status'] as String? ?? 'Draft',
      decisionResponseDate: map['decisionResponseDate'] as String? ?? '',
      customerPoRef: map['customerPoRef'] as String? ?? '',
      rejectionReason: map['rejectionReason'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class FleetVehicleModel extends FleetVehicleData {
  const FleetVehicleModel({
    required super.vehicleNo,
    required super.type,
    required super.capacity,
    required super.fuelType,
    required super.ivmsDeviceId,
    required super.status,
    required super.permits,
  });

  factory FleetVehicleModel.fromMap(Map<String, dynamic> map) {
    final vehicleNo =
        map['vehicleNo'] as String? ?? map['vehicleNumber'] as String? ?? '';
    final type = map['type'] as String? ?? map['vehicleClass'] as String? ?? '';
    return FleetVehicleModel(
      vehicleNo: vehicleNo,
      type: type,
      capacity: map['capacity'] as String? ?? 'N/A',
      fuelType: map['fuelType'] as String? ?? 'Diesel',
      ivmsDeviceId: map['ivmsDeviceId'] as String? ??
          'IVMS-${vehicleNo.replaceAll(' ', '-')}',
      status: map['status'] as String? ?? '',
      permits: (map['permits'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
    );
  }
}

class DriverModel extends DriverData {
  const DriverModel({
    required super.driverId,
    required super.name,
    required super.employeeRef,
    required super.licenseNo,
    required super.licenseType,
    required super.licenseIssueDate,
    required super.expiryDate,
    required super.heavyVehicleAllowed,
    required super.specialEndorsementNotes,
    required super.phone,
    required super.nationality,
    required super.baseLocation,
    required super.experience,
    required super.dfmsDeviceId,
    required super.status,
    required super.active,
    required super.assignmentAllowed,
    required super.dispatchAllowed,
    required super.dispatchBlocked,
    required super.blockReason,
    required super.onLeave,
    required super.suspended,
    required super.suspensionReason,
    required super.currentAssignmentStatus,
    required super.currentWorkOrder,
    required super.currentLocation,
    required super.allowedVehicleTypes,
    required super.longHaulAllowed,
    required super.nightDrivingAllowed,
    required super.hazardousCargoAllowed,
    required super.oilfieldAllowed,
    required super.routeRestrictions,
    required super.specialSkillsNotes,
    required super.pdoPassportStatus,
    required super.defensiveDrivingStatus,
    required super.h2sStatus,
    required super.ftwStatus,
    required super.complianceNotes,
    required super.medicalFitnessNote,
    required super.safetyIncidentFlag,
    required super.incidentCount,
    required super.disciplinaryNote,
    required super.temporaryRestrictionNote,
    required super.preferredRegion,
    required super.preferredRouteType,
    required super.preferredVehicleType,
    required super.preferredCargoType,
    required super.specialAssignmentNotes,
    required super.certifications,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    final allowedVehicleTypes =
        (map['allowedVehicleTypes'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList();

    return DriverModel(
      driverId: map['driverId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      employeeRef: map['employeeRef'] as String? ?? '',
      licenseNo: map['licenseNo'] as String? ?? '',
      licenseType: map['licenseType'] as String? ?? 'Light Vehicle',
      licenseIssueDate: map['licenseIssueDate'] as String? ?? '',
      expiryDate: map['expiryDate'] as String? ?? '',
      heavyVehicleAllowed: map['heavyVehicleAllowed'] as bool? ?? false,
      specialEndorsementNotes: map['specialEndorsementNotes'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      nationality: map['nationality'] as String? ?? 'Omani',
      baseLocation: map['baseLocation'] as String? ?? 'Muscat',
      experience: (map['experience'] as num?)?.toInt() ?? 0,
      dfmsDeviceId: map['dfmsDeviceId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      active: map['active'] as bool? ?? true,
      assignmentAllowed: map['assignmentAllowed'] as bool? ?? true,
      dispatchAllowed: map['dispatchAllowed'] as bool? ?? true,
      dispatchBlocked: map['dispatchBlocked'] as bool? ?? false,
      blockReason: map['blockReason'] as String? ?? '',
      onLeave: map['onLeave'] as bool? ?? false,
      suspended: map['suspended'] as bool? ?? false,
      suspensionReason: map['suspensionReason'] as String? ?? '',
      currentAssignmentStatus:
          map['currentAssignmentStatus'] as String? ?? 'Unassigned',
      currentWorkOrder: map['currentWorkOrder'] as String? ?? '',
      currentLocation: map['currentLocation'] as String? ?? 'Muscat',
      allowedVehicleTypes: allowedVehicleTypes,
      longHaulAllowed: map['longHaulAllowed'] as bool? ?? true,
      nightDrivingAllowed: map['nightDrivingAllowed'] as bool? ?? true,
      hazardousCargoAllowed: map['hazardousCargoAllowed'] as bool? ?? false,
      oilfieldAllowed: map['oilfieldAllowed'] as bool? ?? false,
      routeRestrictions: map['routeRestrictions'] as String? ?? '',
      specialSkillsNotes: map['specialSkillsNotes'] as String? ?? '',
      pdoPassportStatus: map['pdoPassportStatus'] as String? ?? 'Not Required',
      defensiveDrivingStatus:
          map['defensiveDrivingStatus'] as String? ?? 'Not Required',
      h2sStatus: map['h2sStatus'] as String? ?? 'Not Required',
      ftwStatus: map['ftwStatus'] as String? ?? 'Not Required',
      complianceNotes: map['complianceNotes'] as String? ?? '',
      medicalFitnessNote: map['medicalFitnessNote'] as String? ?? '',
      safetyIncidentFlag: map['safetyIncidentFlag'] as bool? ?? false,
      incidentCount: (map['incidentCount'] as num?)?.toInt() ?? 0,
      disciplinaryNote: map['disciplinaryNote'] as String? ?? '',
      temporaryRestrictionNote:
          map['temporaryRestrictionNote'] as String? ?? '',
      preferredRegion: map['preferredRegion'] as String? ?? '',
      preferredRouteType: map['preferredRouteType'] as String? ?? '',
      preferredVehicleType: map['preferredVehicleType'] as String? ?? '',
      preferredCargoType: map['preferredCargoType'] as String? ?? '',
      specialAssignmentNotes: map['specialAssignmentNotes'] as String? ?? '',
      certifications:
          (map['certifications'] as List<dynamic>? ?? const <dynamic>[])
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(),
    );
  }
}

class JourneyMasterModel extends JourneyMasterData {
  const JourneyMasterModel({
    required super.journeyId,
    required super.planName,
    required super.origin,
    required super.destination,
    required super.stops,
    required super.restPoints,
  });

  factory JourneyMasterModel.fromMap(Map<String, dynamic> map) {
    final route = (map['route'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();
    final stops = (map['stops'] as List<dynamic>? ?? route)
        .map((item) => item.toString())
        .toList();

    final restPoints =
        (map['restPoints'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList();

    final origin =
        map['origin'] as String? ?? (route.isNotEmpty ? route.first : '');
    final destination =
        map['destination'] as String? ?? (route.isNotEmpty ? route.last : '');
    final planName = map['planName'] as String? ??
        '${origin.isEmpty ? 'Origin' : origin} to ${destination.isEmpty ? 'Destination' : destination}';

    return JourneyMasterModel(
      journeyId: map['journeyId'] as String? ?? map['id'] as String? ?? '',
      planName: planName,
      origin: origin,
      destination: destination,
      stops: stops,
      restPoints: restPoints.isEmpty
          ? (stops.length > 1 ? [stops[1]] : const <String>[])
          : restPoints,
    );
  }
}

class IvmsModel extends IvmsData {
  const IvmsModel({
    required super.vehicleId,
    required super.lat,
    required super.lng,
    required super.speed,
    required super.fuelLevel,
    required super.distanceCovered,
    required super.status,
  });

  factory IvmsModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;
    return IvmsModel(
      vehicleId: map['vehicleId'] as String? ?? '',
      lat: (map['lat'] as num?)?.toDouble() ??
          (location?['lat'] as num?)?.toDouble() ??
          0,
      lng: (map['lng'] as num?)?.toDouble() ??
          (location?['lng'] as num?)?.toDouble() ??
          0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0,
      fuelLevel: (map['fuelLevel'] as num?)?.toDouble() ?? 0,
      distanceCovered: (map['distanceCovered'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? '',
    );
  }
}

class DfmsModel extends DfmsData {
  const DfmsModel({
    required super.driverId,
    required super.fatigueLevel,
    required super.eyeClosureRate,
    required super.drivingHours,
    required super.alert,
  });

  factory DfmsModel.fromMap(Map<String, dynamic> map) {
    return DfmsModel(
      driverId: map['driverId'] as String? ?? '',
      fatigueLevel: map['fatigueLevel'] as String? ?? '',
      eyeClosureRate: (map['eyeClosureRate'] as num?)?.toDouble() ?? 0,
      drivingHours: (map['drivingHours'] as num?)?.toDouble() ?? 0,
      alert: map['alert'] as String? ?? '',
    );
  }
}
