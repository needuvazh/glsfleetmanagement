import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/logistics_flow_models.dart';

abstract class LogisticsLocalDataSource {
  Future<List<CustomerRequestModel>> getCustomerRequests();
  Future<List<QuotationModel>> getQuotations();
  Future<List<WorkOrderFlowModel>> getFlowWorkOrders();
  Future<List<FleetVehicleModel>> getVehicles();
  Future<List<DriverModel>> getDrivers();
  Future<List<JourneyMasterModel>> getJourneyMaster();
  Future<List<IvmsModel>> getIvmsData();
  Future<List<DfmsModel>> getDfmsData();
}

class LogisticsLocalDataSourceImpl implements LogisticsLocalDataSource {
  static const _customerRequestsCacheKey = 'master_customer_requests_v3';
  static const _flowWorkOrdersCacheKey = 'master_flow_work_orders_v1';
  static const _vehiclesCacheKey = 'master_vehicles_v1';
  static const _driversCacheKey = 'master_drivers_v1';

  const LogisticsLocalDataSourceImpl({required AssetBundle assetBundle})
      : _assetBundle = assetBundle;

  final AssetBundle _assetBundle;

  @override
  Future<List<CustomerRequestModel>> getCustomerRequests() async {
    final list = await _readCachedList(
      cacheKey: _customerRequestsCacheKey,
      seed: _seedCustomerRequests,
    );
    return list.map(CustomerRequestModel.fromMap).toList();
  }

  static const _quotationsCacheKey = 'master_quotations_v1';

  @override
  Future<List<QuotationModel>> getQuotations() async {
    final list = await _readCachedList(
      cacheKey: _quotationsCacheKey,
      seed: _seedQuotations,
    );
    return list.map(QuotationModel.fromMap).toList();
  }

  @override
  Future<List<WorkOrderFlowModel>> getFlowWorkOrders() async {
    final list = await _readCachedList(
      cacheKey: _flowWorkOrdersCacheKey,
      seed: _seedFlowWorkOrders,
    );
    return list.map(WorkOrderFlowModel.fromMap).toList();
  }

  @override
  Future<List<FleetVehicleModel>> getVehicles() async {
    final list = await _readCachedList(
      cacheKey: _vehiclesCacheKey,
      seed: _seedVehicles,
    );
    return list.map(FleetVehicleModel.fromMap).toList();
  }

  @override
  Future<List<DriverModel>> getDrivers() async {
    final list = await _readCachedList(
      cacheKey: _driversCacheKey,
      seed: _seedDrivers,
    );
    return list.map(DriverModel.fromMap).toList();
  }

  @override
  Future<List<JourneyMasterModel>> getJourneyMaster() async {
    final list = await _readList(AppConstants.journeyMasterMockPath);
    return list.map(JourneyMasterModel.fromMap).toList();
  }

  @override
  Future<List<IvmsModel>> getIvmsData() async {
    final list = await _readList(AppConstants.ivmsMockPath);
    return list.map(IvmsModel.fromMap).toList();
  }

