import '../domain/user_model.dart';
import 'user_mock_datasource.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUserById(String userId);
  Future<List<UserModel>> addUser(UserModel user);
  Future<List<UserModel>> updateUser(UserModel user);
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required UserMockDataSource dataSource})
      : _dataSource = dataSource;

  final UserMockDataSource _dataSource;

  @override
  Future<List<UserModel>> getUsers() => _dataSource.getUsers();

  @override
  Future<UserModel?> getUserById(String userId) =>
      _dataSource.getUserById(userId);

  @override
  Future<List<UserModel>> addUser(UserModel user) => _dataSource.addUser(user);

  @override
  Future<List<UserModel>> updateUser(UserModel user) =>
      _dataSource.updateUser(user);
}
