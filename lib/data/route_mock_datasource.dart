import '../domain/location_model.dart';
import '../domain/route_model.dart';
import 'location_repository.dart';

abstract class RouteMockDataSource {
  Future<List<RouteLocationModel>> loadRoutes();
}

class RouteMockDataSourceImpl implements RouteMockDataSource {
  RouteMockDataSourceImpl({
    required LocationRepository locationRepository,
  }) : _locationRepository = locationRepository;

  final LocationRepository _locationRepository;

  @override
  Future<List<RouteLocationModel>> loadRoutes() async {
    final locations = await _locationRepository.getLocations();

    LocationModel byCode(String code) {
      for (final location in locations) {
        if (location.locationCode == code) {
          return location;
        }
      }
      throw StateError('Location $code not found for route mock data.');
    }

    return [
      RouteLocationModel(
        routeId: 'RTE-001',
        startLocation: byCode('MCT'),
        endLocation: byCode('SOH'),
        stops: [byCode('NZW'), byCode('IBR')],
        estimatedTime: '6 hrs',
      ),
      RouteLocationModel(
        routeId: 'RTE-002',
        startLocation: byCode('SOH'),
        endLocation: byCode('SAL'),
        stops: [byCode('MCT')],
        estimatedTime: '9 hrs',
      ),
      RouteLocationModel(
        routeId: 'RTE-003',
        startLocation: byCode('NZW'),
        endLocation: byCode('MCT'),
        stops: [],
        estimatedTime: '2 hrs',
      ),
    ];
  }
}
