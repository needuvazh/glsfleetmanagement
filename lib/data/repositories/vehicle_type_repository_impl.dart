import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/vehicle_type.dart';
import '../../domain/repositories/vehicle_type_repository.dart';
import '../datasources/local/vehicle_type_local_datasource.dart';
import '../models/vehicle_type_model.dart';

class VehicleTypeRepositoryImpl implements VehicleTypeRepository {
  VehicleTypeRepositoryImpl({
    required VehicleTypeLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  static const _cacheKey = 'vehicle_type_master_records_v2';
  final VehicleTypeLocalDataSource _localDataSource;
  List<VehicleType>? _cache;

  Future<List<VehicleType>> _ensureLoaded() async {
    if (_cache != null) {
      return _cache!;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final cached = decoded
            .map((entry) => VehicleTypeModel.fromMap(
                  Map<String, dynamic>.from(entry),
                ))
            .cast<VehicleType>()
            .toList();
        _cache = cached;
        return cached;
      } catch (_) {
        // Fall back to asset load.
      }
    }

    final loaded = await _localDataSource.loadVehicleTypes();
    _cache = loaded;
    await _persist();
    return loaded;
  }

  Future<void> _persist() async {
    if (_cache == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final payload = _cache!.map(_toMap).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  Map<String, dynamic> _toMap(VehicleType item) {
    return {
      'name': item.name,
      'code': item.code,
      'category': item.category,
      'vehicleClass': item.vehicleClass,
      'ownershipTypes': item.ownershipTypes,
      'vendorRequired': item.vendorRequired,
      'loadType': item.loadType,
      'transportType': item.transportType,
      'maxTripsPerDay': item.maxTripsPerDay,
      'allowMultiDayJourney': item.allowMultiDayJourney,
      'allowMultipleStops': item.allowMultipleStops,
      'maxStopsAllowed': item.maxStopsAllowed,
      'requireRoutePlanApproval': item.requireRoutePlanApproval,
      'isHazardous': item.isHazardous,
      'requiresSafetyCompliance': item.requiresSafetyCompliance,
      'temperatureControlled': item.temperatureControlled,
      'requiresEscortVehicle': item.requiresEscortVehicle,
      'defaultCapacity': item.defaultCapacity,
      'capacityUnit': item.capacityUnit,
      'features': item.features,
      'requiresInsurance': item.requiresInsurance,
      'requiresPermit': item.requiresPermit,
      'requiresFitness': item.requiresFitness,
      'requiresPollution': item.requiresPollution,
      'complianceMode': item.complianceMode,
      'documentRequirements': [
        for (final doc in item.documentRequirements)
          {
            'documentName': doc.documentName,
            'mandatory': doc.mandatory,
            'validityValue': doc.validityValue,
            'validityUnit': doc.validityUnit,
            'applicableFor': doc.applicableFor,
          },
      ],
      'status': item.status,
      'isDefaultType': item.isDefaultType,
    };
  }

  @override
  Future<List<VehicleType>> getVehicleTypes() async {
    final list = await _ensureLoaded();
    return List<VehicleType>.from(list);
  }

  @override
  Future<List<VehicleType>> addVehicleType(VehicleType item) async {
    final list = await _ensureLoaded();
    _cache = [item, ...list];
    await _persist();
    return List<VehicleType>.from(_cache!);
  }

  @override
  Future<List<VehicleType>> updateVehicleType(
    String originalCode,
    VehicleType item,
  ) async {
    final list = await _ensureLoaded();
    _cache = list.map((entry) {
      if (entry.code.toLowerCase() == originalCode.toLowerCase()) {
        return item;
      }
      return entry;
    }).toList();

    await _persist();
    return List<VehicleType>.from(_cache!);
  }

  @override
  Future<List<VehicleType>> deleteVehicleType(String code) async {
    final list = await _ensureLoaded();
    _cache = list
        .where((entry) => entry.code.toLowerCase() != code.toLowerCase())
        .toList();

    await _persist();
    return List<VehicleType>.from(_cache!);
  }
}
