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
        'routeRiskLevel': 'Low',
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
        'status': 'Accepted',
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
        'cargoType': 'Industrial Chemicals',
        'weightVolume': '8 Tons',
        'pickup': 'Salalah',
        'delivery': 'Thumrait',
        'requestDate': '2026-03-12',
        'notes': 'Hazardous cargo. MSDS required.',
        'hazardous': true,
        'pdoSpec': 'PDO',
        'route': 'Salalah -> Thumrait',
        'routeMasterId': 'RT002',
        'routeCode': 'SAL-THU',
        'routeName': 'Salalah to Thumrait',
        'routeRiskLevel': 'Medium',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '10 Drums',
        'dimensions': 'Standard Drum',
        'customerSpecificRequirement': 'Hazmat certified driver mandatory.',
        'requiredVehicleType': 'Tanker',
        'tentativeDispatchDate': '2026-03-26',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': true,
        'status': 'Accepted',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 3200.0,
        'feasibilityRemarks': 'Tanker available.',
        'vehicleSuitability': 'Tanker available.',
        'routeSuitability': 'Safe route.',
        'manpowerReadiness': 'Driver available.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Net 30',
        'reviewedBy': 'Ops Manager',
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
        'status': 'Accepted',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 6200.0,
        'feasibilityRemarks': 'Oversize permit pending.',
        'vehicleSuitability': 'Heavy load flatbed available.',
        'routeSuitability': 'Route SHR-IBR suitable for oversize with escort.',
        'manpowerReadiness': 'Escort team available.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Net 15',
        'reviewedBy': 'Ops Manager',
        'createdAt': '2026-03-14T11:00:00.000',
        'updatedAt': '2026-03-20T11:00:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-004',
        'requestSource': 'Email',
        'customerName': 'Shell Oman',
        'requestType': 'Transport Request',
        'emailOrReference': 'ops@shelloman.com',
        'contact': '+968-24701234',
        'cargoType': 'Valve Components',
        'weightVolume': '5 Tons',
        'pickup': 'Nizwa',
        'delivery': 'Duqm',
        'requestDate': '2026-03-16',
        'notes': 'Maintenance spares for Duqm plant.',
        'hazardous': false,
        'pdoSpec': 'PDO',
        'route': 'Nizwa -> Duqm',
        'routeMasterId': 'RT004',
        'routeCode': 'NZW-DUQ',
        'routeName': 'Nizwa to Duqm',
        'routeRiskLevel': 'Low',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '12 Crates',
        'dimensions': '1.2m x 1.2m x 1.2m',
        'customerSpecificRequirement': 'Standard transport.',
        'requiredVehicleType': 'Flatbed Truck',
        'tentativeDispatchDate': '2026-03-25',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Accepted',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 1800.0,
        'feasibilityRemarks': 'Route clear.',
        'vehicleSuitability': 'Standard truck available.',
        'routeSuitability': 'Standard route.',
        'manpowerReadiness': 'Driver available.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Net 30',
        'reviewedBy': 'Ops Manager',
        'createdAt': '2026-03-16T10:00:00.000',
        'updatedAt': '2026-03-16T10:00:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-005',
        'requestSource': 'Email',
        'customerName': 'BSC (Bahwan Cybertek)',
        'requestType': 'Transport Request',
        'emailOrReference': 'ref-bsc-5120',
        'contact': '+968-24724700',
        'cargoType': 'IT Server Equipment',
        'weightVolume': '2 Tons',
        'pickup': 'Muscat',
        'delivery': 'Salalah',
        'requestDate': '2026-03-18',
        'notes': 'Sensitive equipment. Temperature control required.',
        'hazardous': false,
        'pdoSpec': 'Non-PDO',
        'route': 'Muscat -> Salalah',
        'routeMasterId': 'RT005',
        'routeCode': 'MCT-SAL',
        'routeName': 'Muscat to Salalah',
        'routeRiskLevel': 'Medium',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '4 Racks',
        'dimensions': '6.2m x 2.2m x 2.2m',
        'customerSpecificRequirement': 'Shock-absorbing vehicle. Real-time monitoring.',
        'requiredVehicleType': 'Curtainsider Van',
        'tentativeDispatchDate': '2026-03-22',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Accepted',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 2100.0,
        'feasibilityRemarks': 'Climate control van available.',
        'vehicleSuitability': 'Air-ride suspension van available.',
        'routeSuitability': 'Standard highway route.',
        'manpowerReadiness': 'Specialized driver available.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Advance 50%',
        'reviewedBy': 'Commercial Manager',
        'createdAt': '2026-03-18T09:00:00.000',
        'updatedAt': '2026-03-22T15:00:00.000',
      },
      {
        'enquiryNumber': 'ENQ-2026-006',
        'requestSource': 'Direct',
        'customerName': 'BSC (Bahwan Cybertek)',
        'requestType': 'Transport Request',
        'emailOrReference': 'dispatch@bsc.om',
        'contact': '+968-24724700',
        'cargoType': 'Office Furniture',
        'weightVolume': '3 Tons',
        'pickup': 'Sohar',
        'delivery': 'Muscat',
        'requestDate': '2026-03-19',
        'notes': 'Standard office chairs and desks.',
        'hazardous': false,
        'pdoSpec': 'Non-PDO',
        'route': 'Sohar -> Muscat',
        'routeMasterId': 'RT006',
        'routeCode': 'SHR-MCT',
        'routeName': 'Sohar to Muscat',
        'routeRiskLevel': 'Low',
        'routeOperationalStatus': 'Active',
        'routeRestricted': false,
        'routeRestrictionReason': '',
        'quantity': '50 Units',
        'dimensions': 'Standard Furniture',
        'customerSpecificRequirement': 'Standard transport.',
        'requiredVehicleType': 'Flatbed Truck',
        'tentativeDispatchDate': '2026-03-24',
        'routeRiskFlag': false,
        'hazardousComplianceRequired': false,
        'status': 'Accepted',
        'cancellationReason': '',
        'feasibilityStatus': 'Feasible',
        'estimatedCost': 1200.0,
        'feasibilityRemarks': 'Route clear.',
        'vehicleSuitability': 'Standard truck available.',
        'routeSuitability': 'Standard route.',
        'manpowerReadiness': 'Driver available.',
        'creditCheckStatus': 'Cleared',
        'paymentTerms': 'Net 30',
        'reviewedBy': 'Ops Manager',
        'createdAt': '2026-03-19T10:00:00.000',
        'updatedAt': '2026-03-19T10:00:00.000',
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
        "status": "Accepted",
        "decisionResponseDate": "2026-03-20",
        "customerPoRef": "OQ-PO-0091",
        "rejectionReason": "",
        "createdAt": "2026-03-16T09:00:00.000",
        "updatedAt": "2026-03-20T11:00:00.000"
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
        "status": "Accepted",
        "decisionResponseDate": "2026-03-22",
        "customerPoRef": "BSC-PO-4421",
        "rejectionReason": "",
        "createdAt": "2026-03-19T11:00:00.000",
        "updatedAt": "2026-03-22T15:00:00.000"
      },
      {
        "quoteRef": "QUO-2026-004",
        "enquiryRef": "ENQ-2026-002",
        "customer": "PDO (Petroleum Development Oman)",
        "date": "2026-03-14",
        "validityDate": "2026-04-14",
        "rate": 3200.00,
        "costSummary": "Tanker x1 trip @ 3200 OMR",
        "terms": "Net 30 days",
        "remarks": "Hazardous compliance included.",
        "status": "Accepted",
        "decisionResponseDate": "2026-03-20",
        "customerPoRef": "PDO-PO-1122",
        "rejectionReason": "",
        "createdAt": "2026-03-14T09:00:00.000",
        "updatedAt": "2026-03-20T10:00:00.000"
      },
      {
        "quoteRef": "QUO-2026-005",
        "enquiryRef": "ENQ-2026-004",
        "customer": "Shell Oman",
        "date": "2026-03-17",
        "validityDate": "2026-04-17",
        "rate": 1800.00,
        "costSummary": "Flatbed Truck x1 trip @ 1800 OMR",
        "terms": "Net 30 days",
        "remarks": "Standard delivery spares.",
        "status": "Accepted",
        "decisionResponseDate": "2026-03-21",
        "customerPoRef": "SHO-PO-9921",
        "rejectionReason": "",
        "createdAt": "2026-03-17T09:00:00.000",
        "updatedAt": "2026-03-21T10:00:00.000"
      },
      {
        "quoteRef": "QUO-2026-006",
        "enquiryRef": "ENQ-2026-006",
        "customer": "BSC (Bahwan Cybertek)",
        "date": "2026-03-20",
        "validityDate": "2026-04-20",
        "rate": 1200.00,
        "costSummary": "Flatbed Truck x1 trip @ 1200 OMR",
        "terms": "Net 30 days",
        "remarks": "Office furniture relocation.",
        "status": "Accepted",
        "decisionResponseDate": "2026-03-22",
        "customerPoRef": "BSC-PO-5511",
        "rejectionReason": "",
        "createdAt": "2026-03-20T09:00:00.000",
        "updatedAt": "2026-03-22T10:00:00.000"
      }
    ];
  }

  List<Map<String, dynamic>> _seedFlowWorkOrders() {
    return [
      {
        'woId': 'WO-2026-001',
        'requestId': 'ENQ-2026-001',
        'linkedEnquiryNumber': 'ENQ-2026-001',
        'linkedQuotationRef': 'QUO-2026-001',
        'client': 'Shell Oman',
        'customer': 'Shell Oman',
        'route': 'Muscat -> Fahud',
        'routeMasterId': 'RT001',
        'cargo': 'Oilfield Equipment',
        'status': 'Open',
        'routeRiskLevel': 'Low',
        'serviceStartDate': '2026-03-26T08:00:00.000Z',
        'serviceEndDate': '2026-03-27T18:00:00.000Z',
        'internalNotes': 'Follow PDO safety rules.',
        'assignedSupervisor': '',
        'assignedVehicleNo': '',
        'assignedDriverId': '',
        'assignedTrailerId': '',
      },
      {
        'woId': 'WO-2026-002',
        'requestId': 'ENQ-2026-003',
        'linkedEnquiryNumber': 'ENQ-2026-003',
        'linkedQuotationRef': 'QUO-2026-002',
        'client': 'OQ Logistics',
        'customer': 'OQ Logistics',
        'route': 'Sohar -> Ibri',
        'routeMasterId': 'RT003',
        'cargo': 'Heavy Machinery',
        'status': 'Ready for Dispatch',
        'routeRiskLevel': 'High',
        'serviceStartDate': '2026-03-28T06:00:00.000Z',
        'serviceEndDate': '2026-03-29T12:00:00.000Z',
        'internalNotes': 'Oversize escort coordinated.',
      },
      {
        'woId': 'WO-2026-003',
        'requestId': 'ENQ-2026-005',
        'linkedEnquiryNumber': 'ENQ-2026-005',
        'linkedQuotationRef': 'QUO-2026-003',
        'client': 'BSC (Bahwan Cybertek)',
        'customer': 'BSC (Bahwan Cybertek)',
        'route': 'Muscat -> Salalah',
        'routeMasterId': 'RT005',
        'cargo': 'IT Server Equipment',
        'status': 'In Transit',
        'routeRiskLevel': 'Medium',
        'serviceStartDate': '2026-03-22T20:00:00.000Z',
        'serviceEndDate': '2026-03-24T08:00:00.000Z',
        'internalNotes': 'Fragile load.',
      },
      {
        'woId': 'WO-2026-004',
        'requestId': 'ENQ-2026-002',
        'linkedEnquiryNumber': 'ENQ-2026-002',
        'linkedQuotationRef': 'QUO-2026-004',
        'client': 'OQ Logistics',
        'customer': 'PDO (Petroleum Development Oman)',
        'route': 'Salalah -> Thumrait',
        'routeMasterId': 'RT002',
        'cargo': 'Industrial Chemicals',
        'status': 'Ready for Dispatch',
        'routeRiskLevel': 'Medium',
        'serviceStartDate': '2026-03-26T10:00:00.000Z',
        'serviceEndDate': '2026-03-26T16:00:00.000Z',
        'internalNotes': 'Hazmat tanker required.',
      },
      {
        'woId': 'WO-2026-005',
        'requestId': 'ENQ-2026-004',
        'linkedEnquiryNumber': 'ENQ-2026-004',
        'linkedQuotationRef': 'QUO-2026-005',
        'client': 'Shell Oman',
        'customer': 'Shell Oman',
        'route': 'Nizwa -> Duqm',
        'routeMasterId': 'RT004',
        'cargo': 'Valve Components',
        'status': 'In Transit',
        'routeRiskLevel': 'Low',
        'serviceStartDate': '2026-03-25T07:30:00.000Z',
        'serviceEndDate': '2026-03-27T14:45:00.000Z',
        'assignedVehicleNo': '',
        'assignedDriverId': '',
      },
      {
        'woId': 'WO-2026-006',
        'requestId': 'ENQ-2026-006',
        'linkedEnquiryNumber': 'ENQ-2026-006',
        'linkedQuotationRef': 'QUO-2026-006',
        'client': 'BSC (Bahwan Cybertek)',
        'customer': 'BSC (Bahwan Cybertek)',
        'route': 'Sohar -> Muscat',
        'routeMasterId': 'RT006',
        'cargo': 'Office Furniture',
        'status': 'Delivered',
        'routeRiskLevel': 'Low',
        'serviceStartDate': '2026-03-24T09:00:00.000Z',
        'serviceEndDate': '2026-03-24T17:00:00.000Z',
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
