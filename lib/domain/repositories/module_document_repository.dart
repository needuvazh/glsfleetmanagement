import '../entities/module_document.dart';

abstract class ModuleDocumentRepository {
  Future<List<ModuleDocument>> getDocuments();

  Future<List<ModuleDocument>> addDocument(ModuleDocument document);

  Future<List<ModuleDocument>> updateDocument(
      String id, ModuleDocument document);

  Future<List<ModuleDocument>> deleteDocument(String id);
}
