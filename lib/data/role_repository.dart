import '../domain/role_model.dart';
import 'role_mock_datasource.dart';

abstract class RoleRepository {
  Future<List<RoleModel>> getRoles();
  Future<RoleModel?> getRoleById(String roleId);
  Future<List<RoleModel>> addRole(RoleModel role);
  Future<List<RoleModel>> updateRole(RoleModel role);
}

class RoleRepositoryImpl implements RoleRepository {
  RoleRepositoryImpl({required RoleMockDataSource dataSource})
      : _dataSource = dataSource;

  final RoleMockDataSource _dataSource;

  @override
  Future<List<RoleModel>> getRoles() => _dataSource.getRoles();

  @override
  Future<RoleModel?> getRoleById(String roleId) =>
      _dataSource.getRoleById(roleId);

  @override
  Future<List<RoleModel>> addRole(RoleModel role) => _dataSource.addRole(role);

  @override
  Future<List<RoleModel>> updateRole(RoleModel role) =>
      _dataSource.updateRole(role);
}
