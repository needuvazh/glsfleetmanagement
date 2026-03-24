import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/dashboard_local_datasource.dart';
import '../../data/datasources/remote/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

enum DashboardRange { sevenDays, thirtyDays }

extension DashboardRangeX on DashboardRange {
  String get label {
    switch (this) {
      case DashboardRange.sevenDays:
        return '7D';
      case DashboardRange.thirtyDays:
        return '30D';
    }
  }
}

class DashboardUiState {
  const DashboardUiState({
    required this.data,
    required this.range,
    required this.lastUpdated,
  });

  final DashboardData data;
  final DashboardRange range;
  final DateTime lastUpdated;

  List<MileagePoint> get mileageByRange {
    if (range == DashboardRange.sevenDays) {
      return data.weeklyMileageKm;
    }

    final weeklyTotal =
        data.weeklyMileageKm.fold<double>(0, (sum, item) => sum + item.value);

    return List.generate(4, (index) {
      final factor = 0.92 + (index * 0.05);
      return MileagePoint(
        label: 'W${index + 1}',
        value: weeklyTotal * factor,
      );
    });
  }

  DashboardUiState copyWith({
    DashboardData? data,
    DashboardRange? range,
    DateTime? lastUpdated,
  }) {
    return DashboardUiState(
      data: data ?? this.data,
      range: range ?? this.range,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _dashboardLocalDataSourceProvider = Provider<DashboardLocalDataSource>(
  (ref) => DashboardLocalDataSourceImpl(assetBundle: rootBundle),
);

final _dashboardDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>(
  (ref) => DashboardRemoteDataSourceImpl(ref.read(_dashboardDioProvider)),
);

final _dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    return DashboardRepositoryImpl(
      localDataSource: ref.watch(_dashboardLocalDataSourceProvider),
      remoteDataSource: ref.watch(_dashboardRemoteDataSourceProvider),
      useLiveApi: useLiveApi,
    );
  },
);

final _getDashboardUseCaseProvider = Provider<GetDashboardUseCase>(
  (ref) => GetDashboardUseCase(ref.watch(_dashboardRepositoryProvider)),
);

final dashboardViewModelProvider =
    AsyncNotifierProvider<DashboardViewModel, DashboardUiState>(
  DashboardViewModel.new,
);

class DashboardViewModel extends AsyncNotifier<DashboardUiState> {
  Timer? _timer;
  final Random _random = Random();

  @override
  Future<DashboardUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final data = await ref.watch(_getDashboardUseCaseProvider).call();
    _startMockRealtimeUpdates();

    return DashboardUiState(
      data: data,
      range: DashboardRange.sevenDays,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final data = await ref.read(_getDashboardUseCaseProvider).call();
      return DashboardUiState(
        data: data,
        range: previous?.range ?? DashboardRange.sevenDays,
        lastUpdated: DateTime.now(),
      );
    });
  }

  void setRange(DashboardRange range) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(range: range));
  }

  void _startMockRealtimeUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      final current = state.valueOrNull;
      if (current == null) {
        return;
      }

      final kpis = current.data.kpis;
      final totalVehicles = kpis.totalVehicles;

      final activeVehicles =
          (kpis.activeVehicles + _random.nextInt(5) - 2).clamp(0, totalVehicles);

      final inMaintenance = (kpis.inMaintenance + _random.nextInt(3) - 1)
          .clamp(0, totalVehicles - activeVehicles);

      final idleVehicles = totalVehicles - activeVehicles - inMaintenance;

      final criticalAlerts =
          (kpis.criticalAlerts + _random.nextInt(3) - 1).clamp(0, 30);

      final avgFuel = (kpis.avgFuelConsumptionLPer100Km +
              ((_random.nextDouble() - 0.5) * 0.4))
          .clamp(10, 30)
          .toDouble();

      final updatedMileage = current.data.weeklyMileageKm
          .map(
            (item) => item.copyWith(
              value: (item.value + (_random.nextInt(901) - 450))
                  .clamp(5000, 25000)
                  .toDouble(),
            ),
          )
          .toList();

      final updatedData = current.data.copyWith(
        kpis: kpis.copyWith(
          activeVehicles: activeVehicles,
          inMaintenance: inMaintenance,
          criticalAlerts: criticalAlerts,
          avgFuelConsumptionLPer100Km: avgFuel,
        ),
        weeklyMileageKm: updatedMileage,
        vehicleStatusShare: [
          StatusShare(status: 'Active', value: activeVehicles),
          StatusShare(status: 'Maintenance', value: inMaintenance),
          StatusShare(status: 'Idle', value: idleVehicles),
        ],
      );

      state = AsyncData(
        current.copyWith(data: updatedData, lastUpdated: DateTime.now()),
      );
    });
  }
}
