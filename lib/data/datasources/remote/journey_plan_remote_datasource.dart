import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/journey_plan_model.dart';

abstract class JourneyPlanRemoteDataSource {
  Future<List<JourneyPlanModel>> getPlans();
}

class JourneyPlanRemoteDataSourceImpl implements JourneyPlanRemoteDataSource {
  const JourneyPlanRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<JourneyPlanModel>> getPlans() async {
    final response = await _dio.get<dynamic>(AppConstants.journeyPlansEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => JourneyPlanModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
