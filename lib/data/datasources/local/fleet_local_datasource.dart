import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/fleet_model.dart';

abstract class FleetLocalDataSource {
  Future<List<FleetModel>> getFleets();
}

class FleetLocalDataSourceImpl implements FleetLocalDataSource {
  static const _cacheKey = 'fleet_master_records_v1';

  const FleetLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.fleetMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<FleetModel>> getFleets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    List<dynamic> data;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        data = decoded is List ? decoded : _seedFleet();
      } catch (_) {
        data = await _readAssetFleetOrSeed();
      }
    } else {
      data = await _readAssetFleetOrSeed();
      await prefs.setString(_cacheKey, jsonEncode(data));
    }

    return data
        .map((item) => FleetModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> _readAssetFleetOrSeed() async {
    try {
      final jsonString = await _assetBundle.loadString(_assetPath);
      final decoded = jsonDecode(jsonString);
      if (decoded is List<dynamic> && decoded.isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // Fallback to in-memory seed when asset file is unavailable.
    }
    return _seedFleet();
  }

  List<Map<String, dynamic>> _seedFleet() {
    return [
      {
        'id': 'FLT-001',
        'vehicleNumber': 'TRK-101',
        'type': 'Flatbed Truck',
        'status': 'active',
        'driver': 'DRV001',
        'fuelLevel': 84,
        'odometerKm': 198540,
        'lastServiceDate': '2026-02-14',
        'location': {'lat': 23.5880, 'lng': 58.3829}
      },
      {
        'id': 'FLT-002',
        'vehicleNumber': 'PM-205',
        'type': 'Prime Mover',
        'status': 'maintenance',
        'driver': 'DRV004',
        'fuelLevel': 52,
        'odometerKm': 264210,
        'lastServiceDate': '2026-01-03',
        'location': {'lat': 23.7056, 'lng': 57.9550}
      },
      {
        'id': 'FLT-003',
        'vehicleNumber': 'TNK-220',
        'type': 'Tanker',
        'status': 'active',
        'driver': 'DRV005',
        'fuelLevel': 77,
        'odometerKm': 229880,
        'lastServiceDate': '2026-03-01',
        'location': {'lat': 23.6139, 'lng': 58.5918}
      }
    ];
  }
}
