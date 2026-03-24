import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/module_document_local_datasource.dart';
import '../../data/repositories/module_document_repository_impl.dart';
import '../../domain/entities/module_document.dart';
import '../../domain/repositories/module_document_repository.dart';
import '../../domain/usecases/module_document_usecases.dart';

class ModuleDocumentUiState {
  const ModuleDocumentUiState({
    required this.items,
    required this.query,
    required this.roleFilter,
    required this.lastUpdated,
  });

  final List<ModuleDocument> items;
  final String query;
  final String roleFilter;
  final DateTime lastUpdated;

  List<ModuleDocument> get filteredItems {
    final normalized = query.trim().toLowerCase();
    return items.where((item) {
      final rolePass = roleFilter == 'All' || item.targetType == roleFilter;
      if (!rolePass) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }

      final text =
          '${item.id} ${item.documentName} ${item.documentType} ${item.targetType}'
              .toLowerCase();
      return text.contains(normalized);
    }).toList();
  }

  List<ModuleDocument> documentsForRole(String role) {
    return items.where((item) => item.targetType == role).toList();
  }

  ModuleDocumentUiState copyWith({
    List<ModuleDocument>? items,
    String? query,
    String? roleFilter,
    DateTime? lastUpdated,
  }) {
    return ModuleDocumentUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      roleFilter: roleFilter ?? this.roleFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _moduleDocumentLocalDataSourceProvider =
    Provider<ModuleDocumentLocalDataSource>(
  (ref) => ModuleDocumentLocalDataSourceImpl(assetBundle: rootBundle),
);

final _moduleDocumentRepositoryProvider = Provider<ModuleDocumentRepository>(
  (ref) => ModuleDocumentRepositoryImpl(
    localDataSource: ref.watch(_moduleDocumentLocalDataSourceProvider),
  ),
);

final _getModuleDocumentsUseCaseProvider = Provider<GetModuleDocumentsUseCase>(
  (ref) =>
      GetModuleDocumentsUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final _addModuleDocumentUseCaseProvider = Provider<AddModuleDocumentUseCase>(
  (ref) =>
      AddModuleDocumentUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final _deleteModuleDocumentUseCaseProvider =
    Provider<DeleteModuleDocumentUseCase>(
  (ref) =>
      DeleteModuleDocumentUseCase(ref.watch(_moduleDocumentRepositoryProvider)),
);

final moduleDocumentViewModelProvider =
    AsyncNotifierProvider<ModuleDocumentViewModel, ModuleDocumentUiState>(
  ModuleDocumentViewModel.new,
);

class ModuleDocumentViewModel extends AsyncNotifier<ModuleDocumentUiState> {
  static const documentTypes = [
    'PDF',
    'XLSX',
    'DOCX',
    'JPG',
    'PNG',
    'Other',
  ];

  @override
  Future<ModuleDocumentUiState> build() async {
    final items = await ref.watch(_getModuleDocumentsUseCaseProvider).call();
    return ModuleDocumentUiState(
      items: items,
      query: '',
      roleFilter: 'All',
      lastUpdated: DateTime.now(),
    );
  }

  void setQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(query: value));
  }

  void setRoleFilter(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(roleFilter: value));
  }

  Future<String> addDocument({
    required String documentName,
    required String userRole,
    required String documentType,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Document state is not ready.';
    }

    final cleanDocumentName = documentName.trim();
    final cleanUserRole = userRole.trim();
    final cleanDocumentType = documentType.trim();

    if (cleanDocumentName.isEmpty ||
        cleanUserRole.isEmpty ||
        cleanDocumentType.isEmpty) {
      return 'Required document fields are missing.';
    }

    final duplicate = current.items.any(
      (item) =>
          item.targetType.toLowerCase() == cleanUserRole.toLowerCase() &&
          item.documentName.toLowerCase() == cleanDocumentName.toLowerCase(),
    );
    if (duplicate) {
      return 'Document name already exists for this role.';
    }

    final id = _nextId(current.items);
    final document = ModuleDocument(
      id: id,
      documentName: cleanDocumentName,
      targetType: cleanUserRole,
      documentType: cleanDocumentType,
    );

    final next =
        await ref.read(_addModuleDocumentUseCaseProvider).call(document);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Document created successfully.';
  }

  Future<String> deleteDocument(String id) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Document state is not ready.';
    }

    final next = await ref.read(_deleteModuleDocumentUseCaseProvider).call(id);
    state =
        AsyncData(current.copyWith(items: next, lastUpdated: DateTime.now()));
    return 'Document deleted successfully.';
  }

  String _nextId(List<ModuleDocument> items) {
    int maxValue = 0;
    for (final item in items) {
      final raw = item.id.replaceAll('DOC-', '');
      final parsed = int.tryParse(raw);
      if (parsed != null && parsed > maxValue) {
        maxValue = parsed;
      }
    }
    final next = maxValue + 1;
    return 'DOC-${next.toString().padLeft(3, '0')}';
  }
}
