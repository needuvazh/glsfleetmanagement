import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/logistics_flow_models.dart';

abstract class LogisticsRemoteDataSource {
  Future<List<CustomerRequestModel>> getCustomerRequests();
  Future<List<QuotationModel>> getQuotations();
  Future<List<WorkOrderFlowModel>> getFlowWorkOrders();
  Future<List<FleetVehicleModel>> getVehicles();
  Future<List<DriverModel>> getDrivers();
  Future<List<JourneyMasterModel>> getJourneyMaster();
  Future<List<IvmsModel>> getIvmsData();
  Future<List<DfmsModel>> getDfmsData();
}

class LogisticsRemoteDataSourceImpl implements LogisticsRemoteDataSource {
  const LogisticsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CustomerRequestModel>> getCustomerRequests() async {
    final response = await _dio.get<dynamic>(AppConstants.customerRequestsEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => CustomerRequestModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuotationModel>> getQuotations() async {
    final response = await _dio.get<dynamic>(AppConstants.quotationsEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => QuotationModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkOrderFlowModel>> getFlowWorkOrders() async {
    final response = await _dio.get<dynamic>(AppConstants.flowWorkOrdersEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => WorkOrderFlowModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FleetVehicleModel>> getVehicles() async {
    final response = await _dio.get<dynamic>(AppConstants.vehiclesEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => FleetVehicleModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DriverModel>> getDrivers() async {
    final response = await _dio.get<dynamic>(AppConstants.driversEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => DriverModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<JourneyMasterModel>> getJourneyMaster() async {
    final response = await _dio.get<dynamic>(AppConstants.journeyMasterEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => JourneyMasterModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<IvmsModel>> getIvmsData() async {
    final response = await _dio.get<dynamic>(AppConstants.ivmsEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => IvmsModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DfmsModel>> getDfmsData() async {
    final response = await _dio.get<dynamic>(AppConstants.dfmsEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map((entry) => DfmsModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}
