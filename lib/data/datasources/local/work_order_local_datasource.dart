import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/work_order_model.dart';

abstract class WorkOrderLocalDataSource {
  Future<List<WorkOrderModel>> getWorkOrders();
}

class WorkOrderLocalDataSourceImpl implements WorkOrderLocalDataSource {
  const WorkOrderLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.workOrdersMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<WorkOrderModel>> getWorkOrders() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((entry) => WorkOrderModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
