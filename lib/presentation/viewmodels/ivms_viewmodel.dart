import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transport_fleet_management/domain/entities/ivms_data.dart';

final ivmsViewModelProvider = StateNotifierProvider<IVMSViewModel, IVMSState>((ref) {
  return IVMSViewModel();
});

class IVMSState {
  final List<IVMSData> vehicleTracking;
  final bool isLoading;
  final String? error;
  final IVMSData? selectedVehicle;

  IVMSState({
    this.vehicleTracking = const [],
    this.isLoading = false,
    this.error,
    this.selectedVehicle,
  });

  IVMSState copyWith({
    List<IVMSData>? vehicleTracking,
    bool? isLoading,
    String? error,
    IVMSData? selectedVehicle,
  }) {
    return IVMSState(
      vehicleTracking: vehicleTracking ?? this.vehicleTracking,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }
}

class IVMSViewModel extends StateNotifier<IVMSState> {
  IVMSViewModel() : super(IVMSState()) {
    _initializeMockData();
  }

  void _initializeMockData() {
    final mockVehicles = [
      IVMSData(
        vehicleId: 'VEH001',
        vehicleRegistration: '7561 RH',
        latitude: 23.6100,
        longitude: 58.5400,
        speed: 85.5,
        heading: 45.0,
        timestamp: DateTime.now(),
        status: 'MOVING',
        fuelLevel: 78.5,
        temperature: 92.0,
        rpm: 2500,
        odometer: 125450.5,
        engineStatus: true,
        doorsLocked: true,
        lastLocation: 'Muscat Central Warehouse',
        driverName: 'Ahmed Al Balushi',
        tripDuration: 120,
        distanceTraveled: 145.2,
      ),
      IVMSData(
        vehicleId: 'VEH002',
        vehicleRegistration: '7562 RH',
        latitude: 17.0151,
        longitude: 54.0924,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: 'IDLE',
        fuelLevel: 45.2,
        temperature: 88.0,
        rpm: 800,
        odometer: 98765.3,
        engineStatus: true,
        doorsLocked: false,
        lastLocation: 'Salalah Distribution Center',
        driverName: 'Fatima Al Harthi',
        tripDuration: 0,
        distanceTraveled: 0.0,
      ),
      IVMSData(
        vehicleId: 'VEH003',
        vehicleRegistration: '7563 RH',
        latitude: 22.9333,
        longitude: 57.5333,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'STOPPED',
        fuelLevel: 62.0,
        temperature: 85.0,
        rpm: 0,
        odometer: 156234.8,
        engineStatus: false,
        doorsLocked: true,
        lastLocation: 'Nizwa Regional Hub',
        driverName: 'Mohammed Al Rawahi',
        tripDuration: 0,
        distanceTraveled: 0.0,
      ),
      IVMSData(
        vehicleId: 'VEH004',
        vehicleRegistration: '7564 RH',
        latitude: 24.3500,
        longitude: 56.7333,
        speed: 65.0,
        heading: 270.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: 'MOVING',
        fuelLevel: 55.0,
        temperature: 90.0,
        rpm: 2000,
        odometer: 87654.2,
        engineStatus: true,
        doorsLocked: true,
        lastLocation: 'Sohar Port Terminal',
        driverName: 'Salim Al Ghanim',
        tripDuration: 240,
        distanceTraveled: 156.8,
      ),
      IVMSData(
        vehicleId: 'VEH005',
        vehicleRegistration: '7565 RH',
        latitude: 23.5,
        longitude: 58.0,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: 'OFFLINE',
        fuelLevel: 30.0,
        temperature: 75.0,
        rpm: 0,
        odometer: 234567.9,
        engineStatus: false,
        doorsLocked: true,
        lastLocation: 'Maintenance Center',
        driverName: 'Unknown',
        tripDuration: 0,
        distanceTraveled: 0.0,
      ),
    ];

    state = state.copyWith(vehicleTracking: mockVehicles);
  }

  void updateVehicleStatus(IVMSData vehicleData) {
    final updatedList = state.vehicleTracking.map((vehicle) {
      return vehicle.vehicleId == vehicleData.vehicleId ? vehicleData : vehicle;
    }).toList();
    state = state.copyWith(vehicleTracking: updatedList);
  }

  void selectVehicle(IVMSData vehicleData) {
    state = state.copyWith(selectedVehicle: vehicleData);
  }

  void clearSelection() {
    state = state.copyWith(selectedVehicle: null);
  }

  List<IVMSData> getVehiclesByStatus(String status) {
    return state.vehicleTracking.where((vehicle) => vehicle.status == status).toList();
  }

  int getMovingVehiclesCount() {
    return state.vehicleTracking.where((vehicle) => vehicle.status == 'MOVING').length;
  }

  int getIdleVehiclesCount() {
    return state.vehicleTracking.where((vehicle) => vehicle.status == 'IDLE').length;
  }

  int getOfflineVehiclesCount() {
    return state.vehicleTracking.where((vehicle) => vehicle.status == 'OFFLINE').length;
  }
}
