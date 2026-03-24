import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/tracking_point_model.dart';

abstract class TrackingRemoteDataSource {
  Future<List<TrackingPointModel>> getTrackingPoints();
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  const TrackingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TrackingPointModel>> getTrackingPoints() async {
    final response = await _dio.get<dynamic>(AppConstants.trackingEndpoint);
    final list = ApiPayload.asList(response.data);

    return list
        .map(
          (entry) => TrackingPointModel.fromMap(entry as Map<String, dynamic>),
        )
        .toList();
  }
}
