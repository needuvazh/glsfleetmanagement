import '../entities/role_document_mapping_config.dart';
import '../repositories/role_document_mapping_repository.dart';

class GetRoleDocumentMappingConfigUseCase {
  const GetRoleDocumentMappingConfigUseCase(this._repository);

  final RoleDocumentMappingRepository _repository;

  Future<RoleDocumentMappingConfig> call() {
    return _repository.loadConfig();
  }
}

class SaveRoleDocumentMappingUseCase {
  const SaveRoleDocumentMappingUseCase(this._repository);

  final RoleDocumentMappingRepository _repository;

  Future<Map<String, List<String>>> call(
    String role,
    List<String> documents,
  ) {
    return _repository.saveRoleDocuments(role, documents);
  }
}
