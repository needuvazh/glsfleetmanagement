import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/work_order_model.dart';

abstract class WorkOrderRemoteDataSource {
  Future<List<WorkOrderModel>> getWorkOrders();
}

class WorkOrderRemoteDataSourceImpl implements WorkOrderRemoteDataSource {
  const WorkOrderRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<WorkOrderModel>> getWorkOrders() async {
    final response = await _dio.get<dynamic>(AppConstants.workOrdersEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => WorkOrderModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
