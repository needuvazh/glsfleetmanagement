import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/fleet_master_model.dart';
import '../domain/vehicle_type_master_model.dart';

abstract class FleetMasterMockDataSource {
  Future<List<FleetMasterModel>> getFleets();
  Future<FleetMasterModel?> getFleetById(String fleetId);
  Future<List<FleetMasterModel>> addFleet(FleetMasterModel item);
  Future<List<FleetMasterModel>> updateFleet(FleetMasterModel item);
  Future<List<FleetMasterModel>> deleteFleet(String fleetId);
}

class FleetMasterMockDataSourceImpl implements FleetMasterMockDataSource {
  FleetMasterMockDataSourceImpl();

  static const _cacheKey = 'fleet_master_records_v2';
  List<FleetMasterModel>? _items;
  int _sequence = 5;

  Future<void> _ensureInitialized() async {
    if (_items != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _items = decoded
            .map((entry) => _fromMap(Map<String, dynamic>.from(entry)))
            .toList();
      } catch (_) {
        _items = _seedItems();
      }
    } else {
      _items = _seedItems();
    }

    _sequence = _nextSequence(_items!);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(_items!.map(_toMap).toList()),
    );
  }

  @override
  Future<List<FleetMasterModel>> getFleets() async {
    await _ensureInitialized();
    return _items!.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<FleetMasterModel?> getFleetById(String fleetId) async {
    await _ensureInitialized();
    for (final item in _items!) {
      if (item.fleetId == fleetId) {
        return item.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<FleetMasterModel>> addFleet(FleetMasterModel item) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final next = item.copyWith(
      fleetId: item.fleetId.trim().isEmpty ? _nextFleetId() : item.fleetId,
      createdAt: now,
      updatedAt: now,
    );
    _items!.add(next);
    await _persist();
    return getFleets();
  }

  @override
  Future<List<FleetMasterModel>> updateFleet(FleetMasterModel item) async {
    await _ensureInitialized();
    final index = _items!.indexWhere((entry) => entry.fleetId == item.fleetId);
    if (index == -1) {
      return getFleets();
    }

    final existing = _items![index];
    _items![index] = item.copyWith(
      createdAt: existing.createdAt,
      createdBy: existing.createdBy,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return getFleets();
  }

  @override
  Future<List<FleetMasterModel>> deleteFleet(String fleetId) async {
    await _ensureInitialized();
    _items!.removeWhere((entry) => entry.fleetId == fleetId);
    await _persist();
    return getFleets();
  }

  String _nextFleetId() {
    final id = 'FLT-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
  }

  int _nextSequence(List<FleetMasterModel> items) {
    var maxValue = 0;
    for (final item in items) {
      final parsed = int.tryParse(item.fleetId.split('-').last) ?? 0;
      if (parsed > maxValue) {
        maxValue = parsed;
      }
    }
    return maxValue + 1;
  }

  FleetMasterModel _fromMap(Map<String, dynamic> map) {
    return FleetMasterModel(
      fleetId: map['fleetId'] as String? ?? '',
      fleetNumber: map['fleetNumber'] as String? ?? '',
      vehicleTypeId: map['vehicleTypeId'] as String? ?? '',
      ownershipType: _enumByName(
        OwnershipType.values,
        map['ownershipType'] as String?,
        OwnershipType.owned,
      ),
      status: _enumByName(
        RecordStatusType.values,
        map['status'] as String?,
        RecordStatusType.active,
      ),
      registrationNumber: map['registrationNumber'] as String? ?? '',
      registrationExpiryDate:
          DateTime.tryParse(map['registrationExpiryDate'] as String? ?? '') ??
              DateTime.now(),
      insuranceExpiryDate:
          DateTime.tryParse(map['insuranceExpiryDate'] as String? ?? '') ??
              DateTime.now(),
      permitExpiryDate:
          DateTime.tryParse(map['permitExpiryDate'] as String? ?? '') ??
              DateTime.now(),
      rasExpiryDate: DateTime.tryParse(map['rasExpiryDate'] as String? ?? '') ??
          DateTime.now(),
      inspectionDueDate:
          DateTime.tryParse(map['inspectionDueDate'] as String? ?? '') ??
              DateTime.now(),
      ivmsInstalled: map['ivmsInstalled'] as bool? ?? false,
      dfmsInstalled: map['dfmsInstalled'] as bool? ?? false,
      capacityOverride: (map['capacityOverride'] as num?)?.toDouble(),
      axleType: _enumByName(
        AxleType.values,
        map['axleType'] as String?,
        AxleType.axle4x2,
      ),
      fuelType: _enumByName(
        FuelType.values,
        map['fuelType'] as String?,
        FuelType.diesel,
      ),
      bodyType: _enumByName(
        BodyType.values,
        map['bodyType'] as String?,
        BodyType.flatbed,
      ),
      availabilityStatus: _enumByName(
        AvailabilityStatusType.values,
        map['availabilityStatus'] as String?,
        AvailabilityStatusType.available,
      ),
      maintenanceStatus: _enumByName(
        MaintenanceStatusType.values,
        map['maintenanceStatus'] as String?,
        MaintenanceStatusType.operational,
      ),
      currentTripId: map['currentTripId'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      updatedBy: map['updatedBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> _toMap(FleetMasterModel item) {
    return {
      'fleetId': item.fleetId,
      'fleetNumber': item.fleetNumber,
      'vehicleTypeId': item.vehicleTypeId,
      'ownershipType': item.ownershipType.name,
      'status': item.status.name,
      'registrationNumber': item.registrationNumber,
      'registrationExpiryDate': item.registrationExpiryDate.toIso8601String(),
      'insuranceExpiryDate': item.insuranceExpiryDate.toIso8601String(),
      'permitExpiryDate': item.permitExpiryDate.toIso8601String(),
      'rasExpiryDate': item.rasExpiryDate.toIso8601String(),
      'inspectionDueDate': item.inspectionDueDate.toIso8601String(),
      'ivmsInstalled': item.ivmsInstalled,
      'dfmsInstalled': item.dfmsInstalled,
      'capacityOverride': item.capacityOverride,
      'axleType': item.axleType.name,
      'fuelType': item.fuelType.name,
      'bodyType': item.bodyType.name,
      'availabilityStatus': item.availabilityStatus.name,
      'maintenanceStatus': item.maintenanceStatus.name,
      'currentTripId': item.currentTripId,
      'vendorId': item.vendorId,
      'createdAt': item.createdAt.toIso8601String(),
      'createdBy': item.createdBy,
      'updatedAt': item.updatedAt.toIso8601String(),
      'updatedBy': item.updatedBy,
    };
  }

  T _enumByName<T>(List<T> values, String? raw, T fallback) {
    for (final value in values) {
      if (value is Enum && value.name == raw) {
        return value;
      }
    }
    return fallback;
  }
}

List<FleetMasterModel> _seedItems() {
  final now = DateTime.now();
  return [
    FleetMasterModel(
      fleetId: 'FLT-001',
      fleetNumber: 'PM-101',
      vehicleTypeId: 'VT-001',
      ownershipType: OwnershipType.owned,
      status: RecordStatusType.active,
      registrationNumber: 'OMN-78654',
      registrationExpiryDate: DateTime(now.year + 1, 8, 20),
      insuranceExpiryDate: DateTime(now.year, now.month, now.day + 14),
      permitExpiryDate: DateTime(now.year + 1, 2, 1),
      rasExpiryDate: DateTime(now.year + 1, 1, 15),
      inspectionDueDate: DateTime(now.year, now.month + 1, 10),
      ivmsInstalled: true,
      dfmsInstalled: true,
      capacityOverride: null,
      axleType: AxleType.axle6x4,
      fuelType: FuelType.diesel,
      bodyType: BodyType.flatbed,
      availabilityStatus: AvailabilityStatusType.available,
      maintenanceStatus: MaintenanceStatusType.operational,
      currentTripId: '',
      vendorId: '',
      createdAt: now,
      createdBy: 'fleet.admin',
      updatedAt: now,
      updatedBy: 'fleet.admin',
    ),
    FleetMasterModel(
      fleetId: 'FLT-002',
      fleetNumber: 'TRK-204',
      vehicleTypeId: 'VT-002',
      ownershipType: OwnershipType.leased,
      status: RecordStatusType.active,
      registrationNumber: 'OMN-55321',
      registrationExpiryDate: DateTime(now.year + 1, 4, 12),
      insuranceExpiryDate: DateTime(now.year + 1, 3, 30),
      permitExpiryDate: DateTime(now.year, now.month, now.day - 3),
      rasExpiryDate: DateTime(now.year + 1, 5, 1),
      inspectionDueDate: DateTime(now.year, now.month, now.day + 3),
      ivmsInstalled: true,
      dfmsInstalled: false,
      capacityOverride: 12,
      axleType: AxleType.axle4x2,
      fuelType: FuelType.diesel,
      bodyType: BodyType.box,
      availabilityStatus: AvailabilityStatusType.underReview,
      maintenanceStatus: MaintenanceStatusType.preventiveDue,
      currentTripId: 'WO-2026-118',
      vendorId: 'VND-002',
      createdAt: now,
      createdBy: 'ops.supervisor',
      updatedAt: now,
      updatedBy: 'ops.supervisor',
    ),
    FleetMasterModel(
      fleetId: 'FLT-003',
      fleetNumber: 'BUS-501',
      vehicleTypeId: 'VT-003',
      ownershipType: OwnershipType.contracted,
      status: RecordStatusType.inactive,
      registrationNumber: 'OMN-88110',
      registrationExpiryDate: DateTime(now.year + 1, 10, 18),
      insuranceExpiryDate: DateTime(now.year + 1, 8, 10),
      permitExpiryDate: DateTime(now.year + 1, 7, 2),
      rasExpiryDate: DateTime(now.year + 1, 6, 1),
      inspectionDueDate: DateTime(now.year + 1, 1, 20),
      ivmsInstalled: false,
      dfmsInstalled: false,
      capacityOverride: null,
      axleType: AxleType.axle4x2,
      fuelType: FuelType.diesel,
      bodyType: BodyType.busCoach,
      availabilityStatus: AvailabilityStatusType.maintenance,
      maintenanceStatus: MaintenanceStatusType.inMaintenance,
      currentTripId: '',
      vendorId: 'VND-005',
      createdAt: now,
      createdBy: 'fleet.admin',
      updatedAt: now,
      updatedBy: 'workshop.lead',
    ),
  ];
}
