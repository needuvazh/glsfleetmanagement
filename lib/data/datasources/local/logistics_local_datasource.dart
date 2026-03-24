import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/logistics_flow_models.dart';

abstract class LogisticsLocalDataSource {
  Future<List<CustomerRequestModel>> getCustomerRequests();
  Future<List<QuotationModel>> getQuotations();
  Future<List<WorkOrderFlowModel>> getFlowWorkOrders();
  Future<List<FleetVehicleModel>> getVehicles();
  Future<List<DriverModel>> getDrivers();
  Future<List<JourneyMasterModel>> getJourneyMaster();
  Future<List<IvmsModel>> getIvmsData();
  Future<List<DfmsModel>> getDfmsData();
}

class LogisticsLocalDataSourceImpl implements LogisticsLocalDataSource {
  const LogisticsLocalDataSourceImpl({required AssetBundle assetBundle})
      : _assetBundle = assetBundle;

  final AssetBundle _assetBundle;

  @override
  Future<List<CustomerRequestModel>> getCustomerRequests() async {
    final list = await _readList(AppConstants.customerRequestsMockPath);
    return list.map(CustomerRequestModel.fromMap).toList();
  }

  @override
  Future<List<QuotationModel>> getQuotations() async {
    final list = await _readList(AppConstants.quotationsMockPath);
    return list.map(QuotationModel.fromMap).toList();
  }

  @override
  Future<List<WorkOrderFlowModel>> getFlowWorkOrders() async {
    final list = await _readList(AppConstants.flowWorkOrdersMockPath);
    return list.map(WorkOrderFlowModel.fromMap).toList();
  }

  @override
  Future<List<FleetVehicleModel>> getVehicles() async {
    final list = await _readList(AppConstants.vehiclesMockPath);
    return list.map(FleetVehicleModel.fromMap).toList();
  }

  @override
  Future<List<DriverModel>> getDrivers() async {
    final list = await _readList(AppConstants.driversMockPath);
    return list.map(DriverModel.fromMap).toList();
  }

  @override
  Future<List<JourneyMasterModel>> getJourneyMaster() async {
    final list = await _readList(AppConstants.journeyMasterMockPath);
    return list.map(JourneyMasterModel.fromMap).toList();
  }

  @override
  Future<List<IvmsModel>> getIvmsData() async {
    final list = await _readList(AppConstants.ivmsMockPath);
    return list.map(IvmsModel.fromMap).toList();
  }

  @override
  Future<List<DfmsModel>> getDfmsData() async {
    final list = await _readList(AppConstants.dfmsMockPath);
    return list.map(DfmsModel.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> _readList(String path) async {
    final content = await _assetBundle.loadString(path);
    final dynamic data = jsonDecode(content);
    if (data is List<dynamic>) {
      return data.map((entry) => entry as Map<String, dynamic>).toList();
    }
    throw FormatException('Expected list payload for $path');
  }
}
