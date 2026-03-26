import '../domain/location_model.dart';

abstract class LocationMockDataSource {
  Future<List<LocationModel>> loadLocations();
}

class LocationMockDataSourceImpl implements LocationMockDataSource {
  const LocationMockDataSourceImpl();

  @override
  Future<List<LocationModel>> loadLocations() async {
    return const [
      LocationModel(
        locationName: 'Muscat',
        locationCode: 'MCT',
        latitude: 23.5880,
        longitude: 58.3829,
      ),
      LocationModel(
        locationName: 'Sohar',
        locationCode: 'SHR',
        latitude: 24.3474,
        longitude: 56.7075,
      ),
      LocationModel(
        locationName: 'Salalah',
        locationCode: 'SAL',
        latitude: 17.0194,
        longitude: 54.0897,
      ),
      LocationModel(
        locationName: 'Nizwa',
        locationCode: 'NZW',
        latitude: 22.9333,
        longitude: 57.5333,
      ),
      LocationModel(
        locationName: 'Ibri',
        locationCode: 'IBR',
        latitude: 23.2257,
        longitude: 56.5157,
      ),
      LocationModel(
        locationName: 'Duqm',
        locationCode: 'DQM',
        latitude: 19.6620,
        longitude: 57.7050,
      ),
      LocationModel(
        locationName: 'Fahud',
        locationCode: 'FAH',
        latitude: 22.3500,
        longitude: 56.4500,
      ),
      LocationModel(
        locationName: 'Marmul',
        locationCode: 'MAR',
        latitude: 18.2500,
        longitude: 55.3000,
      ),
      LocationModel(
        locationName: 'Ibri Quarry',
        locationCode: 'IBR-Q',
        latitude: 23.2500,
        longitude: 56.4000,
      ),
    ];
  }
}
