import '../../domain/entities/compliance_record.dart';
import '../../domain/repositories/compliance_repository.dart';
import '../datasources/local/compliance_local_datasource.dart';
import '../datasources/remote/compliance_remote_datasource.dart';

class ComplianceRepositoryImpl implements ComplianceRepository {
  const ComplianceRepositoryImpl({
    required ComplianceLocalDataSource localDataSource,
    ComplianceRemoteDataSource? remoteDataSource,
    required bool useLiveApi,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useLiveApi = useLiveApi;

  final ComplianceLocalDataSource _localDataSource;
  final ComplianceRemoteDataSource? _remoteDataSource;
  final bool _useLiveApi;

  @override
  Future<List<ComplianceRecord>> getComplianceRecords() async {
    if (_useLiveApi) {
      final remote = _remoteDataSource;
      if (remote == null) {
        throw Exception('Compliance remote datasource is not configured.');
      }
      return remote.getComplianceRecords();
    }

    return _localDataSource.getComplianceRecords();
  }
}
