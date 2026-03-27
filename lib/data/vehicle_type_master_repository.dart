import '../domain/vehicle_type_master_model.dart';
import 'vehicle_type_master_mock_datasource.dart';

abstract class VehicleTypeMasterRepository {
  Future<List<VehicleTypeMasterModel>> getVehicleTypes();
  Future<List<VehicleTypeMasterModel>> addVehicleType(
    VehicleTypeMasterModel item,
  );
  Future<List<VehicleTypeMasterModel>> updateVehicleType(
    VehicleTypeMasterModel item,
  );
}

class VehicleTypeMasterRepositoryImpl implements VehicleTypeMasterRepository {
  VehicleTypeMasterRepositoryImpl({required VehicleTypeMasterMockDataSource dataSource})
      : _dataSource = dataSource;

  final VehicleTypeMasterMockDataSource _dataSource;

  @override
  Future<List<VehicleTypeMasterModel>> addVehicleType(
    VehicleTypeMasterModel item,
  ) => _dataSource.addVehicleType(item);

  @override
  Future<List<VehicleTypeMasterModel>> getVehicleTypes() =>
      _dataSource.getVehicleTypes();

  @override
  Future<List<VehicleTypeMasterModel>> updateVehicleType(
    VehicleTypeMasterModel item,
  ) => _dataSource.updateVehicleType(item);
}
