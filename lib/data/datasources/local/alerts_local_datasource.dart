import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/alert_item_model.dart';

abstract class AlertsLocalDataSource {
  Future<List<AlertItemModel>> getAlerts();
}

class AlertsLocalDataSourceImpl implements AlertsLocalDataSource {
  const AlertsLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.alertsMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<AlertItemModel>> getAlerts() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;

    return list
        .map((entry) => AlertItemModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
