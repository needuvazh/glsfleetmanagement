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
    this.quantity = '',
    this.dimensions = '',
    this.customerSpecificRequirement = '',
    this.requiredVehicleType = '',
    this.tentativeDispatchDate = '',
    this.routeRiskFlag = false,
    this.hazardousComplianceRequired = false,
    this.status = 'New Enquiry',
    this.cancellationReason = '',
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
  final String quantity;
  final String dimensions;
  final String customerSpecificRequirement;
  final String requiredVehicleType;
  final String tentativeDispatchDate;
  final bool routeRiskFlag;
  final bool hazardousComplianceRequired;
  final String status;
  final String cancellationReason;
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
    String? quantity,
    String? dimensions,
    String? customerSpecificRequirement,
    String? requiredVehicleType,
    String? tentativeDispatchDate,
    bool? routeRiskFlag,
    bool? hazardousComplianceRequired,
    String? status,
    String? cancellationReason,
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
  });

  final String woId;
  final String customer;
  final String route;
  final String cargo;
  final String status;
}

class QuotationData {
  const QuotationData({
    required this.slNo,
    required this.date,
    required this.quoteRef,
    required this.salesPerson,
    required this.customer,
    required this.customerContact,
    required this.workDescription,
    required this.noOfTrips,
    required this.kilometer,
    required this.rate,
    required this.amount,
    required this.approved,
  });

  final int slNo;
  final String date;
  final String quoteRef;
  final String salesPerson;
  final String customer;
  final String customerContact;
  final String workDescription;
  final int noOfTrips;
  final double kilometer;
  final double rate;
  final double amount;
  final bool approved;

  QuotationData copyWith({
    int? slNo,
    String? date,
    String? quoteRef,
    String? salesPerson,
    String? customer,
    String? customerContact,
    String? workDescription,
    int? noOfTrips,
    double? kilometer,
    double? rate,
    double? amount,
    bool? approved,
  }) {
    return QuotationData(
      slNo: slNo ?? this.slNo,
      date: date ?? this.date,
      quoteRef: quoteRef ?? this.quoteRef,
      salesPerson: salesPerson ?? this.salesPerson,
      customer: customer ?? this.customer,
      customerContact: customerContact ?? this.customerContact,
      workDescription: workDescription ?? this.workDescription,
      noOfTrips: noOfTrips ?? this.noOfTrips,
      kilometer: kilometer ?? this.kilometer,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      approved: approved ?? this.approved,
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
  });

  final String vehicleNo;
  final String type;
  final String capacity;
  final String fuelType;
  final String ivmsDeviceId;
  final String status;
}

class DriverData {
  const DriverData({
    required this.driverId,
    required this.name,
    required this.licenseNo,
    required this.expiryDate,
    required this.phone,
    required this.experience,
    required this.dfmsDeviceId,
    required this.status,
  });

  final String driverId;
  final String name;
  final String licenseNo;
  final String expiryDate;
  final String phone;
  final int experience;
  final String dfmsDeviceId;
  final String status;
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
