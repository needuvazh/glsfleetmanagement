import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/logistics_local_datasource.dart';
import '../../data/datasources/remote/logistics_remote_datasource.dart';
import '../../data/repositories/logistics_repository_impl.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/repositories/logistics_repository.dart';
import '../../domain/usecases/get_logistics_data_usecase.dart';
import 'access_control_viewmodel.dart';
import 'module_document_viewmodel.dart';

class LogisticsUiState {
  const LogisticsUiState({
    required this.customerRequests,
    required this.enquiryAuditTrail,
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
  final List<EnquiryAuditEntry> enquiryAuditTrail;
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

  int get availableVehicleCount => vehicles
      .where((item) => item.status.toLowerCase().contains('available'))
      .length;

  int get availableDriverCount => drivers
      .where((item) => item.status.toLowerCase().contains('available'))
      .length;

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
      alerts
          .add('Compliance block: expired vehicle/driver documents detected.');
    }
    if (alerts.isEmpty) {
      alerts.add('No critical alerts now.');
    }
    return alerts;
  }

  LogisticsUiState copyWith({
    List<CustomerRequestData>? customerRequests,
    List<EnquiryAuditEntry>? enquiryAuditTrail,
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
      enquiryAuditTrail: enquiryAuditTrail ?? this.enquiryAuditTrail,
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
  static const _workOrdersCacheKey = 'work_order_records_v2';

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

    final customerRequests =
        _normalizeCustomerRequests(await useCase.getCustomerRequests());
    final quotations = await useCase.getQuotations();
    final sourceWorkOrders = await useCase.getFlowWorkOrders();
    final workOrders = await _loadCachedWorkOrders(sourceWorkOrders);
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
                capacity:
                    '${item.capacity.toStringAsFixed(0)} ${item.capacityUnit}',
                fuelType: item.fuelType,
                ivmsDeviceId: 'IVMS-${item.vehicleNumber}',
                status: item.availabilityStatus,
                permits: item.documents
                    .where(
                      (doc) =>
                          doc.status.trim().toLowerCase() == 'valid' ||
                          doc.status.trim().toLowerCase() == 'active',
                    )
                    .map((doc) => doc.documentName)
                    .toList(),
              ),
          ]
        : fallbackVehicles;

    final drivers = access.users
            .where((item) => item.role.toLowerCase().contains('driver'))
            .isNotEmpty
        ? [
            for (final item in access.users
                .where((u) => u.role.toLowerCase().contains('driver')))
              DriverData(
                driverId: item.userId,
                name: item.fullName,
                employeeRef: item.userId,
                licenseNo: item.licenseNumber,
                licenseType: item.licenseType.trim().isEmpty
                    ? 'Light Vehicle'
                    : item.licenseType,
                licenseIssueDate: '',
                expiryDate: item.licenseExpiryDate,
                heavyVehicleAllowed:
                    item.licenseType.toLowerCase().contains('heavy'),
                specialEndorsementNotes: '',
                phone: item.fullMobile,
                nationality: 'Omani',
                baseLocation: 'Muscat',
                experience: item.experienceYears,
                dfmsDeviceId: 'DFMS-${item.userId}',
                status: item.status,
                active: item.status.toLowerCase() != 'inactive',
                assignmentAllowed: true,
                dispatchAllowed: true,
                dispatchBlocked: false,
                blockReason: '',
                onLeave: false,
                suspended: false,
                suspensionReason: '',
                currentAssignmentStatus: 'Unassigned',
                currentWorkOrder: '',
                currentLocation: 'Muscat',
                allowedVehicleTypes: const [],
                longHaulAllowed: true,
                nightDrivingAllowed: true,
                hazardousCargoAllowed: false,
                oilfieldAllowed: false,
                routeRestrictions: '',
                specialSkillsNotes: '',
                pdoPassportStatus: 'Not Required',
                defensiveDrivingStatus: 'Not Required',
                h2sStatus: 'Not Required',
                ftwStatus: 'Not Required',
                complianceNotes: '',
                medicalFitnessNote: '',
                safetyIncidentFlag: false,
                incidentCount: 0,
                disciplinaryNote: '',
                temporaryRestrictionNote: '',
                preferredRegion: '',
                preferredRouteType: '',
                preferredVehicleType: '',
                preferredCargoType: '',
                specialAssignmentNotes: '',
                certifications: [
                  if (item.licenseType.trim().isNotEmpty) item.licenseType,
                ],
              ),
          ]
        : fallbackDrivers;

    final quoteStatusByRef = {
      for (final q in quotations)
        q.quoteRef: q.approved ? 'Approved' : 'Pending',
    };

    return LogisticsUiState(
      customerRequests: customerRequests,
      enquiryAuditTrail: const [],
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

    final validationMessage = _validateEnquiryRequest(request);
    if (validationMessage != null) {
      return validationMessage;
    }

    if (_isDuplicateEnquiry(current.customerRequests, request)) {
      return 'Duplicate enquiry detected. Save blocked.';
    }

    final now = DateTime.now();
    final entry = request.copyWith(
      enquiryNumber: request.enquiryNumber.trim().isEmpty
          ? _nextEnquiryNumber(current.customerRequests)
          : request.enquiryNumber.trim(),
      requestSource: request.requestSource.trim().isEmpty
          ? 'Phone'
          : request.requestSource.trim(),
      requestType: request.requestType.trim().isEmpty
          ? 'Transport Request'
          : request.requestType.trim(),
      emailOrReference: request.emailOrReference.trim(),
      requestDate: request.requestDate.trim().isEmpty
          ? _formatDate(now)
          : request.requestDate.trim(),
      notes: request.notes.trim(),
      status: 'New Enquiry',
      cancellationReason: '',
      createdAt: now,
      updatedAt: now,
    );

    final nextAudit = [
      EnquiryAuditEntry(
        enquiryNumber: entry.enquiryNumber,
        action: 'Created',
        actor: 'Operations',
        at: now,
        remarks: 'Enquiry captured and status set to New Enquiry.',
      ),
      ...current.enquiryAuditTrail,
    ];

    final next = [entry, ...current.customerRequests];
    state = AsyncData(current.copyWith(
      customerRequests: next,
      enquiryAuditTrail: nextAudit,
      lastUpdated: DateTime.now(),
    ));
    return 'Enquiry ${entry.enquiryNumber} created.';
  }

  String updateEnquiry(CustomerRequestData request) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final enquiryNumber = request.enquiryNumber.trim();
    if (enquiryNumber.isEmpty) {
      return 'Enquiry number is required for edit.';
    }

    final index = current.customerRequests
        .indexWhere((item) => item.enquiryNumber == enquiryNumber);
    if (index < 0) {
      return 'Enquiry not found.';
    }

    final validationMessage = _validateEnquiryRequest(request);
    if (validationMessage != null) {
      return validationMessage;
    }

