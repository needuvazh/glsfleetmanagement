class DashboardSnapshot {
  const DashboardSnapshot({
    required this.totalOrders,
    required this.activeTrips,
    required this.delayedTrips,
    required this.fleetAvailable,
    required this.driverAlerts,
  });

  final int totalOrders;
  final int activeTrips;
  final int delayedTrips;
  final int fleetAvailable;
  final int driverAlerts;
}

class CustomerRequestData {
  const CustomerRequestData({
    required this.enquiryNumber,
    required this.requestSource,
    required this.customerName,
    required this.requestType,
    required this.emailOrReference,
    required this.contact,
    required this.cargoType,
    required this.weightVolume,
    required this.pickup,
    required this.delivery,
    required this.requestDate,
    this.notes = '',
    this.hazardous = false,
    this.pdoSpec = 'Non-PDO',
    this.route = '',
    this.routeMasterId = '',
    this.routeCode = '',
    this.routeName = '',
    this.routeRiskLevel = 'Low',
    this.routeOperationalStatus = 'Active',
    this.routeRestricted = false,
    this.routeRestrictionReason = '',
    this.quantity = '',
    this.dimensions = '',
    this.customerSpecificRequirement = '',
    this.requiredVehicleType = '',
    this.tentativeDispatchDate = '',
    this.routeRiskFlag = false,
    this.hazardousComplianceRequired = false,
    this.status = 'New Enquiry',
    this.cancellationReason = '',
    this.feasibilityStatus = 'Pending',
    this.feasibilityRiskLevel = 'Low',
    this.estimatedCost = 0.0,
    this.paymentTerms = '',
    this.creditCheckStatus = 'Pending',
    this.feasibilityRemarks = '',
    this.vehicleSuitability = '',
    this.routeSuitability = '',
    this.manpowerReadiness = '',
    this.reviewedBy = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String enquiryNumber;
  final String requestSource;
  final String customerName;
  final String requestType;
  final String emailOrReference;
  final String contact;
  final String cargoType;
  final String weightVolume;
  final String pickup;
  final String delivery;
  final String requestDate;
  final String notes;
  final bool hazardous;
  final String pdoSpec;
  final String route;
  final String routeMasterId;
  final String routeCode;
  final String routeName;
  final String routeRiskLevel;
  final String routeOperationalStatus;
  final bool routeRestricted;
  final String routeRestrictionReason;
  final String quantity;
  final String dimensions;
  final String customerSpecificRequirement;
  final String requiredVehicleType;
  final String tentativeDispatchDate;
  final bool routeRiskFlag;
  final bool hazardousComplianceRequired;
  final String status;
  final String cancellationReason;
  final String feasibilityStatus; // Pending, Feasible, Not Feasible
  final String feasibilityRiskLevel; // Low, Medium, High, Critical
  final double estimatedCost;
  final String paymentTerms;
  final String creditCheckStatus;
  final String feasibilityRemarks;
  final String vehicleSuitability;
  final String routeSuitability;
  final String manpowerReadiness;
  final String reviewedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get date => requestDate;

  CustomerRequestData copyWith({
    String? enquiryNumber,
    String? requestSource,
    String? customerName,
    String? requestType,
    String? emailOrReference,
    String? contact,
    String? cargoType,
    String? weightVolume,
    String? pickup,
    String? delivery,
    String? requestDate,
    String? notes,
    bool? hazardous,
    String? pdoSpec,
    String? route,
    String? routeMasterId,
    String? routeCode,
    String? routeName,
    String? routeRiskLevel,
    String? routeOperationalStatus,
    bool? routeRestricted,
    String? routeRestrictionReason,
    String? quantity,
    String? dimensions,
    String? customerSpecificRequirement,
    String? requiredVehicleType,
    String? tentativeDispatchDate,
    bool? routeRiskFlag,
    bool? hazardousComplianceRequired,
    String? status,
    String? cancellationReason,
    String? feasibilityStatus,
    String? feasibilityRiskLevel,
    double? estimatedCost,
    String? paymentTerms,
    String? creditCheckStatus,
    String? feasibilityRemarks,
    String? vehicleSuitability,
    String? routeSuitability,
    String? manpowerReadiness,
    String? reviewedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerRequestData(
      enquiryNumber: enquiryNumber ?? this.enquiryNumber,
      requestSource: requestSource ?? this.requestSource,
      customerName: customerName ?? this.customerName,
      requestType: requestType ?? this.requestType,
      emailOrReference: emailOrReference ?? this.emailOrReference,
      contact: contact ?? this.contact,
      cargoType: cargoType ?? this.cargoType,
      weightVolume: weightVolume ?? this.weightVolume,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      requestDate: requestDate ?? this.requestDate,
      notes: notes ?? this.notes,
      hazardous: hazardous ?? this.hazardous,
      pdoSpec: pdoSpec ?? this.pdoSpec,
      route: route ?? this.route,
      routeMasterId: routeMasterId ?? this.routeMasterId,
      routeCode: routeCode ?? this.routeCode,
      routeName: routeName ?? this.routeName,
      routeRiskLevel: routeRiskLevel ?? this.routeRiskLevel,
      routeOperationalStatus:
          routeOperationalStatus ?? this.routeOperationalStatus,
      routeRestricted: routeRestricted ?? this.routeRestricted,
      routeRestrictionReason:
          routeRestrictionReason ?? this.routeRestrictionReason,
      quantity: quantity ?? this.quantity,
      dimensions: dimensions ?? this.dimensions,
      customerSpecificRequirement:
          customerSpecificRequirement ?? this.customerSpecificRequirement,
      requiredVehicleType: requiredVehicleType ?? this.requiredVehicleType,
      tentativeDispatchDate:
          tentativeDispatchDate ?? this.tentativeDispatchDate,
      routeRiskFlag: routeRiskFlag ?? this.routeRiskFlag,
      hazardousComplianceRequired:
          hazardousComplianceRequired ?? this.hazardousComplianceRequired,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      feasibilityStatus: feasibilityStatus ?? this.feasibilityStatus,
      feasibilityRiskLevel: feasibilityRiskLevel ?? this.feasibilityRiskLevel,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditCheckStatus: creditCheckStatus ?? this.creditCheckStatus,
      feasibilityRemarks: feasibilityRemarks ?? this.feasibilityRemarks,
      vehicleSuitability: vehicleSuitability ?? this.vehicleSuitability,
      routeSuitability: routeSuitability ?? this.routeSuitability,
      manpowerReadiness: manpowerReadiness ?? this.manpowerReadiness,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EnquiryAuditEntry {
  const EnquiryAuditEntry({
    required this.enquiryNumber,
    required this.action,
    required this.actor,
    required this.at,
    this.remarks = '',
  });

  final String enquiryNumber;
  final String action;
  final String actor;
  final DateTime at;
  final String remarks;
}

class WorkOrderFlowItem {
  const WorkOrderFlowItem({
    required this.woId,
    required this.customer,
    required this.route,
    required this.cargo,
    required this.status,
    this.linkedQuotationRef = '',
    this.linkedEnquiryNumber = '',
    this.routeMasterId = '',
    this.routeCode = '',
    this.routeName = '',
    this.routeRiskLevel = 'Low',
    this.routeOperationalStatus = 'Active',
    this.routeRestricted = false,
    this.routeRestrictionReason = '',
    this.customerPoReference = '',
    this.jobFileReference = '',
    this.serviceStartDate = '',
    this.serviceEndDate = '',
    this.internalNotes = '',
  });

  final String woId;
  final String customer;
  final String route;
  final String cargo;
  final String status;
  final String linkedQuotationRef;
  final String linkedEnquiryNumber;
  final String routeMasterId;
  final String routeCode;
  final String routeName;
  final String routeRiskLevel;
  final String routeOperationalStatus;
  final bool routeRestricted;
  final String routeRestrictionReason;
  final String customerPoReference;
  final String jobFileReference;
  final String serviceStartDate;
  final String serviceEndDate;
  final String internalNotes;

  WorkOrderFlowItem copyWith({
    String? woId,
    String? customer,
    String? route,
    String? cargo,
    String? status,
    String? linkedQuotationRef,
    String? linkedEnquiryNumber,
    String? routeMasterId,
    String? routeCode,
    String? routeName,
    String? routeRiskLevel,
    String? routeOperationalStatus,
    bool? routeRestricted,
    String? routeRestrictionReason,
    String? customerPoReference,
    String? jobFileReference,
    String? serviceStartDate,
    String? serviceEndDate,
    String? internalNotes,
  }) {
    return WorkOrderFlowItem(
      woId: woId ?? this.woId,
      customer: customer ?? this.customer,
      route: route ?? this.route,
      cargo: cargo ?? this.cargo,
      status: status ?? this.status,
      linkedQuotationRef: linkedQuotationRef ?? this.linkedQuotationRef,
      linkedEnquiryNumber: linkedEnquiryNumber ?? this.linkedEnquiryNumber,
      routeMasterId: routeMasterId ?? this.routeMasterId,
      routeCode: routeCode ?? this.routeCode,
      routeName: routeName ?? this.routeName,
      routeRiskLevel: routeRiskLevel ?? this.routeRiskLevel,
      routeOperationalStatus:
          routeOperationalStatus ?? this.routeOperationalStatus,
      routeRestricted: routeRestricted ?? this.routeRestricted,
      routeRestrictionReason:
          routeRestrictionReason ?? this.routeRestrictionReason,
      customerPoReference: customerPoReference ?? this.customerPoReference,
      jobFileReference: jobFileReference ?? this.jobFileReference,
      serviceStartDate: serviceStartDate ?? this.serviceStartDate,
      serviceEndDate: serviceEndDate ?? this.serviceEndDate,
      internalNotes: internalNotes ?? this.internalNotes,
    );
  }
}

class QuotationData {
  const QuotationData({
    required this.quoteRef,
    required this.enquiryRef,
    required this.customer,
    required this.date,
    required this.validityDate,
    required this.rate,
    required this.costSummary,
    required this.terms,
    required this.remarks,
    required this.status,
    this.decisionResponseDate = '',
    this.customerPoRef = '',
    this.rejectionReason = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String quoteRef;
  final String enquiryRef;
  final String customer;
  final String date;
  final String validityDate;
  final double rate;
  final String costSummary;
  final String terms;
  final String remarks;
  final String status; // 'Draft', 'Sent', 'Accepted', 'Rejected', 'Expired'
  final String decisionResponseDate;
  final String customerPoRef;
  final String rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuotationData copyWith({
    String? quoteRef,
    String? enquiryRef,
    String? customer,
    String? date,
    String? validityDate,
    double? rate,
    String? costSummary,
    String? terms,
    String? remarks,
    String? status,
    String? decisionResponseDate,
    String? customerPoRef,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuotationData(
      quoteRef: quoteRef ?? this.quoteRef,
      enquiryRef: enquiryRef ?? this.enquiryRef,
      customer: customer ?? this.customer,
      date: date ?? this.date,
      validityDate: validityDate ?? this.validityDate,
      rate: rate ?? this.rate,
      costSummary: costSummary ?? this.costSummary,
      terms: terms ?? this.terms,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      decisionResponseDate: decisionResponseDate ?? this.decisionResponseDate,
      customerPoRef: customerPoRef ?? this.customerPoRef,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FleetVehicleData {
  const FleetVehicleData({
    required this.vehicleNo,
    required this.type,
    required this.capacity,
    required this.fuelType,
    required this.ivmsDeviceId,
    required this.status,
    this.permits = const [],
  });

  final String vehicleNo;
  final String type;
  final String capacity;
  final String fuelType;
  final String ivmsDeviceId;
  final String status;
  final List<String> permits;
}

class DriverData {
  const DriverData({
    required this.driverId,
    required this.name,
    required this.employeeRef,
    required this.licenseNo,
    required this.licenseType,
    required this.licenseIssueDate,
    required this.expiryDate,
    required this.heavyVehicleAllowed,
    required this.specialEndorsementNotes,
    required this.phone,
    required this.nationality,
    required this.baseLocation,
    required this.experience,
    required this.dfmsDeviceId,
    required this.status,
    required this.active,
    required this.assignmentAllowed,
    required this.dispatchAllowed,
    required this.dispatchBlocked,
    required this.blockReason,
    required this.onLeave,
    required this.suspended,
    required this.suspensionReason,
    required this.currentAssignmentStatus,
    required this.currentWorkOrder,
    required this.currentLocation,
    required this.allowedVehicleTypes,
    required this.longHaulAllowed,
    required this.nightDrivingAllowed,
    required this.hazardousCargoAllowed,
    required this.oilfieldAllowed,
    required this.routeRestrictions,
    required this.specialSkillsNotes,
    required this.pdoPassportStatus,
    required this.defensiveDrivingStatus,
    required this.h2sStatus,
    required this.ftwStatus,
    required this.complianceNotes,
    required this.medicalFitnessNote,
    required this.safetyIncidentFlag,
    required this.incidentCount,
    required this.disciplinaryNote,
    required this.temporaryRestrictionNote,
    required this.preferredRegion,
    required this.preferredRouteType,
    required this.preferredVehicleType,
    required this.preferredCargoType,
    required this.specialAssignmentNotes,
    this.certifications = const [],
  });

  final String driverId;
  final String name;
  final String employeeRef;
  final String licenseNo;
  final String licenseType;
  final String licenseIssueDate;
  final String expiryDate;
  final bool heavyVehicleAllowed;
  final String specialEndorsementNotes;
  final String phone;
  final String nationality;
  final String baseLocation;
  final int experience;
  final String dfmsDeviceId;
  final String status;
  final bool active;
  final bool assignmentAllowed;
  final bool dispatchAllowed;
  final bool dispatchBlocked;
  final String blockReason;
  final bool onLeave;
  final bool suspended;
  final String suspensionReason;
  final String currentAssignmentStatus;
  final String currentWorkOrder;
  final String currentLocation;
  final List<String> allowedVehicleTypes;
  final bool longHaulAllowed;
  final bool nightDrivingAllowed;
  final bool hazardousCargoAllowed;
  final bool oilfieldAllowed;
  final String routeRestrictions;
  final String specialSkillsNotes;
  final String pdoPassportStatus;
  final String defensiveDrivingStatus;
  final String h2sStatus;
  final String ftwStatus;
  final String complianceNotes;
  final String medicalFitnessNote;
  final bool safetyIncidentFlag;
  final int incidentCount;
  final String disciplinaryNote;
  final String temporaryRestrictionNote;
  final String preferredRegion;
  final String preferredRouteType;
  final String preferredVehicleType;
  final String preferredCargoType;
  final String specialAssignmentNotes;
  final List<String> certifications;

  bool get licenseValid {
    final expiry = DateTime.tryParse(expiryDate.trim());
    if (expiry == null) {
      return false;
    }
    return !expiry.isBefore(DateTime.now());
  }

  bool get complianceReady {
    final trainingOk = [
      pdoPassportStatus,
      defensiveDrivingStatus,
      h2sStatus,
      ftwStatus,
    ].every((item) {
      final normalized = item.trim().toLowerCase();
      return normalized == 'valid' ||
          normalized == 'active' ||
          normalized == 'not required';
    });
    return licenseValid && trainingOk;
  }

  bool get assignmentEligible {
    final available = status.toLowerCase() == 'available';
    return active &&
        assignmentAllowed &&
        dispatchAllowed &&
        !dispatchBlocked &&
        !onLeave &&
        !suspended &&
        available &&
        complianceReady;
  }

  DriverData copyWith({
    String? name,
    String? licenseNo,
    String? expiryDate,
    String? phone,
    String? status,
    List<String>? certifications,
    String? employeeRef,
    String? nationality,
    String? baseLocation,
    String? licenseType,
    String? licenseIssueDate,
    bool? heavyVehicleAllowed,
    String? specialEndorsementNotes,
    bool? active,
    bool? assignmentAllowed,
    bool? dispatchAllowed,
    bool? dispatchBlocked,
    String? blockReason,
    bool? onLeave,
    bool? suspended,
    String? suspensionReason,
    String? currentAssignmentStatus,
    String? currentWorkOrder,
    String? currentLocation,
    List<String>? allowedVehicleTypes,
    bool? longHaulAllowed,
    bool? nightDrivingAllowed,
    bool? hazardousCargoAllowed,
    bool? oilfieldAllowed,
    String? routeRestrictions,
    String? specialSkillsNotes,
    String? pdoPassportStatus,
    String? defensiveDrivingStatus,
    String? h2sStatus,
    String? ftwStatus,
    String? complianceNotes,
    String? medicalFitnessNote,
    bool? safetyIncidentFlag,
    int? incidentCount,
    String? disciplinaryNote,
    String? temporaryRestrictionNote,
    String? preferredRegion,
    String? preferredRouteType,
    String? preferredVehicleType,
    String? preferredCargoType,
    String? specialAssignmentNotes,
  }) {
    return DriverData(
      driverId: driverId,
      name: name ?? this.name,
      employeeRef: employeeRef ?? this.employeeRef,
      licenseNo: licenseNo ?? this.licenseNo,
      licenseType: licenseType ?? this.licenseType,
      licenseIssueDate: licenseIssueDate ?? this.licenseIssueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      heavyVehicleAllowed: heavyVehicleAllowed ?? this.heavyVehicleAllowed,
      specialEndorsementNotes:
          specialEndorsementNotes ?? this.specialEndorsementNotes,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      baseLocation: baseLocation ?? this.baseLocation,
      experience: experience,
      dfmsDeviceId: dfmsDeviceId,
      status: status ?? this.status,
      active: active ?? this.active,
      assignmentAllowed: assignmentAllowed ?? this.assignmentAllowed,
      dispatchAllowed: dispatchAllowed ?? this.dispatchAllowed,
      dispatchBlocked: dispatchBlocked ?? this.dispatchBlocked,
      blockReason: blockReason ?? this.blockReason,
      onLeave: onLeave ?? this.onLeave,
      suspended: suspended ?? this.suspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      currentAssignmentStatus:
          currentAssignmentStatus ?? this.currentAssignmentStatus,
      currentWorkOrder: currentWorkOrder ?? this.currentWorkOrder,
      currentLocation: currentLocation ?? this.currentLocation,
      allowedVehicleTypes: allowedVehicleTypes ?? this.allowedVehicleTypes,
      longHaulAllowed: longHaulAllowed ?? this.longHaulAllowed,
      nightDrivingAllowed: nightDrivingAllowed ?? this.nightDrivingAllowed,
      hazardousCargoAllowed:
          hazardousCargoAllowed ?? this.hazardousCargoAllowed,
      oilfieldAllowed: oilfieldAllowed ?? this.oilfieldAllowed,
      routeRestrictions: routeRestrictions ?? this.routeRestrictions,
      specialSkillsNotes: specialSkillsNotes ?? this.specialSkillsNotes,
      pdoPassportStatus: pdoPassportStatus ?? this.pdoPassportStatus,
      defensiveDrivingStatus:
          defensiveDrivingStatus ?? this.defensiveDrivingStatus,
      h2sStatus: h2sStatus ?? this.h2sStatus,
      ftwStatus: ftwStatus ?? this.ftwStatus,
      complianceNotes: complianceNotes ?? this.complianceNotes,
      medicalFitnessNote: medicalFitnessNote ?? this.medicalFitnessNote,
      safetyIncidentFlag: safetyIncidentFlag ?? this.safetyIncidentFlag,
      incidentCount: incidentCount ?? this.incidentCount,
      disciplinaryNote: disciplinaryNote ?? this.disciplinaryNote,
      temporaryRestrictionNote:
          temporaryRestrictionNote ?? this.temporaryRestrictionNote,
      preferredRegion: preferredRegion ?? this.preferredRegion,
      preferredRouteType: preferredRouteType ?? this.preferredRouteType,
      preferredVehicleType: preferredVehicleType ?? this.preferredVehicleType,
      preferredCargoType: preferredCargoType ?? this.preferredCargoType,
      specialAssignmentNotes:
          specialAssignmentNotes ?? this.specialAssignmentNotes,
      certifications: certifications ?? this.certifications,
    );
  }
}

class JourneyMasterData {
  const JourneyMasterData({
    required this.journeyId,
    required this.planName,
    required this.origin,
    required this.destination,
    required this.stops,
    required this.restPoints,
  });

  final String journeyId;
  final String planName;
  final String origin;
  final String destination;
  final List<String> stops;
  final List<String> restPoints;
}

class IvmsData {
  const IvmsData({
    required this.vehicleId,
    required this.lat,
    required this.lng,
    required this.speed,
    required this.fuelLevel,
    required this.distanceCovered,
    required this.status,
  });

  final String vehicleId;
  final double lat;
  final double lng;
  final double speed;
  final double fuelLevel;
  final double distanceCovered;
  final String status;

  IvmsData copyWith({
    double? lat,
    double? lng,
    double? speed,
    double? fuelLevel,
    double? distanceCovered,
    String? status,
  }) {
    return IvmsData(
      vehicleId: vehicleId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      speed: speed ?? this.speed,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      distanceCovered: distanceCovered ?? this.distanceCovered,
      status: status ?? this.status,
    );
  }
}

class DfmsData {
  const DfmsData({
    required this.driverId,
    required this.fatigueLevel,
    required this.eyeClosureRate,
    required this.drivingHours,
    required this.alert,
  });

  final String driverId;
  final String fatigueLevel;
  final double eyeClosureRate;
  final double drivingHours;
  final String alert;

  DfmsData copyWith({
    String? fatigueLevel,
    double? eyeClosureRate,
    double? drivingHours,
    String? alert,
  }) {
    return DfmsData(
      driverId: driverId,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      eyeClosureRate: eyeClosureRate ?? this.eyeClosureRate,
      drivingHours: drivingHours ?? this.drivingHours,
      alert: alert ?? this.alert,
    );
  }
}
