import '../entities/alert_item.dart';

abstract class AlertsRepository {
  Future<List<AlertItem>> getAlerts();
}
