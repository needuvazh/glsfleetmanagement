import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardDataModel> getDashboard();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  const DashboardLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.dashboardMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<DashboardDataModel> getDashboard() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return DashboardDataModel.fromMap(map);
  }
}
