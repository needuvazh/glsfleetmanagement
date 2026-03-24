import '../../../domain/entities/role_document_mapping_config.dart';

abstract class RoleDocumentMappingMockDataSource {
  Future<RoleDocumentMappingConfig> loadConfig();

  Future<Map<String, List<String>>> saveRoleDocuments(
    String role,
    List<String> documents,
  );
}

class RoleDocumentMappingMockDataSourceImpl
    implements RoleDocumentMappingMockDataSource {
  static const _roles = [
    'Driver',
    'Vehicle',
    'Employee',
    'Vendor',
  ];

  static const _allDocuments = [
    'License Copy',
    'Passport Copy',
    'RC Book',
    'Insurance',
    'ID Proof',
    'Resume',
  ];

  Map<String, List<String>> _roleDocumentMap = {
    'Driver': ['License Copy', 'Passport Copy'],
    'Vehicle': ['RC Book', 'Insurance'],
    'Employee': ['ID Proof'],
    'Vendor': [],
  };

  @override
  Future<RoleDocumentMappingConfig> loadConfig() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return RoleDocumentMappingConfig(
      roles: List<String>.from(_roles),
      allDocuments: List<String>.from(_allDocuments),
      roleDocumentMap: _copyRoleDocumentMap(_roleDocumentMap),
    );
  }

  @override
  Future<Map<String, List<String>>> saveRoleDocuments(
    String role,
    List<String> documents,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedDocuments = <String>[
      for (final document in _allDocuments)
        if (documents.contains(document)) document,
    ];

    _roleDocumentMap = {
      ..._roleDocumentMap,
      role: normalizedDocuments,
    };

    return _copyRoleDocumentMap(_roleDocumentMap);
  }

  Map<String, List<String>> _copyRoleDocumentMap(
    Map<String, List<String>> source,
  ) {
    return {
      for (final entry in source.entries)
        entry.key: List<String>.from(entry.value),
    };
  }
}
