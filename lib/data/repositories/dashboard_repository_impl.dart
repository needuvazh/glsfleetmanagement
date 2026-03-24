import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/local/dashboard_local_datasource.dart';
import '../datasources/remote/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required DashboardLocalDataSource localDataSource,
    DashboardRemoteDataSource? remoteDataSource,
    required bool useLiveApi,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useLiveApi = useLiveApi;

  final DashboardLocalDataSource _localDataSource;
  final DashboardRemoteDataSource? _remoteDataSource;
  final bool _useLiveApi;

  @override
  Future<DashboardData> getDashboard() async {
    if (_useLiveApi) {
      final remote = _remoteDataSource;
      if (remote == null) {
        throw Exception('Dashboard remote datasource is not configured.');
      }
      return remote.getDashboard();
    }

    return _localDataSource.getDashboard();
  }
}
