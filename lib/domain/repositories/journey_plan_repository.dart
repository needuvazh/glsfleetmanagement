import '../entities/journey_plan.dart';

abstract class JourneyPlanRepository {
  Future<List<JourneyPlan>> getPlans();
}
