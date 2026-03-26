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
  static const _customerRequestsCacheKey = 'master_customer_requests_v1';
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

  @override
  Future<List<QuotationModel>> getQuotations() async {
    final list = await _readList(AppConstants.quotationsMockPath);
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
        'requestId': 'REQ001',
        'clientName': 'Shell',
        'clientType': 'PDO',
        'cargo': 'Oilfield Equipment',
        'pickup': 'Muscat',
        'drop': 'Sohar',
        'weight': 1200,
        'status': 'Approved',
        'requiredVehicleType': 'Prime Mover',
      },
      {
        'requestId': 'REQ003',
        'clientName': 'PDO',
        'clientType': 'PDO',
        'cargo': 'Hazardous Chemical',
        'pickup': 'Muscat',
        'drop': 'Fahud',
        'weight': 650,
        'hazardous': true,
        'status': 'Approved',
        'requiredVehicleType': 'Tanker',
      },
      {
        'requestId': 'REQ004',
        'clientName': 'OQ Logistics',
        'clientType': 'Non-PDO',
        'cargo': 'Heavy Equipment',
        'pickup': 'Sohar',
        'drop': 'Ibri',
        'weight': 3000,
        'status': 'Approved',
        'requiredVehicleType': 'Flatbed Truck',
      },
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
