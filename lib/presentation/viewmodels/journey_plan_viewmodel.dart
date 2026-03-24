import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/data_source_mode_provider.dart';
import '../../data/datasources/local/journey_plan_local_datasource.dart';
import '../../data/datasources/remote/journey_plan_remote_datasource.dart';
import '../../data/repositories/journey_plan_repository_impl.dart';
import '../../domain/entities/journey_plan.dart';
import '../../domain/repositories/journey_plan_repository.dart';
import '../../domain/usecases/get_journey_plans_usecase.dart';

class JourneyPlanUiState {
  const JourneyPlanUiState({
    required this.items,
    this.query = '',
    required this.lastUpdated,
  });

  final List<JourneyPlan> items;
  final String query;
  final DateTime lastUpdated;

  List<JourneyPlan> get filteredItems {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return items;
    }

    return items.where((plan) {
      final searchable = [
        plan.planName,
        plan.origin,
        plan.destination,
        plan.stops.join(' '),
      ].join(' ').toLowerCase();
      return searchable.contains(normalized);
    }).toList();
  }

  JourneyPlanUiState copyWith({
    List<JourneyPlan>? items,
    String? query,
    DateTime? lastUpdated,
  }) {
    return JourneyPlanUiState(
      items: items ?? this.items,
      query: query ?? this.query,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _journeyPlanLocalDataSourceProvider = Provider<JourneyPlanLocalDataSource>(
  (ref) => JourneyPlanLocalDataSourceImpl(assetBundle: rootBundle),
);

final _journeyPlanDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

final _journeyPlanRemoteDataSourceProvider =
    Provider<JourneyPlanRemoteDataSource>(
  (ref) => JourneyPlanRemoteDataSourceImpl(ref.read(_journeyPlanDioProvider)),
);

final _journeyPlanRepositoryProvider = Provider<JourneyPlanRepository>((ref) {
  final useLiveApi = ref.watch(useLiveApiProvider);

  return JourneyPlanRepositoryImpl(
    localDataSource: ref.watch(_journeyPlanLocalDataSourceProvider),
    apiDataSource: ref.watch(_journeyPlanRemoteDataSourceProvider),
    useMock: !useLiveApi,
  );
});

final _getJourneyPlansUseCaseProvider = Provider<GetJourneyPlansUseCase>(
  (ref) => GetJourneyPlansUseCase(ref.watch(_journeyPlanRepositoryProvider)),
);

final journeyPlanViewModelProvider =
    AsyncNotifierProvider<JourneyPlanViewModel, JourneyPlanUiState>(
  JourneyPlanViewModel.new,
);

class JourneyPlanViewModel extends AsyncNotifier<JourneyPlanUiState> {
  @override
  Future<JourneyPlanUiState> build() async {
    final plans = await ref.watch(_getJourneyPlansUseCaseProvider).call();
    return JourneyPlanUiState(items: plans, lastUpdated: DateTime.now());
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final plans = await ref.read(_getJourneyPlansUseCaseProvider).call();
      return JourneyPlanUiState(
        items: plans,
        query: previous?.query ?? '',
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
}
