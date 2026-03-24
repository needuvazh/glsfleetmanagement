import '../../domain/entities/vehicle_type.dart';
import '../../domain/repositories/vehicle_type_repository.dart';
import '../datasources/local/vehicle_type_local_datasource.dart';

class VehicleTypeRepositoryImpl implements VehicleTypeRepository {
  VehicleTypeRepositoryImpl({
    required VehicleTypeLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final VehicleTypeLocalDataSource _localDataSource;
  List<VehicleType>? _cache;

  Future<List<VehicleType>> _ensureLoaded() async {
    if (_cache != null) {
      return _cache!;
    }

    final loaded = await _localDataSource.loadVehicleTypes();
    _cache = loaded;
    return loaded;
  }

  @override
  Future<List<VehicleType>> getVehicleTypes() async {
    final list = await _ensureLoaded();
    return List<VehicleType>.from(list);
  }

  @override
  Future<List<VehicleType>> addVehicleType(VehicleType item) async {
    final list = await _ensureLoaded();
    _cache = [item, ...list];
    return List<VehicleType>.from(_cache!);
  }

  @override
  Future<List<VehicleType>> updateVehicleType(
    String originalCode,
    VehicleType item,
  ) async {
    final list = await _ensureLoaded();
    _cache = list.map((entry) {
      if (entry.code.toLowerCase() == originalCode.toLowerCase()) {
        return item;
      }
      return entry;
    }).toList();

    return List<VehicleType>.from(_cache!);
  }

  @override
  Future<List<VehicleType>> deleteVehicleType(String code) async {
    final list = await _ensureLoaded();
    _cache = list
        .where((entry) => entry.code.toLowerCase() != code.toLowerCase())
        .toList();

    return List<VehicleType>.from(_cache!);
  }
}
