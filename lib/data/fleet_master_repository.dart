import '../domain/fleet_master_model.dart';
import 'fleet_master_mock_datasource.dart';

abstract class FleetMasterRepository {
  Future<List<FleetMasterModel>> getFleets();
  Future<List<FleetMasterModel>> addFleet(FleetMasterModel item);
  Future<List<FleetMasterModel>> updateFleet(FleetMasterModel item);
}

class FleetMasterRepositoryImpl implements FleetMasterRepository {
  FleetMasterRepositoryImpl({required FleetMasterMockDataSource dataSource})
      : _dataSource = dataSource;

  final FleetMasterMockDataSource _dataSource;

  @override
  Future<List<FleetMasterModel>> addFleet(FleetMasterModel item) =>
      _dataSource.addFleet(item);

  @override
  Future<List<FleetMasterModel>> getFleets() => _dataSource.getFleets();

  @override
  Future<List<FleetMasterModel>> updateFleet(FleetMasterModel item) =>
      _dataSource.updateFleet(item);
}
