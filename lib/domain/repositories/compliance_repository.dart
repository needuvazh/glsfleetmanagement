import '../entities/compliance_record.dart';

abstract class ComplianceRepository {
  Future<List<ComplianceRecord>> getComplianceRecords();
}
