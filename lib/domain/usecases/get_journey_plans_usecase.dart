import '../entities/journey_plan.dart';
import '../repositories/journey_plan_repository.dart';

class GetJourneyPlansUseCase {
  const GetJourneyPlansUseCase(this._repository);

  final JourneyPlanRepository _repository;

  Future<List<JourneyPlan>> call() {
    return _repository.getPlans();
  }
}
