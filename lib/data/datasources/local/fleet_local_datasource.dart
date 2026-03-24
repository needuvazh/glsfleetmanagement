import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/fleet_model.dart';

abstract class FleetLocalDataSource {
  Future<List<FleetModel>> getFleets();
}

class FleetLocalDataSourceImpl implements FleetLocalDataSource {
  const FleetLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.fleetMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<FleetModel>> getFleets() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as List<dynamic>;

    return data
        .map((item) => FleetModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
