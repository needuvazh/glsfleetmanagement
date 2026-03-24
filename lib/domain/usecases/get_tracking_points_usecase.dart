import '../entities/tracking_point.dart';
import '../repositories/tracking_repository.dart';

class GetTrackingPointsUseCase {
  const GetTrackingPointsUseCase(this._repository);

  final TrackingRepository _repository;

  Future<List<TrackingPoint>> call() {
    return _repository.getTrackingPoints();
  }
}
