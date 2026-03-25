import '../domain/route_model.dart';
import 'route_mock_datasource.dart';

abstract class RouteLocationRepository {
  Future<List<RouteLocationModel>> getRoutes();
  Future<List<RouteLocationModel>> addRoute(RouteLocationModel route);
  Future<List<RouteLocationModel>> updateRoute(
    String routeId,
    RouteLocationModel route,
  );
}

class RouteLocationRepositoryImpl implements RouteLocationRepository {
  RouteLocationRepositoryImpl({
    required RouteMockDataSource mockDataSource,
  }) : _mockDataSource = mockDataSource;

  final RouteMockDataSource _mockDataSource;
  List<RouteLocationModel>? _cache;

  Future<List<RouteLocationModel>> _ensureLoaded() async {
    if (_cache != null) {
      return _cache!;
    }

    final loaded = await _mockDataSource.loadRoutes();
    _cache = loaded;
    return loaded;
  }

  @override
  Future<List<RouteLocationModel>> getRoutes() async {
    final routes = await _ensureLoaded();
    return List<RouteLocationModel>.from(routes);
  }

  @override
  Future<List<RouteLocationModel>> addRoute(RouteLocationModel route) async {
    final routes = await _ensureLoaded();
    _cache = [route, ...routes];
    return List<RouteLocationModel>.from(_cache!);
  }

  @override
  Future<List<RouteLocationModel>> updateRoute(
    String routeId,
    RouteLocationModel route,
  ) async {
    final routes = await _ensureLoaded();
    _cache = routes.map((entry) {
      if (entry.routeId == routeId) {
        return route;
      }
      return entry;
    }).toList();
    return List<RouteLocationModel>.from(_cache!);
  }
}
