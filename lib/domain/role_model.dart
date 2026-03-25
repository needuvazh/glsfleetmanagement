enum RoleStatusType {
  active('Active'),
  inactive('Inactive');

  const RoleStatusType(this.label);
  final String label;
}

enum RoleModuleType {
  customer('Customer'),
  vendor('Vendor'),
  vehicle('Vehicle'),
  driver('Driver'),
  orders('Orders'),
  reports('Reports');

  const RoleModuleType(this.label);
  final String label;
}

enum PermissionAction {
  view('View'),
  create('Create'),
  edit('Edit'),
  delete('Delete');

  const PermissionAction(this.label);
  final String label;
}

class RolePermission {
  const RolePermission({
    required this.module,
    required this.canView,
    required this.canCreate,
    required this.canEdit,
    required this.canDelete,
  });

  final RoleModuleType module;
  final bool canView;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;

  RolePermission copyWith({
    RoleModuleType? module,
    bool? canView,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
  }) {
    return RolePermission(
      module: module ?? this.module,
      canView: canView ?? this.canView,
      canCreate: canCreate ?? this.canCreate,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }
}

class RoleModel {
  const RoleModel({
    required this.roleId,
    required this.roleName,
    required this.description,
    required this.status,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  final String roleId;
  final String roleName;
  final String description;
  final RoleStatusType status;
  final List<RolePermission> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoleModel copyWith({
    String? roleId,
    String? roleName,
    String? description,
    RoleStatusType? status,
    List<RolePermission>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      description: description ?? this.description,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
