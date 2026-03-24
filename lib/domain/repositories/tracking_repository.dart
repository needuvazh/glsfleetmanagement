import '../entities/tracking_point.dart';

abstract class TrackingRepository {
  Future<List<TrackingPoint>> getTrackingPoints();
}
