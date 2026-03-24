import '../entities/fleet.dart';

abstract class FleetRepository {
  Future<List<Fleet>> getFleets();
}
