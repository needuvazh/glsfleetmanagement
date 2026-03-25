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
    required super.quantity,
    required super.dimensions,
    required super.customerSpecificRequirement,
    required super.requiredVehicleType,
    required super.tentativeDispatchDate,
    required super.routeRiskFlag,
    required super.hazardousComplianceRequired,
    required super.status,
    required super.cancellationReason,
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
    required super.slNo,
    required super.date,
    required super.quoteRef,
    required super.salesPerson,
    required super.customer,
    required super.customerContact,
    required super.workDescription,
    required super.noOfTrips,
    required super.kilometer,
    required super.rate,
    required super.amount,
    required super.approved,
  });

  factory QuotationModel.fromMap(Map<String, dynamic> map) {
    return QuotationModel(
      slNo: (map['slNo'] as num?)?.toInt() ?? 0,
      date: map['date'] as String? ?? '',
      quoteRef: map['quoteRef'] as String? ?? '',
      salesPerson: map['salesPerson'] as String? ?? '',
      customer: map['customer'] as String? ?? '',
      customerContact: map['customerContact'] as String? ?? '',
      workDescription: map['workDescription'] as String? ?? '',
      noOfTrips: (map['noOfTrips'] as num?)?.toInt() ?? 0,
      kilometer: (map['kilometer'] as num?)?.toDouble() ?? 0,
      rate: (map['rate'] as num?)?.toDouble() ?? 0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      approved: map['approved'] as bool? ?? false,
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
    );
  }
}

class DriverModel extends DriverData {
  const DriverModel({
    required super.driverId,
    required super.name,
    required super.licenseNo,
    required super.expiryDate,
    required super.phone,
    required super.experience,
    required super.dfmsDeviceId,
    required super.status,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      driverId: map['driverId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      licenseNo: map['licenseNo'] as String? ?? '',
      expiryDate: map['expiryDate'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      experience: (map['experience'] as num?)?.toInt() ?? 0,
      dfmsDeviceId: map['dfmsDeviceId'] as String? ?? '',
      status: map['status'] as String? ?? '',
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
