import '../domain/role_model.dart';

abstract class RoleMockDataSource {
  Future<List<RoleModel>> getRoles();
  Future<RoleModel?> getRoleById(String roleId);
  Future<List<RoleModel>> addRole(RoleModel role);
  Future<List<RoleModel>> updateRole(RoleModel role);
}

class RoleMockDataSourceImpl implements RoleMockDataSource {
  RoleMockDataSourceImpl() : _roles = _seedRoles();

  final List<RoleModel> _roles;
  int _sequence = 5;

  @override
  Future<List<RoleModel>> getRoles() async {
    return _roles.map((role) => role.copyWith()).toList();
  }

  @override
  Future<RoleModel?> getRoleById(String roleId) async {
    for (final role in _roles) {
      if (role.roleId == roleId) {
        return role.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<RoleModel>> addRole(RoleModel role) async {
    final now = DateTime.now();
    final next = role.copyWith(
      roleId: role.roleId.trim().isEmpty ? _nextRoleId() : role.roleId,
      createdAt: now,
      updatedAt: now,
    );
    _roles.add(next);
    return getRoles();
  }

  @override
  Future<List<RoleModel>> updateRole(RoleModel role) async {
    final index = _roles.indexWhere((entry) => entry.roleId == role.roleId);
    if (index == -1) {
      return getRoles();
    }

    final existing = _roles[index];
    _roles[index] = role.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return getRoles();
  }

  String _nextRoleId() {
    final id = 'ROL-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
  }
}

List<RoleModel> _seedRoles() {
  final now = DateTime.now();
  return [
    RoleModel(
      roleId: 'ROL-001',
      roleName: 'Admin',
      description: 'Full system access across all operational modules.',
      status: RoleStatusType.active,
      permissions: _fullAccessPermissions(),
      createdAt: now,
      updatedAt: now,
    ),
    RoleModel(
      roleId: 'ROL-002',
      roleName: 'Driver',
      description: 'Limited operational access for assigned trips and records.',
      status: RoleStatusType.active,
      permissions: _driverPermissions(),
      createdAt: now,
      updatedAt: now,
    ),
    RoleModel(
      roleId: 'ROL-003',
      roleName: 'Dispatcher',
      description: 'Operations-focused role for scheduling and assignments.',
      status: RoleStatusType.active,
      permissions: _dispatcherPermissions(),
      createdAt: now,
      updatedAt: now,
    ),
    RoleModel(
      roleId: 'ROL-004',
      roleName: 'Viewer',
      description: 'Read-only access to monitor master and reporting data.',
      status: RoleStatusType.active,
      permissions: _viewerPermissions(),
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

List<RolePermission> _fullAccessPermissions() {
  return [
    for (final module in RoleModuleType.values)
      RolePermission(
        module: module,
        canView: true,
        canCreate: true,
        canEdit: true,
        canDelete: true,
      ),
  ];
}

List<RolePermission> _driverPermissions() {
  return [
    const RolePermission(
      module: RoleModuleType.customer,
      canView: true,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.vendor,
      canView: false,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.vehicle,
      canView: true,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.driver,
      canView: true,
      canCreate: false,
      canEdit: true,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.orders,
      canView: true,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.reports,
      canView: false,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
  ];
}

List<RolePermission> _dispatcherPermissions() {
  return [
    const RolePermission(
      module: RoleModuleType.customer,
      canView: true,
      canCreate: true,
      canEdit: true,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.vendor,
      canView: true,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.vehicle,
      canView: true,
      canCreate: false,
      canEdit: true,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.driver,
      canView: true,
      canCreate: false,
      canEdit: true,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.orders,
      canView: true,
      canCreate: true,
      canEdit: true,
      canDelete: false,
    ),
    const RolePermission(
      module: RoleModuleType.reports,
      canView: true,
      canCreate: false,
      canEdit: false,
      canDelete: false,
    ),
  ];
}

List<RolePermission> _viewerPermissions() {
  return [
    for (final module in RoleModuleType.values)
      RolePermission(
        module: module,
        canView: true,
        canCreate: false,
        canEdit: false,
        canDelete: false,
      ),
  ];
}
