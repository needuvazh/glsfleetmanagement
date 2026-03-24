import '../entities/module_document.dart';
import '../repositories/module_document_repository.dart';

class GetModuleDocumentsUseCase {
  const GetModuleDocumentsUseCase(this._repository);

  final ModuleDocumentRepository _repository;

  Future<List<ModuleDocument>> call() {
    return _repository.getDocuments();
  }
}

class AddModuleDocumentUseCase {
  const AddModuleDocumentUseCase(this._repository);

  final ModuleDocumentRepository _repository;

  Future<List<ModuleDocument>> call(ModuleDocument document) {
    return _repository.addDocument(document);
  }
}

class UpdateModuleDocumentUseCase {
  const UpdateModuleDocumentUseCase(this._repository);

  final ModuleDocumentRepository _repository;

  Future<List<ModuleDocument>> call(String id, ModuleDocument document) {
    return _repository.updateDocument(id, document);
  }
}

class DeleteModuleDocumentUseCase {
  const DeleteModuleDocumentUseCase(this._repository);

  final ModuleDocumentRepository _repository;

  Future<List<ModuleDocument>> call(String id) {
    return _repository.deleteDocument(id);
  }
}
