import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/journey_plan_model.dart';

abstract class JourneyPlanLocalDataSource {
  Future<List<JourneyPlanModel>> getPlans();
}

class JourneyPlanLocalDataSourceImpl implements JourneyPlanLocalDataSource {
  const JourneyPlanLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.journeyPlansMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<JourneyPlanModel>> getPlans() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((entry) => JourneyPlanModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
