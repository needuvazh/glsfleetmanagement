import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardDataModel> getDashboard() async {
    final response = await _dio.get<dynamic>(AppConstants.dashboardEndpoint);
    final map = ApiPayload.asMap(response.data);
    return DashboardDataModel.fromMap(map);
  }
}
