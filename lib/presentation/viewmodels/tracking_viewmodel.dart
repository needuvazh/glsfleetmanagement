import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/tracking_local_datasource.dart';
import '../../data/datasources/remote/tracking_remote_datasource.dart';
import '../../data/repositories/tracking_repository_impl.dart';
import '../../domain/entities/tracking_point.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../../domain/usecases/get_tracking_points_usecase.dart';

enum TrackingFilter { all, active, maintenance, idle }

extension TrackingFilterX on TrackingFilter {
  String get label {
    switch (this) {
      case TrackingFilter.all:
        return 'All';
      case TrackingFilter.active:
        return 'Active';
      case TrackingFilter.maintenance:
        return 'Maintenance';
      case TrackingFilter.idle:
        return 'Idle';
    }
  }
}

class TrackingUiState {
  const TrackingUiState({
    required this.items,
    this.query = '',
    this.filter = TrackingFilter.all,
    this.selectedId,
    required this.lastUpdated,
  });

  final List<TrackingPoint> items;
  final String query;
  final TrackingFilter filter;
  final String? selectedId;
  final DateTime lastUpdated;

  List<TrackingPoint> get filteredItems {
    final normalized = query.trim().toLowerCase();

    return items.where((item) {
      final filterOk = switch (filter) {
        TrackingFilter.all => true,
        TrackingFilter.active => item.status == TrackingStatus.active,
        TrackingFilter.maintenance => item.status == TrackingStatus.maintenance,
        TrackingFilter.idle => item.status == TrackingStatus.idle,
      };
      if (!filterOk) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }

      final searchable = [
        item.id,
        item.vehicleNumber,
        item.driver,
        item.status.label,
      ].join(' ').toLowerCase();
      return searchable.contains(normalized);
    }).toList();
  }

  TrackingPoint? get selected {
    if (selectedId == null) {
      return filteredItems.isEmpty ? null : filteredItems.first;
    }
    for (final item in filteredItems) {
      if (item.id == selectedId) {
        return item;
      }
    }
    return filteredItems.isEmpty ? null : filteredItems.first;
  }

  TrackingUiState copyWith({
    List<TrackingPoint>? items,
    String? query,
    TrackingFilter? filter,
    String? selectedId,
    bool clearSelectedId = false,
    DateTime? lastUpdated,
  }) {
    return TrackingUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _trackingLocalDataSourceProvider = Provider<TrackingLocalDataSource>(
  (ref) => TrackingLocalDataSourceImpl(assetBundle: rootBundle),
);

final _trackingDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _trackingRemoteDataSourceProvider = Provider<TrackingRemoteDataSource>(
  (ref) => TrackingRemoteDataSourceImpl(ref.read(_trackingDioProvider)),
);

final _trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    return TrackingRepositoryImpl(
      localDataSource: ref.watch(_trackingLocalDataSourceProvider),
      remoteDataSource: ref.watch(_trackingRemoteDataSourceProvider),
      useLiveApi: useLiveApi,
    );
  },
);

final _getTrackingUseCaseProvider = Provider<GetTrackingPointsUseCase>(
  (ref) => GetTrackingPointsUseCase(ref.watch(_trackingRepositoryProvider)),
);

final trackingViewModelProvider =
    AsyncNotifierProvider<TrackingViewModel, TrackingUiState>(
  TrackingViewModel.new,
);

class TrackingViewModel extends AsyncNotifier<TrackingUiState> {
  Timer? _timer;
  final Random _random = Random();

  @override
  Future<TrackingUiState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final points = await ref.watch(_getTrackingUseCaseProvider).call();
    _startMockRealtimeUpdates();

    return TrackingUiState(
      items: points,
      selectedId: points.isEmpty ? null : points.first.id,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final points = await ref.read(_getTrackingUseCaseProvider).call();
      return TrackingUiState(
        items: points,
        query: previous?.query ?? '',
        filter: previous?.filter ?? TrackingFilter.all,
        selectedId: points.isEmpty ? null : points.first.id,
        lastUpdated: DateTime.now(),
      );
    });
  }

  void setQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        query: value,
        clearSelectedId: value.trim().isNotEmpty,
      ),
    );
  }

  void setFilter(TrackingFilter value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(filter: value, clearSelectedId: true));
  }

  void setSelected(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(selectedId: id));
  }

  void _startMockRealtimeUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      final current = state.valueOrNull;
      if (current == null || current.items.isEmpty) {
        return;
      }

      final updated = current.items.map((item) {
        final speed = item.status == TrackingStatus.active
            ? (item.speedKph + (_random.nextDouble() * 8 - 4)).clamp(15, 95)
            : (item.speedKph + (_random.nextDouble() * 4 - 2)).clamp(0, 30);

        final heading = (item.heading + (_random.nextDouble() * 18 - 9)) % 360;

        final moveFactor = speed / 10000;
        final latDelta = (_random.nextDouble() - 0.5) * moveFactor;
        final lngDelta = (_random.nextDouble() - 0.5) * moveFactor;

        final status = _random.nextInt(60) == 0
            ? TrackingStatus.values[_random.nextInt(TrackingStatus.values.length)]
            : item.status;

        return item.copyWith(
          status: status,
          speedKph: speed.toDouble(),
          heading: heading.toDouble(),
          latitude: (item.latitude + latDelta).clamp(-89.5, 89.5).toDouble(),
          longitude:
              (item.longitude + lngDelta).clamp(-179.5, 179.5).toDouble(),
          lastUpdated: DateTime.now(),
        );
      }).toList();

      state = AsyncData(
        current.copyWith(items: updated, lastUpdated: DateTime.now()),
      );
    });
  }
}