    if (_isDuplicateEnquiry(
      current.customerRequests,
      request,
      ignoreEnquiryNumber: enquiryNumber,
    )) {
      return 'Duplicate enquiry detected. Update blocked.';
    }

    final existing = current.customerRequests[index];
    if (existing.status == 'Cancelled') {
      return 'Cancelled enquiry cannot be edited.';
    }

    final now = DateTime.now();
    final updated = request.copyWith(
      hazardous: existing.hazardous,
      pdoSpec: existing.pdoSpec,
      route: existing.route,
      routeMasterId: existing.routeMasterId,
      routeCode: existing.routeCode,
      routeName: existing.routeName,
      routeRiskLevel: existing.routeRiskLevel,
      routeOperationalStatus: existing.routeOperationalStatus,
      routeRestricted: existing.routeRestricted,
      routeRestrictionReason: existing.routeRestrictionReason,
      quantity: existing.quantity,
      dimensions: existing.dimensions,
      customerSpecificRequirement: existing.customerSpecificRequirement,
      requiredVehicleType: existing.requiredVehicleType,
      tentativeDispatchDate: existing.tentativeDispatchDate,
      routeRiskFlag: existing.routeRiskFlag,
      hazardousComplianceRequired: existing.hazardousComplianceRequired,
      status: existing.status,
      cancellationReason: existing.cancellationReason,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
    final next = [...current.customerRequests];
    next[index] = updated;

    final nextAudit = [
      EnquiryAuditEntry(
        enquiryNumber: enquiryNumber,
        action: 'Edited',
        actor: 'Operations',
        at: now,
        remarks: 'Enquiry details updated.',
      ),
      ...current.enquiryAuditTrail,
    ];

    state = AsyncData(current.copyWith(
      customerRequests: next,
      enquiryAuditTrail: nextAudit,
      lastUpdated: now,
    ));
    return 'Enquiry $enquiryNumber updated.';
  }

  String cancelEnquiry({
    required String enquiryNumber,
    required String reason,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }
    if (reason.trim().isEmpty) {
      return 'Cancellation reason is mandatory.';
    }

    final index = current.customerRequests
        .indexWhere((item) => item.enquiryNumber == enquiryNumber);
    if (index < 0) {
      return 'Enquiry not found.';
    }

    final existing = current.customerRequests[index];
    if (existing.status == 'Cancelled') {
      return 'Enquiry already cancelled.';
    }

    final now = DateTime.now();
    final next = [...current.customerRequests];
    next[index] = existing.copyWith(
      status: 'Cancelled',
      cancellationReason: reason.trim(),
      updatedAt: now,
    );

    final nextAudit = [
      EnquiryAuditEntry(
        enquiryNumber: enquiryNumber,
        action: 'Cancelled',
        actor: 'Operations',
        at: now,
        remarks: reason.trim(),
      ),
      ...current.enquiryAuditTrail,
    ];

    state = AsyncData(current.copyWith(
      customerRequests: next,
      enquiryAuditTrail: nextAudit,
      lastUpdated: now,
    ));
    return 'Enquiry $enquiryNumber cancelled.';
  }

  String moveToDetailCollection(String enquiryNumber) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final index = current.customerRequests
        .indexWhere((item) => item.enquiryNumber == enquiryNumber);
    if (index < 0) {
      return 'Enquiry not found.';
    }

    final existing = current.customerRequests[index];
    if (existing.status == 'Cancelled') {
      return 'Cancelled enquiry cannot move to detail collection.';
    }

    final now = DateTime.now();
    final next = [...current.customerRequests];
    next[index] = existing.copyWith(
      status: 'Detail Collection',
      updatedAt: now,
    );

    final nextAudit = [
      EnquiryAuditEntry(
        enquiryNumber: enquiryNumber,
        action: 'Moved to Detail Collection',
        actor: 'Operations',
        at: now,
        remarks: 'Ready for feasibility and quotation.',
      ),
      ...current.enquiryAuditTrail,
    ];

