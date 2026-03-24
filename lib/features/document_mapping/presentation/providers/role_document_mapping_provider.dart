import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/role_document_mapping_mock_datasource.dart';
import '../../data/repositories/role_document_mapping_repository_impl.dart';
import '../../domain/repositories/role_document_mapping_repository.dart';
import '../../domain/usecases/role_document_mapping_usecases.dart';

class RoleDocumentMappingState {
  const RoleDocumentMappingState({
    required this.roles,
    required this.selectedRole,
    required this.allDocuments,
    required this.roleDocumentMap,
    required this.selectedDocuments,
    required this.isSaving,
    required this.lastUpdated,
  });

  final List<String> roles;
  final String? selectedRole;
  final List<String> allDocuments;
  final Map<String, List<String>> roleDocumentMap;
  final Set<String> selectedDocuments;
  final bool isSaving;
  final DateTime lastUpdated;

  List<String> get selectedDocumentsInDisplayOrder {
    return [
      for (final document in allDocuments)
        if (selectedDocuments.contains(document)) document,
    ];
  }

  List<String> documentsForRole(String role) {
    return roleDocumentMap[role] ?? const [];
  }

  RoleDocumentMappingState copyWith({
    List<String>? roles,
    String? selectedRole,
    bool clearSelectedRole = false,
    List<String>? allDocuments,
    Map<String, List<String>>? roleDocumentMap,
    Set<String>? selectedDocuments,
    bool? isSaving,
    DateTime? lastUpdated,
  }) {
    return RoleDocumentMappingState(
      roles: roles ?? this.roles,
      selectedRole: clearSelectedRole ? null : (selectedRole ?? this.selectedRole),
      allDocuments: allDocuments ?? this.allDocuments,
      roleDocumentMap: roleDocumentMap ?? this.roleDocumentMap,
      selectedDocuments: selectedDocuments ?? this.selectedDocuments,
      isSaving: isSaving ?? this.isSaving,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _roleDocumentMappingDataSourceProvider =
    Provider<RoleDocumentMappingMockDataSource>(
  (ref) => RoleDocumentMappingMockDataSourceImpl(),
);

final _roleDocumentMappingRepositoryProvider =
    Provider<RoleDocumentMappingRepository>(
  (ref) => RoleDocumentMappingRepositoryImpl(
    localDataSource: ref.watch(_roleDocumentMappingDataSourceProvider),
  ),
);

final _getRoleDocumentMappingConfigUseCaseProvider =
    Provider<GetRoleDocumentMappingConfigUseCase>(
  (ref) => GetRoleDocumentMappingConfigUseCase(
    ref.watch(_roleDocumentMappingRepositoryProvider),
  ),
);

final _saveRoleDocumentMappingUseCaseProvider =
    Provider<SaveRoleDocumentMappingUseCase>(
  (ref) => SaveRoleDocumentMappingUseCase(
    ref.watch(_roleDocumentMappingRepositoryProvider),
  ),
);

final roleDocumentMappingProvider = AsyncNotifierProvider<
    RoleDocumentMappingNotifier, RoleDocumentMappingState>(
  RoleDocumentMappingNotifier.new,
);

class RoleDocumentMappingNotifier
    extends AsyncNotifier<RoleDocumentMappingState> {
  @override
  Future<RoleDocumentMappingState> build() async {
    final config =
        await ref.watch(_getRoleDocumentMappingConfigUseCaseProvider).call();
    final selectedRole = config.roles.isEmpty ? null : config.roles.first;

    return RoleDocumentMappingState(
      roles: config.roles,
      selectedRole: selectedRole,
      allDocuments: config.allDocuments,
      roleDocumentMap: config.roleDocumentMap,
      selectedDocuments: {
        ...(selectedRole == null
            ? const <String>[]
            : config.roleDocumentMap[selectedRole] ?? const <String>[]),
      },
      isSaving: false,
      lastUpdated: DateTime.now(),
    );
  }

  void selectRole(String role) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        selectedRole: role,
        selectedDocuments: {...current.documentsForRole(role)},
      ),
    );
  }

  void toggleDocument(String document) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final nextDocuments = Set<String>.from(current.selectedDocuments);
    if (nextDocuments.contains(document)) {
      nextDocuments.remove(document);
    } else {
      nextDocuments.add(document);
    }

    state = AsyncData(current.copyWith(selectedDocuments: nextDocuments));
  }

  Future<String> saveMapping() async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Mapping state is not ready.';
    }

    final selectedRole = current.selectedRole;
    if (selectedRole == null || selectedRole.trim().isEmpty) {
      return 'Please select a role.';
    }

    state = AsyncData(current.copyWith(isSaving: true));

    final updatedMap = await ref
        .read(_saveRoleDocumentMappingUseCaseProvider)
        .call(selectedRole, current.selectedDocumentsInDisplayOrder);

    state = AsyncData(
      current.copyWith(
        roleDocumentMap: updatedMap,
        selectedDocuments: {...(updatedMap[selectedRole] ?? const <String>[])},
        isSaving: false,
        lastUpdated: DateTime.now(),
      ),
    );

    return 'Role-document mapping saved successfully.';
  }
}
