import '../entities/fleet.dart';
import '../repositories/fleet_repository.dart';

class GetFleetsUseCase {
  const GetFleetsUseCase(this._repository);

  final FleetRepository _repository;

  Future<List<Fleet>> call() {
    return _repository.getFleets();
  }
}
