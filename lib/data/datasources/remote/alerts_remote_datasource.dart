import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/alert_item_model.dart';

abstract class AlertsRemoteDataSource {
  Future<List<AlertItemModel>> getAlerts();
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  const AlertsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AlertItemModel>> getAlerts() async {
    final response = await _dio.get<dynamic>(AppConstants.alertsEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => AlertItemModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
