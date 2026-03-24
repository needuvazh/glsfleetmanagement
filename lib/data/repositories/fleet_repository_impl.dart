import '../../domain/entities/fleet.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../datasources/local/fleet_local_datasource.dart';
import '../datasources/remote/fleet_remote_datasource.dart';

class FleetRepositoryImpl implements FleetRepository {
  const FleetRepositoryImpl({
    required FleetLocalDataSource localDataSource,
    FleetRemoteDataSource? remoteDataSource,
    required bool useLiveApi,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useLiveApi = useLiveApi;

  final FleetLocalDataSource _localDataSource;
  final FleetRemoteDataSource? _remoteDataSource;
  final bool _useLiveApi;

  @override
  Future<List<Fleet>> getFleets() async {
    if (_useLiveApi) {
      final remote = _remoteDataSource;
      if (remote == null) {
        throw Exception('Fleet remote datasource is not configured.');
      }
      return remote.getFleets();
    }

    return _localDataSource.getFleets();
  }
}
