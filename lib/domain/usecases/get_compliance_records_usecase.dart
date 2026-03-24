import '../entities/compliance_record.dart';
import '../repositories/compliance_repository.dart';

class GetComplianceRecordsUseCase {
  const GetComplianceRecordsUseCase(this._repository);

  final ComplianceRepository _repository;

  Future<List<ComplianceRecord>> call() {
    return _repository.getComplianceRecords();
  }
}
