import '../domain/cargo_model.dart';
import 'cargo_mock_datasource.dart';

abstract class CargoRepository {
  Future<List<CargoModel>> getCargoTypes();
  Future<CargoModel?> getCargoByCode(String cargoCode);
  Future<List<CargoModel>> addCargo(CargoModel cargo);
  Future<List<CargoModel>> updateCargo(CargoModel cargo);
}

class CargoRepositoryImpl implements CargoRepository {
  CargoRepositoryImpl({required CargoMockDataSource dataSource})
      : _dataSource = dataSource;

  final CargoMockDataSource _dataSource;

  @override
  Future<List<CargoModel>> getCargoTypes() => _dataSource.getCargoTypes();

  @override
  Future<CargoModel?> getCargoByCode(String cargoCode) =>
      _dataSource.getCargoByCode(cargoCode);

  @override
  Future<List<CargoModel>> addCargo(CargoModel cargo) =>
      _dataSource.addCargo(cargo);

  @override
  Future<List<CargoModel>> updateCargo(CargoModel cargo) =>
      _dataSource.updateCargo(cargo);
}