  @override
  Future<List<DfmsModel>> getDfmsData() async {
    final list = await _readList(AppConstants.dfmsMockPath);
    return list.map(DfmsModel.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> _readList(String path) async {
    final content = await _assetBundle.loadString(path);
    final dynamic data = jsonDecode(content);
    if (data is List<dynamic>) {
      return data.map((entry) => entry as Map<String, dynamic>).toList();
    }
    throw FormatException('Expected list payload for $path');
  }

  Future<List<Map<String, dynamic>>> _readCachedList({
    required String cacheKey,
    required List<Map<String, dynamic>> Function() seed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw != null && raw.isNotEmpty) {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded
            .map((entry) => Map<String, dynamic>.from(entry as Map))
            .toList();
      }
    }

    final seeded = seed();
    await prefs.setString(cacheKey, jsonEncode(seeded));
    return seeded;
  }

  List<Map<String, dynamic>> _seedCustomerRequests() {
    final now = DateTime.now().toIso8601String();
    return [
      {
        'enquiryNumber': 'ENQ-2026-001',
        'requestSource': 'Email',
        'customerName': 'Shell Oman',
        'requestType': 'Transport Request',
        'emailOrReference': 'ops@shelloman.com',
        'contact': '+968-24701234',
        'cargoType': 'Oilfield Equipment',
        'weightVolume': '12 Tons',
        'pickup': 'Muscat',
        'delivery': 'Fahud',
        'requestDate': '2026-03-10',
        'notes': 'Urgent delivery required. PDO site access pass required.',
        'hazardous': false,
        'pdoSpec': 'PDO',
        'route': 'Muscat -> Fahud',
        'routeMasterId': 'RT001',
        'routeCode': 'MCT-FAH',
        'routeName': 'Muscat to Fahud',
        'routeRiskLevel': 'Medium',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '3 Units',
        'dimensions': '6m x 2.4m x 2.5m',
        'customerSpecificRequirement': 'PDO Certified Vehicles Only',
        'requiredVehicleType': 'Prime Mover',
        'tentativeDispatchDate': '2026-03-15',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Feasibility Review',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 4800.0,
        'feasibilityRemarks': 'Route clear. Vehicle and driver available.',
        'vehicleSuitability': 'Prime Mover available and certified for PDO sites.',
        'routeSuitability': 'Route MCT-FAH is active with no restrictions.',
        'manpowerReadiness': 'Driver DRV001 (Ahmed Al Balushi) is certified and available.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Net 30',
        'reviewedBy': 'Ops Manager',
        'createdAt': '2026-03-10T08:30:00.000',
        'updatedAt': '2026-03-11T10:00:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-002',
        'requestSource': 'Phone',
        'customerName': 'PDO (Petroleum Development Oman)',
        'requestType': 'Transport Request',
        'emailOrReference': 'logistics@pdo.co.om',
        'contact': '+968-24785600',
        'cargoType': 'Hazardous Chemical (Class 3)',
        'weightVolume': '8 Tons',
        'pickup': 'Sohar Industrial Zone',
        'delivery': 'Marmul',
        'requestDate': '2026-03-12',
        'notes': 'Hazardous cargo. MSDS required. Escort vehicle mandatory.',
        'hazardous': true,
        'pdoSpec': 'PDO',
        'route': 'Sohar -> Marmul',
        'routeMasterId': 'RT002',
        'routeCode': 'SHR-MAR',
        'routeName': 'Sohar to Marmul',
        'routeRiskLevel': 'High',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '2 Loads',
        'dimensions': '—',
        'customerSpecificRequirement': 'Hazmat certified driver. ADR compliance mandatory.',
        'requiredVehicleType': 'Tanker',
        'tentativeDispatchDate': '2026-03-18',
        'routeRiskFlag': true,
        'hazardousComplianceRequired': true,
        'status': 'New Enquiry',
        'cancellationReason': '',
        'feasibilityStatus': 'Pending',
        'estimatedCost': 0.0,
        'feasibilityRemarks': '',
        'vehicleSuitability': '',
        'routeSuitability': '',
        'manpowerReadiness': '',
        'creditCheckStatus': 'Pending',
        'paymentTerms': 'Advance',
        'reviewedBy': '',
        'createdAt': '2026-03-12T09:15:00.000',
        'updatedAt': '2026-03-12T09:15:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-003',
        'requestSource': 'Direct',
        'customerName': 'OQ Logistics',
        'requestType': 'Transport Request',
        'emailOrReference': 'REF-OQ-9321',
        'contact': '+968-24503800',
        'cargoType': 'Heavy Machinery',
        'weightVolume': '28 Tons',
        'pickup': 'Sohar Port',
        'delivery': 'Ibri',
        'requestDate': '2026-03-14',
        'notes': 'Oversize cargo. Police escort approval in progress.',
        'hazardous': false,
        'pdoSpec': 'Non-PDO',
        'route': 'Sohar -> Ibri',
        'routeMasterId': 'RT003',
        'routeCode': 'SHR-IBR',
        'routeName': 'Sohar to Ibri',
        'routeRiskLevel': 'Low',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '1 Unit',
        'dimensions': '12m x 4m x 4.2m',
        'customerSpecificRequirement': 'Oversize transport permit required.',
        'requiredVehicleType': 'Flatbed Trailer',
        'tentativeDispatchDate': '2026-03-20',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Quotation',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 6200.0,
        'feasibilityRemarks': 'Oversize permit pending. Feasible once permit confirmed.',
        'vehicleSuitability': 'Flatbed Trailer available. Checked for load dimensions.',
        'routeSuitability': 'Route SHR-IBR clear. Oversize escort required on highway stretch.',
        'manpowerReadiness': 'Driver DRV004 (Majid Al Kindi) assigned. Escort driver arranged.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Net 15',
        'reviewedBy': 'Ops Manager',
        'createdAt': '2026-03-14T11:00:00.000',
        'updatedAt': '2026-03-15T09:30:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-004',
        'requestSource': 'Email',
        'customerName': 'DHL Supply Chain',
        'requestType': 'Transport Request',
        'emailOrReference': 'om-ops@dhl.com',
        'contact': '+968-24407700',
        'cargoType': 'General Cargo (Palletised)',
        'weightVolume': '6.5 Tons',
        'pickup': 'Muscat Logistics Hub',
        'delivery': 'Nizwa',
        'requestDate': '2026-03-16',
        'notes': 'Temperature-sensitive items. Maintain 5–10°C.',
        'hazardous': false,
        'pdoSpec': 'Non-PDO',
        'route': 'Muscat -> Nizwa',
        'routeMasterId': 'RT004',
        'routeCode': 'MCT-NZW',
        'routeName': 'Muscat to Nizwa',
        'routeRiskLevel': 'Low',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '48 Pallets',
        'dimensions': 'EUR Pallet 120x80cm',
        'customerSpecificRequirement': 'Refrigerated truck required.',
        'requiredVehicleType': 'Refrigerated Truck',
        'tentativeDispatchDate': '2026-03-19',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'New Enquiry',
        'cancellationReason': '',
        'feasibilityStatus': 'Pending',
        'estimatedCost': 0.0,
        'feasibilityRemarks': '',
        'vehicleSuitability': '',
        'routeSuitability': '',
        'manpowerReadiness': '',
        'creditCheckStatus': 'Pending',
        'paymentTerms': 'Net 30',
        'reviewedBy': '',
        'createdAt': '2026-03-16T07:45:00.000',
        'updatedAt': '2026-03-16T07:45:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-005',
        'requestSource': 'Phone',
        'customerName': 'BSC (Bahwan Cybertek)',
        'requestType': 'Equipment Relocation',
        'emailOrReference': 'REF-BSC-5120',
        'contact': '+968-24724700',
        'cargoType': 'IT Server Equipment',
        'weightVolume': '1.2 Tons',
        'pickup': 'Muscat CBD',
        'delivery': 'Salalah',
        'requestDate': '2026-03-17',
        'notes': 'Fragile electronics. Needs air-ride suspension vehicle.',
        'hazardous': false,
        'pdoSpec': 'Non-PDO',
        'route': 'Muscat -> Salalah',
        'routeMasterId': 'RT005',
        'routeCode': 'MCT-SLL',
        'routeName': 'Muscat to Salalah',
        'routeRiskLevel': 'Medium',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '4 Crates',
        'dimensions': 'Mixed sizes',
        'customerSpecificRequirement': 'White glove service. GPS tracking mandatory.',
        'requiredVehicleType': 'Curtainsider Van',
        'tentativeDispatchDate': '2026-03-22',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Decision Received',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 2100.0,
        'feasibilityRemarks': 'Feasible. Suitable vehicle available from Muscat depot.',
        'vehicleSuitability': 'Curtainsider with air-ride suspension available.',
        'routeSuitability': 'MCT-SLL route active. Night driving required for long haul.',
        'manpowerReadiness': 'Driver assigned. FTW certification valid.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Advance 50%',
        'reviewedBy': 'Ops Manager',
        'createdAt': '2026-03-17T13:00:00.000',
        'updatedAt': '2026-03-20T16:45:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-006',
        'requestSource': 'Direct',
        'customerName': 'Al Madina Transport',
        'requestType': 'Transport Request',
        'emailOrReference': 'dispatch@almadina.om',
        'contact': '+968-24612211',
        'cargoType': 'Construction Materials',
        'weightVolume': '15 Tons',
        'pickup': 'Ibri Quarry',
        'delivery': 'Muscat',
        'requestDate': '2026-03-18',
        'notes': 'Sand and gravel. Multiple trips may be required.',
        'hazardous': false,
        'pdoSpec': 'Non-PDO',
        'route': 'Ibri -> Muscat',
        'routeMasterId': 'RT006',
        'routeCode': 'IBR-MCT',
        'routeName': 'Ibri to Muscat',
        'routeRiskLevel': 'Low',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '15 Tons',
        'dimensions': 'Bulk',
        'customerSpecificRequirement': 'Tipper truck preferred.',
        'requiredVehicleType': 'Tipper Truck',
        'tentativeDispatchDate': '2026-03-21',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Cancelled',
        'cancellationReason': 'Customer postponed project to Q2 2026.',
        'feasibilityStatus': 'Pending',
        'estimatedCost': 0.0,
        'feasibilityRemarks': '',
        'vehicleSuitability': '',
        'routeSuitability': '',
        'manpowerReadiness': '',
        'creditCheckStatus': 'On Hold',
        'paymentTerms': 'Net 30',
        'reviewedBy': '',
        'createdAt': '2026-03-18T10:00:00.000',
        'updatedAt': '2026-03-19T14:00:00.000',
      },
    ];
  }

  List<Map<String, dynamic>> _seedQuotations() {
    return [
      {
        "quoteRef": "QUO-2026-001",
        "enquiryRef": "ENQ-2026-001",
        "customer": "Shell Oman",
        "date": "2026-03-12",
        "validityDate": "2026-04-12",
        "rate": 4800.00,
        "costSummary": "Prime Mover x3 trips @ 1600 OMR/trip incl. fuel & driver",
        "terms": "Net 30 days from invoice date",
        "remarks": "PDO-certified vehicle and driver. Rates include site entry compliance.",
        "status": "Accepted",
        "decisionResponseDate": "2026-03-18",
        "customerPoRef": "SHO-PO-2026-0892",
        "rejectionReason": "",
        "createdAt": "2026-03-12T10:00:00.000",
        "updatedAt": "2026-03-18T14:30:00.000"
      },
      {
        "quoteRef": "QUO-2026-002",
        "enquiryRef": "ENQ-2026-003",
        "customer": "OQ Logistics",
        "date": "2026-03-16",
        "validityDate": "2026-04-16",
        "rate": 6200.00,
        "costSummary": "Flatbed Trailer x1 trip L/D @ 6200 OMR incl. oversize escort",
        "terms": "Net 15 days. 50% advance on WO issuance.",
        "remarks": "Rate includes police escort coordination and oversize permit facilitation fee.",
        "status": "Sent",
        "decisionResponseDate": "",
        "customerPoRef": "",
        "rejectionReason": "",
        "createdAt": "2026-03-16T09:00:00.000",
        "updatedAt": "2026-03-16T09:00:00.000"
      },
      {
        "quoteRef": "QUO-2026-003",
        "enquiryRef": "ENQ-2026-005",
        "customer": "BSC (Bahwan Cybertek)",
        "date": "2026-03-19",
        "validityDate": "2026-04-19",
        "rate": 2100.00,
        "costSummary": "Curtainsider Van x1 Muscat to Salalah incl. GPS tracking",
        "terms": "50% advance, 50% on delivery",
        "remarks": "White glove service with real-time GPS tracking. Air-ride suspension vehicle assigned.",
        "status": "Draft",
        "decisionResponseDate": "",
        "customerPoRef": "",
        "rejectionReason": "",
        "createdAt": "2026-03-19T11:00:00.000",
        "updatedAt": "2026-03-19T11:00:00.000"
      }
    ];
  }

  List<Map<String, dynamic>> _seedFlowWorkOrders() {
    return [
      {
        'woId': 'WO001',
        'requestId': 'REQ001',
        'client': 'Shell',
        'route': 'Muscat -> Sohar',
        'cargo': 'Oilfield Equipment',
        'status': 'Assigned',
      },
      {
        'woId': 'WO003',
        'requestId': 'REQ003',
        'client': 'PDO',
        'route': 'Muscat -> Fahud',
        'cargo': 'Hazardous Chemical',
        'status': 'Open',
      },
      {
        'woId': 'WO004',
        'requestId': 'REQ004',
        'client': 'OQ Logistics',
        'route': 'Sohar -> Ibri',
        'cargo': 'Heavy Equipment',
        'status': 'Ready for Allocation',
      },
    ];
  }

  List<Map<String, dynamic>> _seedVehicles() {
    return [
      {
        'vehicleNo': 'TRK-101',
        'type': 'Flatbed Truck',
        'capacity': '10 Tons',
        'fuelType': 'Diesel',
        'status': 'Available',
        'permits': ['Registration', 'Insurance', 'Permit', 'Inspection'],
      },
      {
        'vehicleNo': 'PM-205',
        'type': 'Prime Mover',
        'capacity': '30 Tons',
        'fuelType': 'Diesel',
        'status': 'Available',
        'permits': ['Registration', 'Insurance', 'Permit', 'Inspection'],
      },
      {
        'vehicleNo': 'TNK-220',
        'type': 'Tanker',
        'capacity': '10 Tons',
        'fuelType': 'Diesel',
        'status': 'Available',
        'permits': ['Registration', 'Insurance', 'Permit', 'Inspection'],
      },
    ];
  }

  List<Map<String, dynamic>> _seedDrivers() {
    return [
      {
        'driverId': 'DRV001',
        'name': 'Ahmed Al Balushi',
        'employeeRef': 'EMP-DR-001',
        'licenseNo': 'OM-LIC-458921',
        'licenseType': 'Heavy Vehicle',
        'licenseIssueDate': '2022-01-10',
        'expiryDate': '2027-05-18',
        'heavyVehicleAllowed': true,
        'phone': '+968-98765432',
        'nationality': 'Omani',
        'baseLocation': 'Muscat',
        'experience': 9,
        'dfmsDeviceId': 'DFMS-DRV001',
        'status': 'Available',
        'active': true,
        'assignmentAllowed': true,
        'dispatchAllowed': true,
        'dispatchBlocked': false,
        'onLeave': false,
        'suspended': false,
        'currentAssignmentStatus': 'Unassigned',
        'currentLocation': 'Muscat',
        'allowedVehicleTypes': ['Prime Mover', 'Tanker', 'Flatbed Truck'],
        'nightDrivingAllowed': true,
        'hazardousCargoAllowed': true,
        'oilfieldAllowed': true,
        'pdoPassportStatus': 'Valid',
        'defensiveDrivingStatus': 'Valid',
        'h2sStatus': 'Valid',
        'ftwStatus': 'Valid',
        'certifications': ['PDO Passport', 'Defensive Driving', 'H2S', 'FTW'],
      },
      {
        'driverId': 'DRV004',
        'name': 'Majid Al Kindi',
        'employeeRef': 'EMP-DR-004',
        'licenseNo': 'OM-LIC-715932',
        'licenseType': 'Heavy Vehicle',
        'expiryDate': '2025-10-01',
        'heavyVehicleAllowed': true,
        'phone': '+968-93456789',
        'nationality': 'Omani',
        'baseLocation': 'Duqm',
        'experience': 11,
        'dfmsDeviceId': 'DFMS-DRV004',
        'status': 'Available',
        'active': true,
        'assignmentAllowed': true,
        'dispatchAllowed': true,
        'dispatchBlocked': false,
        'onLeave': false,
        'suspended': false,
        'allowedVehicleTypes': ['Prime Mover', 'Flatbed Truck'],
        'hazardousCargoAllowed': false,
        'oilfieldAllowed': true,
        'pdoPassportStatus': 'Expired',
        'defensiveDrivingStatus': 'Valid',
        'h2sStatus': 'Valid',
        'ftwStatus': 'Valid',
      },
      {
        'driverId': 'DRV007',
        'name': 'Nasser Al Riyami',
        'employeeRef': 'EMP-DR-007',
        'licenseNo': 'OM-LIC-402178',
        'licenseType': 'Light Vehicle',
        'expiryDate': '2027-01-12',
        'heavyVehicleAllowed': false,
        'phone': '+968-97890123',
        'nationality': 'Omani',
        'baseLocation': 'Muscat',
        'experience': 6,
        'dfmsDeviceId': 'DFMS-DRV007',
        'status': 'Suspended',
        'active': true,
        'assignmentAllowed': false,
        'dispatchAllowed': false,
        'dispatchBlocked': true,
        'blockReason': 'Pending safety investigation',
        'suspended': true,
        'suspensionReason': 'Pending safety investigation',
        'allowedVehicleTypes': ['Light Vehicle (4WD)', 'Pickup 1 Ton'],
        'hazardousCargoAllowed': false,
        'oilfieldAllowed': false,
        'defensiveDrivingStatus': 'Expired',
        'incidentCount': 3,
      },
    ];
  }
}
