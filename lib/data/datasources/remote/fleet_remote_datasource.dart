import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/fleet_model.dart';

abstract class FleetRemoteDataSource {
  Future<List<FleetModel>> getFleets();
}

class FleetRemoteDataSourceImpl implements FleetRemoteDataSource {
  const FleetRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FleetModel>> getFleets() async {
    final response = await _dio.get<dynamic>(AppConstants.fleetEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => FleetModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
