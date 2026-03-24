import '../../domain/entities/tracking_point.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/local/tracking_local_datasource.dart';
import '../datasources/remote/tracking_remote_datasource.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  const TrackingRepositoryImpl({
    required TrackingLocalDataSource localDataSource,
    TrackingRemoteDataSource? remoteDataSource,
    required bool useLiveApi,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useLiveApi = useLiveApi;

  final TrackingLocalDataSource _localDataSource;
  final TrackingRemoteDataSource? _remoteDataSource;
  final bool _useLiveApi;

  @override
  Future<List<TrackingPoint>> getTrackingPoints() async {
    if (_useLiveApi) {
      final remote = _remoteDataSource;
      if (remote == null) {
        throw Exception('Tracking remote datasource is not configured.');
      }
      return remote.getTrackingPoints();
    }

    return _localDataSource.getTrackingPoints();
  }
}
