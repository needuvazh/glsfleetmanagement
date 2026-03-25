import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/role_mock_datasource.dart';
import '../../data/role_repository.dart';
import '../../domain/role_model.dart';

class RoleUiState {
  const RoleUiState({
    required this.roles,
    required this.searchQuery,
    required this.lastUpdated,
  });

  final List<RoleModel> roles;
  final String searchQuery;
  final DateTime lastUpdated;

  List<RoleModel> get filteredRoles {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return roles;
    }

    return roles
        .where((role) => role.roleName.toLowerCase().contains(query))
        .toList();
  }

  RoleUiState copyWith({
    List<RoleModel>? roles,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return RoleUiState(
      roles: roles ?? this.roles,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _roleDataSourceProvider = Provider<RoleMockDataSource>(
  (ref) => RoleMockDataSourceImpl(),
);

final _roleRepositoryProvider = Provider<RoleRepository>(
  (ref) => RoleRepositoryImpl(
    dataSource: ref.watch(_roleDataSourceProvider),
  ),
);

final roleViewModelProvider = AsyncNotifierProvider<RoleViewModel, RoleUiState>(
  RoleViewModel.new,
);

class RoleViewModel extends AsyncNotifier<RoleUiState> {
  @override
  Future<RoleUiState> build() async {
    final roles = await ref.watch(_roleRepositoryProvider).getRoles();
    return RoleUiState(
      roles: roles,
      searchQuery: '',
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> getRoles() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final roles = await ref.read(_roleRepositoryProvider).getRoles();
    state = AsyncData(
      current.copyWith(roles: roles, lastUpdated: DateTime.now()),
    );
  }

  Future<RoleModel?> getRoleById(String roleId) {
    return ref.read(_roleRepositoryProvider).getRoleById(roleId);
  }

  Future<String> addRole(RoleModel role) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Role state is not ready.';
    }

    final validation = _validateRole(role, current.roles);
    if (validation != null) {
      return validation;
    }

    final roles = await ref.read(_roleRepositoryProvider).addRole(role);
    state = AsyncData(
      current.copyWith(roles: roles, lastUpdated: DateTime.now()),
    );
    return 'Role created successfully.';
  }

  Future<String> updateRole(RoleModel role) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Role state is not ready.';
    }

    final others =
        current.roles.where((entry) => entry.roleId != role.roleId).toList();
    final validation = _validateRole(role, others);
    if (validation != null) {
      return validation;
    }

    final roles = await ref.read(_roleRepositoryProvider).updateRole(role);
    state = AsyncData(
      current.copyWith(roles: roles, lastUpdated: DateTime.now()),
    );
    return 'Role updated successfully.';
  }

  void setSearchQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: value));
  }

  String? _validateRole(RoleModel role, List<RoleModel> existingRoles) {
    if (role.roleName.trim().isEmpty) {
      return 'Role name is required.';
    }

    final duplicateName = existingRoles.any(
      (entry) => entry.roleName.toLowerCase() == role.roleName.toLowerCase(),
    );
    if (duplicateName) {
      return 'Role name already exists.';
    }

    return null;
  }
}

class RoleFormState {
  const RoleFormState({
    required this.initialized,
    required this.originalRoleId,
    required this.roleName,
    required this.description,
    required this.status,
    required this.permissions,
  });

  final bool initialized;
  final String? originalRoleId;
  final String roleName;
  final String description;
  final RoleStatusType status;
  final List<RolePermission> permissions;

  bool get isEditMode => originalRoleId != null;

  RoleModel toRoleModel() {
    return RoleModel(
      roleId: originalRoleId ?? '',
      roleName: roleName.trim(),
      description: description.trim(),
      status: status,
      permissions: permissions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  RoleFormState copyWith({
    bool? initialized,
    String? originalRoleId,
    bool clearOriginalRoleId = false,
    String? roleName,
    String? description,
    RoleStatusType? status,
    List<RolePermission>? permissions,
  }) {
    return RoleFormState(
      initialized: initialized ?? this.initialized,
      originalRoleId:
          clearOriginalRoleId ? null : (originalRoleId ?? this.originalRoleId),
      roleName: roleName ?? this.roleName,
      description: description ?? this.description,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
    );
  }
}

final roleFormProvider =
    AutoDisposeNotifierProvider<RoleFormNotifier, RoleFormState>(
  RoleFormNotifier.new,
);

class RoleFormNotifier extends AutoDisposeNotifier<RoleFormState> {
  @override
  RoleFormState build() {
    return RoleFormState(
      initialized: false,
      originalRoleId: null,
      roleName: '',
      description: '',
      status: RoleStatusType.active,
      permissions: _defaultPermissions(),
    );
  }

  void initialize(RoleModel? role) {
    if (state.initialized) {
      return;
    }

    if (role == null) {
      state = state.copyWith(initialized: true, clearOriginalRoleId: true);
      return;
    }

    state = RoleFormState(
      initialized: true,
      originalRoleId: role.roleId,
      roleName: role.roleName,
      description: role.description,
      status: role.status,
      permissions: role.permissions,
    );
  }

  void setRoleName(String value) => state = state.copyWith(roleName: value);
  void setDescription(String value) =>
      state = state.copyWith(description: value);
  void setStatus(RoleStatusType value) => state = state.copyWith(status: value);

  void togglePermission(
    RoleModuleType module,
    PermissionAction action,
    bool enabled,
  ) {
    final next = [
      for (final permission in state.permissions)
        if (permission.module == module)
          _applyPermissionChange(permission, action, enabled)
        else
          permission,
    ];

    state = state.copyWith(permissions: next);
  }

  RolePermission _applyPermissionChange(
    RolePermission permission,
    PermissionAction action,
    bool enabled,
  ) {
    switch (action) {
      case PermissionAction.view:
        return permission.copyWith(canView: enabled);
      case PermissionAction.create:
        return permission.copyWith(canCreate: enabled);
      case PermissionAction.edit:
        return permission.copyWith(canEdit: enabled);
      case PermissionAction.delete:
        return permission.copyWith(canDelete: enabled);
    }
  }

  List<RolePermission> _defaultPermissions() {
    return [
      for (final module in RoleModuleType.values)
        RolePermission(
          module: module,
          canView: false,
          canCreate: false,
          canEdit: false,
          canDelete: false,
        ),
    ];
  }
}
