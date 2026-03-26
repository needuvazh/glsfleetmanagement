import '../data/cargo_repository.dart';
import 'cargo_model.dart';

class CargoUseCase {
  CargoUseCase(this._repository);

  final CargoRepository _repository;

  Future<List<CargoModel>> getCargoTypes() => _repository.getCargoTypes();

  Future<CargoModel?> getCargoByCode(String cargoCode) =>
      _repository.getCargoByCode(cargoCode);

  Future<List<CargoModel>> addCargo(CargoModel cargo) =>
      _repository.addCargo(cargo);

  Future<List<CargoModel>> updateCargo(CargoModel cargo) =>
      _repository.updateCargo(cargo);
}
