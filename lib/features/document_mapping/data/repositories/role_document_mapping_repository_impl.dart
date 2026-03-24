import '../../domain/entities/role_document_mapping_config.dart';
import '../../domain/repositories/role_document_mapping_repository.dart';
import '../datasources/local/role_document_mapping_mock_datasource.dart';

class RoleDocumentMappingRepositoryImpl
    implements RoleDocumentMappingRepository {
  const RoleDocumentMappingRepositoryImpl({
    required RoleDocumentMappingMockDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final RoleDocumentMappingMockDataSource _localDataSource;

  @override
  Future<RoleDocumentMappingConfig> loadConfig() {
    return _localDataSource.loadConfig();
  }

  @override
  Future<Map<String, List<String>>> saveRoleDocuments(
    String role,
    List<String> documents,
  ) {
    return _localDataSource.saveRoleDocuments(role, documents);
  }
}
