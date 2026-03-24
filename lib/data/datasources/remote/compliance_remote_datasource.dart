import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_payload.dart';
import '../../models/compliance_record_model.dart';

abstract class ComplianceRemoteDataSource {
  Future<List<ComplianceRecordModel>> getComplianceRecords();
}

class ComplianceRemoteDataSourceImpl implements ComplianceRemoteDataSource {
  const ComplianceRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ComplianceRecordModel>> getComplianceRecords() async {
    final response = await _dio.get<dynamic>(AppConstants.complianceEndpoint);
    final list = ApiPayload.asList(response.data);
    return list
        .map(
          (entry) => ComplianceRecordModel.fromMap(entry as Map<String, dynamic>),
        )
        .toList();
  }
}
