import '../entities/role_document_mapping_config.dart';

abstract class RoleDocumentMappingRepository {
  Future<RoleDocumentMappingConfig> loadConfig();

  Future<Map<String, List<String>>> saveRoleDocuments(
    String role,
    List<String> documents,
  );
}
