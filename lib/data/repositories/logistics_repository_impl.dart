import '../../domain/entities/logistics_flow.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../datasources/local/logistics_local_datasource.dart';
import '../datasources/remote/logistics_remote_datasource.dart';

class LogisticsRepositoryImpl implements LogisticsRepository {
  const LogisticsRepositoryImpl({
    required LogisticsLocalDataSource localDataSource,
    required LogisticsRemoteDataSource remoteDataSource,
    required bool useMock,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useMock = useMock;

  final LogisticsLocalDataSource _localDataSource;
  final LogisticsRemoteDataSource _remoteDataSource;
  final bool _useMock;

  @override
  Future<List<CustomerRequestData>> getCustomerRequests() {
    return _useMock
        ? _localDataSource.getCustomerRequests()
        : _remoteDataSource.getCustomerRequests();
  }

  @override
  Future<List<QuotationData>> getQuotations() {
    return _useMock
        ? _localDataSource.getQuotations()
        : _remoteDataSource.getQuotations();
  }

  @override
  Future<List<WorkOrderFlowItem>> getFlowWorkOrders() {
    return _useMock
        ? _localDataSource.getFlowWorkOrders()
        : _remoteDataSource.getFlowWorkOrders();
  }

  @override
  Future<List<FleetVehicleData>> getVehicles() {
    return _useMock
        ? _localDataSource.getVehicles()
        : _remoteDataSource.getVehicles();
  }

  @override
  Future<List<DriverData>> getDrivers() {
    return _useMock
        ? _localDataSource.getDrivers()
        : _remoteDataSource.getDrivers();
  }

  @override
  Future<List<JourneyMasterData>> getJourneyMaster() {
    return _useMock
        ? _localDataSource.getJourneyMaster()
        : _remoteDataSource.getJourneyMaster();
  }

  @override
  Future<List<IvmsData>> getIvmsData() {
    return _useMock
        ? _localDataSource.getIvmsData()
        : _remoteDataSource.getIvmsData();
  }

  @override
  Future<List<DfmsData>> getDfmsData() {
    return _useMock
        ? _localDataSource.getDfmsData()
        : _remoteDataSource.getDfmsData();
  }
}