    state = AsyncData(current.copyWith(
      customerRequests: next,
      enquiryAuditTrail: nextAudit,
      lastUpdated: now,
    ));
    return 'Enquiry $enquiryNumber moved to detail collection.';
  }

  String gatherEnquiryKeyDetails({
    required String enquiryNumber,
    required String cargoType,
    required bool hazardous,
    required String pdoSpec,
    required String pickup,
    required String route,
    required String destination,
    required String quantity,
    required String dimensions,
    required String weightVolume,
    required String customerSpecificRequirement,
    required String requiredVehicleType,
    required String tentativeDispatchDate,
    required bool routeRiskFlag,
    String routeMasterId = '',
    String routeCode = '',
    String routeName = '',
    String routeRiskLevel = 'Low',
    String routeOperationalStatus = 'Active',
    bool routeRestricted = false,
    String routeRestrictionReason = '',
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final index = current.customerRequests
        .indexWhere((item) => item.enquiryNumber == enquiryNumber);
    if (index < 0) {
      return 'Enquiry not found.';
    }

    if (pickup.trim().isEmpty || destination.trim().isEmpty) {
      return 'Pickup and destination are mandatory.';
    }
    if (cargoType.trim().isEmpty) {
      return 'Cargo type is mandatory.';
    }
    final hasLoadQuantity = quantity.trim().isNotEmpty ||
        dimensions.trim().isNotEmpty ||
        weightVolume.trim().isNotEmpty;
    if (!hasLoadQuantity) {
      return 'At least one load-related quantity field is required.';
    }

    final now = DateTime.now();
    final existing = current.customerRequests[index];
    if (existing.status == 'Cancelled') {
      return 'Cancelled enquiry cannot be updated.';
    }

    final updated = existing.copyWith(
      cargoType: cargoType.trim(),
      hazardous: hazardous,
      pdoSpec: pdoSpec.trim().isEmpty ? existing.pdoSpec : pdoSpec.trim(),
      pickup: pickup.trim(),
      route: route.trim(),
      routeMasterId: routeMasterId.trim(),
      routeCode: routeCode.trim(),
      routeName: routeName.trim(),
      routeRiskLevel: routeRiskLevel,
      routeOperationalStatus: routeOperationalStatus,
      routeRestricted: routeRestricted,
      routeRestrictionReason: routeRestrictionReason.trim(),
      delivery: destination.trim(),
      quantity: quantity.trim(),
      dimensions: dimensions.trim(),
      weightVolume: weightVolume.trim(),
      customerSpecificRequirement: customerSpecificRequirement.trim(),
      requiredVehicleType: requiredVehicleType.trim(),
      tentativeDispatchDate: tentativeDispatchDate.trim(),
      routeRiskFlag: routeRiskFlag,
      hazardousComplianceRequired: hazardous,
      status: 'Detail Collection',
      updatedAt: now,
    );

    final next = [...current.customerRequests];
    next[index] = updated;

    final riskNote =
        routeRiskFlag ? 'Route risk flagged.' : 'Route risk not flagged.';
    final complianceNote = hazardous
        ? 'Hazardous load: compliance flag enabled.'
        : 'Non-hazardous load.';
    final resourceNote =
        'Resource snapshot - Prime Movers: ${current.availableVehicleCount}, Drivers: ${current.availableDriverCount}.';

    final nextAudit = [
      EnquiryAuditEntry(
        enquiryNumber: enquiryNumber,
        action: 'Key Details Collected',
        actor: 'Operations',
        at: now,
        remarks: '$complianceNote $riskNote $resourceNote',
      ),
      ...current.enquiryAuditTrail,
    ];

    state = AsyncData(current.copyWith(
      customerRequests: next,
      enquiryAuditTrail: nextAudit,
      lastUpdated: now,
    ));

    return 'Key details captured. Enquiry is ready for feasibility and costing.';
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
    state = AsyncData(
        current.copyWith(managerOverride: value, lastUpdated: DateTime.now()));
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
        .map((q) => q.quoteRef == quoteRef
            ? q.copyWith(approved: status == 'Approved')
            : q)
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

  String createWorkOrderJobFile({
    required String workOrderNumber,
    required String linkedQuotationRef,
    required String linkedEnquiryNumber,
    required String customerPoReference,
    required String jobFileReference,
    required String serviceStartDate,
    required String serviceEndDate,
    required String internalNotes,
    required String initialStatus,
    bool bypassRouteRestriction = false,
    String overrideRouteMasterId = '',
    String overrideRouteCode = '',
    String overrideRouteName = '',
    String overrideRouteRiskLevel = 'Low',
    String overrideRouteOperationalStatus = 'Active',
    bool overrideRouteRestricted = false,
    String overrideRouteRestrictionReason = '',
    String overrideRouteDisplay = '',
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final woId = workOrderNumber.trim();
    if (woId.isEmpty) {
      return 'Work order number is required.';
    }
    final duplicateWo = current.workOrders.any(
      (item) => item.woId.toLowerCase().trim() == woId.toLowerCase(),
    );
    if (duplicateWo) {
      return 'Work order number already exists. Use a unique WO number.';
    }

    if (linkedQuotationRef.trim().isEmpty) {
      return 'Linked quotation is required.';
    }
    if (linkedEnquiryNumber.trim().isEmpty) {
      return 'Linked enquiry is required.';
    }
    if (customerPoReference.trim().isEmpty) {
      return 'Customer PO / CWO reference is required.';
    }
    if (jobFileReference.trim().isEmpty) {
      return 'Job file reference is required.';
    }
    if (serviceStartDate.trim().isEmpty || serviceEndDate.trim().isEmpty) {
      return 'Service start and end dates are required.';
    }
    final parsedStart = DateTime.tryParse(serviceStartDate.trim());
    final parsedEnd = DateTime.tryParse(serviceEndDate.trim());
    if (parsedStart == null || parsedEnd == null) {
      return 'Service dates are invalid. Use YYYY-MM-DD format.';
    }
    if (parsedEnd.isBefore(parsedStart)) {
      return 'Service end date cannot be before start date.';
    }

    QuotationData? selectedQuotation;
    for (final item in current.quotations) {
      if (item.quoteRef == linkedQuotationRef.trim()) {
        selectedQuotation = item;
        break;
      }
    }

    CustomerRequestData? selectedEnquiry;
    for (final item in current.customerRequests) {
      if (item.enquiryNumber == linkedEnquiryNumber.trim()) {
        selectedEnquiry = item;
        break;
      }
    }

    if (selectedQuotation == null || selectedEnquiry == null) {
      return 'Linked quotation/enquiry not found.';
    }

    final hasOverrideRoute = overrideRouteMasterId.trim().isNotEmpty;
    final effectiveRouteRestricted = hasOverrideRoute
        ? overrideRouteRestricted
        : selectedEnquiry.routeRestricted;
    final effectiveRouteStatus = hasOverrideRoute
        ? overrideRouteOperationalStatus
        : selectedEnquiry.routeOperationalStatus;
    final effectiveRestrictionReason = hasOverrideRoute
        ? overrideRouteRestrictionReason
        : selectedEnquiry.routeRestrictionReason;

    if (effectiveRouteRestricted && !bypassRouteRestriction) {
      return 'WO blocked: selected route is restricted ($effectiveRestrictionReason).';
    }
    if (effectiveRouteStatus.toLowerCase() == 'inactive' &&
        !bypassRouteRestriction) {
      return 'WO blocked: selected route is inactive.';
    }

    final effectiveRouteText = hasOverrideRoute
        ? (overrideRouteDisplay.trim().isEmpty
            ? '${selectedEnquiry.pickup} -> ${selectedEnquiry.delivery}'
            : overrideRouteDisplay.trim())
        : (selectedEnquiry.route.trim().isEmpty
            ? '${selectedEnquiry.pickup} -> ${selectedEnquiry.delivery}'
            : selectedEnquiry.route);

    final customerMatches = selectedQuotation.customer.trim().toLowerCase() ==
        selectedEnquiry.customerName.trim().toLowerCase();
    if (!customerMatches) {
      return 'Linked quotation and enquiry must belong to the same customer.';
    }

    final quotationAccepted =
        (current.quoteStatusByRef[linkedQuotationRef.trim()] ?? 'Pending') ==
            'Approved';
    if (!quotationAccepted) {
      return 'WO blocked: linked quotation must be approved.';
    }

    if (initialStatus != 'Open' && initialStatus != 'Ready for Allocation') {
      return 'Initial status must be Open or Ready for Allocation.';
    }

    final wo = WorkOrderFlowItem(
      woId: woId,
      customer: selectedQuotation.customer,
      route: effectiveRouteText,
      cargo: selectedEnquiry.cargoType,
      status: initialStatus,
      linkedQuotationRef: linkedQuotationRef.trim(),
      linkedEnquiryNumber: linkedEnquiryNumber.trim(),
      routeMasterId: hasOverrideRoute
          ? overrideRouteMasterId.trim()
          : selectedEnquiry.routeMasterId,
      routeCode: hasOverrideRoute
          ? overrideRouteCode.trim()
          : selectedEnquiry.routeCode,
      routeName: hasOverrideRoute
          ? overrideRouteName.trim()
          : selectedEnquiry.routeName,
      routeRiskLevel: hasOverrideRoute
          ? overrideRouteRiskLevel
          : selectedEnquiry.routeRiskLevel,
      routeOperationalStatus: hasOverrideRoute
          ? overrideRouteOperationalStatus
          : selectedEnquiry.routeOperationalStatus,
      routeRestricted: hasOverrideRoute
          ? overrideRouteRestricted
          : selectedEnquiry.routeRestricted,
      routeRestrictionReason: hasOverrideRoute
          ? overrideRouteRestrictionReason.trim()
          : selectedEnquiry.routeRestrictionReason,
      customerPoReference: customerPoReference.trim(),
      jobFileReference: jobFileReference.trim(),
      serviceStartDate: serviceStartDate.trim(),
      serviceEndDate: serviceEndDate.trim(),
      internalNotes: internalNotes.trim(),
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
    unawaited(_persistWorkOrders(state.valueOrNull?.workOrders ?? const []));

    return 'Work order ${wo.woId} created and ready for allocation flow.';
  }

  String createOrderFromQuotation(String quoteRef) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    CustomerRequestData? linkedEnquiry;
    for (final item in current.customerRequests) {
      if (item.status != 'Cancelled') {
        linkedEnquiry = item;
        break;
      }
    }

    return createWorkOrderJobFile(
      workOrderNumber: 'WO-${DateTime.now().millisecondsSinceEpoch % 100000}',
      linkedQuotationRef: quoteRef,
      linkedEnquiryNumber: linkedEnquiry?.enquiryNumber ?? '',
      customerPoReference: 'PO-PENDING',
      jobFileReference: 'JOB-${DateTime.now().millisecondsSinceEpoch % 100000}',
      serviceStartDate: _formatDate(DateTime.now()),
      serviceEndDate: _formatDate(DateTime.now().add(const Duration(days: 1))),
      internalNotes: 'Generated from approved quotation flow.',
      initialStatus: 'Open',
    );
  }

  String duplicateWorkOrder(String workOrderId) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    WorkOrderFlowItem? source;
    for (final item in current.workOrders) {
      if (item.woId == workOrderId) {
        source = item;
        break;
      }
    }

    if (source == null) {
      return 'Work order not found.';
    }

    final newWoId = _nextDuplicatedWorkOrderId(current.workOrders, source.woId);
    final copied = source.copyWith(
      woId: newWoId,
      status: 'Open',
      internalNotes: source.internalNotes.trim().isEmpty
          ? 'Copied from ${source.woId}'
          : '${source.internalNotes}\nCopied from ${source.woId}',
    );

    state = AsyncData(
      current.copyWith(
        workOrders: [copied, ...current.workOrders],
        lastUpdated: DateTime.now(),
      ),
    );
    unawaited(_persistWorkOrders(state.valueOrNull?.workOrders ?? const []));

    return 'Work order copied. New WO created: $newWoId';
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
    final access = ref.read(accessControlProvider);
    TransportItem? selectedTransport;
    for (final item in access.transports) {
      if (item.vehicleNumber == vehicleNo) {
        selectedTransport = item;
        break;
      }
    }

    if (selectedTransport != null && !selectedTransport.assignmentEligible) {
      return 'Assignment blocked: fleet is not assignable due to operational controls.';
    }

    DriverData? selectedDriver;
    for (final item in current.drivers) {
      if (item.driverId == driverId) {
        selectedDriver = item;
        break;
      }
    }
    if (selectedDriver == null) {
      return 'Assignment blocked: selected driver not found in driver master.';
    }
    if (!selectedDriver.assignmentEligible) {
      return 'Assignment blocked: driver is not assignment-ready.';
    }

    final driverCompliance =
        _driverComplianceMasterPass(driver: selectedDriver);
    if (!driverCompliance.$1) {
      return driverCompliance.$2;
    }

    final suitability = _driverVehicleSuitability(
      orderId: orderId,
      vehicle: selectedTransport,
      driver: selectedDriver,
    );
    if (!suitability.$1) {
      return suitability.$2;
    }

    final complianceStage = _fleetComplianceMasterPass(vehicleNo: vehicleNo);
    if (!complianceStage.$1) {
      return complianceStage.$2;
    }
    String clientName = '';
    for (final item in current.workOrders) {
      if (item.woId == orderId) {
        clientName = item.customer.toLowerCase().trim();
        break;
      }
    }
    final isPdoClient = _pdoClients.contains(clientName);

    if (isPdoClient && (vehicleStatus != 'Valid' || driverStatus != 'Valid')) {
      return 'Assignment blocked: PDO client requires strict compliance (Valid documents only).';
    }

    if (vehicleStatus == 'Expired' || driverStatus == 'Expired') {
      return 'Assignment blocked: vehicle or driver documents are expired.';
    }

    final updatedOrders = current.workOrders
        .map((item) =>
            item.woId == orderId ? item.copyWith(status: 'Assigned') : item)
        .toList();

    final updatedDrivers = current.drivers.map((driver) {
      if (driver.driverId == driverId) {
        return driver.copyWith(
          status: 'Assigned',
          currentAssignmentStatus: 'Assigned',
          currentWorkOrder: orderId,
          assignmentAllowed: false,
        );
      }
      return driver;
    }).toList();

    state = AsyncData(
      current.copyWith(
        workOrders: updatedOrders,
        drivers: updatedDrivers,
        assignedOrderId: orderId,
        assignedVehicleNo: vehicleNo,
        assignedDriverId: driverId,
        vehicleDocStatus: vehicleStatus,
        driverDocStatus: driverStatus,
        complianceChecklist: {
          ...current.complianceChecklist,
          'vehicleDocsValid':
              vehicleStatus == 'Valid' || vehicleStatus == 'Expiring Soon',
          'driverDocsValid':
              driverStatus == 'Valid' || driverStatus == 'Expiring Soon',
        },
        timelineStep: max(current.timelineStep, 4),
        lastUpdated: DateTime.now(),
      ),
    );
    unawaited(_persistWorkOrders(state.valueOrNull?.workOrders ?? const []));
    return 'Fleet and driver assigned.';
  }

  String upsertWorkOrderFromMaster({
    required String workOrderNumber,
    required String enquiryReference,
    required String customer,
    required String cargo,
    required String origin,
    required String destination,
    required DateTime? plannedDispatchDate,
    required DateTime? plannedDeliveryDate,
    required String internalNotes,
    required bool isEdit,
    String routeMasterId = '',
    String routeCode = '',
    String routeName = '',
    String routeRiskLevel = 'Low',
    String routeOperationalStatus = 'Active',
    bool routeRestricted = false,
    String routeRestrictionReason = '',
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final woId = workOrderNumber.trim();
    if (woId.isEmpty) {
      return 'Work order number is required.';
    }
    if (enquiryReference.trim().isEmpty) {
      return 'Enquiry / reference is required.';
    }
    if (customer.trim().isEmpty) {
      return 'Customer is required.';
    }
    if (cargo.trim().isEmpty) {
      return 'Cargo type is required.';
    }
    if (origin.trim().isEmpty || destination.trim().isEmpty) {
      return 'Origin and destination are required.';
    }
    if (plannedDispatchDate == null || plannedDeliveryDate == null) {
      return 'Planned dispatch and delivery dates are required.';
    }
    if (plannedDeliveryDate.isBefore(plannedDispatchDate)) {
      return 'Planned delivery date cannot be before dispatch date.';
    }

    final existingIndex =
        current.workOrders.indexWhere((item) => item.woId == woId);
    if (!isEdit && existingIndex >= 0) {
      return 'Work order number already exists. Use a unique WO number.';
    }
    if (isEdit && existingIndex < 0) {
      return 'Work order not found for update.';
    }

    final nextItem = WorkOrderFlowItem(
      woId: woId,
      customer: customer.trim(),
      route: '${origin.trim()} -> ${destination.trim()}',
      cargo: cargo.trim(),
      status: 'Open',
      linkedQuotationRef: '',
      linkedEnquiryNumber: enquiryReference.trim(),
      routeMasterId: routeMasterId,
      routeCode: routeCode,
      routeName: routeName,
      routeRiskLevel: routeRiskLevel,
      routeOperationalStatus: routeOperationalStatus,
      routeRestricted: routeRestricted,
      routeRestrictionReason: routeRestrictionReason,
      customerPoReference: '',
      jobFileReference: '',
      serviceStartDate: _formatDate(plannedDispatchDate),
      serviceEndDate: _formatDate(plannedDeliveryDate),
      internalNotes: internalNotes.trim(),
    );

    List<WorkOrderFlowItem> updated;
    if (isEdit) {
      updated = [...current.workOrders];
      updated[existingIndex] = nextItem;
    } else {
      updated = [nextItem, ...current.workOrders];
    }

    state = AsyncData(current.copyWith(
      workOrders: updated,
      lastUpdated: DateTime.now(),
    ));
    unawaited(_persistWorkOrders(updated));
    return isEdit
        ? 'Work order $woId updated successfully.'
        : 'Work order $woId created successfully.';
  }

  String addDriver({
    required String driverCode,
    required String name,
    String employeeRef = '',
    required String phone,
    required String licenseNo,
    required String licenseType,
    String licenseIssueDate = '',
    required String licenseExpiry,
    required String availability,
    String nationality = 'Omani',
    String baseLocation = 'Muscat',
    bool heavyVehicleAllowed = false,
    String specialEndorsementNotes = '',
    List<String> allowedVehicleTypes = const [],
    bool longHaulAllowed = true,
    bool nightDrivingAllowed = true,
    bool hazardousCargoAllowed = false,
    bool oilfieldAllowed = false,
    String routeRestrictions = '',
    String specialSkillsNotes = '',
    String pdoPassportStatus = 'Not Required',
    String defensiveDrivingStatus = 'Not Required',
    String h2sStatus = 'Not Required',
    String ftwStatus = 'Not Required',
    String complianceNotes = '',
    String currentAssignmentStatus = 'Unassigned',
    String currentWorkOrder = '',
    String currentLocation = 'Muscat',
    bool onLeave = false,
    bool suspended = false,
    String suspensionReason = '',
    bool assignmentAllowed = true,
    bool dispatchAllowed = true,
    bool dispatchBlocked = false,
    String blockReason = '',
    String medicalFitnessNote = '',
    bool safetyIncidentFlag = false,
    int incidentCount = 0,
    String disciplinaryNote = '',
    String temporaryRestrictionNote = '',
    String preferredRegion = '',
    String preferredRouteType = '',
    String preferredVehicleType = '',
    String preferredCargoType = '',
    String specialAssignmentNotes = '',
    bool active = true,
    String certifications = '',
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final code = driverCode.trim();
    if (code.isEmpty) {
      return 'Driver code is required.';
    }
    if (name.trim().isEmpty) {
      return 'Driver name is required.';
    }
    if (licenseNo.trim().isEmpty) {
      return 'License number is required.';
    }
    if (licenseType.trim().isEmpty) {
      return 'License type is required.';
    }
    final expiry = DateTime.tryParse(licenseExpiry.trim());
    if (expiry == null) {
      return 'License expiry must be in YYYY-MM-DD format.';
    }
    if (dispatchBlocked && blockReason.trim().isEmpty) {
      return 'Block reason is required when dispatch is blocked.';
    }
    if (suspended && suspensionReason.trim().isEmpty) {
      return 'Suspension reason is required when driver is suspended.';
    }

    final exists = current.drivers.any((d) => d.driverId == code);
    if (exists) {
      return 'Driver code already exists.';
    }

    final next = DriverData(
      driverId: code,
      name: name.trim(),
      employeeRef: employeeRef.trim(),
      licenseNo: licenseNo.trim(),
      licenseType: licenseType.trim(),
      licenseIssueDate: licenseIssueDate.trim(),
      expiryDate: licenseExpiry.trim(),
      heavyVehicleAllowed: heavyVehicleAllowed,
      specialEndorsementNotes: specialEndorsementNotes.trim(),
      phone: phone.trim().isEmpty ? '-' : phone.trim(),
      nationality: nationality.trim().isEmpty ? 'Omani' : nationality.trim(),
      baseLocation:
          baseLocation.trim().isEmpty ? 'Muscat' : baseLocation.trim(),
      experience: 0,
      dfmsDeviceId: 'DFMS-${code.replaceAll(' ', '')}',
      status: availability.trim().isEmpty ? 'Available' : availability.trim(),
      active: active,
      assignmentAllowed: assignmentAllowed,
      dispatchAllowed: dispatchAllowed,
      dispatchBlocked: dispatchBlocked,
      blockReason: blockReason.trim(),
      onLeave: onLeave,
      suspended: suspended,
      suspensionReason: suspensionReason.trim(),
      currentAssignmentStatus: currentAssignmentStatus.trim().isEmpty
          ? 'Unassigned'
          : currentAssignmentStatus.trim(),
      currentWorkOrder: currentWorkOrder.trim(),
      currentLocation:
          currentLocation.trim().isEmpty ? 'Muscat' : currentLocation.trim(),
      allowedVehicleTypes: allowedVehicleTypes,
      longHaulAllowed: longHaulAllowed,
      nightDrivingAllowed: nightDrivingAllowed,
      hazardousCargoAllowed: hazardousCargoAllowed,
      oilfieldAllowed: oilfieldAllowed,
      routeRestrictions: routeRestrictions.trim(),
      specialSkillsNotes: specialSkillsNotes.trim(),
      pdoPassportStatus: pdoPassportStatus,
      defensiveDrivingStatus: defensiveDrivingStatus,
      h2sStatus: h2sStatus,
      ftwStatus: ftwStatus,
      complianceNotes: complianceNotes.trim(),
      medicalFitnessNote: medicalFitnessNote.trim(),
      safetyIncidentFlag: safetyIncidentFlag,
      incidentCount: incidentCount,
      disciplinaryNote: disciplinaryNote.trim(),
      temporaryRestrictionNote: temporaryRestrictionNote.trim(),
      preferredRegion: preferredRegion.trim(),
      preferredRouteType: preferredRouteType.trim(),
      preferredVehicleType: preferredVehicleType.trim(),
      preferredCargoType: preferredCargoType.trim(),
      specialAssignmentNotes: specialAssignmentNotes.trim(),
      certifications: _splitCsv(certifications),
    );

    state = AsyncData(
      current.copyWith(
        drivers: [next, ...current.drivers],
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Driver $code added.';
  }

  String updateDriver({
    required String driverCode,
    required String name,
    String employeeRef = '',
    required String phone,
    required String licenseNo,
    required String licenseType,
    String licenseIssueDate = '',
    required String licenseExpiry,
    required String availability,
    String nationality = 'Omani',
    String baseLocation = 'Muscat',
    bool heavyVehicleAllowed = false,
    String specialEndorsementNotes = '',
    List<String> allowedVehicleTypes = const [],
    bool longHaulAllowed = true,
    bool nightDrivingAllowed = true,
    bool hazardousCargoAllowed = false,
    bool oilfieldAllowed = false,
    String routeRestrictions = '',
    String specialSkillsNotes = '',
    String pdoPassportStatus = 'Not Required',
    String defensiveDrivingStatus = 'Not Required',
    String h2sStatus = 'Not Required',
    String ftwStatus = 'Not Required',
    String complianceNotes = '',
    String currentAssignmentStatus = 'Unassigned',
    String currentWorkOrder = '',
    String currentLocation = 'Muscat',
    bool onLeave = false,
    bool suspended = false,
    String suspensionReason = '',
    bool assignmentAllowed = true,
    bool dispatchAllowed = true,
    bool dispatchBlocked = false,
    String blockReason = '',
    String medicalFitnessNote = '',
    bool safetyIncidentFlag = false,
    int incidentCount = 0,
    String disciplinaryNote = '',
    String temporaryRestrictionNote = '',
    String preferredRegion = '',
    String preferredRouteType = '',
    String preferredVehicleType = '',
    String preferredCargoType = '',
    String specialAssignmentNotes = '',
    bool active = true,
    String certifications = '',
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }

    final idx = current.drivers.indexWhere((d) => d.driverId == driverCode);
    if (idx < 0) {
      return 'Driver not found.';
    }

    final existing = current.drivers[idx];
    final updated = existing.copyWith(
      name: name.trim().isEmpty ? existing.name : name.trim(),
      employeeRef: employeeRef.trim().isEmpty
          ? existing.employeeRef
          : employeeRef.trim(),
      licenseNo:
          licenseNo.trim().isEmpty ? existing.licenseNo : licenseNo.trim(),
      licenseType: licenseType.trim().isEmpty
          ? existing.licenseType
          : licenseType.trim(),
      licenseIssueDate: licenseIssueDate.trim().isEmpty
          ? existing.licenseIssueDate
          : licenseIssueDate.trim(),
      expiryDate: licenseExpiry.trim().isEmpty
          ? existing.expiryDate
          : licenseExpiry.trim(),
      phone: phone.trim().isEmpty ? existing.phone : phone.trim(),
      status:
          availability.trim().isEmpty ? existing.status : availability.trim(),
      nationality: nationality.trim().isEmpty
          ? existing.nationality
          : nationality.trim(),
      baseLocation: baseLocation.trim().isEmpty
          ? existing.baseLocation
          : baseLocation.trim(),
      heavyVehicleAllowed: heavyVehicleAllowed,
      specialEndorsementNotes: specialEndorsementNotes.trim(),
      active: active,
      assignmentAllowed: assignmentAllowed,
      dispatchAllowed: dispatchAllowed,
      dispatchBlocked: dispatchBlocked,
      blockReason: blockReason.trim(),
      onLeave: onLeave,
      suspended: suspended,
      suspensionReason: suspensionReason.trim(),
      currentAssignmentStatus: currentAssignmentStatus.trim(),
      currentWorkOrder: currentWorkOrder.trim(),
      currentLocation: currentLocation.trim(),
      allowedVehicleTypes: allowedVehicleTypes,
      longHaulAllowed: longHaulAllowed,
      nightDrivingAllowed: nightDrivingAllowed,
      hazardousCargoAllowed: hazardousCargoAllowed,
      oilfieldAllowed: oilfieldAllowed,
      routeRestrictions: routeRestrictions.trim(),
      specialSkillsNotes: specialSkillsNotes.trim(),
      pdoPassportStatus: pdoPassportStatus,
      defensiveDrivingStatus: defensiveDrivingStatus,
      h2sStatus: h2sStatus,
      ftwStatus: ftwStatus,
      complianceNotes: complianceNotes.trim(),
      medicalFitnessNote: medicalFitnessNote.trim(),
      safetyIncidentFlag: safetyIncidentFlag,
      incidentCount: incidentCount,
      disciplinaryNote: disciplinaryNote.trim(),
      temporaryRestrictionNote: temporaryRestrictionNote.trim(),
      preferredRegion: preferredRegion.trim(),
      preferredRouteType: preferredRouteType.trim(),
      preferredVehicleType: preferredVehicleType.trim(),
      preferredCargoType: preferredCargoType.trim(),
      specialAssignmentNotes: specialAssignmentNotes.trim(),
      certifications: certifications.trim().isEmpty
          ? existing.certifications
          : _splitCsv(certifications),
    );

    final nextDrivers = [...current.drivers];
    nextDrivers[idx] = updated;

    state = AsyncData(
      current.copyWith(
        drivers: nextDrivers,
        lastUpdated: DateTime.now(),
      ),
    );
    return 'Driver ${existing.driverId} updated.';
  }

  String markDriverUnavailable(String driverCode, {String reason = ''}) {
    return _mutateDriver(driverCode, (driver) {
      return driver.copyWith(
        status: 'Resting / Off Duty',
        assignmentAllowed: false,
        currentAssignmentStatus: 'Unavailable',
        blockReason: reason.trim(),
      );
    }, success: 'Driver marked unavailable.');
  }

  String suspendDriver(String driverCode, {required String reason}) {
    if (reason.trim().isEmpty) {
      return 'Suspension reason is required.';
    }
    return _mutateDriver(driverCode, (driver) {
      return driver.copyWith(
        status: 'Suspended',
        suspended: true,
        suspensionReason: reason.trim(),
        assignmentAllowed: false,
        dispatchAllowed: false,
        dispatchBlocked: true,
        blockReason: reason.trim(),
      );
    }, success: 'Driver suspended.');
  }

  String deactivateDriver(String driverCode, {String reason = ''}) {
    return _mutateDriver(driverCode, (driver) {
      final note = reason.trim().isEmpty ? 'Deactivated' : reason.trim();
      return driver.copyWith(
        active: false,
        status: 'Inactive',
        assignmentAllowed: false,
        dispatchAllowed: false,
        dispatchBlocked: true,
        blockReason: note,
      );
    }, success: 'Driver deactivated.');
  }

  String _mutateDriver(
    String driverCode,
    DriverData Function(DriverData driver) transform, {
    required String success,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }
    final idx = current.drivers.indexWhere((d) => d.driverId == driverCode);
    if (idx < 0) {
      return 'Driver not found.';
    }
    final next = [...current.drivers];
    next[idx] = transform(next[idx]);
    state =
        AsyncData(current.copyWith(drivers: next, lastUpdated: DateTime.now()));
    return success;
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
    return passed
        ? 'Pre-trip inspection passed.'
        : 'Pre-trip inspection failed.';
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
      timelineStep:
          approved ? max(current.timelineStep, 6) : current.timelineStep,
      lastUpdated: DateTime.now(),
    ));
  }

  String startTrip() {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Data not loaded.';
    }
    if (!current.canStartTrip) {
      if (current.vehicleDocStatus == 'Expired' ||
          current.driverDocStatus == 'Expired') {
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
        if (!item.assignmentAllowed ||
            item.dispatchBlocked ||
            item.status.toLowerCase() != 'active' ||
            item.availabilityStatus.toLowerCase() != 'available') {
          return 'Expired';
        }
        if (!item.complianceReady) {
          return 'Expired';
        }
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

  (bool, String) _fleetComplianceMasterPass({required String vehicleNo}) {
    final rules =
        ref.read(moduleDocumentViewModelProvider).valueOrNull?.items ??
            const [];
    final fleetRules = rules.where((item) {
      if (item.status != 'Active') {
        return false;
      }
      if (item.applicableTo.toLowerCase() != 'fleet') {
        return false;
      }
      if (!item.checkAtAssignment) {
        return false;
      }
      return item.blockingType == 'Soft Block' ||
          item.blockingType == 'Hard Block';
    }).toList();

    if (fleetRules.isEmpty) {
      return (true, 'OK');
    }

    final access = ref.read(accessControlProvider);
    TransportItem? transport;
    for (final item in access.transports) {
      if (item.vehicleNumber == vehicleNo) {
        transport = item;
        break;
      }
    }
    if (transport == null) {
      return (
        false,
        'Assignment blocked: selected fleet not found in fleet master.'
      );
    }

    for (final rule in fleetRules) {
      if (!rule.mandatory) {
        continue;
      }
      bool found = false;
      for (final doc in transport.documents) {
        if (doc.documentName.toLowerCase() == rule.documentName.toLowerCase()) {
          found = true;
          break;
        }
      }
      if (!found) {
        return (
          false,
          'Assignment blocked: compliance master rule missing (${rule.documentName}).',
        );
      }
    }

    return (true, 'OK');
  }

  String _driverDocStatus(String driverId) {
    final current = state.valueOrNull;
    if (current == null) {
      return 'Unknown';
    }
    for (final item in current.drivers) {
      if (item.driverId != driverId) {
        continue;
      }
      if (!item.active ||
          !item.dispatchAllowed ||
          item.dispatchBlocked ||
          item.onLeave ||
          item.suspended) {
        return 'Expired';
      }
      final expiry = DateTime.tryParse(item.expiryDate.trim());
      if (expiry == null || expiry.isBefore(DateTime.now())) {
        return 'Expired';
      }
      final days = expiry.difference(DateTime.now()).inDays;
      if (days <= 30) {
        return 'Expiring Soon';
      }
      if (!item.complianceReady) {
        return 'Expired';
      }
      return 'Valid';
    }
    return 'Valid';
  }

  (bool, String) _driverComplianceMasterPass({required DriverData driver}) {
    final rules =
        ref.read(moduleDocumentViewModelProvider).valueOrNull?.items ??
            const [];
    final driverRules = rules.where((item) {
      if (item.status != 'Active') {
        return false;
      }
      if (item.applicableTo.toLowerCase() != 'driver') {
        return false;
      }
      if (!item.checkAtAssignment) {
        return false;
      }
      return item.mandatory;
    }).toList();

    if (driverRules.isEmpty) {
      return (true, 'OK');
    }

    final availableProofs = <String>{
      for (final cert in driver.certifications) cert.toLowerCase(),
      if (driver.pdoPassportStatus.toLowerCase() == 'valid') 'pdo passport',
      if (driver.defensiveDrivingStatus.toLowerCase() == 'valid')
        'defensive driving',
      if (driver.h2sStatus.toLowerCase() == 'valid') 'h2s',
      if (driver.ftwStatus.toLowerCase() == 'valid') 'ftw',
      'license',
    };

    for (final rule in driverRules) {
      final key = rule.documentName.toLowerCase().trim();
      if (!availableProofs.contains(key)) {
        return (
          false,
          'Assignment blocked: driver missing mandatory compliance (${rule.documentName}).',
        );
      }
    }

    return (true, 'OK');
  }

  (bool, String) _driverVehicleSuitability({
    required String orderId,
    required TransportItem? vehicle,
    required DriverData driver,
  }) {
    if (vehicle == null) {
      return (true, 'OK');
    }

    if (vehicle.vehicleClass.toLowerCase() == 'heavy' &&
        !driver.heavyVehicleAllowed) {
      return (
        false,
        'Assignment blocked: driver not eligible for heavy vehicle operations.',
      );
    }

    if (driver.allowedVehicleTypes.isNotEmpty &&
        !driver.allowedVehicleTypes.contains(vehicle.vehicleType)) {
      return (
        false,
        'Assignment blocked: selected vehicle type is not in driver allowed vehicle list.',
      );
    }

    WorkOrderFlowItem? order;
    final current = state.valueOrNull;
    if (current != null) {
      for (final item in current.workOrders) {
        if (item.woId == orderId) {
          order = item;
          break;
        }
      }
    }

    final cargo = order?.cargo.toLowerCase() ?? '';
    final hazardous = cargo.contains('hazard') || cargo.contains('chemical');
    final oilfield = cargo.contains('oilfield') || cargo.contains('oil field');
    if (hazardous && !driver.hazardousCargoAllowed) {
      return (
        false,
        'Assignment blocked: driver is not qualified for hazardous cargo.',
      );
    }
    if (oilfield && !driver.oilfieldAllowed) {
      return (
        false,
        'Assignment blocked: driver is not qualified for oilfield operations.',
      );
    }

    return (true, 'OK');
  }

  List<String> _splitCsv(String input) {
    return input
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int _firstNumber(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  String? _validateEnquiryRequest(CustomerRequestData request) {
    if (request.requestSource.trim().isEmpty) {
      return 'Request source is required.';
    }
    if (request.customerName.trim().isEmpty) {
      return 'Customer name is required.';
    }
    if (request.requestType.trim().isEmpty) {
      return 'Request type is required.';
    }
    if (request.emailOrReference.trim().isEmpty) {
      return 'Email/Reference is required.';
    }
    if (request.contact.trim().isEmpty) {
      return 'Contact is required.';
    }
    if (request.cargoType.trim().isEmpty) {
      return 'Cargo type is required.';
    }
    if (request.pickup.trim().isEmpty) {
      return 'Pickup location is required.';
    }
    if (request.delivery.trim().isEmpty) {
      return 'Delivery location is required.';
    }
    return null;
  }

  bool _isDuplicateEnquiry(
    List<CustomerRequestData> existing,
    CustomerRequestData candidate, {
    String? ignoreEnquiryNumber,
  }) {
    final customer = _normalizeToken(candidate.customerName);
    final contact = _normalizeToken(candidate.contact);
    final pickup = _normalizeToken(candidate.pickup);
    final delivery = _normalizeToken(candidate.delivery);
    final cargoType = _normalizeToken(candidate.cargoType);
    final weight = _normalizeToken(candidate.weightVolume);
    final requestType = _normalizeToken(candidate.requestType);

    for (final item in existing) {
      if (ignoreEnquiryNumber != null &&
          item.enquiryNumber == ignoreEnquiryNumber) {
        continue;
      }
      if (item.status == 'Cancelled') {
        continue;
      }
      if (_normalizeToken(item.customerName) == customer &&
          _normalizeToken(item.contact) == contact &&
          _normalizeToken(item.pickup) == pickup &&
          _normalizeToken(item.delivery) == delivery &&
          _normalizeToken(item.cargoType) == cargoType &&
          _normalizeToken(item.weightVolume) == weight &&
          _normalizeToken(item.requestType) == requestType) {
        return true;
      }
    }
    return false;
  }

  List<CustomerRequestData> _normalizeCustomerRequests(
    List<CustomerRequestData> requests,
  ) {
    final normalized = <CustomerRequestData>[];
    var sequence = 1;

    for (final item in requests) {
      final now = DateTime.now();
      final enquiryNo = item.enquiryNumber.trim().isEmpty
          ? 'ENQ-${sequence.toString().padLeft(4, '0')}'
          : item.enquiryNumber.trim();
      sequence += 1;

      normalized.add(item.copyWith(
        enquiryNumber: enquiryNo,
        requestSource:
            item.requestSource.trim().isEmpty ? 'Phone' : item.requestSource,
        requestType: item.requestType.trim().isEmpty
            ? 'Transport Request'
            : item.requestType,
        emailOrReference: item.emailOrReference.trim(),
        requestDate: item.requestDate.trim().isEmpty
            ? _formatDate(item.createdAt)
            : item.requestDate,
        status: item.status.trim().isEmpty ? 'New Enquiry' : item.status,
        createdAt: item.createdAt,
        updatedAt:
            item.updatedAt.isBefore(item.createdAt) ? now : item.updatedAt,
      ));
    }

    return normalized;
  }

  String _nextEnquiryNumber(List<CustomerRequestData> requests) {
    var maxId = 0;
    final pattern = RegExp(r'ENQ-(\d+)', caseSensitive: false);
    for (final item in requests) {
      final match = pattern.firstMatch(item.enquiryNumber.trim());
      final value = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (value > maxId) {
        maxId = value;
      }
    }
    return 'ENQ-${(maxId + 1).toString().padLeft(4, '0')}';
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _normalizeToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _nextDuplicatedWorkOrderId(
    List<WorkOrderFlowItem> existing,
    String sourceId,
  ) {
    final source = sourceId.trim();
    var counter = 1;
    while (true) {
      final candidate = '$source-COPY-$counter';
      final taken = existing.any((item) => item.woId == candidate);
      if (!taken) {
        return candidate;
      }
      counter += 1;
    }
  }

  Future<List<WorkOrderFlowItem>> _loadCachedWorkOrders(
    List<WorkOrderFlowItem> fallback,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_workOrdersCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map((entry) => _workOrderFromMap(Map<String, dynamic>.from(entry)))
            .toList();
      }
      await _persistWorkOrders(fallback);
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _persistWorkOrders(List<WorkOrderFlowItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = items.map(_workOrderToMap).toList();
    await prefs.setString(_workOrdersCacheKey, jsonEncode(payload));
  }

  WorkOrderFlowItem _workOrderFromMap(Map<String, dynamic> map) {
    return WorkOrderFlowItem(
      woId: map['woId'] as String? ?? '',
      customer: map['customer'] as String? ?? '',
      route: map['route'] as String? ?? '',
      cargo: map['cargo'] as String? ?? '',
      status: map['status'] as String? ?? 'Open',
      linkedQuotationRef: map['linkedQuotationRef'] as String? ?? '',
      linkedEnquiryNumber: map['linkedEnquiryNumber'] as String? ?? '',
      routeMasterId: map['routeMasterId'] as String? ?? '',
      routeCode: map['routeCode'] as String? ?? '',
      routeName: map['routeName'] as String? ?? '',
      routeRiskLevel: map['routeRiskLevel'] as String? ?? 'Low',
      routeOperationalStatus:
          map['routeOperationalStatus'] as String? ?? 'Active',
      routeRestricted: map['routeRestricted'] as bool? ?? false,
      routeRestrictionReason: map['routeRestrictionReason'] as String? ?? '',
      customerPoReference: map['customerPoReference'] as String? ?? '',
      jobFileReference: map['jobFileReference'] as String? ?? '',
      serviceStartDate: map['serviceStartDate'] as String? ?? '',
      serviceEndDate: map['serviceEndDate'] as String? ?? '',
      internalNotes: map['internalNotes'] as String? ?? '',
    );
  }

  Map<String, dynamic> _workOrderToMap(WorkOrderFlowItem item) {
    return {
      'woId': item.woId,
      'customer': item.customer,
      'route': item.route,
      'cargo': item.cargo,
      'status': item.status,
      'linkedQuotationRef': item.linkedQuotationRef,
      'linkedEnquiryNumber': item.linkedEnquiryNumber,
      'routeMasterId': item.routeMasterId,
      'routeCode': item.routeCode,
      'routeName': item.routeName,
      'routeRiskLevel': item.routeRiskLevel,
      'routeOperationalStatus': item.routeOperationalStatus,
      'routeRestricted': item.routeRestricted,
      'routeRestrictionReason': item.routeRestrictionReason,
      'customerPoReference': item.customerPoReference,
      'jobFileReference': item.jobFileReference,
      'serviceStartDate': item.serviceStartDate,
      'serviceEndDate': item.serviceEndDate,
      'internalNotes': item.internalNotes,
    };
  }
}
