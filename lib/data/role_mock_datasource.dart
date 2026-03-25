import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/role_model.dart';

abstract class RoleMockDataSource {
  Future<List<RoleModel>> getRoles();
  Future<RoleModel?> getRoleById(String roleId);
  Future<List<RoleModel>> addRole(RoleModel role);
  Future<List<RoleModel>> updateRole(RoleModel role);
}

class RoleMockDataSourceImpl implements RoleMockDataSource {
  RoleMockDataSourceImpl();

  static const _cacheKey = 'role_master_records_v1';
  List<RoleModel>? _roles;
  int _sequence = 5;

  Future<void> _ensureInitialized() async {
    if (_roles != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _roles = decoded
            .map((entry) => _roleFromMap(Map<String, dynamic>.from(entry)))
            .toList();
      } catch (_) {
        _roles = _seedRoles();
      }
    } else {
      _roles = _seedRoles();
    }

    _sequence = _nextSequence(_roles!);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _roles!.map(_roleToMap).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    await _ensureInitialized();
    return _roles!.map((role) => role.copyWith()).toList();
  }

  @override
  Future<RoleModel?> getRoleById(String roleId) async {
    await _ensureInitialized();
    for (final role in _roles!) {
      if (role.roleId == roleId) {
        return role.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<RoleModel>> addRole(RoleModel role) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final next = role.copyWith(
      roleId: role.roleId.trim().isEmpty ? _nextRoleId() : role.roleId,
      createdAt: now,
      updatedAt: now,
    );
    _roles!.add(next);
    await _persist();
    return getRoles();
  }

  @override
  Future<List<RoleModel>> updateRole(RoleModel role) async {
    await _ensureInitialized();
    final index = _roles!.indexWhere((entry) => entry.roleId == role.roleId);
    if (index == -1) {
      return getRoles();
    }

    final existing = _roles![index];
    _roles![index] = role.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return getRoles();
  }

  String _nextRoleId() {
    final id = 'ROL-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
  }

  int _nextSequence(List<RoleModel> roles) {
    var maxValue = 0;
    for (final role in roles) {
      final parts = role.roleId.split('-');
      if (parts.length < 2) {
        continue;
      }
      final parsed = int.tryParse(parts.last) ?? 0;
      if (parsed > maxValue) {
        maxValue = parsed;
      }
    }
    return maxValue + 1;
  }

  RoleModel _roleFromMap(Map<String, dynamic> map) {
    return RoleModel(
      roleId: map['roleId'] as String? ?? '',
      roleName: map['roleName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: _roleStatusFromName(map['status'] as String?),
      permissions: _permissionsFromList(map['permissions']),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> _roleToMap(RoleModel role) {
    return {
      'roleId': role.roleId,
      'roleName': role.roleName,
      'description': role.description,
      'status': role.status.name,
      'permissions': role.permissions.map(_permissionToMap).toList(),
      'createdAt': role.createdAt.toIso8601String(),
      'updatedAt': role.updatedAt.toIso8601String(),
    };
  }

  List<RolePermission> _permissionsFromList(dynamic raw) {
    final list = raw as List<dynamic>? ?? const [];
    return list.map((entry) {
      final value = Map<String, dynamic>.from(entry as Map);
      return RolePermission(
        module: _roleModuleFromName(value['module'] as String?),
        canView: value['canView'] as bool? ?? false,
        canCreate: value['canCreate'] as bool? ?? false,
        canEdit: value['canEdit'] as bool? ?? false,
        canDelete: value['canDelete'] as bool? ?? false,
      );
    }).toList();
  }

  Map<String, dynamic> _permissionToMap(RolePermission permission) {
    return {
      'module': permission.module.name,
      'canView': permission.canView,
      'canCreate': permission.canCreate,
      'canEdit': permission.canEdit,
      'canDelete': permission.canDelete,
    };
  }

  RoleStatusType _roleStatusFromName(String? value) {
    for (final item in RoleStatusType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return RoleStatusType.active;
  }

  RoleModuleType _roleModuleFromName(String? value) {
    for (final item in RoleModuleType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return RoleModuleType.customer;
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
