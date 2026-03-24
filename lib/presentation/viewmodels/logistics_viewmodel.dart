import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/logistics_local_datasource.dart';
import '../../data/datasources/remote/logistics_remote_datasource.dart';
import '../../data/repositories/logistics_repository_impl.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../../domain/usecases/get_logistics_data_usecase.dart';
import 'access_control_viewmodel.dart';

class LogisticsUiState {
  const LogisticsUiState({
    required this.customerRequests,
    required this.quotations,
    required this.quoteStatusByRef,
    required this.workOrders,
    required this.vehicles,
    required this.drivers,
    required this.journeyMaster,
    required this.ivms,
    required this.dfms,
    required this.complianceChecklist,
    required this.selectedJourneyId,
    required this.nightDriving,
    required this.nightReason,
    required this.journeyApproved,
    required this.timelineStep,
    required this.assignedOrderId,
    required this.assignedVehicleNo,
    required this.assignedDriverId,
    required this.vehicleDocStatus,
    required this.driverDocStatus,
    required this.preTripPassed,
    required this.isFeasible,
    required this.managerOverride,
    required this.estimatedTravelHours,
    required this.nightDrivingRequired,
    required this.fuelCost,
    required this.driverCost,
    required this.vendorCost,
    required this.customerRate,
    required this.totalCost,
    required this.profit,
    required this.lastUpdated,
  });

  final List<CustomerRequestData> customerRequests;
  final List<QuotationData> quotations;
  final Map<String, String> quoteStatusByRef;
  final List<WorkOrderFlowItem> workOrders;
  final List<FleetVehicleData> vehicles;
  final List<DriverData> drivers;
  final List<JourneyMasterData> journeyMaster;
  final List<IvmsData> ivms;
  final List<DfmsData> dfms;
  final Map<String, bool> complianceChecklist;
  final String? selectedJourneyId;
  final bool nightDriving;
  final String nightReason;
  final bool journeyApproved;
  final int timelineStep;
  final String? assignedOrderId;
  final String? assignedVehicleNo;
  final String? assignedDriverId;
  final String vehicleDocStatus;
  final String driverDocStatus;
  final bool preTripPassed;
  final bool isFeasible;
  final bool managerOverride;
  final double estimatedTravelHours;
  final bool nightDrivingRequired;
  final double fuelCost;
  final double driverCost;
  final double vendorCost;
  final double customerRate;
  final double totalCost;
  final double profit;
  final DateTime lastUpdated;

  int get availableVehicleCount =>
      vehicles.where((item) => item.status.toLowerCase().contains('available')).length;

  int get availableDriverCount =>
      drivers.where((item) => item.status.toLowerCase().contains('available')).length;

  DashboardSnapshot get dashboard {
    final activeTrips =
        ivms.where((item) => item.status.toLowerCase() == 'moving').length;
    final delayedTrips = workOrders
        .where((item) => item.status.toLowerCase().contains('delay'))
        .length;
    final fleetAvailable = availableVehicleCount;
    final fatigueAlerts =
        dfms.where((item) => item.fatigueLevel.toLowerCase() == 'high').length;
    final overspeedAlerts = ivms.where((item) => item.speed > 80).length;

    return DashboardSnapshot(
      totalOrders: workOrders.length,
      activeTrips: activeTrips,
      delayedTrips: delayedTrips,
      fleetAvailable: fleetAvailable,
      driverAlerts: fatigueAlerts + overspeedAlerts,
    );
  }

  JourneyMasterData? get selectedJourney {
    if (journeyMaster.isEmpty) {
      return null;
    }
    if (selectedJourneyId == null) {
      return journeyMaster.first;
    }
    for (final item in journeyMaster) {
      if (item.journeyId == selectedJourneyId) {
        return item;
      }
    }
    return journeyMaster.first;
  }

  bool get compliancePassed {
    const critical = [
      'vehicleDocsValid',
      'driverDocsValid',
      'tyres',
      'brake',
      'lights',
      'fireExtinguisher',
    ];
    for (final key in critical) {
      if (complianceChecklist[key] != true) {
        return false;
      }
    }
    return true;
  }

  bool get canStartTrip =>
      assignedVehicleNo != null &&
      assignedDriverId != null &&
      (vehicleDocStatus == 'Valid' || vehicleDocStatus == 'Expiring Soon') &&
      (driverDocStatus == 'Valid' || driverDocStatus == 'Expiring Soon') &&
      journeyApproved &&
      preTripPassed &&
      compliancePassed;

