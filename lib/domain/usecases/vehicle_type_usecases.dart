import '../entities/vehicle_type.dart';
import '../repositories/vehicle_type_repository.dart';

class GetVehicleTypesUseCase {
  const GetVehicleTypesUseCase(this._repository);

  final VehicleTypeRepository _repository;

  Future<List<VehicleType>> call() {
    return _repository.getVehicleTypes();
  }
}

class AddVehicleTypeUseCase {
  const AddVehicleTypeUseCase(this._repository);

  final VehicleTypeRepository _repository;

  Future<List<VehicleType>> call(VehicleType item) {
    return _repository.addVehicleType(item);
  }
}

class UpdateVehicleTypeUseCase {
  const UpdateVehicleTypeUseCase(this._repository);

  final VehicleTypeRepository _repository;

  Future<List<VehicleType>> call(String originalCode, VehicleType item) {
    return _repository.updateVehicleType(originalCode, item);
  }
}

class DeleteVehicleTypeUseCase {
  const DeleteVehicleTypeUseCase(this._repository);

  final VehicleTypeRepository _repository;

  Future<List<VehicleType>> call(String code) {
    return _repository.deleteVehicleType(code);
  }
}
