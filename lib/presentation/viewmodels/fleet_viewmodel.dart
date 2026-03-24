import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/fleet_local_datasource.dart';
import '../../data/datasources/remote/fleet_remote_datasource.dart';
import '../../data/repositories/fleet_repository_impl.dart';
import '../../domain/entities/fleet.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../../domain/usecases/get_fleets_usecase.dart';

enum FleetFilter { all, active, maintenance, idle }

extension FleetFilterX on FleetFilter {
  String get label {
    switch (this) {
      case FleetFilter.all:
        return 'All';
      case FleetFilter.active:
        return 'Active';
      case FleetFilter.maintenance:
        return 'Maintenance';
      case FleetFilter.idle:
        return 'Idle';
    }
  }
}

class FleetUiState {
  const FleetUiState({
    required this.items,
    this.query = '',
    this.filter = FleetFilter.all,
    required this.lastUpdated,
  });

  final List<Fleet> items;
  final String query;
  final FleetFilter filter;
  final DateTime lastUpdated;

  List<Fleet> get filteredItems {
    final normalized = query.trim().toLowerCase();

    return items.where((fleet) {
      final matchesFilter = switch (filter) {
        FleetFilter.all => true,
        FleetFilter.active => fleet.status == FleetStatus.active,
        FleetFilter.maintenance => fleet.status == FleetStatus.maintenance,
        FleetFilter.idle => fleet.status == FleetStatus.idle,
      };

      if (!matchesFilter) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }

      final searchable = [
        fleet.vehicleNumber,
        fleet.type,
        fleet.driver,
        fleet.id,
        fleet.status.label,
      ].join(' ').toLowerCase();

      return searchable.contains(normalized);
    }).toList();
  }

  FleetUiState copyWith({
    List<Fleet>? items,
    String? query,
    FleetFilter? filter,
    DateTime? lastUpdated,
  }) {
    return FleetUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _fleetLocalDataSourceProvider = Provider<FleetLocalDataSource>(
  (ref) => FleetLocalDataSourceImpl(assetBundle: rootBundle),
);

final _fleetDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _fleetRemoteDataSourceProvider = Provider<FleetRemoteDataSource>(
  (ref) => FleetRemoteDataSourceImpl(ref.read(_fleetDioProvider)),
);

final _fleetRepositoryProvider = Provider<FleetRepository>(
  (ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    return FleetRepositoryImpl(
      localDataSource: ref.watch(_fleetLocalDataSourceProvider),
      remoteDataSource: ref.watch(_fleetRemoteDataSourceProvider),
      useLiveApi: useLiveApi,
    );
  },
);

final _getFleetsUseCaseProvider = Provider<GetFleetsUseCase>(
  (ref) => GetFleetsUseCase(ref.watch(_fleetRepositoryProvider)),
);

final fleetViewModelProvider =
    AsyncNotifierProvider<FleetViewModel, FleetUiState>(FleetViewModel.new);

class FleetViewModel extends AsyncNotifier<FleetUiState> {
  Timer? _timer;
  final _random = Random();

  @override
  Future<FleetUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final fleets = await ref.watch(_getFleetsUseCaseProvider).call();
    _startMockRealtimeUpdates();

    return FleetUiState(items: fleets, lastUpdated: DateTime.now());
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final fleets = await ref.read(_getFleetsUseCaseProvider).call();
      return FleetUiState(
        items: fleets,
        query: previous?.query ?? '',
        filter: previous?.filter ?? FleetFilter.all,
        lastUpdated: DateTime.now(),
      );
    });
  }

  void setQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(query: value));
  }

  void setFilter(FleetFilter filter) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(filter: filter));
  }

  void _startMockRealtimeUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      final current = state.valueOrNull;
      if (current == null || current.items.isEmpty) {
        return;
      }

      final updated = current.items.map((fleet) {
        final randomFuelDelta = _random.nextInt(3);
        final nextFuel = (fleet.fuelLevel - randomFuelDelta).clamp(5, 100);

        if (_random.nextInt(10) < 2) {
          final statuses = FleetStatus.values;
          final nextStatus = statuses[_random.nextInt(statuses.length)];
          return fleet.copyWith(
            fuelLevel: nextFuel,
            status: nextStatus,
          );
        }

        return fleet.copyWith(fuelLevel: nextFuel);
      }).toList();

      state = AsyncData(
        current.copyWith(items: updated, lastUpdated: DateTime.now()),
      );
    });
  }
}
