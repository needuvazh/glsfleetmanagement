import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/compliance_record_model.dart';

abstract class ComplianceLocalDataSource {
  Future<List<ComplianceRecordModel>> getComplianceRecords();
}

class ComplianceLocalDataSourceImpl implements ComplianceLocalDataSource {
  const ComplianceLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.complianceMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<ComplianceRecordModel>> getComplianceRecords() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;

    return list
        .map(
          (entry) => ComplianceRecordModel.fromMap(entry as Map<String, dynamic>),
        )
        .toList();
  }
}
