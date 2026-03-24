import '../../domain/entities/work_order.dart';
import '../../domain/repositories/work_order_repository.dart';
import '../datasources/local/work_order_local_datasource.dart';
import '../datasources/remote/work_order_remote_datasource.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  const WorkOrderRepositoryImpl({
    required WorkOrderLocalDataSource localDataSource,
    WorkOrderRemoteDataSource? remoteDataSource,
    required bool useLiveApi,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useLiveApi = useLiveApi;

  final WorkOrderLocalDataSource _localDataSource;
  final WorkOrderRemoteDataSource? _remoteDataSource;
  final bool _useLiveApi;

  @override
  Future<List<WorkOrder>> getWorkOrders() async {
    if (_useLiveApi) {
      final remote = _remoteDataSource;
      if (remote == null) {
        throw Exception('Work order remote datasource is not configured.');
      }
      return remote.getWorkOrders();
    }

    return _localDataSource.getWorkOrders();
  }
}
