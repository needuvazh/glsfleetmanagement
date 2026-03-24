import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/vehicle_type_model.dart';

abstract class VehicleTypeLocalDataSource {
  Future<List<VehicleTypeModel>> loadVehicleTypes();
}

class VehicleTypeLocalDataSourceImpl implements VehicleTypeLocalDataSource {
  const VehicleTypeLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.vehicleTypesMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<VehicleTypeModel>> loadVehicleTypes() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as List<dynamic>;

    return data
        .map((item) => VehicleTypeModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
