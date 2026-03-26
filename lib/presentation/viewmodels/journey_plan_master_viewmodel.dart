import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transport_fleet_management/domain/entities/journey_plan.dart';
import 'package:transport_fleet_management/domain/entities/location.dart';

final journeyPlanMasterViewModelProvider = StateNotifierProvider<JourneyPlanMasterViewModel, JourneyPlanMasterState>((ref) {
  return JourneyPlanMasterViewModel();
});

class JourneyPlanMasterState {
  final List<JourneyPlan> journeyPlans;
  final bool isLoading;
  final String? error;
  final JourneyPlan? selectedJourneyPlan;

  JourneyPlanMasterState({
    this.journeyPlans = const [],
    this.isLoading = false,
    this.error,
    this.selectedJourneyPlan,
  });

  JourneyPlanMasterState copyWith({
    List<JourneyPlan>? journeyPlans,
    bool? isLoading,
    String? error,
    JourneyPlan? selectedJourneyPlan,
  }) {
    return JourneyPlanMasterState(
      journeyPlans: journeyPlans ?? this.journeyPlans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedJourneyPlan: selectedJourneyPlan ?? this.selectedJourneyPlan,
    );
  }
}

class JourneyPlanMasterViewModel extends StateNotifier<JourneyPlanMasterState> {
  JourneyPlanMasterViewModel() : super(JourneyPlanMasterState()) {
    _initializeMockData();
  }

  void _initializeMockData() {
    final mockLocations = {
      'LOC001': Location(
        id: 'LOC001',
        name: 'Muscat Central Warehouse',
        latitude: 23.6100,
        longitude: 58.5400,
        address: 'Industrial Area, Muscat',
      ),
      'LOC002': Location(
        id: 'LOC002',
        name: 'Salalah Distribution Center',
        latitude: 17.0151,
        longitude: 54.0924,
        address: 'Salalah, Dhofar',
      ),
      'LOC003': Location(
        id: 'LOC003',
        name: 'Nizwa Regional Hub',
        latitude: 22.9333,
        longitude: 57.5333,
        address: 'Nizwa, Ad Dakhiliyah',
      ),
      'LOC004': Location(
        id: 'LOC004',
        name: 'Sohar Port Terminal',
        latitude: 24.3500,
        longitude: 56.7333,
        address: 'Sohar, North Batinah',
      ),
    };

    final mockJourneyPlans = [
      JourneyPlan(
        id: 'JP001',
        name: 'Muscat to Salalah Route',
        fromLocation: mockLocations['LOC001']!,
        toLocation: mockLocations['LOC002']!,
        middleStops: [mockLocations['LOC003']!],
        averageDistanceKm: 1050.0,
        estimatedDuration: const Duration(hours: 14),
        description: 'Primary southern logistics route',
      ),
      JourneyPlan(
        id: 'JP002',
        name: 'Muscat to Sohar Route',
        fromLocation: mockLocations['LOC001']!,
        toLocation: mockLocations['LOC004']!,
        middleStops: [],
        averageDistanceKm: 240.0,
        estimatedDuration: const Duration(hours: 3, minutes: 30),
        description: 'Northern port logistics route',
      ),
      JourneyPlan(
        id: 'JP003',
        name: 'Salalah to Muscat Route',
        fromLocation: mockLocations['LOC002']!,
        toLocation: mockLocations['LOC001']!,
        middleStops: [mockLocations['LOC003']!],
        averageDistanceKm: 1050.0,
        estimatedDuration: const Duration(hours: 14),
        description: 'Return southern logistics route',
      ),
    ];

    state = state.copyWith(journeyPlans: mockJourneyPlans);
  }

  void addJourneyPlan(JourneyPlan journeyPlan) {
    final updatedPlans = [...state.journeyPlans, journeyPlan];
    state = state.copyWith(journeyPlans: updatedPlans);
  }

  void updateJourneyPlan(JourneyPlan journeyPlan) {
    final updatedPlans = state.journeyPlans.map((plan) {
      return plan.id == journeyPlan.id ? journeyPlan : plan;
    }).toList();
    state = state.copyWith(journeyPlans: updatedPlans);
  }

  void deleteJourneyPlan(String journeyPlanId) {
    final updatedPlans = state.journeyPlans.where((plan) => plan.id != journeyPlanId).toList();
    state = state.copyWith(journeyPlans: updatedPlans);
  }

  void selectJourneyPlan(JourneyPlan journeyPlan) {
    state = state.copyWith(selectedJourneyPlan: journeyPlan);
  }

  void clearSelection() {
    state = state.copyWith(selectedJourneyPlan: null);
  }
}
