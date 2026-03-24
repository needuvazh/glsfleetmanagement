import '../../domain/entities/journey_plan.dart';
import '../../domain/repositories/journey_plan_repository.dart';
import '../datasources/local/journey_plan_local_datasource.dart';
import '../datasources/remote/journey_plan_remote_datasource.dart';

class JourneyPlanRepositoryImpl implements JourneyPlanRepository {
  const JourneyPlanRepositoryImpl({
    required JourneyPlanLocalDataSource localDataSource,
    required JourneyPlanRemoteDataSource apiDataSource,
    this.useMock = true,
  })  : _localDataSource = localDataSource,
        _apiDataSource = apiDataSource;

  final JourneyPlanLocalDataSource _localDataSource;
  final JourneyPlanRemoteDataSource _apiDataSource;
  final bool useMock;

  @override
  Future<List<JourneyPlan>> getPlans() async {
    if (useMock) {
      return _localDataSource.getPlans();
    }
    return _apiDataSource.getPlans();
  }
}
