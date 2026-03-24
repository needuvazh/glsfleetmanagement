import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/tracking_point_model.dart';

abstract class TrackingLocalDataSource {
  Future<List<TrackingPointModel>> getTrackingPoints();
}

class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  const TrackingLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.fleetMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<TrackingPointModel>> getTrackingPoints() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;

    return list
        .map(
          (entry) => TrackingPointModel.fromFleetMap(entry as Map<String, dynamic>),
        )
        .toList();
  }
}