  List<String> get executionAlerts {
    final alerts = <String>[];
    for (final item in ivms) {
      if (item.speed > 80) {
        alerts.add(
            'Overspeed alert for ${item.vehicleId} (${item.speed.toStringAsFixed(0)} km/h)');
      }
      if (item.fuelLevel < 25) {
        alerts.add(
            'Low fuel alert for ${item.vehicleId} (${item.fuelLevel.toStringAsFixed(0)}%)');
      }
    }
    for (final item in dfms) {
      if (item.fatigueLevel.toLowerCase() == 'high') {
        alerts.add(
            'Driver fatigue high for ${item.driverId}. Suggest immediate rest stop.');
      }
      if (item.drivingHours > 8) {
        alerts.add(
            'Long driving hours for ${item.driverId} (${item.drivingHours.toStringAsFixed(1)} hrs).');
      }
    }
    if (vehicleDocStatus == 'Expired' || driverDocStatus == 'Expired') {
      alerts.add('Compliance block: expired vehicle/driver documents detected.');
    }
    if (alerts.isEmpty) {
      alerts.add('No critical alerts now.');
    }
    return alerts;
  }

  LogisticsUiState copyWith({
    List<CustomerRequestData>? customerRequests,
    List<QuotationData>? quotations,
    Map<String, String>? quoteStatusByRef,
    List<WorkOrderFlowItem>? workOrders,
    List<FleetVehicleData>? vehicles,
    List<DriverData>? drivers,
    List<JourneyMasterData>? journeyMaster,
    List<IvmsData>? ivms,
    List<DfmsData>? dfms,
    Map<String, bool>? complianceChecklist,
    String? selectedJourneyId,
    bool? nightDriving,
    String? nightReason,
    bool? journeyApproved,
    int? timelineStep,
    String? assignedOrderId,
    bool clearAssignedOrderId = false,
    String? assignedVehicleNo,
    bool clearAssignedVehicleNo = false,
    String? assignedDriverId,
    bool clearAssignedDriverId = false,
    String? vehicleDocStatus,
    String? driverDocStatus,
    bool? preTripPassed,
    bool? isFeasible,
    bool? managerOverride,
    double? estimatedTravelHours,
    bool? nightDrivingRequired,
    double? fuelCost,
    double? driverCost,
    double? vendorCost,
    double? customerRate,
    double? totalCost,
    double? profit,
    DateTime? lastUpdated,
  }) {
    return LogisticsUiState(
      customerRequests: customerRequests ?? this.customerRequests,
      quotations: quotations ?? this.quotations,
      quoteStatusByRef: quoteStatusByRef ?? this.quoteStatusByRef,
      workOrders: workOrders ?? this.workOrders,
      vehicles: vehicles ?? this.vehicles,
      drivers: drivers ?? this.drivers,
      journeyMaster: journeyMaster ?? this.journeyMaster,
      ivms: ivms ?? this.ivms,
      dfms: dfms ?? this.dfms,
      complianceChecklist: complianceChecklist ?? this.complianceChecklist,
      selectedJourneyId: selectedJourneyId ?? this.selectedJourneyId,
      nightDriving: nightDriving ?? this.nightDriving,
      nightReason: nightReason ?? this.nightReason,
      journeyApproved: journeyApproved ?? this.journeyApproved,
      timelineStep: timelineStep ?? this.timelineStep,
      assignedOrderId: clearAssignedOrderId
          ? null
          : (assignedOrderId ?? this.assignedOrderId),
      assignedVehicleNo: clearAssignedVehicleNo
          ? null
          : (assignedVehicleNo ?? this.assignedVehicleNo),
      assignedDriverId: clearAssignedDriverId
          ? null
          : (assignedDriverId ?? this.assignedDriverId),
      vehicleDocStatus: vehicleDocStatus ?? this.vehicleDocStatus,
      driverDocStatus: driverDocStatus ?? this.driverDocStatus,
      preTripPassed: preTripPassed ?? this.preTripPassed,
      isFeasible: isFeasible ?? this.isFeasible,
      managerOverride: managerOverride ?? this.managerOverride,
      estimatedTravelHours: estimatedTravelHours ?? this.estimatedTravelHours,
      nightDrivingRequired: nightDrivingRequired ?? this.nightDrivingRequired,
      fuelCost: fuelCost ?? this.fuelCost,
      driverCost: driverCost ?? this.driverCost,
      vendorCost: vendorCost ?? this.vendorCost,
      customerRate: customerRate ?? this.customerRate,
      totalCost: totalCost ?? this.totalCost,
      profit: profit ?? this.profit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _logisticsLocalDataSourceProvider = Provider<LogisticsLocalDataSource>(
  (ref) => LogisticsLocalDataSourceImpl(assetBundle: rootBundle),
);

final _logisticsDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _logisticsRemoteDataSourceProvider = Provider<LogisticsRemoteDataSource>(
  (ref) => LogisticsRemoteDataSourceImpl(ref.read(_logisticsDioProvider)),
);

final _logisticsRepositoryProvider = Provider<LogisticsRepository>((ref) {
  final useLiveApi = ref.watch(useLiveApiProvider);

  return LogisticsRepositoryImpl(
    localDataSource: ref.watch(_logisticsLocalDataSourceProvider),
    remoteDataSource: ref.watch(_logisticsRemoteDataSourceProvider),
    useMock: !useLiveApi,
  );
});

final _logisticsUseCaseProvider = Provider<GetLogisticsDataUseCase>(
  (ref) => GetLogisticsDataUseCase(ref.watch(_logisticsRepositoryProvider)),
);

final logisticsViewModelProvider =
    AsyncNotifierProvider<LogisticsViewModel, LogisticsUiState>(
  LogisticsViewModel.new,
);

class LogisticsViewModel extends AsyncNotifier<LogisticsUiState> {
  Timer? _timer;
  final Random _random = Random();
  static const _pdoClients = {'shell', 'dhl', 'bsc', 'agreeko', 'stc'};

  @override
  Future<LogisticsUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final state = await _load();
    _startSimulation();
    return state;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _load());
  }

  Future<LogisticsUiState> _load() async {
    final useCase = ref.read(_logisticsUseCaseProvider);
    final access = ref.watch(accessControlProvider);

    final customerRequests = await useCase.getCustomerRequests();
    final quotations = await useCase.getQuotations();
    final workOrders = await useCase.getFlowWorkOrders();
    final fallbackVehicles = await useCase.getVehicles();
    final fallbackDrivers = await useCase.getDrivers();
    final journeys = await useCase.getJourneyMaster();
    final ivms = await useCase.getIvmsData();
    final dfms = await useCase.getDfmsData();

    final vehicles = access.transports.isNotEmpty
        ? [
            for (final item in access.transports)
              FleetVehicleData(
                vehicleNo: item.vehicleNumber,
                type: item.vehicleType,
                capacity: '${item.capacity.toStringAsFixed(0)} ${item.capacityUnit}',
                fuelType: item.fuelType,
                ivmsDeviceId: 'IVMS-${item.vehicleNumber}',
                status: item.availabilityStatus,
              ),
          ]
        : fallbackVehicles;

    final drivers = access.users
            .where((item) => item.role.toLowerCase().contains('driver'))
            .isNotEmpty
        ? [
            for (final item
                in access.users.where((u) => u.role.toLowerCase().contains('driver')))
              DriverData(
                driverId: item.userId,
                name: item.fullName,
                licenseNo: item.licenseNumber,
                expiryDate: item.licenseExpiryDate,
                phone: item.fullMobile,
                experience: item.experienceYears,
                dfmsDeviceId: 'DFMS-${item.userId}',
                status: item.status,
              ),
          ]
        : fallbackDrivers;

    final quoteStatusByRef = {
      for (final q in quotations) q.quoteRef: q.approved ? 'Approved' : 'Pending',
    };

    return LogisticsUiState(
      customerRequests: customerRequests,
      quotations: quotations,
      quoteStatusByRef: quoteStatusByRef,
      workOrders: workOrders,
      vehicles: vehicles,
      drivers: drivers,
      journeyMaster: journeys,
      ivms: ivms,
      dfms: dfms,
      complianceChecklist: const {
        'vehicleDocsValid': true,
        'driverDocsValid': true,
        'tyres': true,
        'brake': true,
        'lights': true,
        'fireExtinguisher': true,
      },
      selectedJourneyId: journeys.isEmpty ? null : journeys.first.journeyId,
      nightDriving: false,
      nightReason: '',
      journeyApproved: false,
      timelineStep: 0,
      assignedOrderId: null,
      assignedVehicleNo: null,
      assignedDriverId: null,
      vehicleDocStatus: 'Unknown',
      driverDocStatus: 'Unknown',
      preTripPassed: false,
      isFeasible: false,
      managerOverride: false,
      estimatedTravelHours: 0,
      nightDrivingRequired: false,
      fuelCost: 0,
      driverCost: 0,
      vendorCost: 0,
      customerRate: 0,
      totalCost: 0,
      profit: 0,
      lastUpdated: DateTime.now(),
    );
  }

  String addCustomerRequest(CustomerRequestData request) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }
    final next = [request, ...current.customerRequests];
    state = AsyncData(current.copyWith(
      customerRequests: next,
      lastUpdated: DateTime.now(),
    ));
    return 'Customer request created.';
  }

  String runFeasibilityCheck({
    required CustomerRequestData request,
    required double customerRate,
    bool managerOverride = false,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final distance = _firstNumber(request.pickup + request.delivery) * 0;
    final parsedDistance =
        _firstNumber(request.weightVolume).toDouble() + 120; // mock baseline
    final estimatedTravelHours = (parsedDistance / 45).clamp(2, 18).toDouble();
    final nightRequired = estimatedTravelHours > 10;

    final fuelCost = parsedDistance * 0.22;
    final driverCost = estimatedTravelHours * 8;
    final vendorCost =
        request.cargoType.toLowerCase().contains('hazard') ? 60.0 : 20.0;
    final totalCost = fuelCost + driverCost + vendorCost;
    final profit = customerRate - totalCost;

    final hasResources =
        current.availableVehicleCount > 0 && current.availableDriverCount > 0;
    final feasible = hasResources && profit >= 0;

    state = AsyncData(current.copyWith(
      isFeasible: feasible,
      managerOverride: managerOverride,
      estimatedTravelHours: estimatedTravelHours,
      nightDrivingRequired: nightRequired,
      fuelCost: fuelCost,
      driverCost: driverCost,
      vendorCost: vendorCost,
      customerRate: customerRate,
      totalCost: totalCost,
      profit: profit,
      lastUpdated: DateTime.now(),
    ));

    if (feasible || managerOverride) {
      return 'Feasibility check passed.';
    }
    return 'Not feasible. Increase rate or use manager override.';
  }

  void setManagerOverride(bool value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(managerOverride: value, lastUpdated: DateTime.now()));
  }

  String addQuotation({
    required String date,
    required String quoteRef,
    required String salesPerson,
    required String customer,
    required String customerContact,
    required String workDescription,
    required int noOfTrips,
    required double kilometer,
    required double rate,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    if (!current.isFeasible && !current.managerOverride) {
      return 'Quotation blocked: job is not feasible.';
    }

    if (quoteRef.trim().isEmpty || customer.trim().isEmpty) {
      return 'Quotation reference and customer are required.';
    }

    final normalizedQuoteRef = quoteRef.trim().toLowerCase();
    final duplicate = current.quotations.any(
      (q) => q.quoteRef.trim().toLowerCase() == normalizedQuoteRef,
    );
    if (duplicate) {
      return 'Quotation reference already exists. Use a unique QUOTE REF.';
    }

    final amount = noOfTrips * kilometer * rate;
    final quotation = QuotationData(
      slNo: current.quotations.length + 1,
      date: date,
      quoteRef: quoteRef,
      salesPerson: salesPerson,
      customer: customer,
      customerContact: customerContact,
      workDescription: workDescription,
      noOfTrips: noOfTrips,
      kilometer: kilometer,
      rate: rate,
      amount: amount,
      approved: false,
    );

    final nextStatuses = Map<String, String>.from(current.quoteStatusByRef)
      ..[quoteRef] = 'Pending';

    state = AsyncData(
      current.copyWith(
        quotations: [quotation, ...current.quotations],
        quoteStatusByRef: nextStatuses,
        lastUpdated: DateTime.now(),
      ),
    );

    return 'Quotation created successfully.';
  }

  void setQuoteStatus(String quoteRef, String status) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final nextStatuses = Map<String, String>.from(current.quoteStatusByRef)
      ..[quoteRef] = status;

    final updated = current.quotations
        .map((q) => q.quoteRef == quoteRef ? q.copyWith(approved: status == 'Approved') : q)
        .toList();

    state = AsyncData(current.copyWith(
      quoteStatusByRef: nextStatuses,
      quotations: updated,
      lastUpdated: DateTime.now(),
    ));
  }

  // Backward compatibility for existing UI action.
  void setQuotationApproval(String quoteRef, bool approved) {
    setQuoteStatus(quoteRef, approved ? 'Approved' : 'Pending');
  }

  String createOrderFromQuotation(String quoteRef) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    QuotationData? selected;
    for (final q in current.quotations) {
      if (q.quoteRef == quoteRef) {
        selected = q;
        break;
      }
    }

    if (selected == null) {
      return 'Quotation not found.';
    }

    if (current.quoteStatusByRef[quoteRef] != 'Approved') {
      return 'Order creation blocked: customer approval pending.';
    }

    final wo = WorkOrderFlowItem(
      woId: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      customer: selected.customer,
      route: selected.workDescription,
      cargo: selected.workDescription,
      status: 'Created',
    );

    state = AsyncData(
      current.copyWith(
        workOrders: [wo, ...current.workOrders],
        timelineStep: max(current.timelineStep, 3),
        assignedOrderId: wo.woId,
        journeyApproved: false,
        preTripPassed: false,
        clearAssignedVehicleNo: true,
        clearAssignedDriverId: true,
        vehicleDocStatus: 'Unknown',
        driverDocStatus: 'Unknown',
        lastUpdated: DateTime.now(),
      ),
    );

    return 'Order created from quotation $quoteRef';
  }

  String assignFleetDriver({
    required String orderId,
    required String vehicleNo,
    required String driverId,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final vehicleStatus = _vehicleDocStatus(vehicleNo);
    final driverStatus = _driverDocStatus(driverId);
    String clientName = '';
    for (final item in current.workOrders) {
      if (item.woId == orderId) {
        clientName = item.customer.toLowerCase().trim();
        break;
      }
    }
    final isPdoClient = _pdoClients.contains(clientName);

    if (isPdoClient &&
        (vehicleStatus != 'Valid' || driverStatus != 'Valid')) {
      return 'Assignment blocked: PDO client requires strict compliance (Valid documents only).';
    }

    if (vehicleStatus == 'Expired' || driverStatus == 'Expired') {
      return 'Assignment blocked: vehicle or driver documents are expired.';
    }

    final updatedOrders = current.workOrders
        .map((item) => item.woId == orderId ? WorkOrderFlowItem(
          woId: item.woId,
          customer: item.customer,
          route: item.route,
          cargo: item.cargo,
          status: 'Assigned',
        ) : item)
        .toList();

    state = AsyncData(
      current.copyWith(
        workOrders: updatedOrders,
        assignedOrderId: orderId,
        assignedVehicleNo: vehicleNo,
        assignedDriverId: driverId,
        vehicleDocStatus: vehicleStatus,
        driverDocStatus: driverStatus,
        complianceChecklist: {
          ...current.complianceChecklist,
          'vehicleDocsValid': vehicleStatus == 'Valid' || vehicleStatus == 'Expiring Soon',
          'driverDocsValid': driverStatus == 'Valid' || driverStatus == 'Expiring Soon',
        },
        timelineStep: max(current.timelineStep, 4),
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Fleet and driver assigned.';
  }

  void updateChecklist(String key, bool value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final nextChecklist = Map<String, bool>.from(current.complianceChecklist);
    nextChecklist[key] = value;
    state = AsyncData(current.copyWith(
      complianceChecklist: nextChecklist,
      lastUpdated: DateTime.now(),
    ));
  }

  String finalizePreTrip() {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final passed = current.compliancePassed;
    state = AsyncData(current.copyWith(
      preTripPassed: passed,
      timelineStep: max(current.timelineStep, 7),
      lastUpdated: DateTime.now(),
    ));
    return passed ? 'Pre-trip inspection passed.' : 'Pre-trip inspection failed.';
  }

  void setJourney(String? journeyId) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      selectedJourneyId: journeyId,
      lastUpdated: DateTime.now(),
    ));
  }

  void setNightDriving(bool enabled, {String reason = ''}) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      nightDriving: enabled,
      nightReason: reason,
      lastUpdated: DateTime.now(),
    ));
  }

  void approveJourney(bool approved) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      journeyApproved: approved,
      timelineStep: approved ? max(current.timelineStep, 6) : current.timelineStep,
      lastUpdated: DateTime.now(),
    ));
  }

  String startTrip() {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }
    if (!current.canStartTrip) {
      if (current.vehicleDocStatus == 'Expired' || current.driverDocStatus == 'Expired') {
        return 'Trip blocked: vehicle/driver documents expired.';
      }
      if (!current.journeyApproved) {
        return 'Trip blocked: JMP not approved.';
      }
      if (!current.preTripPassed) {
        return 'Trip blocked: pre-trip inspection failed.';
      }
      return 'Trip blocked: assignment or compliance prerequisites missing.';
    }
    state = AsyncData(
      current.copyWith(
        timelineStep: max(current.timelineStep, 8),
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Trip started successfully.';
  }

  void updateTimelineStep(int step) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      timelineStep: step,
      lastUpdated: DateTime.now(),
    ));
  }

  void _startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      final current = state.valueOrNull;
      if (current == null || current.ivms.isEmpty || current.dfms.isEmpty) {
        return;
      }

      final updatedIvms = current.ivms.map((item) {
        final speed =
            (item.speed + (_random.nextDouble() * 18 - 9)).clamp(0, 100);
        final fuel =
            (item.fuelLevel - (_random.nextDouble() * 1.5)).clamp(0, 100);
        final status = speed <= 3 ? 'Stop' : 'Moving';
        final lat = item.lat + ((_random.nextDouble() - 0.5) / 300);
        final lng = item.lng + ((_random.nextDouble() - 0.5) / 300);

        return item.copyWith(
          speed: speed.toDouble(),
          fuelLevel: fuel.toDouble(),
          distanceCovered: item.distanceCovered + (speed / 30),
          status: status,
          lat: lat,
          lng: lng,
        );
      }).toList();

      final updatedDfms = current.dfms.map((item) {
        final drivingHours = item.drivingHours + 0.15;
        final eyeClosure =
            (item.eyeClosureRate + (_random.nextDouble() * 0.04 - 0.02))
                .clamp(0.1, 0.95);

        String fatigueLevel;
        String alert;
        if (eyeClosure > 0.65 || drivingHours > 8.5) {
          fatigueLevel = 'High';
          alert = 'Take Rest';
        } else if (eyeClosure > 0.4 || drivingHours > 6) {
          fatigueLevel = 'Medium';
          alert = 'Monitor Driver';
        } else {
          fatigueLevel = 'Low';
          alert = 'Normal';
        }

        return item.copyWith(
          drivingHours: drivingHours,
          eyeClosureRate: eyeClosure.toDouble(),
          fatigueLevel: fatigueLevel,
          alert: alert,
        );
      }).toList();

      state = AsyncData(current.copyWith(
        ivms: updatedIvms,
        dfms: updatedDfms,
        lastUpdated: DateTime.now(),
      ));
    });
  }

  String _vehicleDocStatus(String vehicleNo) {
    final access = ref.read(accessControlProvider);
    for (final item in access.transports) {
      if (item.vehicleNumber == vehicleNo) {
        if (item.documents.isEmpty) {
          return 'Expired';
        }
        final today = DateTime.now();
        var hasExpiringSoon = false;
        for (final doc in item.documents) {
          if (!doc.mandatory) {
            continue;
          }
          if (doc.expiryDate.trim().isEmpty) {
            return 'Expired';
          }
          final expiry = DateTime.tryParse(doc.expiryDate.trim());
          if (expiry == null || expiry.isBefore(today)) {
            return 'Expired';
          }
          final days = expiry.difference(today).inDays;
          if (days <= 30) {
            hasExpiringSoon = true;
          }
        }
        return hasExpiringSoon ? 'Expiring Soon' : 'Valid';
      }
    }
    return 'Valid';
  }

  String _driverDocStatus(String driverId) {
    final access = ref.read(accessControlProvider);
    for (final item in access.users) {
      if (item.userId == driverId) {
        final expiry = DateTime.tryParse(item.licenseExpiryDate.trim());
        if (expiry == null || expiry.isBefore(DateTime.now())) {
          return 'Expired';
        }
        final days = expiry.difference(DateTime.now()).inDays;
        if (days <= 30) {
          return 'Expiring Soon';
        }
        return 'Valid';
      }
    }
    return 'Valid';
  }

  int _firstNumber(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }
}
