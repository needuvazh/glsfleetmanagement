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
        routeCode: 'MCT-SOH-001',
        routeName: 'Muscat to Sohar Corridor',
        startLocation: byCode('MCT'),
        endLocation: byCode('SOH'),
        stopPoints: [
          RouteStopModel(location: byCode('NZW'), type: RouteStopType.rest),
          RouteStopModel(
              location: byCode('IBR'), type: RouteStopType.checkpoint),
        ],
        estimatedTime: '6 hrs',
        distanceKm: 245,
        region: 'North',
        riskLevel: RouteRiskLevel.medium,
        status: RouteOperationalStatus.active,
        customerSpecific: false,
        expectedStops: 2,
        standardRestPoints: const ['Nizwa Highway Point'],
        standardStartWindow: '06:00 - 09:00',
        standardDeliveryWindow: '14:00 - 18:00',
        nightDrivingAllowed: true,
        restrictedSegments: '',
        weatherSensitive: false,
        routeNotes: 'Preferred for standard containers.',
        preferredVehicleType: 'Flatbed',
        trailerTypePreference: 'Standard Trailer',
        escortRequired: false,
        specialHandlingNotes: '',
        alternateRouteAvailable: true,
        specialComplianceRequired: false,
        safetyInstructions: 'Observe speed controls near IBR.',
        customerAuthorityRestrictions: '',
        permitRequirement: 'Standard transit permit',
        requiredDocuments: const ['Route Manifest'],
        temporarilyRestricted: false,
        restrictionReason: '',
      ),
      RouteLocationModel(
        routeId: 'RTE-002',
        routeCode: 'SOH-SAL-002',
        routeName: 'Sohar to Salalah Long Haul',
        startLocation: byCode('SOH'),
        endLocation: byCode('SAL'),
        stopPoints: [
          RouteStopModel(location: byCode('MCT'), type: RouteStopType.fuel),
        ],
        estimatedTime: '9 hrs',
        distanceKm: 630,
        region: 'South',
        riskLevel: RouteRiskLevel.high,
        status: RouteOperationalStatus.active,
        customerSpecific: true,
        expectedStops: 1,
        standardRestPoints: const ['Muscat Logistics Bay'],
        standardStartWindow: '04:00 - 07:00',
        standardDeliveryWindow: '16:00 - 22:00',
        nightDrivingAllowed: false,
        restrictedSegments: 'Mountain bypass after dusk',
        weatherSensitive: true,
        routeNotes: 'Wind-sensitive section near coastal lane.',
        preferredVehicleType: 'Lowbed',
        trailerTypePreference: 'Heavy Duty Trailer',
        escortRequired: true,
        specialHandlingNotes: 'Escort mandatory for oversized cargo.',
        alternateRouteAvailable: true,
        specialComplianceRequired: true,
        safetyInstructions: 'Mandatory fatigue check at Muscat stop.',
        customerAuthorityRestrictions: 'Customer gate slot required.',
        permitRequirement: 'Oversize movement permit',
        requiredDocuments: const ['Escort Approval', 'Oversize Permit'],
        temporarilyRestricted: false,
        restrictionReason: '',
      ),
      RouteLocationModel(
        routeId: 'RTE-003',
        routeCode: 'NZW-MCT-003',
        routeName: 'Nizwa to Muscat Direct',
        startLocation: byCode('NZW'),
        endLocation: byCode('MCT'),
        stopPoints: const [],
        estimatedTime: '2 hrs',
        distanceKm: 160,
        region: 'Central',
        riskLevel: RouteRiskLevel.low,
        status: RouteOperationalStatus.restricted,
        customerSpecific: false,
        expectedStops: 0,
        standardRestPoints: const [],
        standardStartWindow: 'Any',
        standardDeliveryWindow: 'Any',
        nightDrivingAllowed: true,
        restrictedSegments: 'Tunnel diversion',
        weatherSensitive: false,
        routeNotes: 'Temporary lane closure advisory.',
        preferredVehicleType: 'Truck',
        trailerTypePreference: 'Standard',
        escortRequired: false,
        specialHandlingNotes: '',
        alternateRouteAvailable: true,
        specialComplianceRequired: false,
        safetyInstructions: 'Use diversion as instructed.',
        customerAuthorityRestrictions: '',
        permitRequirement: 'None',
        requiredDocuments: const [],
        temporarilyRestricted: true,
        restrictionReason: 'Road maintenance in tunnel segment.',
      ),
    ];
  }
}
