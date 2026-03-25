import '../domain/location_model.dart';
import 'location_mock_datasource.dart';

abstract class LocationRepository {
  Future<List<LocationModel>> getLocations();
  Future<List<LocationModel>> addLocation(LocationModel location);
  Future<List<LocationModel>> updateLocation(
    String originalCode,
    LocationModel location,
  );
}

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({
    required LocationMockDataSource mockDataSource,
  }) : _mockDataSource = mockDataSource;

  final LocationMockDataSource _mockDataSource;
  List<LocationModel>? _cache;

  Future<List<LocationModel>> _ensureLoaded() async {
    if (_cache != null) {
      return _cache!;
    }

    final loaded = await _mockDataSource.loadLocations();
    _cache = loaded;
    return loaded;
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    final list = await _ensureLoaded();
    return List<LocationModel>.from(list);
  }

  @override
  Future<List<LocationModel>> addLocation(LocationModel location) async {
    final list = await _ensureLoaded();
    _cache = [location, ...list];
    return List<LocationModel>.from(_cache!);
  }

  @override
  Future<List<LocationModel>> updateLocation(
    String originalCode,
    LocationModel location,
  ) async {
    final list = await _ensureLoaded();
    _cache = list.map((entry) {
      if (entry.locationCode.toLowerCase() == originalCode.toLowerCase()) {
        return location;
      }
      return entry;
    }).toList();
    return List<LocationModel>.from(_cache!);
  }
}
