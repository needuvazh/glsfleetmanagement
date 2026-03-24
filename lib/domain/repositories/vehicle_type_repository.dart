import '../entities/vehicle_type.dart';

abstract class VehicleTypeRepository {
  Future<List<VehicleType>> getVehicleTypes();

  Future<List<VehicleType>> addVehicleType(VehicleType item);

  Future<List<VehicleType>> updateVehicleType(
      String originalCode, VehicleType item);

  Future<List<VehicleType>> deleteVehicleType(String code);
}
