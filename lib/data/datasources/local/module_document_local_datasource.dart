import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/module_document_model.dart';

abstract class ModuleDocumentLocalDataSource {
  Future<List<ModuleDocumentModel>> loadDocuments();
}

class ModuleDocumentLocalDataSourceImpl
    implements ModuleDocumentLocalDataSource {
  const ModuleDocumentLocalDataSourceImpl({
    required AssetBundle assetBundle,
    String assetPath = AppConstants.moduleDocumentsMockPath,
  })  : _assetBundle = assetBundle,
        _assetPath = assetPath;

  final AssetBundle _assetBundle;
  final String _assetPath;

  @override
  Future<List<ModuleDocumentModel>> loadDocuments() async {
    final jsonString = await _assetBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as List<dynamic>;

    return data
        .map((entry) =>
            ModuleDocumentModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
