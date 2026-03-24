import '../entities/alert_item.dart';
import '../repositories/alerts_repository.dart';

class GetAlertsUseCase {
  const GetAlertsUseCase(this._repository);

  final AlertsRepository _repository;

  Future<List<AlertItem>> call() {
    return _repository.getAlerts();
  }
}
