import '../../domain/entities/alert_item.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/local/alerts_local_datasource.dart';
import '../datasources/remote/alerts_remote_datasource.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  const AlertsRepositoryImpl({
    required AlertsLocalDataSource localDataSource,
    AlertsRemoteDataSource? remoteDataSource,
    required bool useLiveApi,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useLiveApi = useLiveApi;

  final AlertsLocalDataSource _localDataSource;
  final AlertsRemoteDataSource? _remoteDataSource;
  final bool _useLiveApi;

  @override
  Future<List<AlertItem>> getAlerts() async {
    if (_useLiveApi) {
      final remote = _remoteDataSource;
      if (remote == null) {
        throw Exception('Alerts remote datasource is not configured.');
      }
      return remote.getAlerts();
    }

    return _localDataSource.getAlerts();
  }
}
