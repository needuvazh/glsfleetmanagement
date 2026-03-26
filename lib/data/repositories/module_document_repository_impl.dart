import '../../domain/entities/module_document.dart';
import '../../domain/repositories/module_document_repository.dart';
import '../datasources/local/module_document_local_datasource.dart';

class ModuleDocumentRepositoryImpl implements ModuleDocumentRepository {
  ModuleDocumentRepositoryImpl({
    required ModuleDocumentLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final ModuleDocumentLocalDataSource _localDataSource;
  List<ModuleDocument>? _cache;

  Future<List<ModuleDocument>> _ensureLoaded() async {
    if (_cache != null) {
      return _cache!;
    }

    final loaded = await _localDataSource.loadDocuments();
    _cache = loaded;
    return loaded;
  }

  @override
  Future<List<ModuleDocument>> getDocuments() async {
    final list = await _ensureLoaded();
    return List<ModuleDocument>.from(list);
  }

  @override
  Future<List<ModuleDocument>> addDocument(ModuleDocument document) async {
    final list = await _ensureLoaded();
    _cache = [document, ...list];
    await _localDataSource.saveDocuments(_cache!);
    return List<ModuleDocument>.from(_cache!);
  }

  @override
  Future<List<ModuleDocument>> updateDocument(
    String id,
    ModuleDocument document,
  ) async {
    final list = await _ensureLoaded();
    _cache = list.map((item) {
      if (item.id == id) {
        return document;
      }
      return item;
    }).toList();
    await _localDataSource.saveDocuments(_cache!);
    return List<ModuleDocument>.from(_cache!);
  }

  @override
  Future<List<ModuleDocument>> deleteDocument(String id) async {
    final list = await _ensureLoaded();
    _cache = list.where((item) => item.id != id).toList();
    await _localDataSource.saveDocuments(_cache!);
    return List<ModuleDocument>.from(_cache!);
  }
}
